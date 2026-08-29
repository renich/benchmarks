package main

import (
	"bufio"
	"os"
	"strconv"
)

func main() {
	writer := bufio.NewWriterSize(os.Stdout, 65536)
	defer writer.Flush()

	prefix := []byte("Hello, this is iteration number: ")
	var numBuf [16]byte

	for i := 0; i < 1000000; i++ {
		writer.Write(prefix)
		formatted := strconv.AppendInt(numBuf[:0], int64(i), 10)
		writer.Write(formatted)
		writer.WriteByte('\n')
	}
}
