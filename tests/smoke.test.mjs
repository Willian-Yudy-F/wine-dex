import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const html = await readFile("index.html", "utf8");
const manifest = JSON.parse(await readFile("manifest.json", "utf8"));
const serviceWorker = await readFile("sw.js", "utf8");

test("inline application script has valid JavaScript", () => {
  const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
  assert.equal(scripts.length, 1);
  assert.doesNotThrow(() => new Function(scripts[0][1]));
});

test("key UI controls and metadata are present", () => {
  for (const value of [
    'id="addForm"',
    'id="navCellar"',
    'id="navInsights"',
    'id="exportBtn"',
    'id="importInput"',
    'rel="canonical"',
    'property="og:title"',
  ]) assert.match(html, new RegExp(value));
});

test("manifest provides installable PNG icons", () => {
  assert.equal(manifest.display, "standalone");
  assert.ok(manifest.icons.some((icon) => icon.sizes === "192x192" && icon.type === "image/png"));
  assert.ok(manifest.icons.some((icon) => icon.sizes === "512x512" && icon.type === "image/png"));
});

test("service worker caches the complete local app shell", () => {
  for (const asset of ["index.html", "manifest.json", "icon.svg", "icon-192.png", "icon-512.png"]) {
    assert.ok(serviceWorker.includes(asset), `${asset} is missing from the app shell`);
  }
});
