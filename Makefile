# Docker-based orchestration setup using Makefile

.PHONY: help create-network start-grafana start-mongodb start-rabbitmq init-airflow start-airflow-webserver start-airflow-scheduler stop-all clean

DOCKER_NETWORK=orchestration-network

default: help

help:
	@echo "Available commands:"
	@echo "  create-network         - Create a Docker network for communication"
	@echo "  start-grafana          - Start Grafana"
	@echo "  start-mongodb          - Start MongoDB"
	@echo "  start-rabbitmq         - Start RabbitMQ"
	@echo "  init-airflow           - Initialize Airflow database"
	@echo "  start-airflow-webserver - Start Airflow webserver"
	@echo "  start-airflow-scheduler - Start Airflow scheduler"
	@echo "  stop-all               - Stop all running containers"
	@echo "  clean                  - Remove all stopped containers and volumes"

create-network:
	docker network create $(DOCKER_NETWORK) || true

start-grafana:
	docker run -d \
		--name grafana \
		--network $(DOCKER_NETWORK) \
		-p 3000:3000 \
		-e GF_SECURITY_ADMIN_USER=admin \
		-e GF_SECURITY_ADMIN_PASSWORD=admin \
		-v grafana-data:/var/lib/grafana \
		grafana/grafana:latest

start-mongodb:
	docker run -d \
		--name mongodb \
		--network $(DOCKER_NETWORK) \
		-p 27017:27017 \
		-v mongodb-data:/data/db \
		mongo:latest

start-rabbitmq:
	docker run -d \
		--name rabbitmq-management \
		--network $(DOCKER_NETWORK) \
		-p 5672:5672 \
		-p 15672:15672 \
		-e RABBITMQ_DEFAULT_USER=guest \
		-e RABBITMQ_DEFAULT_PASS=guest \
		rabbitmq:3-management

init-airflow:
	docker run --rm \
		--name airflow-init \
		--network $(DOCKER_NETWORK) \
		-v /home/ubuntu/dag:/opt/airflow/dags \
		apache/airflow:2.7.0 airflow db init

start-airflow-webserver:
	docker run -d \
		--name airflow-webserver \
		--network $(DOCKER_NETWORK) \
		-p 8080:8080 \
		-v /home/ubuntu/dag:/opt/airflow/dags \
		-e AIRFLOW__CORE__EXECUTOR=LocalExecutor \
		-e AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=sqlite:////opt/airflow/airflow.db \
		-e AIRFLOW__WEBSERVER__WORKERS=2 \
		apache/airflow:2.7.0 webserver

start-airflow-scheduler:
	docker run -d \
		--name airflow-scheduler \
		--network $(DOCKER_NETWORK) \
		-v /home/ubuntu/dag:/opt/airflow/dags \
		-e AIRFLOW__CORE__EXECUTOR=LocalExecutor \
		-e AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=sqlite:////opt/airflow/airflow.db \
		apache/airflow:2.7.0 scheduler

stop-all:
	docker stop grafana mongodb rabbitmq-management airflow-webserver airflow-scheduler || true
	docker rm grafana mongodb rabbitmq-management airflow-webserver airflow-scheduler || true

clean: stop-all
	docker volume rm grafana-data mongodb-data || true
	docker network rm $(DOCKER_NETWORK) || true
