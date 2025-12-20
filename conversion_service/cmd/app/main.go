package main

import (
	"common"
	config "common/pkg/config"
	"common/pkg/messages"
	"context"
	"encoding/json"
	"log"
	"micro_file_converter/internal/domain"
	"micro_file_converter/internal/service"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
)

func main() {
	conf, err := config.LoadConfig("../..")
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

	publisher, err := messages.NewRabbitMQPublisher(conf[domain.RabbitMQHost], conf[domain.ConversionQueue])
	if err != nil {
		log.Panicf("Could not create publisher: %v", err)
	}
	worker, err := service.NewConverter(conf, publisher)
	if err != nil {
		log.Panicf("Could not create converter: %v", err)
	}
	subscriber, err := messages.NewRabbitMQSubscriber(conf[domain.RabbitMQHost], conf[domain.ConversionQueue], 3, true)

	subscriber.SetConsumeHandler(func(body []byte) error {
		var batch common.Batch
		if err := json.Unmarshal(body, &batch); err != nil {
			log.Printf("failed to deserialize body %s: %v\n", body, err)
			return err
		}

		if err := worker.Convert(context, batch); err != nil {
			log.Printf("batch %s failed: %v", batch.Id, err)
			return err
		}
		return nil

	})
	if err != nil {
		log.Panicf("Could not create subscriber: %v", err)
	}
	subscriber.Start(context)

}
