package main

import (
	"common"
	"context"
	"encoding/json"
	"log"
	"os"
	"path"
	"path/filepath"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

func failOnError(err error, msg string) {
	if err != nil {
		log.Panicf("%s: %s", msg, err)
	}
}

func main() {

	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
	failOnError(err, "Failed to connect to RabbitMQ")
	defer conn.Close()
	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"hello_Q", // name
		false,     // durable
		false,     // delete when unused
		false,     // exclusive
		false,     // no-wait
		nil,       // arguments
	)
	failOnError(err, "Failed to declare a queue")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	batch := common.Batch{Id: "certain_test", Timestamp: time.Now()}
	l, _ := os.Getwd()

	dir := path.Join(filepath.Dir(l), "uploads", "tests", batch.Id)
	err = os.MkdirAll(dir, 0755)
	failOnError(err, "Failed to create uploads test folders")

	body, _ := json.Marshal(batch)
	err = ch.PublishWithContext(ctx,
		"",     // exchange
		q.Name, // routing key
		false,  // mandatory
		false,  // immediate
		amqp.Publishing{
			ContentType: "text/plain",
			Body:        body,
		})

	failOnError(err, "Failed to publish a message")
	log.Printf(" [x] Sent %s\n", body)
}
