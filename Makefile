# Static ———————————————————————————————————————————————————————————————————————————————————————————————————————————————
LC_LANG = it_IT

# Global variables that we're using
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

# Setup ————————————————————————————————————————————————————————————————————————————————————————————————————————————————
set_env := HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID)
docker_compose := HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) docker-compose
php_container := php-fpm


.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available commands list
	@echo "\033[34mList of available commands:\033[39m"
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: start
start: ## Start all project containers
	@$(set_env) $(docker_compose) start

.PHONY: stop
stop: ## Stop the project containers
	@$(set_env) $(docker_compose) stop $(s)

.PHONY: build
build: ## Build project images
	@$(set_env) $(docker_compose) build --no-cache

.PHONY: up
up: ## Spin up project containers
	@$(set_env) $(docker_compose) up

.PHONY: enter
enter: ## Enter the PHP container in bash mode
	@$(set_env) $(docker_compose) exec -it $(php_container) zsh

.PHONY: erase
erase: ## Erase containers with related volumes
	@$(set_env) $(docker_compose) down -v

.PHONY: clear-cache
clear-cache:
	@$(set_env) $(docker_compose) exec -e APP_ENV $(php_container) php bin/console cache:pool:clear cache.global_clearer
	@$(set_env) $(docker_compose) exec -e APP_ENV $(php_container) php bin/console cache:clear --no-warmup
	@$(set_env) $(docker_compose) exec -e APP_ENV $(php_container) php bin/console cache:warmup
