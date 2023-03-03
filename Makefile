help::
	@echo "${GREEN}Emailing API${RESET} https://emailing.pwbs.docker/"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
        		helpMessage = match(lastLine, /^## (.*)/); \
        		if (helpMessage) { \
        			helpCommand = substr($$1, 0, index($$1, ":") - 1); helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
        			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
        		} \
        		isTopic = match(lastLine, /^###/); \
        	    if (isTopic) { printf "\n%s\n", $$1; } \
        	} { lastLine = $$0 }' $(MAKEFILE_LIST)

AWK := $(shell command -v awk 2> /dev/null)

ifndef CI_JOB_ID
	# COLORS
	GREEN  := $(shell tput -Txterm setaf 2)
	YELLOW := $(shell tput -Txterm setaf 3)
	WHITE  := $(shell tput -Txterm setaf 7)
	RESET  := $(shell tput -Txterm sgr0)
	TARGET_MAX_CHAR_NUM=30
endif

TARGET_MAX_CHAR_NUM=30
DOCKER_COMPOSE = docker-compose -f docker-compose.yml
DOCKER_EXEC = $(DOCKER_COMPOSE) exec
EXEC_APP = $(DOCKER_EXEC) app
QUALITY = $(DOCKER_COMPOSE) run --rm quality
CS_COMMAND = php-cs-fixer fix --config=.php-cs-fixer.dist.php --using-cache=no --verbose --diff --allow-risky=yes $(PHPCS_COLOR)

ifeq ($(FORCE_COLORS),1)
	SYMFONY_COLOR = --ansi
	COMPOSER_COLOR = --ansi
	PHPCS_COLOR = --ansi
	PHPSTAN_COLOR = --ansi
endif

.PHONY: docker-files prompt-yesno
.ONESHELL: # Applies to every targets in the file!

prompt-yesno:
	@echo "$(message) [Y/n]:" && read yn; \
	if [ -z $$yn ] || [ "$$yn" != "$${yn#[yYoO]}" ]; then echo Y >&2; else (echo N >&2 && exit 1); fi
	
#################################
Docker:

.PHONY: build rebuild start restart up down goin ps logs bash

## Build the docker image
build:
	$(DOCKER_COMPOSE) build app

## Build the docker image without cache
rebuild:
	$(DOCKER_COMPOSE) build --no-cache app

## Up the services
up:
	$(DOCKER_COMPOSE) up -d --remove-orphans app

## Start service emailing with all require dependancies
start: up vendor

## Restart service emailing with all require dependancies
restart: down start

## List all live containers
ps:
	$(DOCKER_COMPOSE) ps

## Down service emailing container and dependancies
down:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) down --remove-orphans --volumes

## Enter in service-emailing container
goin:
	$(EXEC_APP) bash

## docker-compose logs : Ex: make logs service=minio
logs:
	$(DOCKER_COMPOSE) logs $(service)

## docker-compose exec service bash : Ex make bash service=minio
bash:
	$(DOCKER_COMPOSE) exec $(service) bash

#################################
Dependencies:

.PHONY: vendor composer-update

composer.lock: composer.json

vendor/autoload.php: composer.lock
	@$(EXEC_EMAILING_API) rm -f vendor/autoload.php || true
	@$(EXEC_EMAILING_API) composer install --no-scripts --optimize-autoloader $(COMPOSER_COLOR)

## Composer install
vendor: vendor/autoload.php



#################################
Helper:

## Force remove emailing vendors
rm-vendor:
	@$(EXEC_APP) rm vendor -rf


#################################
Tests:

.PHONY: phpunit

## Run PHPUnit tests
phpunit:
	$(EXEC_APP) php -d xdebug.profiler_enable=on -d memory_limit=-1 ./vendor/bin/phpunit
