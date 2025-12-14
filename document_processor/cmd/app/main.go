package main

import (
	"context"
	"log"
	"micro_file_converter/internal/config"
	"micro_file_converter/internal/service"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
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

	context, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	publisher, err := service.NewPublisher(conf)
	if err != nil {
		log.Panicf("Could not create publisher: %v", err)
	}
	worker, err := service.NewConverter(conf, publisher)
	if err != nil {
		log.Panicf("Could not create converter: %v", err)
	}
	subscriber, err := service.NewSubscriber(conf, worker, 3)
	if err != nil {
		log.Panicf("Could not create subscriber: %v", err)
	}
	subscriber.Start(context)

}
