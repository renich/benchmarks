===================
Polyglot Benchmarks
===================

.. image:: https://gitlab.com/renich/benchmarks/-/raw/master/assets/banner.svg
   :width: 100%
   :align: center
   :alt: Polyglot Benchmarks Banner

|

.. image:: https://gitlab.com/renich/benchmarks/badges/master/pipeline.svg
   :target: https://gitlab.com/renich/benchmarks/-/commits/master
   :alt: Pipeline Status
.. image:: https://img.shields.io/badge/GitLab_Pages-Live_Dashboard-fc6d26?logo=gitlab&style=flat-square
   :target: https://renich.gitlab.io/benchmarks/
   :alt: GitLab Pages Live Dashboard
.. image:: https://img.shields.io/badge/Languages-15_Polyglot-3b82f6?style=flat-square
   :target: https://renich.gitlab.io/benchmarks/
   :alt: 15 Languages Benchmarked
.. image:: https://img.shields.io/badge/Environment-Alpine_Linux_Container-0d597f?logo=alpinelinux&style=flat-square
   :target: Containerfile
   :alt: Alpine Linux Container
.. image:: https://img.shields.io/badge/License-GPLv3-blue.svg?logo=gnu&style=flat-square
   :target: LICENSE
   :alt: License
.. image:: https://img.shields.io/badge/Donate-Liberapay-f6c915.svg?logo=liberapay&logoColor=black&style=flat-square
   :target: https://liberapay.com/Renich/donate
   :alt: Donate using Liberapay

|

A reproducible, multi-language benchmark suite comparing execution times, peak memory usage (isolated per-process Peak RSS), and throughput across **15 programming languages** running inside an isolated **Alpine Linux** container environment.

Live Dashboard
--------------
Live interactive benchmark results and performance visualizer are published via GitLab Pages at:
https://renich.gitlab.io/benchmarks/

Supported Languages
-------------------
* **Compiled**: C (Clang), C++ (Clang++), Crystal, Go, Haskell (GHC), Nim, Rust
* **JIT / VM**: Java (OpenJDK 21), JavaScript (Node.js)
* **Interpreted**: Perl, PHP, Python 3, R, Raku, Ruby

Benchmark Suites
----------------
1. ``one_million/``: Sequential I/O loop generating numbers ``0..999,999`` and printing formatted lines to standard output (``/dev/null``).
2. ``pipeline/``: Multi-stage concurrent Producer-Consumer queue. 1 Producer pushes 100,000 tasks into a bounded channel (capacity 1,000) $\to$ 8 Workers compute 64-bit FNV-1a checksums $\to$ 1 Aggregator tallies totals and validates state.
3. ``tree_walk/``: Parallel filesystem traversal across 2,500 structured text files in 40 nested directories $\to$ 8 Workers scan for regex error tokens (``category=<CAT>``) $\to$ Aggregates total keyword matches (deterministic baseline: ``7,143``).
4. ``async_checker/``: Simulates 10,000 asynchronous non-blocking tasks with pseudo-random microsecond delays, aggregating HTTP status codes and computing exact P50/P95/P99 latency percentiles with $O(K)$ histogram binning.

Measurement Modes
-----------------
1. **⚡ Race Mode (Optimized)**: Maximum throughput implementation leveraging chunked buffered I/O, native CPU instructions (``--mcpu=native``, ``-march=native``, ``-C target-cpu=native``), zero-allocation byte scans, and compiler release optimizations.
2. **📦 Out-of-the-Box Mode (Naive)**: Standard idiomatic print/loop/scan statements using default language runtime configurations.

Performance Summary
-------------------

