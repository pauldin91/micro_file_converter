package main

import (
	"log"
	"micro_file_converter/service"
	"micro_file_converter/utils"
	"os"
	"path/filepath"
)

func main() {
	conf, err := utils.LoadConfig()
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
