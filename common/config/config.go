package config

import (
	"os"

	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	cfg map[string]string
}

func NewConfig() Config {
	return Config{
		cfg: map[string]string{},
	}
}

func (c *Config) Get(varName string) string {
	return c.cfg[varName]
}

func (c *Config) LoadConfig(path string) error {

	d, _ := os.Getwd()
	viper.SetConfigName("app")
	viper.SetConfigType("env")
	viper.AddConfigPath(path)
	viper.AddConfigPath(d)
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		return err
	}

	if err := viper.Unmarshal(&c.cfg); err != nil {
		return err
	}

	for k, v := range c.cfg {
		c.cfg[strings.ToUpper(k)] = v
	}
	return nil
}