Suite 1: One Million Lines I/O
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 15 25 30 30

   * - Rank
     - Language
     - Race Mode (Optimized)
     - Out-of-the-Box (Naive)
   * - 🥇 #1
     - Crystal
     - 0.0100s [1.65 MB]
     - 0.6000s [1.73 MB]
   * - 🥇 #1
     - C
     - 0.0100s [1.67 MB]
     - 0.1100s [1.62 MB]
   * - 🥇 #1
     - Go
     - 0.0100s [1.73 MB]
     - 0.6200s [6.83 MB]
   * - 🥇 #1
     - Nim
     - 0.0100s [1.61 MB]
     - 0.5900s [1.62 MB]
   * - 🥇 #1
     - Rust
     - 0.0100s [1.63 MB]
     - 0.5500s [1.65 MB]
   * - 🥈 #2
     - C++
     - 0.0106s [2.62 MB]
     - 0.0600s [2.61 MB]
   * - #3
     - PHP
     - 0.0700s [9.21 MB]
     - 0.5100s [8.66 MB]
   * - #4
     - Haskell
     - 0.0900s [5.96 MB]
     - 0.4200s [5.95 MB]
   * - #5
     - Perl
     - 0.0900s [4.35 MB]
     - 0.0800s [3.22 MB]
   * - #6
     - Java
     - 0.1200s [42.58 MB]
     - 0.8000s [112.57 MB]
   * - #7
     - Node.js
     - 0.1200s [98.58 MB]
     - 1.6700s [77.24 MB]
   * - #8
     - Ruby
     - 0.3300s [12.20 MB]
     - 0.5100s [12.11 MB]
   * - #9
     - Python 3
     - 0.3600s [10.29 MB]
     - 0.3800s [6.23 MB]
   * - #10
     - Raku
     - 1.7900s [280.0 MB]
     - 1.3800s [147.78 MB]
   * - #11
     - R
     - 2.1600s [238.88 MB]
     - 4.5000s [71.63 MB]

Suite 2: Concurrent Producer-Consumer Pipeline (100k Tasks)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 15 25 30 30

   * - Rank
     - Language
     - Race Mode (Optimized)
     - Out-of-the-Box (Naive)
   * - 🥇 #1
     - Crystal
     - 0.0053s [1.65 MB]
     - 0.0100s [1.89 MB]
   * - 🥈 #2
     - Go
     - 0.0100s [2.40 MB]
     - 0.0100s [2.52 MB]
   * - 🥉 #3
     - Nim
     - 0.0100s [1.61 MB]
     - 0.0100s [1.67 MB]
   * - #4
     - Haskell
     - 0.0100s [7.14 MB]
     - 0.0100s [6.87 MB]
   * - #5
     - Perl
     - 0.0100s [3.97 MB]
     - 0.0100s [3.97 MB]
   * - #6
     - PHP
     - 0.0200s [8.90 MB]
     - 0.0200s [9.02 MB]
   * - #7
     - Rust
     - 0.0300s [1.61 MB]
     - 0.0500s [1.57 MB]
   * - #8
     - C
     - 0.0400s [1.60 MB]
     - 0.0400s [1.66 MB]
   * - #9
     - C++
     - 0.0600s [2.61 MB]
     - 0.0400s [2.63 MB]
   * - #10
     - Java
     - 0.0900s [54.27 MB]
     - 0.0900s [58.77 MB]
   * - #11
     - Node.js
     - 0.1300s [67.66 MB]
     - 0.1300s [67.79 MB]
   * - #12
     - R
     - 0.1900s [70.86 MB]
     - 0.3200s [75.71 MB]
   * - #13
     - Python 3
     - 0.2200s [7.52 MB]
     - 0.5100s [7.69 MB]
   * - #14
     - Raku
     - 0.2200s [170.0 MB]
     - 0.1900s [147.32 MB]
   * - #15
     - Ruby
     - 0.5600s [12.68 MB]
     - 0.7800s [12.15 MB]

