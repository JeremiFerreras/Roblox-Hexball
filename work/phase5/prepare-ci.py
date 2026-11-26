"""Regenerate reviewable source/manifest/place artifacts before CI validation."""
import collections
import hashlib
import json
import pathlib
import shlex
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
OFFLINE = ROOT / "tests/offline"
package = json.loads((OFFLINE / "package.json").read_text())
# Run the project's own maintained-source formatter; multiple passes reach its fixed point.
args = shlex.split(package["scripts"]["format:check:luau"])
args[0] = str(OFFLINE / "node_modules/.bin/stylua")
args.remove("--check")
for _ in range(4):
    subprocess.run(args, cwd=OFFLINE, check=True)
subprocess.run([str(OFFLINE / "node_modules/.bin/prettier"), "--write", "*.mjs", "package.json"], cwd=OFFLINE, check=True)
subprocess.run(["python", "tools/place.py", "build", "Roblox Hexball.rbxlx"], cwd=ROOT, check=True)

counts = collections.Counter()
scripts = []
referents = {}
def visit(relative):
    directory = ROOT / "src" / relative
    data = json.loads((directory / "instance.json").read_text())
    classname = data["attributes"]["class"]
    counts[classname] += 1
    referents[data["attributes"]["referent"]] = "src/" + relative
    for field in data["fields"]:
        for prop in field.get("children", []):
            if "sourceFile" in prop:
                path = directory / prop["sourceFile"]
                scripts.append({
                    "path": path.relative_to(ROOT).as_posix(),
                    "className": classname,
                    "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                })
    for child in data["children"]:
        visit(child)
for child in json.loads((ROOT / "src/place.json").read_text())["children"]:
    visit(child)
(ROOT / "docs/inventory.json").write_text(json.dumps({
    "instances": sum(counts.values()), "classes": dict(sorted(counts.items())),
    "scripts": scripts, "referents": referents,
}, ensure_ascii=False, indent=2) + "\n")
subprocess.run(["python", "tests/validate_place.py"], cwd=ROOT, check=True)
subprocess.run(["python", "tools/place.py", "verify"], cwd=ROOT, check=True)
