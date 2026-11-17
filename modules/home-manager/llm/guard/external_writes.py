import json
import os
import re
import sys

GIT_OPTIONS_WITH_ARGUMENT = {
    "-C",
    "-c",
    "--git-dir",
    "--work-tree",
    "--namespace",
    "--super-prefix",
    "--config-env",
    "--attr-source",
}
GH_OPTIONS_WITH_ARGUMENT = {"-R", "--repo", "-H", "--hostname"}
RUNNERS = {
    "bash",
    "sh",
    "zsh",
    "dash",
    "fish",
    "env",
    "xargs",
    "sudo",
    "doas",
    "timeout",
    "nohup",
    "nice",
    "time",
    "watch",
    "setsid",
    "flock",
    "stdbuf",
    "script",
    "ssh",
    "eval",
    "exec",
    "command",
    "builtin",
    "python",
    "python3",
    "node",
    "bun",
    "deno",
    "perl",
    "ruby",
}
HTTP_CLIENTS = {"curl", "wget", "http", "https", "xh"}
UNSAFE_CHARACTERS = set("{}*?[]\\~^#$`&<>()")
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")


def load_patterns(path):
    with open(path, encoding="utf-8") as handle:
        data = json.load(handle)
    gh_groups = "|".join(
        f"{re.escape(group)}\\s+(?:{'|'.join(re.escape(verb) for verb in verbs)})"
        for group, verbs in data["gh_writes"].items()
    )
    compiled = [
        ("gh write", re.compile(rf"\bgh\s+(?:(?:-R|--repo)[ =]\S+\s+)?(?:{gh_groups})\b"))
    ]
    compiled += [(item["name"], re.compile(item["re"])) for item in data["regex"]]
    return data["gh_writes"], compiled


def scan(text, patterns):
    names = []
    for name, expression in patterns:
        if expression.search(text) and name not in names:
            names.append(name)
    return names


def plain_commands(script):
    """Split a script the way Codex's execpolicy does, or return None.

    Stricter than Codex: anything it might not treat as plain is rejected, so a
    command accepted here is always matched by prefix rules.
    """
    commands = []
    current = []
    word = None
    position = 0
    length = len(script)

    def end_word():
        nonlocal word
        if word is not None:
            current.append(word)
            word = None

    def end_command():
        nonlocal current
        end_word()
        if not current:
            return False
        commands.append(current)
        current = []
        return True

    while position < length:
        char = script[position]
        if char in " \t":
            end_word()
        elif char == "\n":
            end_word()
            if current:
                end_command()
        elif char in ";|":
            if not end_command():
                return None
            if script.startswith("||", position):
                position += 1
        elif script.startswith("&&", position):
            if not end_command():
                return None
            position += 1
        elif char == "'":
            closing = script.find("'", position + 1)
            if closing < 0:
                return None
            word = (word or "") + script[position + 1 : closing]
            position = closing
        elif char == '"':
            closing = script.find('"', position + 1)
            if closing < 0:
                return None
            content = script[position + 1 : closing]
            if any(unsafe in content for unsafe in "$`\\"):
                return None
            word = (word or "") + content
            position = closing
        elif char in UNSAFE_CHARACTERS:
            return None
        else:
            word = (word or "") + char
        position += 1
    if word is not None or current:
        if not end_command():
            return None
    elif commands and script.rstrip()[-1:] in ";|&":
        return None
    for command in commands:
        if ASSIGNMENT.match(command[0]) or command[0].startswith("="):
            return None
    return commands


def program(token):
    return os.path.basename(token)


def git_subcommand(argv, start):
    index = start + 1
    while index < len(argv):
        token = argv[index]
        if token in GIT_OPTIONS_WITH_ARGUMENT:
            index += 2
        elif token.startswith("-"):
            index += 1
        else:
            return token
    return None


def gh_group_and_verb(argv, start):
    tokens = []
    index = start + 1
    while index < len(argv) and len(tokens) < 2:
        token = argv[index]
        if token in GH_OPTIONS_WITH_ARGUMENT:
            index += 2
        elif token.startswith("-"):
            index += 1
        else:
            tokens.append(token)
            index += 1
    return tuple(tokens) if len(tokens) == 2 else None


def classify(argv, gh_writes, patterns):
    """Return (prompted_by_rules, blocked) write operations found in one command."""
    prompted = []
    blocked = []
    first = program(argv[0])
    canonical = argv[0] == first
    if first in HTTP_CLIENTS:
        blocked += scan(" ".join(argv), patterns)
    elif first in RUNNERS:
        blocked += scan(" ".join(argv[1:]), patterns)
    elif first == "git" and git_subcommand(argv, 0) == "push":
        (prompted if canonical and argv[1] == "push" else blocked).append("git push")
    elif first == "gh":
        pair = gh_group_and_verb(argv, 0)
        if pair and pair[0] == "api":
            if scan(" ".join(argv), patterns):
                blocked.append("gh api write")
        elif pair and pair[1] in gh_writes.get(pair[0], []):
            label = f"gh {pair[0]} {pair[1]}"
            (prompted if canonical and tuple(argv[1:3]) == pair else blocked).append(label)
    return prompted, blocked


def codex_verdict(script, gh_writes, patterns):
    hits = scan(script, patterns)
    if not hits:
        return None
    commands = plain_commands(script)
    if commands is None:
        return (
            f"{', '.join(hits)} appears in a command that Codex's approval rules cannot "
            "inspect (redirects, substitutions, variables or subshells). Run it as a "
            "plain standalone command so the approval prompt can be shown, or ask the "
            "user to run it."
        )
    blocked = []
    for command in commands:
        blocked += classify(command, gh_writes, patterns)[1]
    if not blocked:
        return None
    return (
        f"{', '.join(dict.fromkeys(blocked))} is written in a form the approval rules "
        "do not match (global options before the subcommand, a wrapper, a nested shell, "
        "or an API call). Run it as `git push ...` or `gh <group> <verb> ...` on its own "
        "(use `cd DIR && ...` instead of `git -C DIR`), or ask the user to run it."
    )


def claude_reason(text, patterns):
    hits = scan(text, patterns)
    if not hits:
        return None
    return (
        f"External write detected ({', '.join(hits)}). "
        "Approve only if you explicitly asked for this action."
    )


def emit(event, decision, reason):
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": event,
                    "permissionDecision": decision,
                    "permissionDecisionReason": reason,
                }
            },
            ensure_ascii=False,
        )
    )


def main(argv):
    mode, patterns_path = argv[1], argv[2]
    gh_writes, patterns = load_patterns(patterns_path)
    payload = json.load(sys.stdin)
    if payload.get("tool_name") != "Bash":
        return 0
    command = (payload.get("tool_input") or {}).get("command")
    if not isinstance(command, str):
        return 0
    if mode == "claude":
        reason = claude_reason(command, patterns)
        if reason:
            emit("PreToolUse", "ask", reason)
    elif mode == "codex":
        reason = codex_verdict(command, gh_writes, patterns)
        if reason:
            emit("PreToolUse", "deny", reason)
    else:
        raise SystemExit(f"unknown mode: {mode}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
