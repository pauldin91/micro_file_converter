package main

import (
	"flag"
	"fmt"
	"micro_file_converter/internal/service"
	"os"
)

func main() {
	serviceName := flag.String("qname", "", "The name of the queue to consume")
	flag.Parse()

	if *serviceName == "" {
		fmt.Println("Please provide a queue name using -qname flag")
		os.Exit(1)
	}

	worker := service.NewWorker(*serviceName)
	worker.Start()

}
