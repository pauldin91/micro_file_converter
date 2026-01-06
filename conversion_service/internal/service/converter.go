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
		uploadDir = filepath.Join(filepath.Dir(filepath.Dir(filepath.Dir(cwd))), "uploads")
	}

	return &Converter{
		conf:      conf,
		uploadDir: uploadDir,
		publisher: publisher,
	}, nil
}

func (c *Converter) getUploadDirectoriesForBatch(batchId string) (string, string) {
	inputDir := filepath.Join(c.uploadDir, batchId)
	outputDir := filepath.Join(inputDir, "converted")
	return inputDir, outputDir
}

func (c *Converter) fetchBatchFilenames(batchId string) ([]string, error) {
	inputDir, outputDir := c.getUploadDirectoriesForBatch(batchId)
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return nil, fmt.Errorf("create output dir: %w", err)
	}

	entries, err := os.ReadDir(inputDir)
	if err != nil {
		return nil, fmt.Errorf("read input dir: %w", err)
	}
	filenames := make([]string, len(entries))
	for _, e := range entries {
		if e.IsDir() || strings.EqualFold(filepath.Ext(e.Name()), ".json") {
			continue
		}
		filenames = append(filenames, e.Name())
	}
	return filenames, nil
}

func (c *Converter) Convert(ctx context.Context, batch common.Batch) error {
	inputDir, outputDir := c.getUploadDirectoriesForBatch(batch.Id)
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

		if err := c.convertFile(inputDir, outputDir, e); err != nil {
			return err
		}
	}

	err = c.notifyForCompletion(batch)
	if err != nil {
		log.Printf("batch %s processed successfully", batch.Id)
		return fmt.Errorf("unable to publish for batch %s completion: %v", batch.Id, err.Error())
	}
	log.Printf("batch %s processed successfully", batch.Id)

	return nil
}

func (c *Converter) notifyForCompletion(batch common.Batch) error {
	payload, err := json.Marshal(batch)
	if err != nil {
		return fmt.Errorf("marshal batch: %w", err)
	}

	if err := c.publisher.Publish(payload); err != nil {
		return fmt.Errorf("publish result: %w", err)
	}
	return nil
}

func (c *Converter) convertFile(inputDir, outputDir, filename string) error {
	src := filepath.Join(inputDir, filename)
	base := strings.TrimSuffix(filename, filepath.Ext(filename))
	dst := filepath.Join(outputDir, base+".pdf")

	log.Printf("converting %s -> %s", src, dst)

	cmd := exec.Command("magick", src, dst)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("convert %s: %w", filename, err)
	}

	return nil
}
