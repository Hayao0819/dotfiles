// @ts-nocheck
import { readFileSync } from "node:fs";

const data = JSON.parse(
  readFileSync(process.env.EXTERNAL_WRITES_DATA ?? "@GUARD_DATA@", "utf8"),
);

const escape = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const ghGroups = Object.entries(data.gh_writes)
  .map(([group, verbs]) => `${escape(group)}\\s+(?:${verbs.map(escape).join("|")})`)
  .join("|");
const patterns = [
  ["gh write", new RegExp(`\\bgh\\s+(?:(?:-R|--repo)[ =]\\S+\\s+)?(?:${ghGroups})\\b`)],
  ...data.regex.map((item) => [item.name, new RegExp(item.re)]),
];
const approvalGlobs = data.ompGlobs.map(
  (glob) => new RegExp(`^${glob.split("*").map(escape).join(".*")}$`, "s"),
);

const scan = (text) => patterns.filter(([, expression]) => expression.test(text)).map(([name]) => name);
const coveredByApprovalRules = (command) => approvalGlobs.some((expression) => expression.test(command));

function textOf(event) {
  if (event.toolName === "bash") return event.input?.command;
  if (event.toolName === "eval") return event.input?.code;
  return undefined;
}

export default function (pi) {
  pi.on("tool_call", async (event, ctx) => {
    const text = textOf(event);
    if (typeof text !== "string") return;
    const hits = scan(text);
    if (hits.length === 0) return;
    if (event.toolName === "bash" && coveredByApprovalRules(text)) return;
    const reason = `External write detected (${hits.join(", ")}).`;
    if (!ctx.hasUI) {
      return { block: true, reason: `${reason} Blocked: no interactive session to approve it.` };
    }
    const approved = await ctx.ui.confirm(
      "External write",
      `${reason}\n\n${text.slice(0, 800)}\n\nAllow only if you explicitly asked for this.`,
    );
    return approved ? undefined : { block: true, reason: "Declined by the user." };
  });
}
