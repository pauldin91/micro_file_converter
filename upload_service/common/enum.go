package common

type Status string

const (
	Queued Status = "Queued"

	Processing = "Processing"
	Completed  = "Completed"

	Fail = "Fail"
)
