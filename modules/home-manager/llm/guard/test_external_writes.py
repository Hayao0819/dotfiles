import io
import json
import os
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch

import external_writes

PATTERNS = Path(__file__).with_name("patterns.json")
GH_WRITES, REGEXES = external_writes.load_patterns(PATTERNS)


def run_hook(mode, command, tool="Bash"):
    payload = json.dumps({"tool_name": tool, "tool_input": {"command": command}})
    output = io.StringIO()
    with patch("sys.stdin", io.StringIO(payload)), redirect_stdout(output):
        external_writes.main(["guard", mode, str(PATTERNS)])
    return json.loads(output.getvalue()) if output.getvalue() else None


class ScanTests(unittest.TestCase):
    def test_detects_writes_in_the_shapes_agents_actually_use(self):
        for command in (
            "git push origin master",
            "git push",
            "git -C /home/hayao/Git/kigumi push origin master",
            "git -c core.x=1 push",
            "git --no-pager push --force-with-lease",
            "/usr/bin/git push",
            "cd /home/hayao/Git/kigumi && git push origin master 2>&1 | tail -2",
            "bash -lc 'git push'",
            "env GIT_TERMINAL_PROMPT=0 git push",
            "gh pr create --title x",
            "gh   pr   create",
            "gh -R owner/repo pr merge 3",
            "gh issue comment 3 -b hi",
            "gh repo fork owner/repo --clone=false",
            "gh release create v1",
            "gh workflow run ci.yml",
            "gh api repos/a/b/issues -f title=x",
            "gh api -X POST repos/a/b/issues",
            "gh api --method=DELETE repos/a/b",
            "gh api repos/a/b/issues/1/comments -f body=hello",
            "gh api graphql -f query='mutation { addStar(input: {}) { clientMutationId } }'",
            "curl -X POST https://api.github.com/repos/a/b/issues -d '{}'",
            "curl -H 'Authorization: x' -d @body.json https://api.github.com/repos/a/b/issues",
            "python3 -c \"import subprocess; subprocess.run(['git', 'push'])\"",
            "subprocess.run(['gh', 'pr', 'create'])",
        ):
            with self.subTest(command=command):
                self.assertTrue(external_writes.scan(command, REGEXES))

    def test_reads_and_unrelated_text_are_not_flagged(self):
        for command in (
            "git status",
            "git log --grep push",
            "git commit -m 'fix: handle pushes'",
            "git pull --rebase",
            "gh pr view 3 --json title",
            "gh pr list",
            "gh issue list -R owner/repo",
            "gh api repos/a/b --jq .name",
            "gh api -X GET search/issues -f q='repo:a/b is:open'",
            "gh api --method GET search/issues -f q=x",
            "gh api graphql -f query='{ viewer { login } }'",
            "gh run list --limit 3",
            "gh run cancel 123",
            "curl -s https://api.github.com/repos/a/b",
            "curl -sS -D - https://api.github.com/repos/a/b -o /tmp/x",
            "cargo push-something",
        ):
            with self.subTest(command=command):
                self.assertEqual(external_writes.scan(command, REGEXES), [])


class PlainCommandTests(unittest.TestCase):
    def test_accepts_only_word_only_sequences(self):
        self.assertEqual(
            external_writes.plain_commands("cd /x && git push origin main"),
            [["cd", "/x"], ["git", "push", "origin", "main"]],
        )
        self.assertEqual(
            external_writes.plain_commands("git commit -m 'fix(x): y' ; git status\n\nls"),
            [["git", "commit", "-m", "fix(x): y"], ["git", "status"], ["ls"]],
        )
        for script in (
            "git push 2>&1 | tail -2",
            "echo $(git push)",
            "git push `x`",
            "FOO=1 git push",
            "(git push)",
            "git push &",
            "git commit -m \"$MSG\"",
            "git push; ",
            "a && && b",
            "echo 'unterminated",
            "cat <<EOF\nx\nEOF",
            "ls *.go",
        ):
            with self.subTest(script=script):
                self.assertIsNone(external_writes.plain_commands(script))


class ClaudeHookTests(unittest.TestCase):
    def test_write_asks_the_user_with_a_reason(self):
        result = run_hook("claude", "git -C /x push origin main")
        decision = result["hookSpecificOutput"]
        self.assertEqual(decision["permissionDecision"], "ask")
        self.assertIn("git push", decision["permissionDecisionReason"])

    def test_other_commands_and_tools_pass_silently(self):
        self.assertIsNone(run_hook("claude", "git status"))
        self.assertIsNone(run_hook("claude", "git push", tool="Read"))


class CodexHookTests(unittest.TestCase):
    def verdict(self, command):
        return external_writes.codex_verdict(command, GH_WRITES, REGEXES)

    def test_promptable_forms_are_left_to_the_approval_rules(self):
        for command in (
            "git push origin main",
            "cd /x && git push",
            "gh pr create --title x",
            "gh issue comment 3 -b hi",
            "git status && git diff --check",
            "git commit -m 'document git push'",
            "echo git push",
            "git log --oneline",
            "gh pr view 3",
        ):
            with self.subTest(command=command):
                self.assertIsNone(self.verdict(command))

    def test_forms_the_rules_cannot_match_are_denied(self):
        for command in (
            "git -C /x push origin main",
            "git push origin main 2>&1 | tail -2",
            "/usr/bin/git push",
            "env X=1 git push",
            "sudo git push",
            "bash -c 'git push'",
            "xargs git push",
            "gh -R a/b pr create",
            "gh api repos/a/b/issues -f title=x",
            "curl -X POST https://api.github.com/repos/a/b/issues",
            "git push $(echo origin) main",
            "FOO=1 gh pr create",
        ):
            with self.subTest(command=command):
                self.assertIsNotNone(self.verdict(command))

    def test_hook_output_is_a_deny_decision(self):
        result = run_hook("codex", "git -C /x push")
        self.assertEqual(result["hookSpecificOutput"]["permissionDecision"], "deny")
        self.assertIsNone(run_hook("codex", "git push origin main"))


if __name__ == "__main__":
    unittest.main()
