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

A reproducible, multi-language benchmark suite comparing execution times (in milliseconds), peak memory usage (isolated per-process Peak RSS), and throughput across **15 programming languages** running inside an isolated **Alpine Linux** container environment.

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

Performance Summary (Milliseconds)
----------------------------------

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
     - 10.0 ms [1.65 MB]
     - 600.0 ms [1.73 MB]
   * - 🥇 #1
     - C
     - 10.0 ms [1.67 MB]
     - 110.0 ms [1.62 MB]
   * - 🥇 #1
     - Go
     - 10.0 ms [1.73 MB]
     - 620.0 ms [6.83 MB]
   * - 🥇 #1
     - Nim
     - 10.0 ms [1.61 MB]
     - 590.0 ms [1.62 MB]
   * - 🥇 #1
     - Rust
     - 10.0 ms [1.63 MB]
     - 550.0 ms [1.65 MB]
   * - 🥈 #2
     - C++
     - 10.6 ms [2.62 MB]
     - 60.0 ms [2.61 MB]
   * - #3
     - PHP
     - 70.0 ms [9.21 MB]
     - 510.0 ms [8.66 MB]
   * - #4
     - Haskell
     - 90.0 ms [5.96 MB]
     - 420.0 ms [5.95 MB]
   * - #5
     - Perl
     - 90.0 ms [4.35 MB]
     - 80.0 ms [3.22 MB]
   * - #6
     - Java
     - 120.0 ms [42.58 MB]
     - 800.0 ms [112.57 MB]
   * - #7
     - Node.js
     - 120.0 ms [98.58 MB]
     - 1,670.0 ms [77.24 MB]
   * - #8
     - Ruby
     - 330.0 ms [12.20 MB]
     - 510.0 ms [12.11 MB]
   * - #9
     - Python 3
     - 360.0 ms [10.29 MB]
     - 380.0 ms [6.23 MB]
   * - #10
     - Raku
     - 1,790.0 ms [280.0 MB]
     - 1,380.0 ms [147.78 MB]
   * - #11
     - R
     - 2,160.0 ms [238.88 MB]
     - 4,500.0 ms [71.63 MB]

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
     - 5.3 ms [1.65 MB]
     - 10.0 ms [1.89 MB]
   * - 🥈 #2
     - Go
     - 10.0 ms [2.40 MB]
     - 10.0 ms [2.52 MB]
   * - 🥉 #3
     - Nim
     - 10.0 ms [1.61 MB]
     - 10.0 ms [1.67 MB]
   * - #4
     - Haskell
     - 10.0 ms [7.14 MB]
     - 10.0 ms [6.87 MB]
   * - #5
     - Perl
     - 10.0 ms [3.97 MB]
     - 10.0 ms [3.97 MB]
   * - #6
     - PHP
     - 20.0 ms [8.90 MB]
     - 20.0 ms [9.02 MB]
   * - #7
     - Rust
     - 30.0 ms [1.61 MB]
     - 50.0 ms [1.57 MB]
   * - #8
     - C
     - 40.0 ms [1.60 MB]
     - 40.0 ms [1.66 MB]
   * - #9
     - C++
     - 60.0 ms [2.61 MB]
     - 40.0 ms [2.63 MB]
   * - #10
     - Java
     - 90.0 ms [54.27 MB]
     - 90.0 ms [58.77 MB]
   * - #11
     - Node.js
     - 130.0 ms [67.66 MB]
     - 130.0 ms [67.79 MB]
   * - #12
     - R
     - 190.0 ms [70.86 MB]
     - 320.0 ms [75.71 MB]
   * - #13
     - Python 3
     - 220.0 ms [7.52 MB]
     - 510.0 ms [7.69 MB]
   * - #14
     - Raku
     - 220.0 ms [170.0 MB]
     - 190.0 ms [147.32 MB]
   * - #15
     - Ruby
     - 560.0 ms [12.68 MB]
     - 780.0 ms [12.15 MB]

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
     - 2.3 ms [1.67 MB]
     - 2.3 ms [1.65 MB]
   * - 🥈 #2
     - Rust
     - 10.0 ms [1.61 MB]
     - 10.2 ms [1.63 MB]
   * - 🥉 #3
     - Go
     - 10.0 ms [7.29 MB]
     - 10.0 ms [8.05 MB]
   * - #4
     - C++
     - 10.0 ms [3.01 MB]
     - 20.0 ms [3.19 MB]
   * - #5
     - Nim
     - 20.0 ms [1.67 MB]
     - 20.0 ms [1.64 MB]
   * - #6
     - Crystal
     - 40.0 ms [2.49 MB]
     - 40.0 ms [2.74 MB]
   * - #7
     - PHP
     - 40.0 ms [9.58 MB]
     - 40.0 ms [9.91 MB]
   * - #8
     - Perl
     - 40.0 ms [5.66 MB]
     - 50.0 ms [5.60 MB]
   * - #9
     - Node.js
     - 60.0 ms [64.14 MB]
     - 60.0 ms [62.47 MB]
   * - #10
     - Haskell
     - 70.0 ms [42.66 MB]
     - 70.0 ms [42.79 MB]
   * - #11
     - Java
     - 90.0 ms [53.55 MB]
     - 100.0 ms [59.74 MB]
   * - #12
     - Ruby
     - 100.0 ms [18.97 MB]
     - 120.0 ms [15.15 MB]
   * - #13
     - Python 3
     - 110.0 ms [9.29 MB]
     - 160.0 ms [9.90 MB]
   * - #14
     - Raku
     - 300.0 ms [160.97 MB]
     - 650.0 ms [159.43 MB]
   * - #15
     - R
     - 310.0 ms [84.72 MB]
     - 320.0 ms [89.98 MB]

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
     - 2.0 ms [1.68 MB]
     - 2.5 ms [1.62 MB]
   * - 🥈 #2
     - Crystal
     - 2.8 ms [1.68 MB]
     - 3.0 ms [1.71 MB]
   * - 🥉 #3
     - Go
     - 3.2 ms [2.27 MB]
     - 3.7 ms [2.41 MB]
   * - #4
     - PHP
     - 8.1 ms [8.84 MB]
     - 10.3 ms [9.46 MB]
   * - #5
     - Perl
     - 8.9 ms [4.09 MB]
     - 10.0 ms [4.53 MB]
   * - #6
     - Haskell
     - 9.0 ms [7.34 MB]
     - 9.3 ms [7.45 MB]
   * - #7
     - Rust
     - 10.0 ms [1.63 MB]
     - 10.0 ms [1.59 MB]
   * - #8
     - C
     - 20.0 ms [1.64 MB]
     - 20.0 ms [1.60 MB]
   * - #9
     - C++
     - 20.0 ms [2.62 MB]
     - 20.0 ms [2.64 MB]
   * - #10
     - Python 3
     - 20.0 ms [6.64 MB]
     - 30.0 ms [7.73 MB]
   * - #11
     - Node.js
     - 30.0 ms [59.14 MB]
     - 40.0 ms [66.12 MB]
   * - #12
     - Ruby
     - 40.0 ms [11.56 MB]
     - 50.0 ms [12.22 MB]
   * - #13
     - Java
     - 60.0 ms [43.68 MB]
     - 70.0 ms [46.55 MB]
   * - #14
     - R
     - 160.0 ms [57.21 MB]
     - 170.0 ms [57.04 MB]
   * - #15
     - Raku
     - 290.0 ms [160.54 MB]
     - 280.0 ms [152.78 MB]

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
