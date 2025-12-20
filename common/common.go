package common

import (
	"common/pkg/config"
	"common/pkg/messages"
	"common/pkg/types"
)

type Config config.Config
type RabbitMQSubscriber messages.RabbitMQSubscriber
type RabbitMQPublisher messages.RabbitMQPublisher
type Publisher messages.Publisher
type Batch types.Batch
