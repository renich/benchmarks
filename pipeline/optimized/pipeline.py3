#!/usr/bin/env python3
import threading
import queue

FNV_OFFSET = 0xcbf29ce484222325
FNV_PRIME  = 0x100000001b3
MASK64     = 0xFFFFFFFFFFFFFFFF

def fnv1a(data: bytes) -> int:
    h = FNV_OFFSET
    for b in data:
        h = ((h ^ b) * FNV_PRIME) & MASK64
    return h

def main():
    task_q = queue.Queue(maxsize=1000)
    res_q = queue.Queue(maxsize=1000)
    workers = 8
    threads = []

    def worker():
        prefix = b"task:item:"
        while True:
            batch = task_q.get()
            if batch is None:
                task_q.task_done()
                break
            batch_total = 0
            for item in batch:
                payload = prefix + str(item).encode("ascii")
                batch_total = (batch_total + fnv1a(payload)) & MASK64
            res_q.put((len(batch), batch_total))
            task_q.task_done()

    for _ in range(workers):
        t = threading.Thread(target=worker)
        t.start()
        threads.append(t)

    def producer():
        chunk_size = 500
        for i in range(0, 100000, chunk_size):
            task_q.put(range(i, min(100000, i + chunk_size)))
        for _ in range(workers):
            task_q.put(None)

    prod_t = threading.Thread(target=producer)
    prod_t.start()

    total = 0
    count = 0
    while count < 100000:
        c, chk = res_q.get()
        count += c
        total = (total + chk) & MASK64
        res_q.task_done()

    prod_t.join()
    for t in threads:
        t.join()

    print(f"Pipeline complete: processed={count}, checksum={total}")

if __name__ == "__main__":
    main()
