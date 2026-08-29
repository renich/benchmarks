#!/usr/bin/env python3
import os
import threading
import queue
from pathlib import Path

def find_files(dir_path):
    files = []
    for root, _, filenames in os.walk(dir_path):
        for fn in filenames:
            if fn.endswith(".txt"):
                files.append(os.path.join(root, fn))
    return files

def main():
    data_dir = "tree_walk/_data"
    if not os.path.exists(data_dir):
        if os.path.exists("../../_data"):
            data_dir = "../../_data"
        elif os.path.exists("../_data"):
            data_dir = "../_data"
        else:
            data_dir = "_data"

    files = find_files(data_dir)
    file_q = queue.Queue(maxsize=500)
    res_q = queue.Queue(maxsize=500)
    workers = 8
    threads = []
    needle = b"category="

    def worker():
        local_matches = 0
        while True:
            batch = file_q.get()
            if batch is None:
                file_q.task_done()
                break
            for path in batch:
                with open(path, "rb") as f:
                    data = f.read()
                    local_matches += data.count(needle)
            file_q.task_done()
        res_q.put(local_matches)

    for _ in range(workers):
        t = threading.Thread(target=worker)
        t.start()
        threads.append(t)

    def producer():
        chunk_size = 50
        for i in range(0, len(files), chunk_size):
            file_q.put(files[i:i + chunk_size])
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
