Concurrent Producer-Consumer Pipeline Benchmark
================================================

Description
-----------
This suite measures multi-stage concurrent throughput, synchronization overhead, and bounded channel backpressure.

Architecture
------------
1. **Producer**: Pushes **100,000 tasks** (IDs ``0..99,999``) into a bounded queue / channel (capacity ``1,000``).
2. **Worker Pool (8 Workers)**: Pulls tasks concurrently, generates ASCII payload ``task:item:<id>``, computes 64-bit FNV-1a checksum, and pushes result to the output channel.
3. **Aggregator**: Drains output channel, computes running 64-bit checksum sum, and verifies exact match with deterministic baseline (``18214484931122151148``).

Structure
---------
* ``naive/``: Standard idiomatic queues, threads, and channel communication.
* ``optimized/``: High-throughput batching, zero-allocation buffers, and compiler optimizations.
