#!/usr/bin/env bash
#
# Verifiable privacy guarantee (NFR-priv-1, AC-11): GoToBed makes no network
# connections. We assert this statically in two ways:
#   1. No networking APIs are referenced anywhere in Sources/.
#   2. The entitlements grant no network capability.
# This runs in CI / `make validate` so a regression fails the build.
set -euo pipefail

cd "$(dirname "$0")/.."

fail=0

echo "==> Checking sources for networking APIs"
# Word-boundary matches so e.g. "network" in a comment about *not* networking
# doesn't trip it; we look for actual API symbols.
patterns='URLSession|URLConnection|NWConnection|NWListener|import Network|CFSocket|Socket\(|getaddrinfo|CFStream|NSURLConnection'
if grep -REn "$patterns" Sources/ ; then
    echo "ERROR: networking API reference found in Sources/."
    fail=1
else
    echo "OK: no networking APIs referenced."
fi

echo "==> Checking entitlements for network capability"
if grep -Eq "com.apple.security.network" Packaging/GoToBed.entitlements ; then
    echo "ERROR: a network entitlement is present."
    fail=1
else
    echo "OK: no network entitlement granted."
fi

exit $fail
