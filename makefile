drop:
	cd ./core && mix ecto.drop && cd -

create:
	cd ./core && mix ecto.create && mix ecto.migrate && cd -

all: drop create

build:
	docker compose up $(ps)

exec:
	docker exec -it $(img) sh