#!/usr/bin/env python3
"""
Synthetic Tree Generator for tree_walk Benchmark
Generates a deterministic hierarchy of 2,500 text files with embedded keyword patterns.
"""

import argparse
import os
import shutil
from pathlib import Path

CATEGORIES = ["AUTH_FAILURE", "DB_DEADLOCK", "NETWORK_TIMEOUT", "CRYPTO_ERROR", "DISK_FULL", "RATE_LIMIT"]

def generate_tree(target_dir, num_files=2500, dirs=10):
    base = Path(target_dir).resolve()
    if base.exists():
        shutil.rmtree(base)
    base.mkdir(parents=True, exist_ok=True)

    dir_paths = []
    for d in range(dirs):
        dp = base / f"sub_{d:02d}"
        dp.mkdir(exist_ok=True)
        dir_paths.append(dp)
        # Sub-sub directories
        for sub in range(3):
            ssp = dp / f"nest_{sub}"
            ssp.mkdir(exist_ok=True)
            dir_paths.append(ssp)

    total_dirs = len(dir_paths)
    for i in range(num_files):
        dp = dir_paths[i % total_dirs]
        fp = dp / f"log_{i:04d}.txt"

        lines = []
        # Generate 20 lines per file
        for l in range(20):
            line_id = i * 20 + l
            if line_id % 7 == 0:
                cat = CATEGORIES[line_id % len(CATEGORIES)]
                lines.append(f"2026-08-28T22:00:{l:02d}Z [WARN] server-01 error_code={line_id} category={cat} message=\"system alert\"\n")
            else:
                lines.append(f"2026-08-28T22:00:{l:02d}Z [INFO] server-01 request_id={line_id} path=/api/v1/health status=200\n")

        fp.write_text("".join(lines), encoding="utf-8")

    print(f"[+] Generated {num_files} synthetic files in {total_dirs} directories at: {base}")

def main():
    parser = argparse.ArgumentParser(description="Synthetic tree generator for tree_walk benchmark")
    parser.add_argument("--output", default="tree_walk/_data", help="Output directory for generated tree")
    parser.add_argument("--files", type=int, default=2500, help="Number of files to generate")
    args = parser.parse_args()
    generate_tree(args.output, num_files=args.files)

if __name__ == "__main__":
    main()
