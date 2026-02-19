package main

import (
	"common"
	"common/messages"
	"context"
	"encoding/json"
	"log/slog"
	"micro_file_converter/internal/domain"
	"micro_file_converter/internal/service"
	"os"
	"os/signal"
	"syscall"

	"github.com/joho/godotenv"
)

func main() {

	_ = godotenv.Load()
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	publisher, err := messages.NewRabbitMQPublisher(
		os.Getenv(domain.RabbitMQHost),
		os.Getenv(domain.ProcessedQueue),
	)
	if err != nil {
		logger.Error("could not create publisher", slog.Any("error", err))
		os.Exit(1)
	}
	defer publisher.Close()

	converter, err := service.NewConverter(publisher, logger)
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
		os.Getenv(domain.RabbitMQHost),
		os.Getenv(domain.ConversionQueue),
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
