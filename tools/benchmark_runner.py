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

# Suite Language Definitions and Command Configs (Dynamic per suite)
LANGUAGE_TEMPLATES = {
    "c": {
        "name": "C",
        "category": "Compiled",
        "ext": "c",
        "compile": "clang -O3 -pthread -o {bin} {src}",
        "compile_opt": "clang -O3 -march=native -mtune=native -pthread -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "clang --version | head -n 1",
    },
    "cpp": {
        "name": "C++",
        "category": "Compiled",
        "ext": "cpp",
        "compile": "clang++ -O3 -std=c++20 -pthread -o {bin} {src}",
        "compile_opt": "clang++ -O3 -march=native -mtune=native -std=c++20 -pthread -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "clang++ --version | head -n 1",
    },
    "crystal": {
        "name": "Crystal",
        "category": "Compiled",
        "ext": "cr",
        "compile": "crystal build --release --no-debug -o {bin} {src}",
        "compile_opt": "crystal build --release --mcpu=native --no-debug -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "crystal --version | head -n 1",
    },
    "go": {
        "name": "Go",
        "category": "Compiled",
        "ext": "go",
        "compile": "go build -o {bin} {src}",
        "compile_opt": "go build -ldflags='-s -w' -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "go version",
    },
    "haskell": {
        "name": "Haskell",
        "category": "Compiled",
        "ext": "hs",
        "compile": "ghc -O2 -v0 -outputdir {out_dir} -o {bin} {src}",
        "compile_opt": "ghc -O2 -optc-march=native -v0 -outputdir {out_dir} -o {bin} {src}",
        "run": "{bin}",
        "version_cmd": "ghc --version | head -n 1",
    },
    "java": {
        "name": "Java",
        "category": "JIT / VM",
        "ext": "java",
        "compile": "javac -d {out_dir} {src}",
        "compile_opt": "javac -d {out_dir} {src}",
        "run": "java -cp {out_dir} {java_class}",
        "version_cmd": "java --version | head -n 1",
    },
    "javascript": {
        "name": "JavaScript (Node)",
        "category": "JIT",
        "ext": "js",
        "compile": None,
        "compile_opt": None,
        "run": "node {src}",
        "version_cmd": "node --version",
    },
    "nim": {
        "name": "Nim",
        "category": "Compiled",
        "ext": "nim",
        "compile": "nim c --cc:clang -d:release --verbosity:0 --hints:off --nimcache:{out_dir}/nimcache -o:{bin} {src}",
        "compile_opt": "nim c --cc:clang -d:release -d:danger --passC:-march=native --verbosity:0 --hints:off --nimcache:{out_dir}/nimcache -o:{bin} {src}",
        "run": "{bin}",
        "version_cmd": "nim --version | head -n 1",
    },
    "php": {
        "name": "PHP",
        "category": "Interpreted",
        "ext": "phps",
        "compile": None,
        "compile_opt": None,
        "run": "php {src}",
        "version_cmd": "php --version | head -n 1",
    },
    "perl": {
        "name": "Perl",
        "category": "Interpreted",
        "ext": "pl",
        "compile": None,
        "compile_opt": None,
        "run": "perl {src}",
        "version_cmd": "perl --version | grep -m1 'This is perl'",
    },
    "python3": {
        "name": "Python 3",
        "category": "Interpreted",
        "ext": "py3",
        "compile": None,
        "compile_opt": None,
        "run": "python3 {src}",
        "version_cmd": "python3 --version",
    },
    "r": {
        "name": "R",
        "category": "Interpreted",
        "ext": "R",
        "compile": None,
        "compile_opt": None,
        "run": "Rscript {src}",
        "version_cmd": "Rscript --version 2>&1 | head -n 1",
    },
    "raku": {
        "name": "Raku",
        "category": "Interpreted",
        "ext": "p6",
        "compile": None,
        "compile_opt": None,
        "run": "rakudo {src}",
        "version_cmd": "rakudo --version | head -n 1",
    },
    "ruby": {
        "name": "Ruby",
        "category": "Interpreted",
        "ext": "rb",
        "compile": None,
        "compile_opt": None,
        "run": "ruby {src}",
        "version_cmd": "ruby --version | head -n 1",
    },
    "rust": {
        "name": "Rust",
        "category": "Compiled",
        "ext": "rs",
        "compile": "rustc -O -o {bin} {src}",
        "compile_opt": "rustc -O -C target-cpu=native -o {bin} {src}",
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
    times = []
    user_times = []
    sys_times = []
    max_rss_list = []

    time_bin = shutil.which("time") or "/usr/bin/time"

    for i in range(runs):
        start = time.perf_counter()
        wrapped_cmd = f"{time_bin} -f \"__BENCH_META__:%M:%e:%U:%S\" bash -c '{cmd}'"
        proc = subprocess.Popen(
            wrapped_cmd,
            shell=True,
            cwd=str(work_dir),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
        )
        _, stderr_data = proc.communicate()
        elapsed = time.perf_counter() - start

        if proc.returncode != 0:
            error_msg = stderr_data.decode("utf-8", errors="replace").strip()
            raise RuntimeError(f"Command '{cmd}' failed (exit {proc.returncode}): {error_msg}")

        stderr_text = stderr_data.decode("utf-8", errors="replace")
        import re
        match = re.search(r"__BENCH_META__:(\d+):([0-9.]+):([0-9.]+):([0-9.]+)", stderr_text)
        if match:
            rss_kb = int(match.group(1))
            wall_s = float(match.group(2))
            u_time = float(match.group(3))
            s_time = float(match.group(4))
            times.append(wall_s if wall_s > 0 else elapsed)
            user_times.append(u_time)
            sys_times.append(s_time)
            max_rss_list.append(rss_kb / 1024.0)
        else:
            times.append(elapsed)
            user_times.append(0.0)
            sys_times.append(0.0)
            max_rss_list.append(0.0)

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
        "mean_ms": round(mean_time * 1000.0, 2),
        "median_ms": round(median_time * 1000.0, 2),
        "min_ms": round(min_time * 1000.0, 2),
        "max_ms": round(max_time * 1000.0, 2),
        "runs": runs,
        "raw_times": [round(t, 4) for t in times],
        "max_rss_mb": round(max(max_rss_list), 2),
    }


def find_source_file(mode_dir, suite_name, ext):
    candidates = [
        mode_dir / f"{suite_name}.{ext}",
        mode_dir / f"{suite_name.capitalize()}.{ext}",
        mode_dir / f"{suite_name.title().replace('_', '')}.{ext}",
    ]
    for c in candidates:
        if c.exists():
            return c
    # Fallback to any file with matching extension in mode_dir
    matches = list(mode_dir.glob(f"*.{ext}"))
    if matches:
        return matches[0]
    return None


def compile_implementation(lang_key, config, suite_name, mode, mode_dir, out_dir):
    src_file = find_source_file(mode_dir, suite_name, config["ext"])
    if not src_file:
        return None, None, f"No source file with ext .{config['ext']} found in {mode_dir}"

    bin_name = f"bin_{lang_key}"
    bin_path = (out_dir / bin_name).resolve()
    src_abs = src_file.resolve()
    out_dir_abs = out_dir.resolve()

    java_class = src_file.stem

    compile_cmd = config.get("compile_opt") if mode == "optimized" and config.get("compile_opt") else config.get("compile")
    if compile_cmd:
        cmd = compile_cmd.format(
            bin=str(bin_path),
            src=str(src_abs),
            out_dir=str(out_dir_abs),
            java_class=java_class,
        )
        res = subprocess.run(
            cmd, shell=True, cwd=str(out_dir_abs), capture_output=True, text=True
        )
        if res.returncode != 0:
            return None, None, f"Compilation failed: {res.stderr.strip()}"

    if lang_key == "java" and out_dir_abs.exists():
        classes = [f.stem for f in out_dir_abs.glob("*.class") if "$" not in f.stem]
        if classes:
            java_class = classes[0]

    run_cmd = config["run"].format(
        bin=str(bin_path),
        src=str(src_abs),
        out_dir=str(out_dir_abs),
        java_class=java_class,
    )
    return run_cmd, src_file, None


def run_suite(suite_dir, runs=3, selected_languages=None):
    suite_path = Path(suite_dir).resolve()
    suite_id = suite_path.name

    results = {
        "suite_id": suite_id,
        "title": suite_id.replace("_", " ").title(),
        "description": "Benchmark suite",
        "unit": "milliseconds (lower is faster)",
        "modes": {},
    }

    metadata_file = suite_path / "benchmark.json"
    if metadata_file.exists():
        try:
            meta = json.loads(metadata_file.read_text(encoding="utf-8"))
            results["title"] = meta.get("title", results["title"])
            results["description"] = meta.get("description", results["description"])
            setup_cmd = meta.get("setup_cmd")
            if setup_cmd:
                subprocess.run(setup_cmd, shell=True, check=False)
        except Exception as e:
            print(f"[!] Suite setup warning: {e}")

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

        for lang_key, config in LANGUAGE_TEMPLATES.items():
            if selected_languages and lang_key not in selected_languages:
                continue

            src_file = find_source_file(mode_dir, suite_id, config["ext"])
            if not src_file:
                print(f"[-] Skipping {config['name']} (no .{config['ext']} file)")
                continue

            print(f"[*] Benchmarking {config['name']} ({config['category']})... ", end="", flush=True)

            try:
                run_cmd, actual_src, error = compile_implementation(lang_key, config, suite_id, mode, mode_dir, build_dir)
                if error:
                    print(f"COMPILE ERROR: {error}")
                    continue

                bench_stats = run_benchmark_command(run_cmd, build_dir, runs=runs)
                version_str = get_tool_version(config["version_cmd"])

                source_code = actual_src.read_text(encoding="utf-8")

                entry = {
                    "id": lang_key,
                    "name": config["name"],
                    "category": config["category"],
                    "file": actual_src.name,
                    "version": version_str,
                    "stats": bench_stats,
                    "source_code": source_code,
                    "run_command": run_cmd,
                }
                mode_results.append(entry)
                print(f"Done! Median: {bench_stats['median_ms']}ms (Min: {bench_stats['min_ms']}ms, Max: {bench_stats['max_ms']}ms)")

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


def discover_suites(base_dir):
    base_path = Path(base_dir).resolve()
    preferred_order = ["one_million", "pipeline", "tree_walk", "async_checker"]
    suites = []
    for item in base_path.iterdir():
        if item.is_dir() and (item / "benchmark.json").exists():
            suites.append(item)
    suites.sort(key=lambda p: preferred_order.index(p.name) if p.name in preferred_order else 99)
    return suites


def main():
    parser = argparse.ArgumentParser(description="Multi-language benchmark runner")
    parser.add_argument("--suite", default="all", help="Suite directory or 'all' for all discovered suites")
    parser.add_argument("--runs", type=int, default=3, help="Number of iterations per implementation")
    parser.add_argument("--lang", nargs="*", help="Specific languages to benchmark")
    parser.add_argument("--output", default="benchmark_data.json", help="Path to write JSON results")

    args = parser.parse_args()
    base_dir = Path(".").resolve()

    if args.suite == "all":
        suites_to_run = discover_suites(base_dir)
        if not suites_to_run:
            suites_to_run = [base_dir / "one_million"]
    else:
        suite_path = (base_dir / args.suite).resolve()
        if not suite_path.exists():
            raise FileNotFoundError(f"Suite directory '{args.suite}' does not exist.")
        suites_to_run = [suite_path]

    specs = get_system_specs()
    suites_data = {}

    for s_path in suites_to_run:
        suite_res = run_suite(s_path, runs=args.runs, selected_languages=args.lang)
        suites_data[suite_res["suite_id"]] = suite_res

    output_payload = {
        "system": specs,
        "suites": suites_data,
    }

    out_file = Path(args.output).resolve()
    out_file.write_text(json.dumps(output_payload, indent=2), encoding="utf-8")
    print(f"\n[+] All benchmarks complete! Results written to {out_file}")


if __name__ == "__main__":
    main()
