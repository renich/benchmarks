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
* ``one_million/``: Sequential loop generating numbers ``0..999,999`` and printing formatted lines to standard output (``/dev/null``).

Measurement Modes
-----------------
1. **⚡ Race Mode (Optimized)**: Maximum throughput implementation leveraging chunked buffered I/O, syscall batching, compiler release optimizations (``-O3``, ``--release``), and fast integer formatting.
2. **📦 Out-of-the-Box Mode (Naive)**: Standard idiomatic print/loop statements using default language runtime configurations.

Performance Summary (One Million Lines I/O)
-------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15 25 30 30

   * - Rank
     - Language
     - Race Mode (Optimized)
     - Out-of-the-Box (Naive)
   * - 🥇 #1
     - C++
     - 0.0092s
     - 0.0643s
   * - 🥈 #2
     - C
     - 0.0100s
     - 0.1037s
   * - 🥉 #3
     - Rust
     - 0.0102s
     - 0.5606s
   * - #4
     - Go
     - 0.0213s
     - 0.6306s
   * - #5
     - Crystal
     - 0.0346s
     - 0.5947s
   * - #6
     - Nim
     - 0.0676s
     - 0.5893s
   * - #7
     - PHP
     - 0.0757s
     - 0.5140s
   * - #8
     - Haskell
     - 0.0904s
     - 0.4011s
   * - #9
     - Perl
     - 0.0975s
     - 0.0816s
   * - #10
     - Java
     - 0.1200s
     - 0.7816s
   * - #11
     - Node.js
     - 0.1315s
     - 1.6249s
   * - #12
     - Ruby
     - 0.3098s
     - 0.5168s
   * - #13
     - Python 3
     - 0.3627s
     - 0.3863s
   * - #14
     - Raku
     - 1.6016s
     - 1.3737s
   * - #15
     - R
     - 2.0580s
     - 4.4477s

Local Development with Podman
-----------------------------
Build the Alpine container image with all 15 language compilers and runtimes::

   make build-env

Run the benchmark suite inside the Podman container (default: 3 iterations per implementation)::

   make bench

Generate the static GitLab Pages dashboard into ``public/``::

   make site

Execute both and prepare site::

   make all

Clean artifacts and binaries::

   make clean

Adding a New Benchmark Suite
----------------------------
1. Create a new directory (e.g. ``matrix_mult/``) with a ``benchmark.json`` descriptor.
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
