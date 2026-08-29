#!/usr/bin/env python3
"""
Multi-Language Benchmark Runner
Measures execution time, memory usage (RSS), and environment specs across languages and suites.
"""

import argparse
import datetime
import json
import os
import platform
import resource
import shutil
import statistics
import subprocess
import sys
import time
from pathlib import Path

# Suite Language Definitions and Command Configs
LANGUAGE_CONFIGS = {
    "c": {
        "name": "C",
        "category": "Compiled",
        "file": "one_million.c",
        "compile": "clang -O3 -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "clang --version | head -n 1",
    },
    "cpp": {
        "name": "C++",
        "category": "Compiled",
        "file": "one_million.cpp",
        "compile": "clang++ -O3 -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "clang++ --version | head -n 1",
    },
    "crystal": {
        "name": "Crystal",
        "category": "Compiled",
        "file": "one_million.cr",
        "compile": "crystal build --release --no-debug -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "crystal --version | head -n 1",
    },
    "go": {
        "name": "Go",
        "category": "Compiled",
        "file": "one_million.go",
        "compile": "go build -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "go version",
    },
    "haskell": {
        "name": "Haskell",
        "category": "Compiled",
        "file": "one_million.hs",
        "compile": "ghc -O2 -v0 -outputdir {out_dir} -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "ghc --version | head -n 1",
    },
    "java": {
        "name": "Java",
        "category": "JIT / VM",
        "file": "one_million.java",
        "compile": "javac -d {out_dir} {src}",
        "run": "java -cp {out_dir} OneMillion",
        "version_cmd": "java --version | head -n 1",
    },
    "javascript": {
        "name": "JavaScript (Node)",
        "category": "JIT",
        "file": "one_million.js",
        "compile": None,
        "run": "node {src}",
        "version_cmd": "node --version",
    },
    "nim": {
        "name": "Nim",
        "category": "Compiled",
        "file": "one_million.nim",
        "compile": "nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:{out_dir}/nimcache -o:{bin} {src}",
        "run": "{bin}",
        "version_cmd": "nim --version | head -n 1",
    },
    "php": {
        "name": "PHP",
        "category": "Interpreted",
        "file": "one_million.phps",
        "compile": None,
        "run": "php {src}",
        "version_cmd": "php --version | head -n 1",
    },
    "perl": {
        "name": "Perl",
        "category": "Interpreted",
        "file": "one_million.pl",
        "compile": None,
        "run": "perl {src}",
        "version_cmd": "perl --version | grep -m1 'This is perl'",
    },
    "python3": {
        "name": "Python 3",
        "category": "Interpreted",
        "file": "one_million.py3",
        "compile": None,
        "run": "python3 {src}",
        "version_cmd": "python3 --version",
    },
    "r": {
        "name": "R",
        "category": "Interpreted",
        "file": "one_million.R",
        "compile": None,
        "run": "Rscript {src}",
        "version_cmd": "Rscript --version 2>&1 | head -n 1",
    },
    "raku": {
        "name": "Raku",
        "category": "Interpreted",
        "file": "one_million.p6",
        "compile": None,
        "run": "rakudo {src}",
        "version_cmd": "rakudo --version | head -n 1",
    },
    "ruby": {
        "name": "Ruby",
        "category": "Interpreted",
        "file": "one_million.rb",
        "compile": None,
        "run": "ruby {src}",
        "version_cmd": "ruby --version | head -n 1",
    },
    "rust": {
        "name": "Rust",
        "category": "Compiled",
        "file": "one_million.rs",
        "compile": "rustc -O -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "rustc --version",
    },
}


def get_system_specs():
    specs = {
        "os": f"{platform.system()} {platform.release()}",
        "architecture": platform.machine(),
        "python_version": platform.python_version(),
        "cpu_model": "Unknown CPU",
        "cpu_cores": os.cpu_count() or 1,
        "total_memory_mb": 0,
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }

    # Extract CPU model on Linux
    cpuinfo = Path("/proc/cpuinfo")
    if cpuinfo.exists():
        for line in cpuinfo.read_text().splitlines():
            if "model name" in line:
                specs["cpu_model"] = line.split(":", 1)[1].strip()
                break

    # Extract memory on Linux
    meminfo = Path("/proc/meminfo")
    if meminfo.exists():
        for line in meminfo.read_text().splitlines():
            if "MemTotal" in line:
                parts = line.split()
                if len(parts) >= 2:
                    specs["total_memory_mb"] = round(int(parts[1]) / 1024, 1)
                break

    return specs


def get_tool_version(version_cmd):
    if not version_cmd:
        return "N/A"
    try:
        res = subprocess.run(
            version_cmd, shell=True, capture_output=True, text=True, timeout=5
        )
        if res.returncode == 0:
            return res.stdout.strip().replace("\n", " ")
        return res.stderr.strip().replace("\n", " ") or "Unknown"
    except Exception:
        return "Unknown"


