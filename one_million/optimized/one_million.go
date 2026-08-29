package main

import (
	"strconv"
	"syscall"
)

func main() {
	const bufSize = 65536
	var buf [bufSize]byte
	pos := 0
	prefix := []byte("Hello, this is iteration number: ")
	prefixLen := len(prefix)
	var numBuf [16]byte

	for i := 0; i < 1000000; i++ {
		if pos+prefixLen+16 > bufSize {
			_, _ = syscall.Write(1, buf[:pos])
			pos = 0
		}
		copy(buf[pos:], prefix)
		pos += prefixLen
		formatted := strconv.AppendInt(numBuf[:0], int64(i), 10)
		copy(buf[pos:], formatted)
		pos += len(formatted)
		buf[pos] = '\n'
		pos++
	}
	if pos > 0 {
		_, _ = syscall.Write(1, buf[:pos])
	}
}
