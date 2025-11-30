package main

import (
	"log"
	"os"
	"path/filepath"
	"regexp"
)

func main() {
	cwd, _ := os.Getwd()
	dir := filepath.Join(cwd, "uploads")
	d, err := os.ReadDir(dir)
	if err != nil {
		l := filepath.Base(dir)
		log.Printf("CWD is: %s error %s\n", l, err)
		log.Fatal("Invalid upload dir\n")
	}
	reg := regexp.MustCompile("[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
	for _, ntry := range d {
		fullPath := filepath.Join(dir, ntry.Name())
		log.Printf("Ntry is: %s\n", fullPath)
		if reg.Match([]byte(fullPath)) {
			err := os.RemoveAll(fullPath)
			if err != nil {
				log.Printf("dir to remove was: %s error %s\n", fullPath, err)

			} else {

				log.Printf("dir removed: %s\n", fullPath)
			}

		}
	}
}
