package config

import (
	"os"

	"strings"

	"github.com/spf13/viper"
)

func LoadConfig(path string) (map[string]string, error) {
	config := map[string]string{}

	d, _ := os.Getwd()
	viper.SetConfigName("app")
	viper.SetConfigType("env")
	viper.AddConfigPath(path)
	viper.AddConfigPath(d)
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		return config, err
	}

	raw := map[string]string{}
	if err := viper.Unmarshal(&raw); err != nil {
		return config, err
	}

	for k, v := range raw {
		config[strings.ToUpper(k)] = v
	}

	return config, nil
}
