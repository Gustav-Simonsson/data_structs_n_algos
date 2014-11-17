package main

import "fmt"
import "time"
import "math/rand"
import "encoding/binary"
import "hash/fnv"

type Node struct {
	bitmap uint64
	// TODO: child type array / bitmap?
	// TODO: what type can be either pointer to struct or uint64?
	children *[64]interface{}
}

const hashIndexBitCount uint8 = 6

func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	Test1()
}

func Hash(int64 uint64) uint64 {
	buf := make([]byte, 8)
	binary.PutUvarint(buf, int64)
	h := fnv.New64a()
	h.Write(buf)
	return h.Sum64()
}

func HashIndex(hash uint64, bitcount uint64) uint64 {
	return (hash >> bitcount) & 63
}

func CheckBit(bitmap uint64, pos uint64) bool {
	return (bitmap & (1 << pos)) == 1
}

func SetBit(bitmap uint64, pos uint64) uint64 {
	// TODO: can this be returned as one expression?
	bitmap |= (1 << pos)
	return bitmap
}

func Insert(node *Node, newValue uint64) {
	hashIndex := HashIndex(Hash(newValue), 0)
	if CheckBit(node.bitmap, hashIndex) {
		// TODO: traverse down to next level
		// TODO: distinguish between value and pointer to next level
	} else {
		node.children[hashIndex] = newValue
		node.bitmap = SetBit(node.bitmap, hashIndex)
	}
}

//
// TESTS
//
func Test1() {
	// node := new(Node)
	// Insert(node, 42)
	fmt.Println(Hash(42))
}
