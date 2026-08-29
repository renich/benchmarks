Parallel Directory Tree Walker & Aggregator Benchmark
======================================================

Description
-----------
This suite measures parallel filesystem traversal, recursive directory scanning, and keyword/regex pattern aggregation across a deep hierarchy of 2,500 structured text files.

Architecture
------------
1. **Dataset Generator**: ``tools/gen_tree.py`` builds a deterministic tree of 2,500 text files distributed across 40 nested directories.
2. **Worker Pool (8 Workers)**: Concurrently walks the tree, reads file contents, and searches for error category tokens (``category=<CAT>``).
3. **Aggregator**: Sums the total keyword matches across all files and verifies against the deterministic baseline (``7,143`` matches).

Structure
---------
* ``naive/``: Idiomatic directory iteration and standard regex matches.
* ``optimized/``: Fast byte search / memory scanning and batch queuing.
