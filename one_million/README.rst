One Million Lines I/O Benchmark
================================

Description
-----------
This suite measures formatted string output and loop throughput across languages.

Every implementation generates integer numbers from ``0`` to ``999,999`` (exactly 1,000,000 lines) and writes the following exact string to standard output redirected to ``/dev/null``::

   Hello, this is iteration number: <n>

Structure
---------
* ``naive/``: Idiomatic out-of-the-box print statements.
* ``optimized/``: High-throughput race mode using buffered I/O, custom formatting, and batch syscalls.

Running
-------
Inside the Alpine container or local environment::

   make all       # Runs both optimized and naive
   make optimized # Runs only race-mode implementations
   make naive     # Runs only out-of-the-box implementations
