package main

import (
	"log"
	"micro_file_converter/internal/service"
	"micro_file_converter/internal/utils"
	"os"
	"path/filepath"
)

func main() {
	l, _ := os.Getwd()
	conf, err := utils.LoadConfig(l)
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
