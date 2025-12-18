package messages

import (
	"context"

	amqp "github.com/rabbitmq/amqp091-go"
)

type RabbitMQPublisher struct {
	conn  *amqp.Connection
	ch    *amqp.Channel
	queue string
}

func NewRabbitMQPublisher(addr, queue string) (*RabbitMQPublisher, error) {
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

	return &RabbitMQPublisher{
		conn:  conn,
		ch:    ch,
		queue: queue,
	}, nil
}

func (p *RabbitMQPublisher) Publish(body []byte) error {
	return p.ch.PublishWithContext(
		context.Background(),
		"",
		p.queue,
		false,
		false,
		amqp.Publishing{
			ContentType:  "application/json",
			Body:         body,
			DeliveryMode: amqp.Persistent,
		},
	)
}

func (p *RabbitMQPublisher) Close() error {
	if err := p.ch.Close(); err != nil {
		return err
	}
	return p.conn.Close()
}
