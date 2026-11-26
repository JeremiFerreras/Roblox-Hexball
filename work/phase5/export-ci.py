"""Print only changed project files after all checks pass; no credentials or environment."""
import hashlib
import json
import pathlib
import subprocess
ROOT = pathlib.Path(__file__).resolve().parents[2]
paths = sorted(set(subprocess.check_output(
    ["git", "ls-files", "--modified", "--others", "--exclude-standard"], cwd=ROOT, text=True,
).splitlines()))
entries = [{"path": p, "mode": "100644", "type": "blob", "content": (ROOT / p).read_text()} for p in paths]
payload = json.dumps(entries, ensure_ascii=True, separators=(",", ":"))
print("HEX_PATCH_LENGTH=" + str(len(payload)))
print("HEX_PATCH_SHA256=" + hashlib.sha256(payload.encode()).hexdigest())
for offset in range(0, len(payload), 8000):
    print("HEX_PATCH_CHUNK=" + json.dumps(payload[offset:offset + 8000]))
print("HEX_PATCH_END")
