package types

import "time"

type Batch struct {
	Id        string    `json:"id"`
	Timestamp time.Time `json:"timestamp"`
}
