SHELL := /bin/bash

# Override if `make` inherits a minimal PATH (e.g. some IDE terminals): DOCKER=/path/to/docker
DOCKER ?= docker

export COMPOSE_PROJECT_NAME ?= gnoswap_performance_research

REF ?= local
GNOSWAP_REF ?= $(REF)
WORKLOAD_NS ?= 1,10,100
GNO_RPC_PORT ?= 46657
GNO_REST_PORT ?= 48888
ARTIFACTS_DIR ?= artifacts
RUNLOGS_DIR ?= .runlogs
DOCKER_STAGING_DIR ?= .docker
DOCKER_BUILD_CONTEXT ?= $(DOCKER_STAGING_DIR)/context
DOCKERFILE_PATH ?= gno/Dockerfile
STAGED_GNOSWAP_DIR ?= $(DOCKER_STAGING_DIR)/gnoswap-src
GNOSWAP_SOURCE_REPO ?= $(abspath ../gnoswap)
RESEARCH_REPORT_OUT ?= $(ARTIFACTS_DIR)/latest-report.tsv
RESEARCH_REPORT_LOG_OUT ?= $(RUNLOGS_DIR)/latest-report.log
RESEARCH_METRIC_LOG_OUT ?= $(RUNLOGS_DIR)/metric-output.log
RESEARCH_TEST_PATTERN ?= TestResearchReport
RESEARCH_READY_TIMEOUT_SECS ?= 600
PREPARE_GNOSWAP_SRC = git -C .. submodule update --init --recursive gnoswap >/dev/null 2>&1 || true; \
	resolve_ref() { \
		local ref="$$1"; \
		git -C "$(GNOSWAP_SOURCE_REPO)" fetch origin >/dev/null 2>&1 || true; \
		if git -C "$(GNOSWAP_SOURCE_REPO)" rev-parse -q --verify "$${ref}^{commit}" >/dev/null 2>&1; then \
			git -C "$(GNOSWAP_SOURCE_REPO)" rev-parse "$${ref}^{commit}"; \
		elif git -C "$(GNOSWAP_SOURCE_REPO)" rev-parse -q --verify "origin/$${ref}^{commit}" >/dev/null 2>&1; then \
			git -C "$(GNOSWAP_SOURCE_REPO)" rev-parse "origin/$${ref}^{commit}"; \
		else \
			echo "Could not resolve gnoswap ref '$$ref'" >&2; \
			exit 1; \
		fi; \
	}; \
	RESOLVED_GNOSWAP_REF="$$(resolve_ref "$(GNOSWAP_REF)")"; \
	rm -rf "$(DOCKER_BUILD_CONTEXT)" "$(STAGED_GNOSWAP_DIR)"; \
	mkdir -p "$(DOCKER_BUILD_CONTEXT)/.docker"; \
	cp -R gno "$(DOCKER_BUILD_CONTEXT)/gno"; \
	git clone "$(GNOSWAP_SOURCE_REPO)" "$(DOCKER_BUILD_CONTEXT)/.docker/gnoswap-src" >/dev/null 2>&1; \
	git -C "$(DOCKER_BUILD_CONTEXT)/.docker/gnoswap-src" checkout --detach "$$RESOLVED_GNOSWAP_REF" >/dev/null 2>&1;
WAIT_FOR_RESEARCH_RUNTIME = deadline=$$(( $$(date +%s) + $(RESEARCH_READY_TIMEOUT_SECS) )); \
	while true; do \
		container_id="$$($(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" ps -q gno 2>/dev/null | head -n 1)"; \
		if [ -n "$$container_id" ] \
			&& $(DOCKER) exec "$$container_id" sh -lc 'test -f /tmp/gnoswap-ready' >/dev/null 2>&1 \
			&& $(DOCKER) exec "$$container_id" gnokey query vm/qeval -data 'gno.land/r/gnoswap/access.MustGetAddress("pool")' -remote localhost:26657 >/dev/null 2>&1; then \
			break; \
		fi; \
		if [ $$(date +%s) -ge $$deadline ]; then \
			echo "research runtime not ready on localhost:$(GNO_REST_PORT) within $(RESEARCH_READY_TIMEOUT_SECS)s" >&2; \
			$(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" logs --no-color --tail=120 >&2 || true; \
			exit 1; \
		fi; \
		sleep 2; \
	done;

.PHONY: up down build logs test test-only test-keep-up report clean ensure-dirs

ensure-dirs:
	@mkdir -p $(ARTIFACTS_DIR) $(RUNLOGS_DIR) $(DOCKER_STAGING_DIR)

