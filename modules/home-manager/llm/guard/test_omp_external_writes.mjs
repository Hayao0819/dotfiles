import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";

const patterns = JSON.parse(readFileSync(new URL("./patterns.json", import.meta.url), "utf8"));
const file = path.join(mkdtempSync(path.join(tmpdir(), "guard-")), "data.json");
writeFileSync(file, JSON.stringify({ ...patterns, ompGlobs: ["*git*push*", "*gh pr create*"] }));
process.env.EXTERNAL_WRITES_DATA = file;

const { default: install } = await import("./omp-external-writes.ts");
let handler;
install({ on: (name, fn) => { if (name === "tool_call") handler = fn; } });

const call = (toolName, input, ctx) => handler({ toolName, input }, ctx);
const ui = (answer) => ({ hasUI: true, ui: { confirm: async () => answer } });
const headless = { hasUI: false };

assert.equal(await call("bash", { command: "git status" }, headless), undefined);
assert.equal(await call("read", { path: "x" }, headless), undefined);
assert.equal(await call("bash", { command: "git -C /x push" }, headless), undefined, "covered by bash.patterns");
const gist = await call("bash", { command: "gh gist create a.txt" }, headless);
assert.equal(gist.block, true);
assert.match(gist.reason, /no interactive session/);
assert.equal((await call("bash", { command: "gh gist create a.txt" }, ui(false))).block, true);
assert.equal(await call("bash", { command: "gh gist create a.txt" }, ui(true)), undefined);
const code = "import subprocess\nsubprocess.run(['git', 'push'])";
assert.equal((await call("eval", { code }, headless)).block, true);
assert.equal(await call("eval", { code: "print(1)" }, headless), undefined);
console.log("omp hook: ok");
