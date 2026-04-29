SHELL := /bin/bash

.PHONY: help init gas-report stress-report metric metric-force stress stress-force compare-metric compare-metric-force compare-stress compare-stress-force summary summary-force clean-worktrees research-up research-down research-test research-report compare-research research-compare

# Default target
help:
	@echo "Usage (Metric Reports):"
	@echo "  make metric <commits>              # Generate metric reports (skip existing)"
	@echo "  make metric-force <commits>        # Force regenerate all metric reports"
	@echo "  make stress <commits>              # Generate stress reports (skip existing)"
	@echo "  make stress-force <commits>        # Force regenerate all stress reports"
	@echo ""
	@echo "Usage (Compare):"
	@echo "  make compare-metric <commits>             # Compare metric reports (skip existing)"
	@echo "  make compare-metric-force <commits>       # Force regenerate metric comparisons"
	@echo "  make compare-stress <commits>             # Compare stress reports (skip existing)"
	@echo "  make compare-stress-force <commits>       # Force regenerate stress comparisons"
	@echo ""
	@echo "Usage (Summary):"
	@echo "  make summary                       # Generate summary (skip existing)"
	@echo "  make summary-force                 # Force regenerate all reports and summary"
	@echo ""
	@echo "Usage (Research):"
	@echo "  make research-up                   # Start live-chain research runtime"
	@echo "  make research-down                 # Stop live-chain research runtime"
	@echo "  make research-test                 # Run research lane smoke harness"
	@echo "  GNO_RPC_PORT=<rpc> GNO_REST_PORT=<rest> make research-report <ref>"
	@echo "                                   # Run integrated deploy + probes + report"
	@echo "  make compare-research <refs>       # Compare research reports"
	@echo "  make research-compare <latest.md> <previous.md>"
	@echo "                                   # Compare two existing research report files"
	@echo ""
	@echo "Usage (Setup):"
	@echo "  make init                          # Initialize project"
	@echo "  make clean-worktrees               # Remove cached benchmark worktrees"

init:
	git submodule update --init --recursive
	cd gno && make install

# --- Simplified Commands ---

# Helper to extract commit arguments (everything after the target name)
ARGS = $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

ifneq (,$(filter research-compare,$(MAKECMDGOALS)))
ifneq ($(word 2,$(MAKECMDGOALS)),)
$(eval $(word 2,$(MAKECMDGOALS)):; @:)
endif
ifneq ($(word 3,$(MAKECMDGOALS)),)
$(eval $(word 3,$(MAKECMDGOALS)):; @:)
endif
endif

# Metric Report Generation Only (No Compare)
metric:
	@./scripts/compare_multiple.sh --skip-exists --report-only $(ARGS)

metric-force:
	@./scripts/compare_multiple.sh --report-only $(ARGS)

stress:
	@./scripts/compare_multiple.sh --stress --skip-exists --report-only $(ARGS)

stress-force:
	@./scripts/compare_multiple.sh --stress --report-only $(ARGS)

# Compare (Generate if missing + Compare)
compare-metric:
	@./scripts/compare_multiple.sh --skip-exists $(ARGS)

compare-stress:
	@./scripts/compare_multiple.sh --stress --skip-exists $(ARGS)

# Compare (Force Regenerate + Compare)
compare-metric-force:
	@./scripts/compare_multiple.sh $(ARGS)

compare-stress-force:
	@./scripts/compare_multiple.sh --stress $(ARGS)

research-up:
	@$(MAKE) -C research up GNOSWAP_REF="$(or $(word 2,$(MAKECMDGOALS)),3f2642b8898ae02d14a14c4050d80919f18f3f21)" GNO_RPC_PORT="$(or $(GNO_RPC_PORT),46657)" GNO_REST_PORT="$(or $(GNO_REST_PORT),48888)"

research-down:
	@$(MAKE) -C research down

research-test:
	@$(MAKE) -C research test GNOSWAP_REF="$(or $(word 2,$(MAKECMDGOALS)),3f2642b8898ae02d14a14c4050d80919f18f3f21)" GNO_RPC_PORT="$(or $(GNO_RPC_PORT),46657)" GNO_REST_PORT="$(or $(GNO_REST_PORT),48888)"

