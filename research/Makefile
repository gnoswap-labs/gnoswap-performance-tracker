SHELL := /bin/bash

export COMPOSE_PROJECT_NAME ?= gnoswap_performance_research

REF ?= local
ARTIFACTS_DIR := artifacts
RUNLOGS_DIR := .runlogs
LAST_REPORT := $(ARTIFACTS_DIR)/latest-report.tsv

.PHONY: up down build logs test test-only test-keep-up report clean ensure-dirs

ensure-dirs:
	@mkdir -p $(ARTIFACTS_DIR) $(RUNLOGS_DIR)

up: ensure-dirs
	@docker compose up -d --build --force-recreate

down:
	@docker compose down -v

build:
	@docker compose build

logs:
	@docker compose logs -f

test: ensure-dirs
	@docker compose up -d --build --force-recreate
	@go test -v -timeout 10m -count=1 ./...; ret=$$?; docker compose down -v; exit $$ret

test-only: ensure-dirs
	@go test -v -timeout 10m -count=1 ./...

test-keep-up: ensure-dirs
	@docker compose up -d --build --force-recreate
	@go test -v -timeout 10m -count=1 ./...

report: ensure-dirs
	@printf "research PlaceholderProbe (n=1)\t0\t0\t0\n" | tee "$(LAST_REPORT)"

clean:
	@rm -rf $(ARTIFACTS_DIR)/* $(RUNLOGS_DIR)/*
