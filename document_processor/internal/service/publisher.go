package service

import (
	"context"
	"micro_file_converter/internal/config"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Publisher struct {
	conn  *amqp.Connection
	ch    *amqp.Channel
	queue string
}

func NewPublisher(cfg config.Config) (*Publisher, error) {
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
		cfg.ProcessedQueue,
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

	return &Publisher{
		conn:  conn,
		ch:    ch,
		queue: cfg.ProcessedQueue,
	}, nil
}

func (p *Publisher) Publish(body []byte) error {
	return p.ch.PublishWithContext(
		context.Background(),
		"",
		p.queue,
		false,
		false,
		amqp.Publishing{
			ContentType: "application/json",
			Body:        body,
		},
	)
}

func (p *Publisher) Close() error {
	if err := p.ch.Close(); err != nil {
		return err
	}
	return p.conn.Close()
}