research-report:
	@set -euo pipefail; \
	REF="$(or $(word 2,$(MAKECMDGOALS)),main)"; \
	RPC_PORT="$(GNO_RPC_PORT)"; \
	REST_PORT="$(GNO_REST_PORT)"; \
	if [ -z "$$RPC_PORT" ] || [ -z "$$REST_PORT" ]; then \
		echo "GNO_RPC_PORT and GNO_REST_PORT are required for make research-report <ref>" >&2; \
		exit 1; \
	fi; \
	git submodule update --init --recursive gnoswap >/dev/null 2>&1 || true; \
	resolve_ref() { \
		local ref="$$1"; \
		git -C "$(CURDIR)/gnoswap" fetch origin >/dev/null 2>&1 || true; \
		if git -C "$(CURDIR)/gnoswap" rev-parse -q --verify "$${ref}^{commit}" >/dev/null 2>&1; then \
			git -C "$(CURDIR)/gnoswap" rev-parse "$${ref}^{commit}"; \
		elif git -C "$(CURDIR)/gnoswap" rev-parse -q --verify "origin/$${ref}^{commit}" >/dev/null 2>&1; then \
			git -C "$(CURDIR)/gnoswap" rev-parse "origin/$${ref}^{commit}"; \
		else \
			echo "Could not resolve ref '$$ref'" >&2; \
			exit 1; \
		fi; \
	}; \
	FULL_REF=""; \
	FULL_REF="$$(resolve_ref "$$REF")"; \
	SHORT_REF="$$(git -C "$(CURDIR)/gnoswap" rev-parse --short=7 "$$FULL_REF")"; \
	TIMESTAMP="$$(python3 -c 'from datetime import datetime, timezone; print(datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S-%f"))')"; \
	RUN_STEM="$$SHORT_REF-$$TIMESTAMP"; \
	PROJECT_NAME="gnoswap_performance_research_$$RUN_STEM"; \
	DOCKER_STAGING_DIR="$(CURDIR)/research/.docker/$$RUN_STEM"; \
	DOCKER_BUILD_CONTEXT="$$DOCKER_STAGING_DIR/context"; \
	REPORT_RAW="$(CURDIR)/research/artifacts/research-report-$$RUN_STEM.tsv"; \
	REPORT_LOG="$(CURDIR)/research/.runlogs/research-report-$$RUN_STEM.log"; \
	METRIC_LOG="$(CURDIR)/research/.runlogs/metric-output-$$RUN_STEM.log"; \
	FINAL_REPORT="$(CURDIR)/reports/research/commits/$$SHORT_REF.md"; \
	TMP_REPORT="$$FINAL_REPORT.tmp"; \
	mkdir -p "$(CURDIR)/reports/research/commits" "$(CURDIR)/research/artifacts" "$(CURDIR)/research/.runlogs"; \
	trap "rm -f \"$$TMP_REPORT\"" EXIT; \
	$(MAKE) -C research report REF="$$FULL_REF" GNOSWAP_REF="$$FULL_REF" COMPOSE_PROJECT_NAME="$$PROJECT_NAME" DOCKER_STAGING_DIR="$$DOCKER_STAGING_DIR" DOCKER_BUILD_CONTEXT="$$DOCKER_BUILD_CONTEXT" GNO_RPC_PORT="$$RPC_PORT" GNO_REST_PORT="$$REST_PORT" GNO_GNOKEY_REMOTE="localhost:26657" GNO_REST="http://localhost:$$REST_PORT" RESEARCH_REPORT_OUT="$$REPORT_RAW" RESEARCH_REPORT_LOG_OUT="$$REPORT_LOG" RESEARCH_METRIC_LOG_OUT="$$METRIC_LOG"; \
	./scripts/parse_research.sh "$$REPORT_RAW" > "$$TMP_REPORT"; \
	mv "$$TMP_REPORT" "$$FINAL_REPORT"; \
	echo "Research report saved to $$FINAL_REPORT"

compare-research:
	@./scripts/compare_multiple_research.sh --skip-exists $(ARGS)

research-compare:
	@set -euo pipefail; \
	LATEST="$(word 2,$(MAKECMDGOALS))"; \
	PREVIOUS="$(word 3,$(MAKECMDGOALS))"; \
	EXTRA="$(word 4,$(MAKECMDGOALS))"; \
	if [ -z "$$LATEST" ] || [ -z "$$PREVIOUS" ] || [ -n "$$EXTRA" ]; then \
		echo "Usage: make research-compare <latest.md> <previous.md>" >&2; \
		exit 1; \
	fi; \
	./scripts/compare_reports.sh "$$LATEST" "$$PREVIOUS"

