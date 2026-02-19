package messages

import (
	"context"
	"sync"

	amqp "github.com/rabbitmq/amqp091-go"
)

type RabbitMQSubscriber struct {
	conn                   *amqp.Connection
	ch                     *amqp.Channel
	queue                  string
	prefetchCount          int
	requeueMessagesOnError bool
	handler                func(body []byte) error
}

func NewRabbitMQSubscriber(addr, queue string, prefetchCount int, requeueMessagesOnError bool) (*RabbitMQSubscriber, error) {
	conn, err := amqp.Dial(addr)
	if err != nil {
		return nil, err
	}

	ch, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, err
	}

	if _, err := ch.QueueDeclare(
		queue,
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

	if err := ch.Qos(prefetchCount, 0, false); err != nil {
		ch.Close()
		conn.Close()
		return nil, err
	}

	return &RabbitMQSubscriber{
		conn:                   conn,
		ch:                     ch,
		queue:                  queue,
		prefetchCount:          prefetchCount,
		requeueMessagesOnError: requeueMessagesOnError,
		handler:                func([]byte) error { return nil },
	}, nil
}

func (s *RabbitMQSubscriber) SetConsumeHandler(consumeHandler func(body []byte) error) {
	s.handler = consumeHandler
}

func (s *RabbitMQSubscriber) Start(ctx context.Context) error {
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
	sem := make(chan struct{}, s.prefetchCount)

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
				if err := s.handler(d.Body); err != nil {
					d.Nack(false, s.requeueMessagesOnError)
					return
				}

				d.Ack(false)
			}(d)
		}
	}
}

func (s *RabbitMQSubscriber) Close() error {
	if err := s.ch.Close(); err != nil {
		return err
	}
	return s.conn.Close()
}
