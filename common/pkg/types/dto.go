package types

import "time"

type File struct {
	Name string `json:"filename"`
	Size int64  `json:"size"`
	Type string `json:"content_type"`
}

type Batch struct {
	Id        string    `json:"batch_id"`
	Timestamp time.Time `json:"timestamp"`
	Files     []File    `json:"files"`
	Transform string    `json:"transform"`
}