# --- Internal / Legacy Commands ---

# Usage: make gas-report [commit]
gas-report:
	@set -eu; \
	REF="$(or $(word 2,$(MAKECMDGOALS)),main)"; \
	eval "$$(./scripts/prepare_benchmark_workspace.sh "$$REF")"; \
	cleanup() { \
		git -C "$(CURDIR)/gno" worktree remove --force "$$GNO_WORKTREE" >/dev/null 2>&1 || true; \
		git -C "$(CURDIR)/gno" worktree prune >/dev/null 2>&1 || true; \
		rm -rf "$$RUN_ROOT"; \
	}; \
	trap cleanup EXIT; \
	(cd "$$GNOSWAP_WORKTREE" && python3 setup.py --exclude-tests -w "$$RUN_ROOT"); \
	rm -rf "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/metric"; \
	cp -r tests/metric "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/metric"; \
	mkdir -p reports/metric/commits; \
	set +e; \
	(cd "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/metric" && gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > "reports/metric/commits/$$SHORT_COMMIT.md"; \
	test_exit=$${PIPESTATUS[0]}; \
	set -e; \
	if [ "$$test_exit" -ne 0 ] && [ ! -s "reports/metric/commits/$$SHORT_COMMIT.md" ]; then \
		echo "Metric run failed before report generation" >&2; \
		exit "$$test_exit"; \
	fi; \
	echo "Report saved to reports/metric/commits/$$SHORT_COMMIT.md"

# Usage: make stress-report [commit]
stress-report:
	@set -eu; \
	REF="$(or $(word 2,$(MAKECMDGOALS)),main)"; \
	eval "$$(./scripts/prepare_benchmark_workspace.sh "$$REF")"; \
	cleanup() { \
		git -C "$(CURDIR)/gno" worktree remove --force "$$GNO_WORKTREE" >/dev/null 2>&1 || true; \
		git -C "$(CURDIR)/gno" worktree prune >/dev/null 2>&1 || true; \
		rm -rf "$$RUN_ROOT"; \
	}; \
	trap cleanup EXIT; \
	(cd "$$GNOSWAP_WORKTREE" && python3 setup.py --exclude-tests -w "$$RUN_ROOT"); \
	rm -rf "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/metric"; \
	cp -r tests/metric "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/metric"; \
	rm -rf "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/stress"; \
	cp -r tests/stress "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/stress"; \
	mkdir -p reports/stress/commits; \
	set +e; \
	(cd "$$GNO_WORKTREE/examples/gno.land/r/gnoswap/scenario/stress" && GNOROOT="$$GNO_WORKTREE" gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > "reports/stress/commits/$$SHORT_COMMIT.md"; \
	test_exit=$${PIPESTATUS[0]}; \
	set -e; \
	if [ "$$test_exit" -ne 0 ] && [ ! -s "reports/stress/commits/$$SHORT_COMMIT.md" ]; then \
		echo "Stress run failed before report generation" >&2; \
		exit "$$test_exit"; \
	fi; \
	echo "Report saved to reports/stress/commits/$$SHORT_COMMIT.md"

# Generate summary report from commit-history.txt
summary:
	@./scripts/generate_summary_report.sh

summary-force:
	@./scripts/generate_summary_report.sh --force

clean-worktrees:
	@set -eu; \
	if [ -d .worktrees/runs ]; then \
		for dir in .worktrees/runs/*; do \
			if [ -d "$$dir/gno" ]; then \
				git -C gno worktree remove --force "$$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$$dir/gno")" >/dev/null 2>&1 || true; \
			fi; \
		done; \
	fi; \
	if [ -d .worktrees/gnoswap ]; then \
		for dir in .worktrees/gnoswap/*; do \
			if [ -d "$$dir" ]; then \
				git -C gnoswap worktree remove --force "$$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$$dir")" >/dev/null 2>&1 || true; \
			fi; \
		done; \
	fi; \
	rm -rf .worktrees; \
	git -C gnoswap worktree prune >/dev/null 2>&1 || true; \
	git -C gno worktree prune >/dev/null 2>&1 || true; \
	echo "Removed benchmark worktrees"

# Prevent "No rule to make target" errors for commit hash arguments
%:
	@:
