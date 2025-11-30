package rabbitmq

import (
	"context"
	"encoding/json"
	"time"
	"webapi/internal/config"

	amqp "github.com/rabbitmq/amqp091-go"
	"github.com/rs/zerolog/log"
)

type Publisher struct {
	conn    *amqp.Connection
	channel *amqp.Channel
	queue   amqp.Queue
}

func NewPublisher(cfg config.Config) *Publisher {
	log.Info().Msgf("MQ address is: %s\n", cfg.Amqp)
	conn, err := amqp.Dial(cfg.Amqp)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to connect to RabbitMQ")
	}

	ch, err := conn.Channel()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to open a channel")
	}

	q, err := ch.QueueDeclare(
		cfg.BatchQueue,
		true, // durable
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to declare a queue")
	}

	return &Publisher{
		conn:    conn,
		channel: ch,
		queue:   q,
	}
}

func (p *Publisher) Publish(v any) {
	body, err := json.Marshal(v)
	if err != nil {
		log.Error().Err(err).Msg("Unable to serialize event")
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = p.channel.PublishWithContext(
		ctx,
		"",           // exchange
		p.queue.Name, // routing key
		false,
		false,
		amqp.Publishing{
			ContentType:  "application/json",
			Body:         body,
			DeliveryMode: amqp.Persistent, // survive restarts
		},
	)
	if err != nil {
		log.Error().Err(err).Msg("Unable to publish message")
	}
}

func (p *Publisher) Close() {
	p.channel.Close()
	p.conn.Close()
}
