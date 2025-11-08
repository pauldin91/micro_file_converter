package service

import (
	"log"
	"sync"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Worker struct {
	errors chan error
	wg     *sync.WaitGroup
}

func NewWorker() *Worker {
	return &Worker{
		errors: make(chan error),
		wg:     &sync.WaitGroup{},
	}
}

func (w *Worker) Start() {
	w.wg.Add(1)

	go func() {
		defer w.wg.Done()

		conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
		failOnError(err, "Failed to connect to RabbitMQ")
		defer conn.Close()

		ch, err := conn.Channel()
		failOnError(err, "Failed to open a channel")
		defer ch.Close()

		q, err := ch.QueueDeclare(
			"hello", // name
			false,   // durable
			false,   // delete when unused
			false,   // exclusive
			false,   // no-wait
			nil,     // arguments
		)
		failOnError(err, "Failed to declare a queue")

		msgs, err := ch.Consume(
			q.Name, // queue
			"",     // consumer
			true,   // auto-ack
			false,  // exclusive
			false,  // no-local
			false,  // no-wait
			nil,    // args
		)
		failOnError(err, "Failed to register a consumer")

		log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
		for d := range msgs {
			log.Printf("Received a message: %s", d.Body)
		}

	}()
	go w.handle()

	w.wg.Wait()

}

func (w *Worker) handle() {
	for {
		select {
		case err := <-w.errors:
			log.Printf("error %v\n", err)
		}
	}
}

func failOnError(err error, msg string) {
	if err != nil {
		log.Panicf("%s: %s", msg, err)
	}
}
