import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relativePath) =>
  fs.readFileSync(path.join(root, relativePath), "utf8").replace(/^\uFEFF/, "");

function markdownFiles(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) return markdownFiles(entryPath);
    return entry.isFile() && entry.name.endsWith(".md") ? [entryPath] : [];
  });
}

test("published versions stay synchronized", () => {
  const version = read("VERSION").trim();
  const packageVersion = JSON.parse(read("package.json")).version;
  const pluginVersions = [
    ".github/plugin/plugin.json",
    ".claude-plugin/plugin.json",
    ".codex-plugin/plugin.json",
  ].map((file) => JSON.parse(read(file)).version);
  const skillVersion = read("skills/feather-engineering-agent/SKILL.md")
    .match(/^\s*version:\s*"([^"]+)"/m)?.[1];

  assert.equal(packageVersion, version);
  assert.equal(skillVersion, version);
  for (const pluginVersion of pluginVersions) assert.equal(pluginVersion, version);
});

test("plugin manifests point to the canonical skill", () => {
  const skill = path.join(root, "skills", "feather-engineering-agent", "SKILL.md");
  assert.equal(fs.existsSync(skill), true);

  const copilot = JSON.parse(read(".github/plugin/plugin.json"));
  const claude = JSON.parse(read(".claude-plugin/plugin.json"));
  const codex = JSON.parse(read(".codex-plugin/plugin.json"));

  assert.equal(copilot.skills, "skills/");
  assert.deepEqual(claude.skills, ["./skills/feather-engineering-agent"]);
  assert.equal(codex.skills, "./skills/");
});

test("every eval case has the required decision sections", () => {
  const evalRoot = path.join(root, "evals");
  const cases = markdownFiles(evalRoot).filter(
    (file) => path.basename(file).toLowerCase() !== "readme.md",
  );

  assert.ok(cases.length > 0);
  for (const file of cases) {
    const body = fs.readFileSync(file, "utf8");
    for (const heading of ["模式", "输入", "合格结果", "失败特征"]) {
      assert.match(
        body,
        new RegExp(`^## ${heading}\\s*$`, "m"),
        `${path.relative(root, file)} is missing ## ${heading}`,
      );
    }
  }
});

test("local Markdown links resolve", () => {
  const markdownRoots = [
    "AGENTS.md",
    "CONTRIBUTING.md",
    "README.md",
    "THIRD_PARTY_NOTICES.md",
    "docs",
    "evals",
    "skills",
  ].flatMap((entry) => {
    const entryPath = path.join(root, entry);
    return fs.statSync(entryPath).isDirectory() ? markdownFiles(entryPath) : [entryPath];
  });

  for (const file of markdownRoots) {
    const body = fs.readFileSync(file, "utf8");
    for (const match of body.matchAll(/\[[^\]]*]\(([^)]+)\)/g)) {
      const target = match[1].trim().split(/\s+"/, 1)[0];
      if (/^(?:[a-z]+:|#)/i.test(target)) continue;

      const relativeTarget = decodeURIComponent(target.split("#", 1)[0]);
      const resolved = path.resolve(path.dirname(file), relativeTarget);
      assert.equal(
        fs.existsSync(resolved),
        true,
        `${path.relative(root, file)} links to missing ${target}`,
      );
    }
  }
});
