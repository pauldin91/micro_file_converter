

build:
	docker compose up --build $(ps)

exec:
	docker exec -it $(img) sh

clean:
	go run tools/clean/clean_up.go