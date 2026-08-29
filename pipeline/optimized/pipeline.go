package main

import (
	"fmt"
	"strconv"
	"sync"
)

const (
	fnvOffset = 0xcbf29ce484222325
	fnvPrime  = 0x100000001b3
)

func fnv1a(b []byte) uint64 {
	h := uint64(fnvOffset)
	for _, c := range b {
		h = (h ^ uint64(c)) * fnvPrime
	}
	return h
}

type Task struct {
	id int
}

type Result struct {
	id       int
	checksum uint64
}

func main() {
	tasks := make(chan Task, 1000)
	results := make(chan Result, 1000)
	workers := 8
	var wg sync.WaitGroup

	for w := 0; w < workers; w++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			var buf [32]byte
			prefix := []byte("task:item:")
			for task := range tasks {
				copy(buf[:], prefix)
				idx := len(prefix)
				idx += copy(buf[idx:], strconv.Itoa(task.id))
				chk := fnv1a(buf[:idx])
				results <- Result{id: task.id, checksum: chk}
			}
		}()
	}

	go func() {
		wg.Wait()
		close(results)
	}()

	go func() {
		for i := 0; i < 100000; i++ {
			tasks <- Task{id: i}
		}
		close(tasks)
	}()

	var total uint64
	count := 0
	for res := range results {
		total += res.checksum
		count++
	}

	fmt.Printf("Pipeline complete: processed=%d, checksum=%d\n", count, total)
}
