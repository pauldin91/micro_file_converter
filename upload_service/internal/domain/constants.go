package domain

const (
	ApiRoot         string = "/api"
	UploadEndpoint  string = ApiRoot + "/uploads"
	SwaggerEndpoint string = "/swagger/*"
)

const (
	Environment       string = "ENVIRONMENT"
	DbConn            string = "DATABASE_URL"
	HttpServerAddress string = "HTTP_SERVER_ADDRESS"
	RabbitMQHost      string = "RABBITMQ_HOST"
	ConversionQueue   string = "CONVERSION_QUEUE"
	MigrationsDir     string = "MIGRATIONS_DIR"
	UploadDir         string = "UPLOAD_DIR"
)

type Status string

const (
	Queued Status = "Queued"

	Processing = "Processing"
	Completed  = "Completed"

	Fail = "Fail"
)
