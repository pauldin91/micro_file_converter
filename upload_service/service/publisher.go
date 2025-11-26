package service

import (
	"context"
	"webapi/common"

	amqp "github.com/rabbitmq/amqp091-go"
	"github.com/rs/zerolog/log"
)

type Publisher struct {
	addr    string
	queue   string
	channel *amqp.Channel

	receiver chan string
}

func NewPublisher(addr, queue string, receiver chan string) *Publisher {
	return &Publisher{
		addr:     addr,
		queue:    queue,
		receiver: receiver,
	}
}

func (pub *Publisher) Start(ctx context.Context) {
	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")

	common.FailOnError(err, "Failed to connect to RabbitMQ")
	defer conn.Close()

	ch, err := conn.Channel()
	common.FailOnError(err, "Failed to open a channel")
	defer ch.Close()

	_, err = ch.QueueDeclare(
		pub.queue, // name
		false,     // durable
		false,     // delete when unused
		false,     // exclusive
		false,     // no-wait
		nil,       // arguments
	)

	common.FailOnError(err, "Failed to declare a queue")
	pub.channel = ch

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
