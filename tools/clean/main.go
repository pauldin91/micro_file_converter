package main

import (
	"log"
	"os"
	"path/filepath"
	"regexp"
)

func main() {
	cwd, _ := os.Getwd()
	directories := []string{
		filepath.Join(cwd, "uploads"),
		filepath.Join(cwd, "core", "priv", "uploads"),
	}
	for _, dir := range directories {
		d, err := os.ReadDir(dir)
		if err != nil {
			l := filepath.Base(dir)
			log.Printf("CWD is: %s error %s\n", l, err)
			log.Fatal("Invalid upload dir\n")
		}
		reg := regexp.MustCompile("[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
		for _, ntry := range d {
			fullPath := filepath.Join(dir, ntry.Name())
			if reg.Match([]byte(fullPath)) {
				err := os.RemoveAll(fullPath)
				if err == nil {
					log.Printf("removed: %s\n", fullPath)
				}

			}
		}
	}
}
