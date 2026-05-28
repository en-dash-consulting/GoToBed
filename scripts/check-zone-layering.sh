#!/usr/bin/env bash
#
# Architectural guard: enforces intra-module zone isolation within GoToBedKit.
#
# Within the GoToBedKit module all files share one Swift namespace, so there
# are no `import` statements between zones — zone boundaries are expressed as
# "zone X must not reference types defined in zone Y." This script makes that
# constraint machine-checkable so silent layering erosion surfaces in CI rather
# than at runtime.
#
# Zone map (directory → role):
#
#   Sources/GoToBed/Scheduler/           service layer   — pure scheduling logic, no UI
#   Sources/GoToBed/Overlay/             overlay-ui      — presentation only; no settings or scheduler
#   Sources/GoToBed/UI/                  settings-ui     — settings views; no overlay or scheduler
#   Sources/GoToBed/AppEnvironment.swift
#   Sources/GoToBed/SettingsWindowController.swift
#                                        app-lifecycle / composition root — the only files
#                                        allowed to wire all zones together.
#                                        SettingsWindowController lives here (not in UI/)
#                                        because window lifecycle is a composition-root concern.
#
# GoToBedCore (Sources/GoToBedCore/) boundary is enforced separately by
# scripts/check-core-purity.sh.
#
# Runs in CI and `make validate` (see Makefile).

set -euo pipefail
cd "$(dirname "$0")/.."

FAIL=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# check_excludes <zone_dir> <zone_label> <type1> [type2 ...]
#   Greps <zone_dir> for any of the given type names (word-boundary match).
#   Prints an error and increments FAIL for each type found.
check_excludes() {
    local zone_dir="$1"
    local zone_label="$2"
    shift 2
    local types=("$@")

    if [ ! -d "$zone_dir" ]; then
        echo "WARNING: $zone_dir not found — skipping $zone_label check." >&2
        return
    fi

    echo "==> Checking $zone_label ($zone_dir) for forbidden cross-zone type references..."

    local zone_ok=1
    for type in "${types[@]}"; do
        # -w: word-boundary match; -l: list file names only (for the error message)
        if grep -rn --include="*.swift" -w "$type" "$zone_dir" 2>/dev/null; then
            echo "ERROR: $zone_label must not reference '$type'." >&2
            zone_ok=0
        fi
    done

    if [ "$zone_ok" -eq 1 ]; then
        echo "OK: $zone_label has no forbidden cross-zone references."
    else
        FAIL=$((FAIL + 1))
    fi
}

# ---------------------------------------------------------------------------
# Zone type inventories
# ---------------------------------------------------------------------------

# Types whose definition lives in Sources/GoToBed/Scheduler/
SCHEDULER_TYPES=(
    SchedulerEngine
)

# Types whose definition lives in Sources/GoToBed/Overlay/
OVERLAY_TYPES=(
    OverlayController
    OverlayView
    OverlayWindow
)

# Types whose definition lives in Sources/GoToBed/UI/
SETTINGS_UI_TYPES=(
    AppearanceEditor
    ScheduleEditorView
    SettingsView
    WeekdayPicker
)

# Types whose definition lives at the composition-root level alongside
# AppEnvironment.swift (Sources/GoToBed/*.swift, not in any subdirectory zone).
# Scheduler and Overlay zones must not reach into the composition root.
COMPOSITION_ROOT_TYPES=(
    SettingsWindowController
)

# ---------------------------------------------------------------------------
# Rules
# ---------------------------------------------------------------------------

# Rule 1: Scheduler zone must not reference overlay, settings-ui, or
#         composition-root types. The scheduler is a pure service; UI and
#         windowing concerns must never leak in.
check_excludes "Sources/GoToBed/Scheduler" "scheduler-zone" \
    "${OVERLAY_TYPES[@]}" "${SETTINGS_UI_TYPES[@]}" "${COMPOSITION_ROOT_TYPES[@]}"

# Rule 2: Overlay zone must not reference settings-ui, composition-root types,
#         or the scheduler. The overlay is a presentation component wired by the
#         composition root; it must remain independent of settings and scheduling.
check_excludes "Sources/GoToBed/Overlay" "overlay-zone" \
    "${SETTINGS_UI_TYPES[@]}" "${COMPOSITION_ROOT_TYPES[@]}" "${SCHEDULER_TYPES[@]}"

# Rule 3: Settings-ui zone must not reference overlay types or the scheduler.
#         Settings views access the overlay or scheduler only through
#         AppEnvironment (the composition root), never by direct type reference.
check_excludes "Sources/GoToBed/UI" "settings-ui-zone" \
    "${OVERLAY_TYPES[@]}" "${SCHEDULER_TYPES[@]}"

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------

echo ""
if [ "$FAIL" -gt 0 ]; then
    echo "ERROR: $FAIL zone layering violation(s) detected." >&2
    echo "       Cross-zone dependencies within GoToBedKit must flow through" >&2
    echo "       AppEnvironment (the composition root), not via direct type" >&2
    echo "       references. See scripts/check-zone-layering.sh for the rules." >&2
    exit 1
fi

echo "OK: All GoToBedKit zone boundaries are intact."
