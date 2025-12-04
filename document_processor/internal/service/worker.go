package service

import (
	"common"
	"common/pkg/types"
	"encoding/json"
	"log"
	"micro_file_converter/internal/config"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"sync"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Worker struct {
	errors    chan error
	wg        *sync.WaitGroup
	conf      config.Config
	uploadDir string
}

func NewWorker(conf config.Config) *Worker {
	var uploadDir string = conf.UploadData
	if len(conf.UploadData) == 0 {
		cwd, _ := os.Getwd()
		uploadDir = filepath.Join(filepath.Dir(filepath.Dir(filepath.Dir(cwd))), "uploads")
	}
	return &Worker{
		errors:    make(chan error),
		wg:        &sync.WaitGroup{},
		conf:      conf,
		uploadDir: uploadDir,
	}
}

func (w *Worker) Start() {
	w.wg.Add(1)

	go func() {
		defer w.wg.Done()

		conn, err := amqp.Dial(w.conf.RabbitMQHost)
		types.FailOnError(err, "Failed to connect to RabbitMQ")
		defer conn.Close()

		ch, err := conn.Channel()
		types.FailOnError(err, "Failed to open a channel")
		defer ch.Close()

		q, err := ch.QueueDeclare(
			w.conf.BatchQueue, // name
			true,              // durable
			false,             // delete when unused
			false,             // exclusive
			false,             // no-wait
			nil,               // arguments
		)
		types.FailOnError(err, "Failed to declare a queue")

		msgs, err := ch.Consume(
			q.Name, // queue
			"",     // consumer
			true,   // auto-ack
			false,  // exclusive
			false,  // no-local
			false,  // no-wait
			nil,    // args
		)
		types.FailOnError(err, "Failed to register a consumer")

		log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
		for d := range msgs {
			var batch common.Batch
			json.Unmarshal(d.Body, &batch)
			go w.convert(batch)
		}

	}()

	w.wg.Wait()

}

func (w *Worker) convert(batch common.Batch) {

	dir := path.Join(w.uploadDir, batch.Id)
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
