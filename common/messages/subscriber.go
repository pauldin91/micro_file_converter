package messages

import "context"

type Subscriber interface {
	Start(ctx context.Context) error
	SetConsumeHandler(func([]byte) error)
	Close() error
}
