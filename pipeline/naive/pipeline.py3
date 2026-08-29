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
        while True:
            item = task_q.get()
            if item is None:
                task_q.task_done()
                break
            payload = f"task:item:{item}".encode("ascii")
            chk = fnv1a(payload)
            res_q.put((item, chk))
            task_q.task_done()

    for _ in range(workers):
        t = threading.Thread(target=worker)
        t.start()
        threads.append(t)

    def producer():
        for i in range(100000):
            task_q.put(i)
        for _ in range(workers):
            task_q.put(None)

    prod_t = threading.Thread(target=producer)
    prod_t.start()

    total = 0
    count = 0
    for _ in range(100000):
        _, chk = res_q.get()
        total = (total + chk) & MASK64
        count += 1
        res_q.task_done()

    prod_t.join()
    for t in threads:
        t.join()

    print(f"Pipeline complete: processed={count}, checksum={total}")

if __name__ == "__main__":
    main()
