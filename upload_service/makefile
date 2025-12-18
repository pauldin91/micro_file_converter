include app.env

up:
	migrate -path $(MIGRATIONS) -database "$(DATABASE_URL)"  up $(times)

down:
	migrate -path $(MIGRATIONS) -database "$(DATABASE_URL)"  down $(times)  

dirty:
	migrate -path $(MIGRATIONS) -database "$(DATABASE_URL)" force $(version)  
	make down

migrate_version:
	migrate -path $(MIGRATIONS) -database "$(DATABASE_URL)" version


new_migration:
	migrate create -ext sql -dir  -seq $(name)

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
