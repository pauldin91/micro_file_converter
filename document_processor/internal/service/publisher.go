package service

import (
	"common/pkg/types"
	"micro_file_converter/internal/config"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Publisher struct {
	conn  *amqp.Connection
	ch    *amqp.Channel
	queue string
}

func NewPublisher(cfg config.Config) *Publisher {
	conn, err := amqp.Dial(cfg.RabbitMQHost)
	types.FailOnError(err, "Failed to connect to RabbitMQ")

	ch, err := conn.Channel()
	types.FailOnError(err, "Failed to open a channel")

	_, err = ch.QueueDeclare(
		cfg.ProcessedQueue, // name
		true,               // durable
		false,              // delete when unused
		false,              // exclusive
		false,              // no-wait
		nil,                // arguments
	)
	types.FailOnError(err, "Failed to declare a queue")

	return &Publisher{
		conn:  conn,
		ch:    ch,
		queue: cfg.ProcessedQueue,
	}
}

func (p *Publisher) Publish(msg []byte) error {

	return p.ch.Publish(
		"",
		p.queue,
		false,
		false,
		amqp.Publishing{
			ContentType: "application/json",
			Body:        msg,
		})

}
