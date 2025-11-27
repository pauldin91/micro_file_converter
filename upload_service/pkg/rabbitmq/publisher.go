package rabbitmq

import (
	"webapi/common"
	"webapi/internal/config"

	amqp "github.com/rabbitmq/amqp091-go"
	"github.com/rs/zerolog/log"
)

type Publisher struct {
	conn    *amqp.Connection
	channel *amqp.Channel
	queue   string

	receiver chan string
}

func NewPublisher(cfg config.Config, receiver chan string) *Publisher {
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
		channel:  ch,
		conn:     conn,
		queue:    cfg.BatchQueue,
		receiver: receiver,
	}
}

func (pub *Publisher) Publish(msg string) {
	err := pub.channel.Publish("", // exchange
		pub.queue, // routing key
		false,     // mandatory
		false,     // immediate
		amqp.Publishing{
			ContentType: "text/plain",
			Body:        []byte(msg),
		})
	if err != nil {
		log.Error().Msgf("unable to send msg to broker: %s\n", err.Error())
	}
}
