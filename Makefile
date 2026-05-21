.PHONY: build test validate app clean

# The project validation command (used by the n-dx workflow).
validate: build test
	./scripts/verify-no-network.sh

build:
	swift build

test:
	swift test

# Build a signed universal GoToBed.app into build/.
app:
	./scripts/build-app.sh

clean:
	rm -rf .build build
