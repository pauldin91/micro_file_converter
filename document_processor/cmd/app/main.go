package main

import (
	"log"
	"micro_file_converter/internal/config"
	"micro_file_converter/internal/service"
	"os"
	"path/filepath"
)

func main() {
	conf, err := config.LoadConfig()
	if err != nil {
		l, _ := os.Getwd()
		files, _ := os.ReadDir(l)
		for _, f := range files {
			log.Printf("Could not load app.env file in %s\n", f.Name())
		}
		log.Panicf("Could not load app.env file in %s\n", filepath.Dir(l))
	}
	worker := service.NewWorker(conf)
	worker.Start()

}
