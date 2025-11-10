package service

import (
	"encoding/json"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"sync"

	"micro_file_converter/internal/utils"
	dto "micro_file_converter/pkg/types"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Worker struct {
	errors chan error
	wg     *sync.WaitGroup
	conf   utils.Config
}

func NewWorker(conf utils.Config) *Worker {
	return &Worker{
		errors: make(chan error),
		wg:     &sync.WaitGroup{},
		conf:   conf,
	}
}

func (w *Worker) Start() {
	w.wg.Add(1)

	go func() {
		defer w.wg.Done()

		conn, err := amqp.Dial(w.conf.RabbitMQHost)
		failOnError(err, "Failed to connect to RabbitMQ")
		defer conn.Close()

		ch, err := conn.Channel()
		failOnError(err, "Failed to open a channel")
		defer ch.Close()

		q, err := ch.QueueDeclare(
			w.conf.BatchQueue, // name
			false,             // durable
			false,             // delete when unused
			false,             // exclusive
			false,             // no-wait
			nil,               // arguments
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
			var batch dto.Batch
			json.Unmarshal(d.Body, &batch)
			go w.convert(batch)
		}

	}()
	go w.handle()

	w.wg.Wait()

}

func (w *Worker) convert(batch dto.Batch) {
	l, _ := os.Getwd()
	dir := path.Join(filepath.Dir(filepath.Dir(l)), "data", batch.Id)
	outputDir := path.Join(dir, "converted")
	os.MkdirAll(outputDir, 0755)
	files, err := os.ReadDir(dir)
	if err != nil {
		w.errors <- err
		log.Printf("Error reading dir: %s\n", err.Error())
	}

	for _, f := range files {
		log.Printf("Received a message: %s\n", path.Join(outputDir, f.Name()))
		cmd := exec.Command("libreoffice", "--headless", "--convert-to", "pdf", "--outdir", outputDir, path.Join(dir, f.Name()))
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			log.Printf("Error: %s\n", err.Error())
		}

	}

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
