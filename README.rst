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

Measurement Modes
-----------------
1. **⚡ Race Mode (Optimized)**: Maximum throughput implementation leveraging chunked buffered I/O, syscall batching, compiler release optimizations (``-O3``, ``--release``), and fast integer formatting.
2. **📦 Out-of-the-Box Mode (Naive)**: Standard idiomatic print/loop statements using default language runtime configurations.

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
     - Rust
     - 0.0093s
     - 0.5571s
   * - 🥈 #2
     - C
     - 0.0098s
     - 0.1065s
   * - 🥉 #3
     - C++
     - 0.0100s
     - 0.0658s
   * - #4
     - Go
     - 0.0214s
     - 0.6111s
   * - #5
     - Crystal
     - 0.0353s
     - 0.5663s
   * - #6
     - Nim
     - 0.0680s
     - 0.6088s
   * - #7
     - PHP
     - 0.0740s
     - 0.5362s
   * - #8
     - Haskell
     - 0.0916s
     - 0.3987s
   * - #9
     - Perl
     - 0.0966s
     - 0.0886s
   * - #10
     - Java
     - 0.1256s
     - 0.7591s
   * - #11
     - Node.js
     - 0.1328s
     - 1.6430s
   * - #12
     - Ruby
     - 0.3051s
     - 0.5045s
   * - #13
     - Python 3
     - 0.3577s
     - 0.3946s
   * - #14
     - Raku
     - 1.5845s
     - 1.3797s
   * - #15
     - R
     - 2.0470s
     - 4.4155s

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
     - 0.0045s
     - 0.0112s
   * - 🥈 #2
     - Nim
     - 0.0103s
     - 0.0137s
   * - 🥉 #3
     - Perl
     - 0.0106s
     - 0.0107s
   * - #4
     - Haskell
     - 0.0153s
     - 0.0153s
   * - #5
     - Go
     - 0.0165s
     - 0.0184s
   * - #6
     - PHP
     - 0.0294s
     - 0.0290s
   * - #7
     - Rust
     - 0.0388s
     - 0.0544s
   * - #8
     - C
     - 0.0436s
     - 0.0468s
   * - #9
     - C++
     - 0.0455s
     - 0.0469s
   * - #10
     - Java
     - 0.0954s
     - 0.0939s
   * - #11
     - Node.js
     - 0.1397s
     - 0.1367s
   * - #12
     - R
     - 0.1939s
     - 0.3434s
   * - #13
     - Python 3
     - 0.2423s
     - 0.5925s
   * - #14
     - Raku
     - 0.2436s
     - 0.1912s
   * - #15
     - Ruby
     - 0.5816s
     - 0.7787s

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
1. Create a new directory (e.g. ``tree_walk/``) with a ``benchmark.json`` descriptor.
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
