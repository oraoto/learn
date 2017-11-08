package main

import (
	"sync"
)

const count = 1000

func main() {
	m := make(map[int]int)

	for i := 0; i < count; i++ {
		m[i] = i
	}

	var wait sync.WaitGroup
	wait.Add(2)

	// loop through all element
	go func() {
		for _ = range m {
			// runtime.Gosched()
		}
		wait.Done()
	}()

	// remove some element in map
	go func() {
		for i := 0; i < count; i += 20 {
			delete(m, i)
		}
		wait.Done()
	}()

	wait.Wait()
}
