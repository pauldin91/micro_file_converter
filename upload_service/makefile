DB_URL=postgresql://postgres:mysecretpassword@localhost:5432/upload_service_dev?sslmode=disable

migrateup:
	migrate -path db/migrations -database "$(DB_URL)" -verbose up $(times)

migratedown:
	migrate -path db/migrations -database "$(DB_URL)" -verbose down $(times)  

dirty:
	migrate -path db/migrations -database "$(DB_URL)" force $(version)  
	make migratedown

migrate_version:
	migrate -path db/migrations -database "$(DB_URL)" version


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

.PHONY: network postgres createdb dropdb migrateup migratedown migrateup1 migratedown1 new_migration db_docs db_schema sqlc test server mock proto evans redis