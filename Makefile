.PHONY: build test validate app clean

# Release version resolved from the single source of truth
# (.release-please-manifest.json) by scripts/version.sh. Exported so build-app.sh
# and other scripts pick it up via the MARKETING_VERSION env var.
MARKETING_VERSION := $(shell ./scripts/version.sh 2>/dev/null || echo 0.0.0-dev)
export MARKETING_VERSION

# The project validation command (used by the n-dx workflow).
validate: build test
	./scripts/verify-no-network.sh
	./scripts/check-core-purity.sh
	bash ./scripts/check-zone-layering.sh
	sh ./scripts/check-site-docs.sh

build:
	swift build

test:
	swift test

# Build a signed universal GoToBed.app into build/.
# MARKETING_VERSION (from the release-please manifest) is forwarded via the environment.
app:
	./scripts/build-app.sh

clean:
	rm -rf .build build
