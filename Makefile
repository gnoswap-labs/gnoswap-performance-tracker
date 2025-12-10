.PHONY: help init gas-report stress-report metric metric-force stress stress-force compare-metric compare-metric-force compare-stress compare-stress-force summary summary-force

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
	@echo "Usage (Setup):"
	@echo "  make init                          # Initialize project"

init:
	git submodule update --init --recursive
	cd gno && make install

# --- Simplified Commands ---

# Helper to extract commit arguments (everything after the target name)
ARGS = $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

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

# --- Internal / Legacy Commands ---

# Usage: make gas-report [commit]
gas-report:
	$(eval COMMIT := $(or $(word 2,$(MAKECMDGOALS)),main))
	$(eval CURRENT_COMMIT := $(shell cd gnoswap && git fetch >/dev/null 2>&1 && git checkout -f $(COMMIT) >/dev/null 2>&1 && git rev-parse --short=7 HEAD))
	cd gnoswap && python3 setup.py --exclude-tests -w ../
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/metric
	cp -r tests/metric gno/examples/gno.land/r/gnoswap/scenario/metric
	mkdir -p reports/metric/commits
	(cd gno/examples/gno.land/r/gnoswap/scenario/metric && gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > reports/metric/commits/$(CURRENT_COMMIT).md
	@echo "Report saved to reports/metric/commits/$(CURRENT_COMMIT).md"

# Usage: make stress-report [commit]
stress-report:
	$(eval COMMIT := $(or $(word 2,$(MAKECMDGOALS)),main))
	$(eval CURRENT_COMMIT := $(shell cd gnoswap && git fetch >/dev/null 2>&1 && git checkout -f $(COMMIT) >/dev/null 2>&1 && git rev-parse --short=7 HEAD))
	cd gnoswap && python3 setup.py --exclude-tests -w ../
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/metric
	cp -r tests/metric gno/examples/gno.land/r/gnoswap/scenario/metric
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/stress
	cp -r tests/stress gno/examples/gno.land/r/gnoswap/scenario/stress
	mkdir -p reports/stress/commits
	(cd gno/examples/gno.land/r/gnoswap/scenario/stress && gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > reports/stress/commits/$(CURRENT_COMMIT).md
	@echo "Report saved to reports/stress/commits/$(CURRENT_COMMIT).md"

# Generate summary report from commit-history.txt
summary:
	@./scripts/generate_summary_report.sh

summary-force:
	@./scripts/generate_summary_report.sh --force

# Prevent "No rule to make target" errors for commit hash arguments
%:
	@:
