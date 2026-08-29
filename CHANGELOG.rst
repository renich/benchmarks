=========
Changelog
=========

All notable changes to the **Polyglot Benchmarks** project will be documented in this file.

The format is based on `Keep a Changelog <https://keepachangelog.com/en/1.1.0/>`_,
and this project adheres to `Semantic Versioning <https://semver.org/spec/v2.0.0.html>`_.

.. rubric:: [Unreleased]

.. rubric:: Added

* **Suite 1: One Million Lines I/O (``one_million/``)**:
  Measures raw unbuffered vs chunked buffered I/O throughput across 1,000,000 formatted lines.
* **Suite 2: Concurrent Producer-Consumer Pipeline (``pipeline/``)**:
  Measures multi-stage concurrency with 1 Producer, a bounded channel (capacity 1,000), 8 Workers computing 64-bit FNV-1a checksums, and 1 Aggregator.
* **Suite 3: Parallel Directory Tree Walker (``tree_walk/``)**:
  Measures parallel filesystem traversal and error keyword aggregation across 2,500 structured text files in 40 nested directories.
* **Suite 4: Async Latency & Percentile Checker (``async_checker/``)**:
  Simulates 10,000 asynchronous non-blocking tasks, aggregating status codes and computing exact P50/P95/P99 latency percentiles with $O(K)$ histogram binning.
* **15 Polyglot Language Implementations**:
  C, C++, Crystal, Go, Haskell, Java, JavaScript (Node.js), Nim, Perl, PHP, Python 3, R, Raku, Ruby, and Rust.
* **Dual Execution Paradigms**:
  * ⚡ **Race Mode (Optimized)**: Peak performance implementations leveraging chunked buffered I/O, native CPU instruction targeting (``--mcpu=native``, ``-march=native``), zero-allocation byte scans, and compiler release flags.
  * 📦 **Out-of-the-Box Mode (Naive)**: Idiomatic, standard runtime configurations representing baseline developer ergonomics.
* **Hermetic Alpine Linux Container Environment**:
  Automated Podman build (``Containerfile``) packaging all 15 language compilers and runtimes.
* **Interactive GitLab Pages Dashboard**:
  Client-side dashboard featuring multi-suite tab switcher, median execution time charts, speedup factor rankings, peak RSS memory bars, and embedded source code viewers.
* **GNUmakefile Build System**:
  Complete targets for ``make all``, ``make bench``, ``make site``, ``make build-env``, and ``make clean``.
* **Liberapay Funding & Community Sponsorship**:
  Donation badges and direct Liberapay funding widgets in dashboard and documentation.

.. rubric:: Changed

* Upgraded compiler flags in Race Mode to leverage native CPU instruction vectorization (AVX2, AVX-512, BMI2).
* Refactored ``tools/benchmark_runner.py`` for dynamic multi-suite discovery and automated setup hooks.
