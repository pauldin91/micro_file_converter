package main

import (
	"flag"
	"micro_file_converter/internal/service"
)

func main() {
	serviceName := flag.String("qname", "", "The name of the queue to consume")
	flag.Parse()

	if *serviceName == "" {
		*serviceName = "hello_Q"
	}

	worker := service.NewWorker(*serviceName)
	worker.Start()

}
