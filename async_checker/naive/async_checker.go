package main

import (
	"fmt"
	"sort"
	"sync"
)

type TaskResult struct {
	latency int
	status  int
}

func runTask(id int) TaskResult {
	seed := (uint64(id)*1664525 + 1013904223) & 0xFFFFFFFF
	latency := int(10 + (seed % 990))
	status := 200
	if (seed % 7) == 0 {
		if (seed % 3) == 0 {
			status = 429
		} else {
			status = 500
		}
	}
	return TaskResult{latency: latency, status: status}
}

func main() {
	tasks := 10000
	workers := 16
	ch := make(chan TaskResult, 1000)
	var wg sync.WaitGroup

	chunkSize := tasks / workers
	for w := 0; w < workers; w++ {
		wg.Add(1)
		startIdx := w * chunkSize
		endIdx := startIdx + chunkSize
		if w == workers-1 {
			endIdx = tasks
		}
		go func(start, end int) {
			defer wg.Done()
			for i := start; i < end; i++ {
				ch <- runTask(i)
			}
		}(startIdx, endIdx)
	}

	go func() {
		wg.Wait()
		close(ch)
	}()

	okCount := 0
	rlCount := 0
	errCount := 0
	totalLat := int64(0)
	latencies := make([]int, 0, tasks)

	for res := range ch {
		latencies = append(latencies, res.latency)
		totalLat += int64(res.latency)
		switch res.status {
		case 200:
			okCount++
		case 429:
			rlCount++
		case 500:
			errCount++
		}
	}

	sort.Ints(latencies)
	p50 := latencies[int(float64(tasks)*0.50)]
	p95 := latencies[int(float64(tasks)*0.95)]
	p99 := latencies[int(float64(tasks)*0.99)]

	fmt.Printf("Async complete: tasks=%d, ok=%d, rate_limited=%d, errors=%d, latency_sum=%d, p50=%d, p95=%d, p99=%d\n",
		tasks, okCount, rlCount, errCount, totalLat, p50, p95, p99)
}
