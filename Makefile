# Docker Compose and Airflow Setup

.PHONY: help up down init-db logs restart

# Display help message
help:
	@echo "Available commands:"
	@echo "  up        - Start all services"
	@echo "  down      - Stop all services"
	@echo "  init-db   - Initialize the Airflow database"
	@echo "  logs      - Show logs for Airflow Webserver"
	@echo "  restart   - Restart all services"

# Start all services
up:
	docker compose up -d

# Stop all services
down:
	docker compose down

# Initialize the Airflow database
init-db:
	docker compose run --rm airflow-init

# Show logs for Airflow Webserver
logs:
	docker compose logs -f airflow-webserver

# Restart all services
restart: down up
