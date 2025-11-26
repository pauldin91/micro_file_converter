package utils

import "github.com/spf13/viper"

type Config struct {
	Environment       string `mapstructure:"ENVIRONMENT"`
	DbConn            string `mapstructure:"DB_CONN"`
	HttpServerAddress string `mapstructure:"HTTP_SERVER_ADDRESS"`
	Amqp              string `mapstructure:"AMQP"`
	BatchQueue        string `mapstructure:"BATCH_QUEUE"`
}

func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("app")
	viper.SetConfigType("env")
	viper.AutomaticEnv()

	err = viper.ReadInConfig()
	if err != nil {
		return
	}

	err = viper.Unmarshal(&config)
	return
}
