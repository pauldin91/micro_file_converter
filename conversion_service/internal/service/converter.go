package service

import (
	"common"
	config "common/config"
	"common/messages"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"micro_file_converter/internal/domain"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// batchStatus values sent to the result queue.
const (
	statusCompleted = "Completed"
	statusFailed    = "Failed"
)

type Converter struct {
	conf      config.Config
	uploadDir string
	publisher messages.Publisher
	logger    *slog.Logger
}

func NewConverter(conf config.Config, publisher messages.Publisher, logger *slog.Logger) (*Converter, error) {
	if logger == nil {
		logger = slog.Default()
	}

	uploadDir := conf.Get(domain.UploadDir)
	if uploadDir == "" {
		cwd, err := os.Getwd()
		if err != nil {
			return nil, fmt.Errorf("resolve working directory: %w", err)
		}
		uploadDir = filepath.Join(filepath.Dir(cwd), "uploads")
	}

	return &Converter{
		conf:      conf,
		uploadDir: uploadDir,
		publisher: publisher,
		logger:    logger,
	}, nil
}

func (c *Converter) Convert(ctx context.Context, batch common.Batch) error {
	log := c.logger.With(slog.String("batch_id", batch.Id))

	filenames, err := c.prepareAndListFiles(batch.Id)
	if err != nil {
		return fmt.Errorf("prepare batch %s: %w", batch.Id, err)
	}

	var conversionErrs []error
	for _, filename := range filenames {
		if err := ctx.Err(); err != nil {
			return err
		}

		if err := c.convertFile(ctx, filename); err != nil {
			log.Error("file conversion failed", slog.String("file", filename), slog.Any("error", err))
			conversionErrs = append(conversionErrs, err)
		}
	}

	status := statusCompleted
	if len(conversionErrs) > 0 {
		status = statusFailed
	}

	if err := c.publishResult(ctx, batch, status); err != nil {
		return fmt.Errorf("publish result for batch %s: %w", batch.Id, err)
	}

	if len(conversionErrs) > 0 {
		return fmt.Errorf("batch %s had %d conversion error(s): %w", batch.Id, len(conversionErrs), errors.Join(conversionErrs...))
	}

	return nil
}

func (c *Converter) prepareAndListFiles(batchID string) ([]string, error) {
	inputDir := filepath.Join(c.uploadDir, batchID)
	outputDir := filepath.Join(inputDir, "converted")

	if err := os.MkdirAll(outputDir, 0o755); err != nil {
		return nil, fmt.Errorf("create output directory %q: %w", outputDir, err)
	}

	entries, err := os.ReadDir(inputDir)
	if err != nil {
		return nil, fmt.Errorf("read input directory %q: %w", inputDir, err)
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

func (c *Converter) convertFile(ctx context.Context, filename string) error {
	dir := filepath.Dir(filename)
	base := strings.TrimSuffix(filepath.Base(filename), filepath.Ext(filename))
	dst := filepath.Join(dir, "converted", base+".pdf")

	var stdout, stderr strings.Builder
	cmd := exec.CommandContext(ctx, "magick", filename, dst)
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("magick %q → %q: %w (stderr: %s)", filename, dst, err, stderr.String())
	}

	return nil
}

func (c *Converter) publishResult(ctx context.Context, batch common.Batch, status string) error {
	dto := common.Result{
		Id:        batch.Id,
		Timestamp: time.Now().UTC(),
		Status:    status,
	}

	payload, err := json.Marshal(dto)
	if err != nil {
		return fmt.Errorf("marshal result: %w", err)
	}

	return c.publisher.Publish(ctx, payload)
}
