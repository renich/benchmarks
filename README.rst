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

A reproducible, multi-language benchmark suite comparing execution times, peak memory usage (RSS), and I/O throughput across **15 programming languages** running inside an isolated **Alpine Linux** container environment.

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
     - C++
     - 0.0091s
     - 0.0654s
   * - 🥈 #2
     - Rust
     - 0.0097s
     - 0.5557s
   * - 🥉 #3
     - C
     - 0.0097s
     - 0.1045s
   * - #4
     - Go
     - 0.0214s
     - 0.6117s
   * - #5
     - Crystal
     - 0.0345s
     - 0.5680s
   * - #6
     - Nim
     - 0.0680s
     - 0.5902s
   * - #7
     - PHP
     - 0.0740s
     - 0.5144s
   * - #8
     - Perl
     - 0.0800s
     - 0.0800s
   * - #9
     - Haskell
     - 0.0916s
     - 0.3956s
   * - #10
     - Java
     - 0.1256s
     - 0.7657s
   * - #11
     - Node.js
     - 0.1328s
     - 1.6073s
   * - #12
     - Ruby
     - 0.3057s
     - 0.5246s
   * - #13
     - Python 3
     - 0.3577s
     - 0.3950s
   * - #14
     - Raku
     - 1.6209s
     - 1.3565s
   * - #15
     - R
     - 2.0470s
     - 4.4130s

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
     - 0.0040s
     - 0.0102s
   * - 🥈 #2
     - Perl
     - 0.0098s
     - 0.0102s
   * - 🥉 #3
     - Nim
     - 0.0102s
     - 0.0129s
   * - #4
     - Haskell
     - 0.0144s
     - 0.0147s
   * - #5
     - Go
     - 0.0163s
     - 0.0178s
   * - #6
     - PHP
     - 0.0281s
     - 0.0288s
   * - #7
     - Rust
     - 0.0407s
     - 0.0588s
   * - #8
     - C++
     - 0.0440s
     - 0.0432s
   * - #9
     - C
     - 0.0448s
     - 0.0442s
   * - #10
     - Java
     - 0.0890s
     - 0.0972s
   * - #11
     - Node.js
     - 0.1296s
     - 0.1351s
   * - #12
     - R
     - 0.1919s
     - 0.3812s
   * - #13
     - Raku
     - 0.2212s
     - 0.2166s
   * - #14
     - Python 3
     - 0.2246s
     - 0.5497s
   * - #15
     - Ruby
     - 0.5509s
     - 0.7692s

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
     - 0.0011s
     - 0.0009s
   * - 🥈 #2
     - Rust
     - 0.0099s
     - 0.0100s
   * - 🥉 #3
     - Go
     - 0.0117s
     - 0.0123s
   * - #4
     - C++
     - 0.0156s
     - 0.0303s
   * - #5
     - Nim
     - 0.0229s
     - 0.0240s
   * - #6
     - PHP
     - 0.0419s
     - 0.0427s
   * - #7
     - Perl
     - 0.0462s
     - 0.0571s
   * - #8
     - Crystal
     - 0.0508s
     - 0.0388s
   * - #9
     - Node.js
     - 0.0671s
     - 0.0627s
   * - #10
     - Haskell
     - 0.0720s
     - 0.0717s
   * - #11
     - Java
     - 0.0944s
     - 0.1081s
   * - #12
     - Python 3
     - 0.1182s
     - 0.1570s
   * - #13
     - Ruby
     - 0.1179s
     - 0.1322s
   * - #14
     - R
     - 0.3126s
     - 0.3354s
   * - #15
     - Raku
     - 0.3222s
     - 0.7091s

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

Adding a New Benchmark Suite
----------------------------
1. Create a new directory (e.g. ``async_checker/``) with a ``benchmark.json`` descriptor.
2. Provide ``naive/`` and ``optimized/`` implementations following the naming convention.
3. Run ``make all`` to automatically execute and publish results to the dashboard.

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
