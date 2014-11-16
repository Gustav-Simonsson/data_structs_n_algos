// min-heap of int64 values as a slice with fixed capacity
// http://en.wikipedia.org/wiki/Binary_heap
// http://www.cs.cmu.edu/~adamchik/15-121/lectures/Binary%20Heaps/heaps.html
package main

import "fmt"
import "time"
import "math/rand"

var heapCapacity int = 1024 * 1024

func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	Test2()
	Test3()
	Test4()
}

// API
func findMin(bh []int64) int64 {
	return bh[0]
}

func FromSlice(slice []int64) []int64 {
	bh := make([]int64, 0, heapCapacity)
	sliceLen := len(slice)
	for i := 0; i < sliceLen; i++ {
		bh = Insert(bh, slice[i])
	}
	return bh
}

func Insert(bh []int64, newValue int64) []int64 {
	i := len(bh)
	bh = bh[0 : i+1]
	bh[i] = newValue
	// "percolation up" - swap parent and child until
	// parent is smaller than or equal to child
	for i > 0 {
		// node's parent is at floor((i - 1) / 2)
		j := (i - 1) / 2
		if newValue <= bh[j] {
			bh[i] = bh[j]
			bh[j] = newValue
			i = j
		} else {
			break
		}
	}
	return bh
}

func DeleteMin(bh []int64) (int64, []int64) {
	// "percolation down" - swap parent and child similar to insert operation
	// but from root down to leaves
	lastIndex := len(bh) - 1
	parentIndex := 0
	oldMin := bh[parentIndex]
	bh[parentIndex] = bh[lastIndex]
	bh = bh[0 : lastIndex] // re-slice, reducing length by one
	left := 1
	for left < lastIndex {
		right := left + 1
		smallestChildIndex := left
		if (right) < lastIndex  {
			if (bh[right] < bh[left]) {
				smallestChildIndex = right
			}
		}
		childValue := bh[smallestChildIndex]
		parentValue := bh[parentIndex]
		if childValue < parentValue {
			bh[smallestChildIndex] = parentValue
			bh[parentIndex] = childValue
			parentIndex = smallestChildIndex
			left = (parentIndex * 2) + 1
		} else {
			break
		}
	}
	return oldMin, bh
}

//
// TESTS
//
// Test values are from http://en.wikipedia.org/wiki/Binary_heap#Heap_operations
func Test1() {
	testSlice := []int64{8, 4, 5, 11, 3}
	bh := FromSlice(testSlice)
	fmt.Println("bh:", bh)
}

// Time insertion of all elements from array
func Test2() {
	testSliceLen := heapCapacity
	testSlice := make([]int64, testSliceLen, testSliceLen)
	for i := 0; i < testSliceLen; i++ {
		testSlice[i] = rand.Int63()
	}
	startTime := time.Now()
	_ = FromSlice(testSlice)
	elapsed := time.Since(startTime)
	fmt.Println("Test 2 OK:", elapsed.Nanoseconds(),"ns")
}

// Time insertion and deletion of all elements
func Test3() {
	testSliceLen := heapCapacity
	testSlice := make([]int64, testSliceLen, testSliceLen)
	for i := 0; i < testSliceLen; i++ {
		testSlice[i] = rand.Int63()
	}
	startTime := time.Now()
	bh := FromSlice(testSlice)
	// var oldMin int64 = 0
	bhLen := len(bh)
	for i := 0; i < bhLen; i++ {
		_, bh = DeleteMin(bh)
	}
	// fmt.Println("bh:", bh)
	elapsed := time.Since(startTime)
	fmt.Println("Test 3 OK:", elapsed.Nanoseconds(),"ns")
}

// Time findMin O(1)
func Test4() {
	testSliceLen := heapCapacity
	testSlice := make([]int64, testSliceLen, testSliceLen)
	for i := 0; i < testSliceLen; i++ {
		testSlice[i] = rand.Int63()
	}
	bh := FromSlice(testSlice)
	startTime := time.Now()
	_ = findMin(bh)
	elapsed := time.Since(startTime)
	fmt.Println("Test 4 OK:", elapsed.Nanoseconds(),"ns")
}
