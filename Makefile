.PHONY: help init gas-report stress-report compare compare-stress run run-all stress stress-all summary summary-with-run compare-with-run stress-compare stress-compare-with-run

# Default target
help:
	@echo "Usage (Reports Only):"
	@echo "  make run <commits>          # Generate reports (Skip existing)"
	@echo "  make run-all <commits>      # Generate reports (Regenerate all)"
	@echo "  make stress <commits>       # Generate stress reports (Skip existing)"
	@echo "  make stress-all <commits>   # Generate stress reports (Regenerate all)"
	@echo ""
	@echo "Usage (Compare):"
	@echo "  make compare <commits>         # Compare commits (Skip existing reports)"
	@echo "  make compare-with-run <commits>      # Compare commits (Regenerate all)"
	@echo "  make stress-compare <commits>        # Compare stress reports (Skip existing)"
	@echo "  make stress-compare-with-run <commits> # Compare stress reports (Regenerate all)"
	@echo ""
	@echo "Usage (Summary):"
	@echo "  make summary                # Generate summary from existing reports"
	@echo "  make summary-with-run       # Generate reports, compare, and create summary"
	@echo ""
	@echo "Usage (Setup):"
	@echo "  make init                   # Initialize project"

init:
	git submodule update --init --recursive
	cd gno && make install

# --- Simplified Commands ---

# Helper to extract commit arguments (everything after the target name)
ARGS = $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Report Generation Only (No Compare)
run:
	@./scripts/compare_multiple.sh --skip-exists --report-only $(ARGS)

run-all:
	@./scripts/compare_multiple.sh --report-only $(ARGS)

stress:
	@./scripts/compare_multiple.sh --stress --skip-exists --report-only $(ARGS)

stress-all:
	@./scripts/compare_multiple.sh --stress --report-only $(ARGS)

# Compare (Generate if missing + Compare)
compare:
	@./scripts/compare_multiple.sh --skip-exists $(ARGS)

stress-compare:
	@./scripts/compare_multiple.sh --stress --skip-exists $(ARGS)

# Compare (Force Regenerate + Compare)
compare-with-run:
	@./scripts/compare_multiple.sh $(ARGS)

stress-compare-with-run:
	@./scripts/compare_multiple.sh --stress $(ARGS)

# --- Internal / Legacy Commands ---

# Usage: make gas-report [commit]
gas-report:
	$(eval COMMIT := $(or $(word 2,$(MAKECMDGOALS)),main))
	$(eval CURRENT_COMMIT := $(shell cd gnoswap && git fetch >/dev/null 2>&1 && git checkout -f $(COMMIT) >/dev/null 2>&1 && git rev-parse --short HEAD))
	cd gnoswap && python3 setup.py --exclude-tests -w ../
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/metric
	cp -r tests/metric gno/examples/gno.land/r/gnoswap/scenario/metric
	mkdir -p reports/commits
	(cd gno/examples/gno.land/r/gnoswap/scenario/metric && gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > reports/commits/$(CURRENT_COMMIT).md
	@echo "Report saved to reports/commits/$(CURRENT_COMMIT).md"

# Usage: make stress-report [commit]
stress-report:
	$(eval COMMIT := $(or $(word 2,$(MAKECMDGOALS)),main))
	$(eval CURRENT_COMMIT := $(shell cd gnoswap && git fetch >/dev/null 2>&1 && git checkout -f $(COMMIT) >/dev/null 2>&1 && git rev-parse --short HEAD))
	cd gnoswap && python3 setup.py --exclude-tests -w ../
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/metric
	cp -r tests/metric gno/examples/gno.land/r/gnoswap/scenario/metric
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/stress
	cp -r tests/stress gno/examples/gno.land/r/gnoswap/scenario/stress
	mkdir -p reports/commits
	(cd gno/examples/gno.land/r/gnoswap/scenario/stress && gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > reports/commits/stress_$(CURRENT_COMMIT).md
	@echo "Report saved to reports/commits/stress_$(CURRENT_COMMIT).md"

# Generate summary report from commit-history.txt
summary:
	@./scripts/generate_summary_report.sh

summary-with-run:
	@./scripts/generate_summary_report.sh --run-tests

# Prevent "No rule to make target" errors for commit hash arguments
%:
	@:
