package service

import (
	"common"
	"common/pkg/types"
	"encoding/json"
	"log"
	"micro_file_converter/internal/config"
	"sync"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Subscriber struct {
	conn      *amqp.Connection
	ch        *amqp.Channel
	queue     string
	wg        *sync.WaitGroup
	converter *Converter
}

func NewSubscriber(cfg config.Config, converter *Converter) *Subscriber {
	conn, err := amqp.Dial(cfg.RabbitMQHost)
	types.FailOnError(err, "Failed to connect to RabbitMQ")

	ch, err := conn.Channel()
	types.FailOnError(err, "Failed to open a channel")

	_, err = ch.QueueDeclare(
		cfg.PendingQueue, // name
		true,             // durable
		false,            // delete when unused
		false,            // exclusive
		false,            // no-wait
		nil,              // arguments
	)
	types.FailOnError(err, "Failed to declare a queue")

	return &Subscriber{
		conn:      conn,
		ch:        ch,
		queue:     cfg.PendingQueue,
		wg:        &sync.WaitGroup{},
		converter: converter,
	}
}

func (s *Subscriber) Start() {
	s.wg.Add(1)

	go func() {
		defer s.wg.Done()

		msgs, err := s.ch.Consume(
			s.queue, // queue
			"",      // consumer
			true,    // auto-ack
			false,   // exclusive
			false,   // no-local
			false,   // no-wait
			nil,     // args
		)
		types.FailOnError(err, "Failed to register a consumer")

		doneChan := make(chan bool, len(msgs))
		errorChan := make(chan error)

		for d := range msgs {
			var batch common.Batch
			json.Unmarshal(d.Body, &batch)
			go s.converter.convert(batch, doneChan, errorChan)
		}

		for e := range errorChan {
			log.Printf("Published message: %s", e)
		}

	}()

	s.wg.Wait()
}
