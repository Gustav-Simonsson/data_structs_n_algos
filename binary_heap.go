// http://en.wikipedia.org/wiki/Binary_heap
// min-heap of int64 values as a slice with fixed capacity

package main

import "fmt"
import "time"

var heapCapacity int = 1024 * 1024

func main() {
	startTime := time.Now()
	Test1()
	elapsed := time.Since(startTime)
	fmt.Println("OK:", elapsed.Nanoseconds(), "ns")
}

// Test values are from http://en.wikipedia.org/wiki/Binary_heap#Heap_operations
func Test1() {
	testArray := []int64{8, 4, 5, 11, 3}
	bh := FromArray(testArray)
	fmt.Println("bh4: ", bh)
}

func FromArray(array []int64) []int64 {
	bh := make([]int64, 0, heapCapacity)
	arrayLen := len(array)
	for i := 0; i < arrayLen; i++ {
		bh = Insert(bh, array[i])
	}
	return bh
}

func Insert(bh []int64, newVal int64) []int64 {
	i := len(bh)
	bh = bh[0 : i + 1]
	bh[i] = newVal
	for i > 0 {
		// node's parent is at floor((i - 1) / 2)
		j := (i - 1) / 2
		// fmt.Println("bh1: ", bh, i, j)
		if newVal < bh[j] {
			bh[i] = bh[j]
			bh[j] = newVal
			// fmt.Println("bh2: ", bh, i, j)
			i = j
		} else {
			break
		}
	}
	fmt.Println("bh3: ", bh)
	return bh
}
