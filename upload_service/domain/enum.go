package domain

type Status string

const (
	Queued     Status = "Queued"
	Processing Status = "Processing"
	Completed  Status = "Completed"
	Fail       Status = "Fail"
)
