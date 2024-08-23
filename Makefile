# Note: GNU Makefile
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

## Requirements:
## docker-compose : <pkg:deb/debian/docker-ce-cli>
## psql           : <pkg:deb/debian/postgresql-client-common>
## xargs
## find
## realpath
## duckdb

### Platform helper
MKDIR_P := mkdir -p
ECHO    := echo

define MISSING_ENV_MSG :=
****
Missing .env file. Please copy from .env.template.

  cp .env.template .env
****
endef
ifneq (,$(wildcard ./.env))
    include .env
    export
else
    $(info $(MISSING_ENV_MSG))
endif

.PHONY: help            \
	_env-guard      \
	run-psql        \
	run-psql-csv    \
	run-duckdb      \
	run-duckdb-csv  \
	#

define MESSAGE
Targets for $(MAKE):

## Docker

- docker-compose-up   : start Docker Compose (in background)
- docker-compose-down : stop Docker Compose

- docker-load-data    : load data from schema dump
- docker-clean-data   : remove data from PostgreSQL data dir
                        [ $(DOCKER_POSTGRES_DATA_DIR) ]

## PostgreSQL

- run-psql            : run a given SQL file using `psql`
- run-psql-csv        : run a given SQL file using `psql` with CSV output

      make run-psql FILE=/path/to/pg.sql

  Variables:

  - `FILE`: path to SQL file

  NOTE: Runs on the host. Requires `psql`.

- run-duckdb          : run a given SQL file using `duckdb`
- run-duckdb          : run a given SQL file using `duckdb` with CSV output

      make run-duckdb FILE=/path/to/duckdb.sql

  Variables:

  - `FILE`: path to SQL file

  NOTE: Runs on the host. Requires `duckdb`.

endef

# Default target
export MESSAGE
help:
	@$(ECHO) "$$MESSAGE"

_env-guard:

env-guard-%: _env-guard
	@if [ -z '${${*}}' ]; then echo 'Environment variable $* not set' && exit 1; fi

.PHONY: \
	docker-compose-up \
	docker-compose-down \
	docker-load-data

PROJECT_MAIN_SERVICE := aact-db

docker-compose-up: env-guard-DOCKER_POSTGRES_DATA_DIR
	@$(MKDIR_P) "${DOCKER_POSTGRES_DATA_DIR}"
	docker compose \
		up -d --build

docker-compose-down:
	docker compose \
		down

docker-load-data:
	D=./download/aact/db-dump; \
	find $$D -type f -name '*.zip' -print \
		| xargs -I{} realpath --relative-to=$$D {} \
		| xargs -I{} docker compose \
				exec -T $(PROJECT_MAIN_SERVICE) \
					/script/load.sh /aact-data/{}

DOCKER_PGDATA_DIR := $(DOCKER_POSTGRES_DATA_DIR)
DOCKER_PGDATA_TARGET := /var/lib/postgresql/data

docker-clean-data: docker-compose-down
	docker compose \
		run \
		-v $(DOCKER_PGDATA_DIR):$(DOCKER_PGDATA_TARGET) \
		$(PROJECT_MAIN_SERVICE) \
		bash -vc ' \
			[ -d "$$PGDATA" ] && rm -Rfv "$$PGDATA"/*;   \
		'
	[ -d "$(DOCKER_PGDATA_DIR)" ] && rmdir -v "$(DOCKER_PGDATA_DIR)"

RUN_DB_CMD_DEPS :=                   \
		env-guard-FILE       \
		env-guard-PGDATABASE \
		#

run-psql: $(RUN_DB_CMD_DEPS)
	@if [ -f "${FILE}" ]; then psql < "${FILE}"; fi

run-psql-csv: $(RUN_DB_CMD_DEPS)
	@if [ -f "${FILE}" ]; then psql --csv < "${FILE}"; fi

run-duckdb: $(RUN_DB_CMD_DEPS)
	@if [ -f "${FILE}" ]; then duckdb < "${FILE}"; fi

run-duckdb-csv: $(RUN_DB_CMD_DEPS)
	@if [ -f "${FILE}" ]; then duckdb -csv < "${FILE}"; fi