Suite 3: Parallel Directory Tree Walker (2,500 Files)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 15 25 30 30

   * - Rank
     - Language
     - Race Mode (Optimized)
     - Out-of-the-Box (Naive)
   * - 🥇 #1
     - C
     - 0.0023s [1.67 MB]
     - 0.0023s [1.65 MB]
   * - 🥈 #2
     - Rust
     - 0.0100s [1.61 MB]
     - 0.0102s [1.63 MB]
   * - 🥉 #3
     - Go
     - 0.0100s [7.29 MB]
     - 0.0100s [8.05 MB]
   * - #4
     - C++
     - 0.0100s [3.01 MB]
     - 0.0200s [3.19 MB]
   * - #5
     - Nim
     - 0.0200s [1.67 MB]
     - 0.0200s [1.64 MB]
   * - #6
     - Crystal
     - 0.0400s [2.49 MB]
     - 0.0400s [2.74 MB]
   * - #7
     - PHP
     - 0.0400s [9.58 MB]
     - 0.0400s [9.91 MB]
   * - #8
     - Perl
     - 0.0400s [5.66 MB]
     - 0.0500s [5.60 MB]
   * - #9
     - Node.js
     - 0.0600s [64.14 MB]
     - 0.0600s [62.47 MB]
   * - #10
     - Haskell
     - 0.0700s [42.66 MB]
     - 0.0700s [42.79 MB]
   * - #11
     - Java
     - 0.0900s [53.55 MB]
     - 0.1000s [59.74 MB]
   * - #12
     - Ruby
     - 0.1000s [18.97 MB]
     - 0.1200s [15.15 MB]
   * - #13
     - Python 3
     - 0.1100s [9.29 MB]
     - 0.1600s [9.90 MB]
   * - #14
     - Raku
     - 0.3000s [160.97 MB]
     - 0.6500s [159.43 MB]
   * - #15
     - R
     - 0.3100s [84.72 MB]
     - 0.3200s [89.98 MB]

Suite 4: Async Latency & Percentile Checker (10,000 Tasks)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 15 25 30 30

   * - Rank
     - Language
     - Race Mode (Optimized)
     - Out-of-the-Box (Naive)
   * - 🥇 #1
     - Nim
     - 0.0020s [1.68 MB]
     - 0.0025s [1.62 MB]
   * - 🥈 #2
     - Crystal
     - 0.0028s [1.68 MB]
     - 0.0030s [1.71 MB]
   * - 🥉 #3
     - Go
     - 0.0032s [2.27 MB]
     - 0.0037s [2.41 MB]
   * - #4
     - PHP
     - 0.0081s [8.84 MB]
     - 0.0103s [9.46 MB]
   * - #5
     - Perl
     - 0.0089s [4.09 MB]
     - 0.0100s [4.53 MB]
   * - #6
     - Haskell
     - 0.0090s [7.34 MB]
     - 0.0093s [7.45 MB]
   * - #7
     - Rust
     - 0.0100s [1.63 MB]
     - 0.0100s [1.59 MB]
   * - #8
     - C
     - 0.0200s [1.64 MB]
     - 0.0200s [1.60 MB]
   * - #9
     - C++
     - 0.0200s [2.62 MB]
     - 0.0200s [2.64 MB]
   * - #10
     - Python 3
     - 0.0200s [6.64 MB]
     - 0.0300s [7.73 MB]
   * - #11
     - Node.js
     - 0.0300s [59.14 MB]
     - 0.0400s [66.12 MB]
   * - #12
     - Ruby
     - 0.0400s [11.56 MB]
     - 0.0500s [12.22 MB]
   * - #13
     - Java
     - 0.0600s [43.68 MB]
     - 0.0700s [46.55 MB]
   * - #14
     - R
     - 0.1600s [57.21 MB]
     - 0.1700s [57.04 MB]
   * - #15
     - Raku
     - 0.2900s [160.54 MB]
     - 0.2800s [152.78 MB]

Local Development with Podman
-----------------------------
Build the Alpine container image with all 15 language compilers and runtimes::

   make build-env

Run all benchmark suites inside the Podman container (default: 3 iterations per implementation)::

   make bench

Generate the static GitLab Pages dashboard into ``public/``::

   make site

Execute both and prepare site::

   make all

Clean artifacts and binaries::

   make clean

Adding a New Contender or Benchmark
-----------------------------------
Please review `CONTRIBUTING.rst <CONTRIBUTING.rst>`_ to enter the arena and submit optimized implementations.

Support & Donations
-------------------
If you find these benchmarks insightful and would like to support ongoing development, consider donating via Liberapay:

.. image:: https://liberapay.com/assets/widgets/donate.svg
   :target: https://liberapay.com/Renich/donate
   :alt: Donate using Liberapay

License
-------
This project is licensed under the GNU General Public License v3.0 or later.
See the `LICENSE <LICENSE>`_ file for details.
