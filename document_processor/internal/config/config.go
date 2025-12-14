package config

import (
	"fmt"
	"os"

	"github.com/spf13/viper"
)

type Config struct {
	RabbitMQHost   string `mapstructure:"RABBITMQ_HOST"`
	PendingQueue   string `mapstructure:"PENDING_QUEUE"`
	ProcessedQueue string `mapstructure:"PROCESSED_QUEUE"`
	UploadData     string `mapstructure:"UPLOAD_DATA_VOLUME"`
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
