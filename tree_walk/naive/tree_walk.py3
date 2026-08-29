#!/usr/bin/env python3
import os
import re
import threading
import queue
from pathlib import Path

def find_files(dir_path):
    return [p for p in Path(dir_path).rglob("*.txt")]

def main():
    data_dir = Path("tree_walk/_data")
    if not data_dir.exists():
        if Path("../../_data").exists():
            data_dir = Path("../../_data")
        elif Path("../_data").exists():
            data_dir = Path("../_data")
        else:
            data_dir = Path("_data")

    files = find_files(data_dir)
    file_q = queue.Queue(maxsize=500)
    res_q = queue.Queue(maxsize=500)
    workers = 8
    threads = []
    pattern = re.compile(r"category=([A-Z_]+)")

    def worker():
        local_matches = 0
        while True:
            fp = file_q.get()
            if fp is None:
                file_q.task_done()
                break
            content = fp.read_text(encoding="utf-8")
            local_matches += len(pattern.findall(content))
            file_q.task_done()
        res_q.put(local_matches)

    for _ in range(workers):
        t = threading.Thread(target=worker)
        t.start()
        threads.append(t)

    def producer():
        for f in files:
            file_q.put(f)
        for _ in range(workers):
            file_q.put(None)

    prod_t = threading.Thread(target=producer)
    prod_t.start()

    total_matches = 0
    for _ in range(workers):
        total_matches += res_q.get()

    prod_t.join()
    for t in threads:
        t.join()

    print(f"Tree walk complete: files={len(files)}, matches={total_matches}")

if __name__ == "__main__":
    main()
