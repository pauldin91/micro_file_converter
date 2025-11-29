DBSRC=postgresql://postgres:mysecretpassword@localhost:5432/upload_service_dev?sslmode=disable

up:
	migrate -path db/migrations -database "$(DBSRC)"  up $(times)

down:
	migrate -path db/migrations -database "$(DBSRC)"  down $(times)  

dirty:
	migrate -path db/migrations -database "$(DBSRC)" force $(version)  
	make down

migrate_version:
	migrate -path db/migrations -database "$(DBSRC)" version


new_migration:
	migrate create -ext sql -dir db/migrations -seq $(name)

docs:
	dbdocs build doc/db.dbml

gen:
	sqlc generate

test:
	go test -v -cover -short ./...

build: 
	mkdir -p build
	go build -o build/main ./cmd/api/main.go

clean:
	rm -rf build
