#!/usr/bin/env python3
import sys

def main():
    write = sys.stdout.buffer.write
    prefix = b"Hello, this is iteration number: "
    chunk = []

    for n in range(1000000):
        chunk.append(prefix + str(n).encode("ascii") + b"\n")
        if n % 20000 == 19999:
            write(b"".join(chunk))
            chunk.clear()

    if chunk:
        write(b"".join(chunk))

if __name__ == "__main__":
    main()
