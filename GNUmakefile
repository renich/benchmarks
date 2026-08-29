# Polyglot Benchmarks Master Build & Runner
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

IMAGE_NAME ?= benchmarks-env
RUNS ?= 3

.PHONY: help all build-env bench bench-local site run clean

help:
	@echo "Polyglot Benchmarks Build System"
	@echo ""
	@echo "Targets:"
	@echo "  build-env    Build the Alpine Podman container with all runtimes"
	@echo "  bench        Run all benchmarks inside Podman container (RUNS=$(RUNS))"
	@echo "  bench-local  Run all benchmarks directly on host system"
	@echo "  site         Generate static GitLab Pages dashboard into public/"
	@echo "  all          Run benchmarks in Podman and generate site"
	@echo "  clean        Clean build artifacts, temporary binaries, and generated site"

build-env:
	podman build -t $(IMAGE_NAME) -f Containerfile .

bench:
	podman run --rm -v $$(pwd):/benchmarks:z $(IMAGE_NAME) python3 tools/benchmark_runner.py --runs $(RUNS) --output benchmark_data.json

bench-local:
	python3 tools/benchmark_runner.py --runs $(RUNS) --output benchmark_data.json

site:
	python3 tools/site_generator.py --data benchmark_data.json --site site --output public

all: bench site

run: all

clean:
	rm -rf public benchmark_data.json
	rm -rf one_million/naive/_build one_million/optimized/_build
	rm -f one_million/one_million_* one_million/OneMillion.class one_million/*.o one_million/*.hi one_million/one_million_rakudo
