ifneq (,$(wildcard ./.env))
  include .env
  export
endif

.PHONY: tests
.DEFAULT_GOAL := help

# Define COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

TARGET_MAX_CHAR_NUM=20

WORKING_DIR := $(shell pwd)

## Show help information
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

# Check if a command exists
cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "'$(*)' must be installed and available on your PATH."; exit 1)

## Build Docker image of leader-elector
docker-build-elector: cmd-exists-docker
	@docker buildx build \
		--build-arg "TARGETPLATFORM=$(TARGET_PLATFORM)" \
		--no-cache \
		--load \
		--platform $(TARGET_PLATFORM) \
		--file leader-elector/Dockerfile \
		--tag $(ELECTOR_REPOSITORY):amd64-$(ELECTOR_VERSION) \
		leader-elector/

## Build Docker image of dagster-daemon
docker-build-daemon: cmd-exists-docker
	@docker build \
		--build-arg "DAGSTER_VERSION=${DAGSTER_VERSION}" \
		--no-cache \
		--file dagster-daemon/Dockerfile \
		--tag $(DAEMON_REPOSITORY):$(DAGSTER_VERSION) \
		dagster-daemon/

## Build all Docker images
docker-build-all: cmd-exists-docker docker-build-elector docker-build-daemon

## Remove Docker image of leader-elector
docker-rmi-elector: cmd-exists-docker
	@docker rmi $(ELECTOR_REPOSITORY):amd64-$(ELECTOR_VERSION)

## Remove Docker image of dagster-daemon
docker-rmi-daemon: cmd-exists-docker
	@docker rmi $(DAEMON_REPOSITORY):$(DAGSTER_VERSION)

## Remove all Docker images
docker-rmi-all: cmd-exists-docker docker-rmi-daemon docker-rmi-elector

## Deploy to Kind cluster
kind-deploy: cmd-exists-kind cmd-exists-helm cmd-exists-kubectl
	@${WORKING_DIR}/deploy/kind-setup

