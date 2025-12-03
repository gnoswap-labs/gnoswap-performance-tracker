.PHONY: init gas-report

init:
	git submodule update --init --recursive
	cd gno && make install

# Usage: make gas-report [commit]
# Example: make gas-report (defaults to main)
#          make gas-report feature-branch
gas-report:
	$(eval COMMIT := $(or $(word 2,$(MAKECMDGOALS)),main))
	$(eval CURRENT_COMMIT := $(shell cd gnoswap && git fetch && git checkout $(COMMIT) && git rev-parse --short HEAD))
	cd gnoswap && python3 setup.py --exclude-tests -w ../
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/metric
	cp -r metric_test gno/examples/gno.land/r/gnoswap/scenario/metric
	mkdir -p reports/commits
	(cd gno/examples/gno.land/r/gnoswap/scenario/metric && gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > reports/commits/$(CURRENT_COMMIT).md
	@echo "Report saved to reports/commits/$(CURRENT_COMMIT).md"

# Usage: make compare <latest> <previous>
# Example: make compare 94d46710 94d46728
compare:
	@./scripts/compare_reports.sh reports/commits/$(word 2,$(MAKECMDGOALS)).md reports/commits/$(word 3,$(MAKECMDGOALS)).md

# Prevent "No rule to make target" errors for commit hash arguments
%:
	@:
