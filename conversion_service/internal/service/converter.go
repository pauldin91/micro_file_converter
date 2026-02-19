package service

import (
	"common"
	config "common/config"
	"common/messages"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"micro_file_converter/internal/domain"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

type Converter struct {
	conf      config.Config
	uploadDir string
	publisher messages.Publisher
}

func NewConverter(conf config.Config, publisher messages.Publisher) (*Converter, error) {
	uploadDir := conf.Get(domain.UploadDir)
	if uploadDir == "" {
		cwd, err := os.Getwd()
		if err != nil {
			return nil, err
		}
		uploadDir = filepath.Join(filepath.Dir(cwd), "uploads")

	}
	return &Converter{
		conf:      conf,
		uploadDir: uploadDir,
		publisher: publisher,
	}, nil
}

func (c *Converter) getUploadDirectoriesForBatch(batchId string) string {
	inputDir := filepath.Join(c.uploadDir, batchId)
	return inputDir
}

func (c *Converter) fetchBatchFilenames(batchId string) ([]string, error) {
	inputDir := c.getUploadDirectoriesForBatch(batchId)
	if err := os.MkdirAll(filepath.Join(inputDir, "converted"), 0755); err != nil {
		return nil, fmt.Errorf("create output dir: %w", err)
	}
	entries, err := os.ReadDir(inputDir)
	if err != nil {
		return nil, fmt.Errorf("read input dir: %w", err)
	}
	filenames := make([]string, 0, len(entries))
	for _, e := range entries {
		if e.IsDir() || strings.EqualFold(filepath.Ext(e.Name()), ".json") {
			continue
		}
		filenames = append(filenames, filepath.Join(inputDir, e.Name()))
	}
	return filenames, nil
}

func (c *Converter) Convert(ctx context.Context, batch common.Batch) error {
	filenames, err := c.fetchBatchFilenames(batch.Id)
	if err != nil {
		return fmt.Errorf("unable to fetch Batch Filenames %v", err.Error())
	}
	for _, e := range filenames {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}
		if err := c.convertFile(e); err != nil {
			log.Printf("error %v converting the file %v\n", err, e)
			return err
		}
	}
	err = c.notifyForCompletion(batch)
	if err != nil {
		log.Printf("failed to notify completion for batch %s", batch.Id)
		return fmt.Errorf("unable to publish for batch %s completion: %v", batch.Id, err.Error())
	}
	return nil
}

func (c *Converter) notifyForCompletion(batch common.Batch) error {
	dto := common.Result{
		Id:        batch.Id,
		Timestamp: time.Now().UTC(),
		Status:    "Completed",
	}
	payload, _ := json.Marshal(dto)
	if err := c.publisher.Publish(payload); err != nil {
		return fmt.Errorf("publish result: %w", err)
	}
	return nil
}

func (c *Converter) convertFile(filename string) error {
	dir := filepath.Dir(filename)
	base := strings.TrimSuffix(filepath.Base(filename), filepath.Ext(filename))
	dst := filepath.Join(dir, "converted", base+".pdf")
	cmd := exec.Command("magick", filename, dst)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("conversion error %v: %v", filename, err)
	}
	return nil
}
