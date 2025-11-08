package main

import (
	"micro_file_converter/internal/service"
)

func main() {
	worker := service.NewWorker()
	worker.Start()

}
