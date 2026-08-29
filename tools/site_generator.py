#!/usr/bin/env python3
"""
Static Site Generator for Polyglot Benchmark Suite
Compiles benchmark results JSON into a standalone GitLab Pages website (public/).
"""

import argparse
import json
import shutil
from pathlib import Path

def generate_site(data_path, site_dir, output_dir):
    data_file = Path(data_path).resolve()
    site_path = Path(site_dir).resolve()
    out_path = Path(output_dir).resolve()

    if not data_file.exists():
        raise FileNotFoundError(f"Benchmark data file not found: {data_file}")
    if not site_path.exists():
        raise FileNotFoundError(f"Site template directory not found: {site_path}")

    # Ensure output directory exists
    out_path.mkdir(parents=True, exist_ok=True)

    # Read data JSON
    raw_data = data_file.read_text(encoding="utf-8")
    benchmark_json = json.loads(raw_data)

    # Read template HTML
    template_html = (site_path / "index.html").read_text(encoding="utf-8")

    # Invert/inject data into template
    injection = f"window.BENCHMARK_DATA = {json.dumps(benchmark_json)};"
    final_html = template_html.replace("/* __BENCHMARK_DATA_INJECTION__ */", injection)

    # Write final index.html
    (out_path / "index.html").write_text(final_html, encoding="utf-8")

    # Copy assets
    shutil.copy2(site_path / "style.css", out_path / "style.css")
    shutil.copy2(site_path / "app.js", out_path / "app.js")
    shutil.copy2(data_file, out_path / "benchmark_data.json")

    print(f"[+] Static site generated successfully at: {out_path}")
    print(f"    - index.html ({len(final_html)} bytes)")
    print(f"    - style.css")
    print(f"    - app.js")
    print(f"    - benchmark_data.json")

def main():
    parser = argparse.ArgumentParser(description="GitLab Pages site generator for benchmarks")
    parser.add_argument("--data", default="benchmark_data.json", help="Path to benchmark_data.json")
    parser.add_argument("--site", default="site", help="Path to site template directory")
    parser.add_argument("--output", default="public", help="Output directory for static site")

    args = parser.parse_args()
    generate_site(args.data, args.site, args.output)

if __name__ == "__main__":
    main()
