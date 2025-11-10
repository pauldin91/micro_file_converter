package utils

import "github.com/spf13/viper"

type Config struct {
	RabbitMQHost string `mapstructure:"RABBITMQ_HOST"`
	BatchQueue   string `mapstructure:"BATCH_QUEUE"`
}

func LoadConfig(path string) (Config, error) {
	viper.AddConfigPath(path)
	viper.SetConfigName("app")
	viper.SetConfigType("env")
	viper.AutomaticEnv()

	var config Config
	err := viper.ReadInConfig()
	if err != nil {
		return config, err
	}

	err = viper.Unmarshal(&config)

	return config, err
}