up: ensure-dirs
	@set -euo pipefail; \
	$(PREPARE_GNOSWAP_SRC) \
	GNOSWAP_REF="$$RESOLVED_GNOSWAP_REF" GNO_RPC_PORT="$(GNO_RPC_PORT)" GNO_REST_PORT="$(GNO_REST_PORT)" $(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" up -d --build --force-recreate

down:
	@$(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" down -v

build:
	@set -euo pipefail; \
	$(PREPARE_GNOSWAP_SRC) \
	GNOSWAP_REF="$$RESOLVED_GNOSWAP_REF" GNO_RPC_PORT="$(GNO_RPC_PORT)" GNO_REST_PORT="$(GNO_REST_PORT)" $(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" build

logs:
	@$(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" logs -f

test: ensure-dirs
	@set -euo pipefail; \
	mkdir -p "$(ARTIFACTS_DIR)" "$(RUNLOGS_DIR)" "$(dir $(RESEARCH_METRIC_LOG_OUT))"; \
	cleanup() { $(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" down -v >/dev/null 2>&1 || true; }; \
	trap cleanup EXIT; \
	$(PREPARE_GNOSWAP_SRC) \
	GNOSWAP_REF="$$RESOLVED_GNOSWAP_REF" GNO_RPC_PORT="$(GNO_RPC_PORT)" GNO_REST_PORT="$(GNO_REST_PORT)" $(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" up -d --build --force-recreate; \
	$(WAIT_FOR_RESEARCH_RUNTIME) \
	GNO_GNOKEY_REMOTE="localhost:26657" GNO_REST="http://localhost:$(GNO_REST_PORT)" RESEARCH_METRIC_LOG_OUT="$(RESEARCH_METRIC_LOG_OUT)" COMPOSE_PROJECT_NAME="$(COMPOSE_PROJECT_NAME)" go test -v -timeout 1000m -count=1 ./...

test-only: ensure-dirs
	@go test -v -timeout 1000m -count=1 ./...

test-keep-up: ensure-dirs
	@set -euo pipefail; \
	mkdir -p "$(ARTIFACTS_DIR)" "$(RUNLOGS_DIR)" "$(dir $(RESEARCH_METRIC_LOG_OUT))"; \
	$(PREPARE_GNOSWAP_SRC) \
	GNOSWAP_REF="$$RESOLVED_GNOSWAP_REF" GNO_RPC_PORT="$(GNO_RPC_PORT)" GNO_REST_PORT="$(GNO_REST_PORT)" $(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" up -d --build --force-recreate; \
	$(WAIT_FOR_RESEARCH_RUNTIME) \
	GNO_GNOKEY_REMOTE="localhost:26657" GNO_REST="http://localhost:$(GNO_REST_PORT)" RESEARCH_METRIC_LOG_OUT="$(RESEARCH_METRIC_LOG_OUT)" COMPOSE_PROJECT_NAME="$(COMPOSE_PROJECT_NAME)" go test -v -timeout 1000m -count=1 ./...

report: ensure-dirs
	@set -euo pipefail; \
	mkdir -p "$(ARTIFACTS_DIR)" "$(RUNLOGS_DIR)" "$(dir $(RESEARCH_REPORT_OUT))" "$(dir $(RESEARCH_REPORT_LOG_OUT))" "$(dir $(RESEARCH_METRIC_LOG_OUT))"; \
	cleanup() { $(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" down -v >/dev/null 2>&1 || true; }; \
	trap cleanup EXIT; \
	rm -f "$(RESEARCH_REPORT_OUT)" "$(RESEARCH_REPORT_LOG_OUT)" "$(RESEARCH_METRIC_LOG_OUT)"; \
	$(PREPARE_GNOSWAP_SRC) \
	GNOSWAP_REF="$$RESOLVED_GNOSWAP_REF" GNO_RPC_PORT="$(GNO_RPC_PORT)" GNO_REST_PORT="$(GNO_REST_PORT)" $(DOCKER) compose -p "$(COMPOSE_PROJECT_NAME)" up -d --build --force-recreate; \
	$(WAIT_FOR_RESEARCH_RUNTIME) \
	RESEARCH_REPORT=1 RESEARCH_REPORT_OUT="$(RESEARCH_REPORT_OUT)" RESEARCH_METRIC_LOG_OUT="$(RESEARCH_METRIC_LOG_OUT)" WORKLOAD_NS="$(WORKLOAD_NS)" GNO_GNOKEY_REMOTE="localhost:26657" GNO_REST="http://localhost:$(GNO_REST_PORT)" COMPOSE_PROJECT_NAME="$(COMPOSE_PROJECT_NAME)" go test -v -timeout 1000m -count=1 -run '$(RESEARCH_TEST_PATTERN)' ./... > "$(RESEARCH_REPORT_LOG_OUT)" 2>&1; \
	ret=$$?; \
	if [ $$ret -ne 0 ]; then cat "$(RESEARCH_REPORT_LOG_OUT)"; exit $$ret; fi

clean:
	@rm -rf $(ARTIFACTS_DIR)/* $(RUNLOGS_DIR)/*
