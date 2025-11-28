package rabbitmq

import (
	"encoding/json"
	"webapi/common"
	"webapi/internal/config"

	amqp "github.com/rabbitmq/amqp091-go"
	"github.com/rs/zerolog/log"
)

type Publisher struct {
	conn    *amqp.Connection
	channel *amqp.Channel
	queue   string
}

func NewPublisher(cfg config.Config) *Publisher {
	conn, err := amqp.Dial(cfg.Amqp)
	common.FailOnError(err, "Failed to connect to RabbitMQ")
	ch, err := conn.Channel()
	common.FailOnError(err, "Failed to open a channel")

	_, err = ch.QueueDeclare(
		cfg.BatchQueue, // name
		false,          // durable
		false,          // delete when unused
		false,          // exclusive
		false,          // no-wait
		nil,            // arguments
	)

	common.FailOnError(err, "Failed to declare a queue")
	return &Publisher{
		channel: ch,
		conn:    conn,
		queue:   cfg.BatchQueue,
	}
}

func (pub *Publisher) Publish(msg any) {
	body, err := json.Marshal(msg)
	if err != nil {
		log.Error().Msgf("nable to serialize event %s\n", err.Error())
		return
	}
	err = pub.channel.Publish("", // exchange
		pub.queue, // routing key
		false,     // mandatory
		false,     // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        []byte(body),
		})
	if err != nil {
		log.Error().Msgf("unable to send msg to broker: %s\n", err.Error())
	}
}
