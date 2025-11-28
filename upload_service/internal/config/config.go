package config

import (
	"fmt"
	"os"

	"github.com/spf13/viper"
)

type Config struct {
	Environment       string `mapstructure:"ENVIRONMENT"`
	DbConn            string `mapstructure:"DB_SOURCE"`
	HttpServerAddress string `mapstructure:"HTTP_SERVER_ADDRESS"`
	Amqp              string `mapstructure:"AMQP"`
	BatchQueue        string `mapstructure:"BATCH_QUEUE"`
}

func LoadConfig() (config Config, err error) {

	d, err := os.Getwd()
	fmt.Printf("Current dir is : %s\n", d)
	viper.SetConfigName("app")
	viper.SetConfigType("env")
	viper.AddConfigPath(d)
	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
