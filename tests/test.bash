#!/usr/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "[+] Starting high-core Testing Farm benchmark run..."
lscpu | grep -E "Model name|CPU\(s\):|Thread\(s\) per core" || true

# Build container and run all suites
make build-env
make all

# Assert benchmark_data.json exists and is valid JSON with 4 suites
python3 -c '
import json
with open("benchmark_data.json") as f:
    data = json.load(f)
assert len(data["suites"]) == 4, f"Expected 4 suites, got {len(data[\"suites\"])}"
print("[+] Verification passed: 4 suites completed successfully on Testing Farm!")
'
