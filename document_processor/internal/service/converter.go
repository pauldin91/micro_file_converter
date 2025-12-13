package service

import (
	"common"
	"encoding/json"
	"log"
	"micro_file_converter/internal/config"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
	"sync"
)

type Converter struct {
	errors    chan error
	wg        *sync.WaitGroup
	conf      config.Config
	uploadDir string
	publisher *Publisher
}

func NewConverter(conf config.Config, publisher *Publisher) *Converter {
	var uploadDir string = conf.UploadData
	if len(conf.UploadData) == 0 {
		cwd, _ := os.Getwd()
		uploadDir = filepath.Join(filepath.Dir(filepath.Dir(filepath.Dir(cwd))), "uploads")
	}
	return &Converter{
		errors:    make(chan error),
		wg:        &sync.WaitGroup{},
		conf:      conf,
		uploadDir: uploadDir,
		publisher: publisher,
	}
}

func (w *Converter) convert(batch common.Batch, doneChan chan bool, errs chan error) {

	dir := path.Join(w.uploadDir, batch.Id)
	outputDir := path.Join(dir, "converted")
	os.MkdirAll(outputDir, 0755)
	files, err := os.ReadDir(dir)
	if err != nil {
		w.errors <- err
		log.Printf("Error reading dir: %s\n", err.Error())
	}

	var status string = "completed"
	for _, f := range files {
		if !f.IsDir() && strings.ToLower(path.Ext(f.Name())) != ".json" {
			log.Printf("Received a message: %s\n", path.Join(outputDir, f.Name()))
			cmd := exec.Command("convert", path.Join(dir, f.Name()), path.Join(outputDir, strings.Split(f.Name(), ".")[0]+".pdf"))
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			if err := cmd.Run(); err != nil {
				log.Printf("Error: %s\n", err.Error())
				status = "failed"
				break
			}
		}

	}
	serialized, _ := json.Marshal(common.Batch{
		Id:     batch.Id,
		Status: status,
	})
	log.Printf("Batch %s converted with status %s\n", batch.Id, status)

	err = w.publisher.Publish(serialized)
	if err != nil {
		log.Printf("Error publishing message: %s\n", err.Error())
		doneChan <- false
		errs <- err
	} else {
		doneChan <- true
	}

}
