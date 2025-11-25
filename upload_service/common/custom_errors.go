package common

import "github.com/rs/zerolog/log"

func FailOnError(err error, msg string) {
	if err != nil {
		log.Panic().Msgf("%s: %s", msg, err)
	}
}
