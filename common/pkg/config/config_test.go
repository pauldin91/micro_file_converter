package config

import (
	"log"
	"os"
	"path"
	"strings"
	"testing"
)

var dirs []string = []string{
	".",
	"../../../upload_service",
	"../../../conversion_service",
}

const (
	envFilename string = "app.env"
	rabbitHost  string = "RABBITMQ_HOST"
	convQueue   string = "CONVERSION_QUEUE"
)

func TestLoadFromDirectories(t *testing.T) {
	for _, d := range dirs {
		extectedLoadHelper(t, path.Join(d, envFilename))
		actualLoadHelper(t, d)
	}
}

func TestOverwriteCfg(t *testing.T) {

	var appEnvFile string = "RABBITMQ_HOST=local.rabbit\nCONVERSION_QUEUE=local.queue"

	var lines []string = strings.Split(appEnvFile, "\n")
	for _, i := range lines {
		var key []string = strings.Split(i, "=")
		os.Setenv(key[0], key[1])
	}

	actualLoadHelper(t, ".")

}

func extectedLoadHelper(t *testing.T, envFilename string) {
	file, err := os.ReadFile(envFilename)
	if err != nil {
		t.Errorf("file app.env not found : %v\n", err.Error())
		return
	}
	var appEnvFile string = strings.Trim(string(file), "\n")

	var lines []string = strings.Split(appEnvFile, "\n")
	for _, i := range lines {
		var key []string = strings.Split(i, "=")
		if len(key) == 1 {
			key = append(key, "")
		}
		os.Setenv(key[0], key[1])
	}
}

func actualLoadHelper(t *testing.T, envDirectory string) {
	cfg, err := LoadConfig(envDirectory)
	if err != nil {
		log.Println("could load cfg")
	}
	if cfg[rabbitHost] != os.Getenv("RABBITMQ_HOST") ||
		cfg[convQueue] != os.Getenv("CONVERSION_QUEUE") {
		t.Errorf("cfg could not be overwritten %s", err)
	}
}
