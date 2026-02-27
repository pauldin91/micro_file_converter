package domain

type Status string

const (
	Environment       string = "ENVIRONMENT"
	DbConn            string = "DATABASE_URL"
	HttpServerAddress string = "HTTP_SERVER_ADDRESS"
	RabbitMQHost      string = "RABBITMQ_HOST"
	ConversionQueue   string = "CONVERSION_QUEUE"
	MigrationsDir     string = "MIGRATIONS_DIR"
	UploadDir         string = "UPLOAD_DIR"

	ApiRoot         string = "/api"
	UploadEndpoint  string = ApiRoot + "/uploads"
	SwaggerEndpoint string = "/swagger/*"

	Queued     Status = "Queued"
	Processing Status = "Processing"
	Completed  Status = "Completed"
	Fail       Status = "Fail"
)
