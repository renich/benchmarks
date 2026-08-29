==============================================
Contributing to Polyglot Benchmarks: Enter the Arena
==============================================

.. image:: https://gitlab.com/renich/benchmarks/-/raw/master/assets/banner.svg
   :width: 100%
   :align: center
   :alt: Polyglot Benchmarks Banner

|

Think your favorite programming language is superior? Think you can write faster, leaner, and more cache-efficient code than the current leaderboards?

**Prove it on the track.**

This project is an open battleground for compiler engineers, systems hackers, runtime optimizers, and language enthusiasts. We welcome contributors who want to push their language of choice to its absolute physical limits.

The Two Battle Arenas
---------------------

Every benchmark suite supports two distinct competition tracks:

.. rubric:: 1. ⚡ Race Mode (Optimized Track)

* **Objective**: Maximum execution velocity and minimum memory footprint.
* **Rules of Engagement**:
  * Utilize every low-level trick in your language's arsenal: chunked buffered I/O, custom syscall batching, zero-allocation byte slicing, SIMD vectorization, cache-friendly data layouts, lock-free queues, and compiler optimization flags (``-O3``, ``--release``, ``--mcpu=native``, ``-C target-cpu=native``).
  * No external third-party dependencies unless officially part of the language runtime or standard library.
  * **Strict Requirement**: The implementation MUST actually perform the computation and match the exact deterministic verification baseline. Cheating by pre-computing or bypassing the workload will result in instant disqualification.

.. rubric:: 2. 📦 Out-of-the-Box Mode (Naive Track)

* **Objective**: Measure real-world developer ergonomics and default runtime performance.
* **Rules of Engagement**:
  * Write clean, idiomatic code using standard library constructs without esoteric buffer gymnastics.
  * Represents how code is written on Day 1 by an average developer in that language.

Contender Requirements
----------------------

To add a new language or optimize an existing contender:

1. **Deterministic Verification**:
   Your implementation must produce the exact expected output on ``stdout``:
   * ``one_million``: 1,000,000 formatted lines.
   * ``pipeline``: ``Pipeline complete: processed=100000, checksum=18214484931122151148``
   * ``tree_walk``: ``Tree walk complete: files=2500, matches=7143``
   * ``async_checker``: ``Async complete: tasks=10000, ok=8572, rate_limited=476, errors=952, latency_sum=5042064, p50=505, p95=950, p99=990``

2. **Standard Alpine Environment**:
   All contenders run inside our hermetic Alpine Linux Podman container.
   If introducing a new language, update ``Containerfile`` with the official Alpine APK package or official toolchain installer.

3. **Multi-Run Precision**:
   The runner measures median wall time, user time, system time, and peak RSS memory across 3 iterations (configurable with ``--runs``).

Submission Protocol
-------------------

1. **Fork the Repository**:
   * GitLab: `gitlab.com/renich/benchmarks <https://gitlab.com/renich/benchmarks>`_
   * GitHub: `github.com/renich/benchmarks <https://github.com/renich/benchmarks>`_

2. **Run Local Verification**:
   Build the container and run the full suite::

      make build-env
      make all

3. **Inspect the Leaderboard**:
   Check ``public/index.html`` to verify your rank, median timings, and memory footprint.

4. **Commit & Submit a Merge Request**:
   * Follow `Conventional Commits <https://www.conventionalcommits.org/>`_ (e.g. ``perf(rust): optimize tree_walk byte scanning``).
   * Include your benchmark before/after numbers in the MR description.
   * Open a Merge Request on GitLab or Pull Request on GitHub.

May the fastest runtime win!
