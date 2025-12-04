.PHONY: init gas-report

init:
	git submodule update --init --recursive
	cd gno && make install

# Usage: make gas-report [commit]
# Example: make gas-report (defaults to main)
#          make gas-report feature-branch
gas-report:
	$(eval COMMIT := $(or $(word 2,$(MAKECMDGOALS)),main))
	$(eval CURRENT_COMMIT := $(shell cd gnoswap && git fetch >/dev/null 2>&1 && git checkout -f $(COMMIT) >/dev/null 2>&1 && git rev-parse --short HEAD))
	cd gnoswap && python3 setup.py --exclude-tests -w ../
	rm -rf gno/examples/gno.land/r/gnoswap/scenario/metric
	cp -r metric_test gno/examples/gno.land/r/gnoswap/scenario/metric
	mkdir -p reports/commits
	(cd gno/examples/gno.land/r/gnoswap/scenario/metric && gno test . -v -run .) 2>&1 | ./scripts/parse_metrics.sh > reports/commits/$(CURRENT_COMMIT).md
	@echo "Report saved to reports/commits/$(CURRENT_COMMIT).md"

# Usage: make compare <commit1> <commit2>
# Example: make compare 94d46710 94d46728
compare:
	@./scripts/compare_reports.sh reports/commits/$(shell echo "$(word 2,$(MAKECMDGOALS))" | cut -c1-8).md reports/commits/$(shell echo "$(word 3,$(MAKECMDGOALS))" | cut -c1-8).md

# Usage: make compare-with-report <commit1> <commit2> [commit3] ...
#        make compare-with-report-all <commit1> <commit2> [commit3] ...
#        SKIP=1 make compare-with-report <commit1> <commit2> [commit3] ...
# Example: make compare-with-report abc123 def456 ghi789
# This will:
#   1. Generate gas reports for each commit
#   2. Compare consecutive commits (commit1~commit2, commit2~commit3, ...)
#   3. Compare first commit to last commit (overall comparison)
compare-with-report:
	@./scripts/compare_multiple.sh --skip-exists $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Same as compare-with-report but skips existing reports
compare-with-report-all:
	@./scripts/compare_multiple.sh $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Prevent "No rule to make target" errors for commit hash arguments
%:
	@:
