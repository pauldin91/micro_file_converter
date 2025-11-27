package config

import (
	"log"
	"os"
	"strings"
	"testing"
)

func TestOverwriteCfg(t *testing.T) {

	var appEnvFile string = "DB_CONN=\"host+localhost user+postgres password+postgres dbname+myapp port+5432 sslmode+disable\"\nHTTP_SERVER_ADDRESS=localhost:8080"

	var lines []string = strings.Split(appEnvFile, "\n")
	for _, i := range lines {
		var key []string = strings.Split(i, "=")
		os.Setenv(key[0], key[1])
	}

	cfg, err := LoadConfig()
	if err != nil {
		log.Println("could load cfg")
	}
	if cfg.DbConn != os.Getenv("DB_CONN") ||
		cfg.HttpServerAddress != os.Getenv("HTTP_SERVER_ADDRESS") {
		t.Errorf("cfg could not be overwritten %s", err)
	}

}
