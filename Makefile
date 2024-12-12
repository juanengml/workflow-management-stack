.PHONY: up down build logs clean restart init

up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose build

logs:
	docker-compose logs -f

clean:
	docker-compose down -v
	rm -rf ./logs/*
	rm -rf ./plugins/*
	find ./dags -type f ! -name '.gitkeep' -delete

restart: down up

init: clean
	mkdir -p ./dags ./logs ./plugins
	docker-compose up airflow-init
	make up