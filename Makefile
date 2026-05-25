.PHONY: build test validate app clean

# Single source of truth for the release version.
# build-app.sh picks this up via the MARKETING_VERSION env var.
MARKETING_VERSION := $(shell cat VERSION 2>/dev/null || echo 0.0.0-dev)
export MARKETING_VERSION

# The project validation command (used by the n-dx workflow).
validate: build test
	./scripts/verify-no-network.sh
	./scripts/check-core-purity.sh

build:
	swift build

test:
	swift test

# Build a signed universal GoToBed.app into build/.
# MARKETING_VERSION (from VERSION) is forwarded via the environment.
app:
	./scripts/build-app.sh

clean:
	rm -rf .build build
