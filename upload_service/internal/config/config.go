package config

import (
	"fmt"
	"os"
	"runtime"
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	Environment       string `mapstructure:"ENVIRONMENT"`
	DbConn            string `mapstructure:"DATABASE_URL"`
	HttpServerAddress string `mapstructure:"HTTP_SERVER_ADDRESS"`
	RabbitMQHost      string `mapstructure:"RABBITMQ_HOST"`
	ConversionQueue   string `mapstructure:"CONVERSION_QUEUE"`
	MigrationsDir     string `mapstructure:"MIGRATIONS_DIR"`
	UploadDir         string `mapstructure:"UPLOAD_DIR"`
}

func IsUnderDebugger() bool {
	for _, pc := range make([]uintptr, 32) {
		f := runtime.FuncForPC(pc)
		if f != nil && strings.Contains(f.Name(), "debug") {
			return true
		}
	}
	return false
}
func LoadConfig() (Config, error) {
	var config Config
	var d string
	var err error

	d, _ = os.Getwd()
	fmt.Printf("Current dir is : %s\n", d)
	viper.SetConfigName("app")
	viper.SetConfigType("env")
	viper.AddConfigPath("../..")
	viper.AddConfigPath(d)
	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return config, err
	}

	err = viper.Unmarshal(&config)
	return config, err
}
