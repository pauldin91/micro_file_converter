package types

import "time"

type File struct {
	Name string `json:"filename"`
	Size int64  `json:"size"`
	Type string `json:"content_type"`
}

type Transform struct {
	Name  string            `json:"name"`
	Props map[string]string `json:"props"`
}

type Batch struct {
	Id        string    `json:"id"`
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Files     []File    `json:"files"`
	Transform Transform `json:"transform"`
}
