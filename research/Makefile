SHELL := /bin/bash

export COMPOSE_PROJECT_NAME ?= gnoswap_performance_research

REF ?= local
WORKLOAD_NS ?= 1,100,10000
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
	@docker compose up -d --build --force-recreate
	@RESEARCH_REPORT=1 RESEARCH_REPORT_OUT="$(LAST_REPORT)" WORKLOAD_NS="$(WORKLOAD_NS)" go test -v -timeout 60m -count=1 -run TestResearchReportPoolCreate ./... > "$(RUNLOGS_DIR)/latest-report.log" 2>&1; ret=$$?; if [ $$ret -ne 0 ]; then cat "$(RUNLOGS_DIR)/latest-report.log"; docker compose down -v; exit $$ret; fi; cat "$(LAST_REPORT)"; docker compose down -v

clean:
	@rm -rf $(ARTIFACTS_DIR)/* $(RUNLOGS_DIR)/*
