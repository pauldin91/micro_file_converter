package background

import (
	"context"
	"os"
	"os/signal"
	"syscall"
	"webapi/common"
	"webapi/utils"

	amqp "github.com/rabbitmq/amqp091-go"
	"github.com/rs/zerolog/log"
)

type Publisher struct {
	addr    string
	queue   string
	channel *amqp.Channel

	receiver chan string
}

func NewPublisher(cfg utils.Config, receiver chan string) *Publisher {
	return &Publisher{
		addr:     cfg.Amqp,
		queue:    cfg.BatchQueue,
		receiver: receiver,
	}
}

func (pub *Publisher) Start(ctx context.Context) error {

	conn, err := amqp.Dial(pub.addr)

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

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	log.Info().Msgf("Started publisher at : %s\n", pub.addr)

	sig := <-quit
	log.Info().Msgf("Received : %s\n", sig)

	return nil

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
