package main

import (
	"common"
	config "common/config"
	"common/messages"
	"context"
	"encoding/json"
	"log/slog"
	"micro_file_converter/internal/domain"
	"micro_file_converter/internal/service"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

	conf := config.NewConfig()
	if err := conf.LoadConfig("../.."); err != nil {
		cwd, _ := os.Getwd()
		logger.Error("could not load app.env", slog.String("search_path", cwd), slog.Any("error", err))
		os.Exit(1)
	}

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	publisher, err := messages.NewRabbitMQPublisher(
		conf.Get(domain.RabbitMQHost),
		conf.Get(domain.ProcessedQueue),
	)
	if err != nil {
		logger.Error("could not create publisher", slog.Any("error", err))
		os.Exit(1)
	}
	defer publisher.Close()

	converter, err := service.NewConverter(conf, publisher, logger)
	if err != nil {
		logger.Error("could not create converter", slog.Any("error", err))
		os.Exit(1)
	}

	handler := func(body []byte) error {
		var batch common.Batch
		if err := json.Unmarshal(body, &batch); err != nil {
			logger.Error("failed to deserialise message body", slog.Any("error", err))
			return nil
		}

		if err := converter.Convert(ctx, batch); err != nil {
			logger.Error("batch conversion failed",
				slog.String("batch_id", batch.Id),
				slog.Any("error", err),
			)
			return err
		}

		logger.Info("batch converted successfully", slog.String("batch_id", batch.Id))
		return nil
	}

	subscriber, err := messages.NewRabbitMQSubscriber(
		conf.Get(domain.RabbitMQHost),
		conf.Get(domain.ConversionQueue),
		3,
		true,
		handler,
	)
	if err != nil {
		logger.Error("could not create subscriber", slog.Any("error", err))
		os.Exit(1)
	}
	defer subscriber.Close()

	logger.Info("file converter started")

	if err := subscriber.Start(ctx); err != nil && err != context.Canceled {
		logger.Error("subscriber exited with error", slog.Any("error", err))
		os.Exit(1)
	}

	logger.Info("file converter stopped")
}
