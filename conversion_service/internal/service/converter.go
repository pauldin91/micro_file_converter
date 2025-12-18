package service

import (
	"common"
	"common/pkg/messages"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"micro_file_converter/internal/config"
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
	uploadDir := conf.UploadDir
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

func (c *Converter) Convert(ctx context.Context, batch common.Batch) error {
	inputDir := filepath.Join(c.uploadDir, batch.Id)
	outputDir := filepath.Join(inputDir, "converted")

	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("create output dir: %w", err)
	}

	entries, err := os.ReadDir(inputDir)
	if err != nil {
		return fmt.Errorf("read input dir: %w", err)
	}

	for _, e := range entries {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}

		if e.IsDir() || strings.EqualFold(filepath.Ext(e.Name()), ".json") {
			continue
		}

		if err := c.convertFile(inputDir, outputDir, e.Name()); err != nil {
			return err
		}
	}

	payload, err := json.Marshal(batch)
	if err != nil {
		return fmt.Errorf("marshal batch: %w", err)
	}

	if err := c.publisher.Publish(payload); err != nil {
		return fmt.Errorf("publish result: %w", err)
	}

	log.Printf("batch %s processed successfully", batch.Id)
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
