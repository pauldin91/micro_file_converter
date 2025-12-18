package messages

type Publisher interface {
	Publish(body []byte) error
	Close() error
}
