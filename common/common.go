package common

import (
	"common/config"
	"common/messages"
	"common/types"
)

type Config config.Config
type RabbitMQSubscriber messages.RabbitMQSubscriber
type RabbitMQPublisher messages.RabbitMQPublisher
type Publisher messages.Publisher
type Batch types.Batch
type Result types.Result
