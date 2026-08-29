package main

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

func findFiles(dir string) []string {
	var files []string
	_ = filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err == nil && !info.IsDir() && strings.HasSuffix(path, ".txt") {
			files = append(files, path)
		}
		return nil
	})
	return files
}

func main() {
	dataDir := "tree_walk/_data"
	if _, err := os.Stat(dataDir); os.IsNotExist(err) {
		if _, err := os.Stat("../../_data"); err == nil {
			dataDir = "../../_data"
		} else if _, err := os.Stat("../_data"); err == nil {
			dataDir = "../_data"
		} else {
			dataDir = "_data"
		}
	}

	files := findFiles(dataDir)
	fileChan := make(chan string, 500)
	resChan := make(chan int, 500)
	workers := 8
	var wg sync.WaitGroup

	needle := []byte("category=")

	for w := 0; w < workers; w++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			matches := 0
			for path := range fileChan {
				data, err := os.ReadFile(path)
				if err == nil {
					matches += bytes.Count(data, needle)
				}
			}
			resChan <- matches
		}()
	}

	go func() {
		wg.Wait()
		close(resChan)
	}()

	go func() {
		for _, f := range files {
			fileChan <- f
		}
		close(fileChan)
	}()

	totalMatches := 0
	for count := range resChan {
		totalMatches += count
	}

	fmt.Printf("Tree walk complete: files=%d, matches=%d\n", len(files), totalMatches)
}