def run_benchmark_command(cmd, work_dir, runs=3):
    """
    Executes command with stdout redirected to /dev/null,
    measuring wall time, user time, system time, and max RSS (KB).
    """
    times = []
    user_times = []
    sys_times = []
    max_rss_list = []

    devnull = open(os.devnull, "wb")

    for i in range(runs):
        start = time.perf_counter()
        proc = subprocess.Popen(
            cmd,
            shell=True,
            cwd=str(work_dir),
            stdout=devnull,
            stderr=subprocess.PIPE,
        )
        _, stderr_data = proc.communicate()
        elapsed = time.perf_counter() - start

        if proc.returncode != 0:
            devnull.close()
            error_msg = stderr_data.decode("utf-8", errors="replace").strip()
            raise RuntimeError(f"Command '{cmd}' failed (exit {proc.returncode}): {error_msg}")

        ru = resource.getrusage(resource.RUSAGE_CHILDREN)
        times.append(elapsed)
        user_times.append(ru.ru_utime)
        sys_times.append(ru.ru_stime)
        max_rss_list.append(ru.ru_maxrss / 1024.0)

    devnull.close()

    mean_time = statistics.mean(times)
    median_time = statistics.median(times)
    stddev_time = statistics.stdev(times) if len(times) > 1 else 0.0
    min_time = min(times)
    max_time = max(times)

    return {
        "mean_seconds": round(mean_time, 4),
        "median_seconds": round(median_time, 4),
        "stddev_seconds": round(stddev_time, 4),
        "min_seconds": round(min_time, 4),
        "max_seconds": round(max_time, 4),
        "runs": runs,
        "raw_times": [round(t, 4) for t in times],
        "max_rss_mb": round(max(max_rss_list), 2),
    }


def compile_implementation(lang_key, config, mode_dir, out_dir):
    src_file = mode_dir / config["file"]
    if not src_file.exists():
        return None, f"Source file {src_file} does not exist"

    bin_name = f"bin_{lang_key}"
    bin_path = (out_dir / bin_name).resolve()
    src_abs = src_file.resolve()
    out_dir_abs = out_dir.resolve()

    compile_cmd = config["compile"]
    if compile_cmd:
        cmd = compile_cmd.format(
            bin=str(bin_path),
            src=str(src_abs),
            out_dir=str(out_dir_abs),
        )
        res = subprocess.run(
            cmd, shell=True, cwd=str(out_dir_abs), capture_output=True, text=True
        )
        if res.returncode != 0:
            return None, f"Compilation failed: {res.stderr.strip()}"

    run_cmd = config["run"].format(
        bin=str(bin_path),
        src=str(src_abs),
        out_dir=str(out_dir_abs),
    )
    return run_cmd, None


def run_suite(suite_dir, runs=3, selected_languages=None):
    suite_path = Path(suite_dir).resolve()
    suite_id = suite_path.name

    results = {
        "suite_id": suite_id,
        "title": "One Million Lines I/O",
        "description": "Sequential loop generating numbers 0..999,999 and printing formatted lines to standard output (/dev/null).",
        "unit": "seconds (lower is faster)",
        "modes": {},
    }

    metadata_file = suite_path / "benchmark.json"
    if metadata_file.exists():
        try:
            meta = json.loads(metadata_file.read_text())
            results["title"] = meta.get("title", results["title"])
            results["description"] = meta.get("description", results["description"])
        except Exception:
            pass

    for mode in ["optimized", "naive"]:
        mode_dir = suite_path / mode
        if not mode_dir.exists():
            continue

        print(f"\n==========================================")
        print(f"  Suite: {results['title']} | Mode: {mode.upper()}")
        print(f"==========================================")

        build_dir = mode_dir / "_build"
        build_dir.mkdir(parents=True, exist_ok=True)

        mode_results = []

        for lang_key, config in LANGUAGE_CONFIGS.items():
            if selected_languages and lang_key not in selected_languages:
                continue

            src_file = mode_dir / config["file"]
            if not src_file.exists():
                print(f"[-] Skipping {config['name']} (missing {config['file']})")
                continue

            print(f"[*] Benchmarking {config['name']} ({config['category']})... ", end="", flush=True)

            try:
                run_cmd, error = compile_implementation(lang_key, config, mode_dir, build_dir)
                if error:
                    print(f"COMPILE ERROR: {error}")
                    continue

                bench_stats = run_benchmark_command(run_cmd, build_dir, runs=runs)
                version_str = get_tool_version(config["version_cmd"])

                # Read source code snippet for UI inspection
                source_code = src_file.read_text(encoding="utf-8")

                entry = {
                    "id": lang_key,
                    "name": config["name"],
                    "category": config["category"],
                    "file": config["file"],
                    "version": version_str,
                    "stats": bench_stats,
                    "source_code": source_code,
                    "run_command": run_cmd,
                }
                mode_results.append(entry)
                print(f"Done! Median: {bench_stats['median_seconds']}s (Min: {bench_stats['min_seconds']}s, Max: {bench_stats['max_seconds']}s)")

            except Exception as e:
                print(f"FAILED: {e}")

        # Sort mode results by median execution time
        mode_results.sort(key=lambda x: x["stats"]["median_seconds"])

        # Calculate relative factor against fastest implementation
        if mode_results:
            fastest_time = mode_results[0]["stats"]["median_seconds"]
            for rank, item in enumerate(mode_results, 1):
                item["rank"] = rank
                if fastest_time > 0:
                    item["speedup_factor"] = round(item["stats"]["median_seconds"] / fastest_time, 2)
                else:
                    item["speedup_factor"] = 1.0

        results["modes"][mode] = mode_results

    return results


def main():
    parser = argparse.ArgumentParser(description="Multi-language benchmark runner")
    parser.add_argument("--suite", default="one_million", help="Benchmark suite directory to run")
    parser.add_argument("--runs", type=int, default=3, help="Number of iterations per implementation")
    parser.add_argument("--lang", nargs="*", help="Specific languages to benchmark")
    parser.add_argument("--output", default="benchmark_data.json", help="Path to write JSON results")

    args = parser.parse_args()

    specs = get_system_specs()
    suite_data = run_suite(args.suite, runs=args.runs, selected_languages=args.lang)

    output_payload = {
        "system": specs,
        "suites": {
            suite_data["suite_id"]: suite_data
        }
    }

    out_file = Path(args.output).resolve()
    out_file.write_text(json.dumps(output_payload, indent=2), encoding="utf-8")
    print(f"\n[+] Benchmark complete! Results written to {out_file}")


if __name__ == "__main__":
    main()
