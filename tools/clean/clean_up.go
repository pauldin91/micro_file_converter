package main

import (
	"log"
	"os"
	"regexp"
)

func main() {
	uploadDir := "../../../uploads"
	d, err := os.ReadDir(uploadDir)
	if err != nil {
		log.Fatal("Invalid upload dir\n")
	}
	reg := regexp.MustCompile("[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
	for _, ntry := range d {
		if reg.Match([]byte(ntry.Name())) {
			os.RemoveAll(ntry.Name())
		}
	}
}
