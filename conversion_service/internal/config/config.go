package config

import (
	"fmt"
	"os"

	"github.com/spf13/viper"
)

type Config struct {
	RabbitMQHost    string `mapstructure:"RABBITMQ_HOST"`
	ConversionQueue string `mapstructure:"CONVERSION_QUEUE"`
	ProcessedQueue  string `mapstructure:"PROCESSED_QUEUE"`
	UploadDir       string `mapstructure:"UPLOAD_DIR"`
}

func LoadConfig() (Config, error) {
	d, _ := os.Getwd()
	fmt.Printf("Current dir is : %s\n", d)
	viper.SetConfigName("app")
	viper.SetConfigType("env")
	viper.AddConfigPath("../..")
	viper.AddConfigPath(d)
	viper.AutomaticEnv()

	var config Config
	err := viper.ReadInConfig()
	if err != nil {
		return config, err
	}

	err = viper.Unmarshal(&config)

	return config, err
}
