package tests

import (
	"log"
	"micro_file_converter/internal/config"
	"os"
	"strings"
	"testing"
)

func TestOverwriteCfg(t *testing.T) {
	var appEnvFile string = "RABBITMQ_HOST=amqp://guest:guest@rabbit:5672/\nBATCH_QUEUE=Q"
	var lines []string = strings.Split(appEnvFile, "\n")
	for _, i := range lines {
		var key []string = strings.Split(i, "=")
		os.Setenv(key[0], key[1])
	}
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Println("could load cfg")
	}
	if cfg.RabbitMQHost != "amqp://guest:guest@rabbit:5672/" ||
		cfg.ConversionQueue != "Q" {
		t.Errorf("cfg could not be overwritten %s", err)
	}

}
