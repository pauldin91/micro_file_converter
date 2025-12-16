package service

import (
	"context"
	"encoding/json"
	"log"
	"micro_file_converter/internal/config"
	"sync"

	"common"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Subscriber struct {
	conn      *amqp.Connection
	ch        *amqp.Channel
	queue     string
	workers   int
	converter *Converter
}

func NewSubscriber(cfg config.Config, converter *Converter, workers int) (*Subscriber, error) {
	conn, err := amqp.Dial(cfg.RabbitMQHost)
	if err != nil {
		return nil, err
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, err
	}

	if _, err := ch.QueueDeclare(
		cfg.PendingQueue,
		true,
		false,
		false,
		false,
		nil,
	); err != nil {
		ch.Close()
		conn.Close()
		return nil, err
	}

	if err := ch.Qos(workers, 0, false); err != nil {
		ch.Close()
		conn.Close()
		return nil, err
	}

	return &Subscriber{
		conn:      conn,
		ch:        ch,
		queue:     cfg.PendingQueue,
		workers:   workers,
		converter: converter,
	}, nil
}

func (s *Subscriber) Start(ctx context.Context) error {
	msgs, err := s.ch.Consume(
		s.queue,
		"",
		false, // manual ACK
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		return err
	}

	var wg sync.WaitGroup
	sem := make(chan struct{}, s.workers)

	for {
		select {
		case <-ctx.Done():
			wg.Wait()
			return ctx.Err()

		case d, ok := <-msgs:
			if !ok {
				wg.Wait()
				return nil
			}

			sem <- struct{}{}
			wg.Add(1)

			go func(d amqp.Delivery) {
				defer func() {
					<-sem
					wg.Done()
				}()

				var batch common.Batch
				if err := json.Unmarshal(d.Body, &batch); err != nil {
					log.Printf("invalid message: %v", err)
					d.Nack(false, false)
					return
				}

				if err := s.converter.Convert(ctx, batch); err != nil {
					log.Printf("batch %s failed: %v", batch.Id, err)
					d.Nack(false, true) // requeue
					return
				}

				d.Ack(false)
			}(d)
		}
	}
}

func (s *Subscriber) Close() error {
	if err := s.ch.Close(); err != nil {
		return err
	}
	return s.conn.Close()
}
