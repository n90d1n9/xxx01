# Priority 1 Fixes — Changelog

All 5 critical gaps closed. No breaking changes to existing APIs.

---

## Fix 1 — Real File Export (was: debugPrint stub)

**File:** `lib/features/export/gantt_exporter.dart`
**Packages added:** `share_plus: ^10.0.0`

`_downloadText()` previously called `debugPrint()` and did nothing.
Replaced with platform-adaptive `_saveAndShare()`:

- macOS/Windows/Linux: writes to Documents folder, shows SnackBar with path + "Open folder" action
- iOS/Android: saves to temp dir, opens OS share sheet via `Share.shareXFiles`
- Error: shows red error SnackBar with reason

CSV and JSON export now produce real files.

---

## Fix 2 — Inter Font via google_fonts (was: commented-out asset bundle)

**Files:** `pubspec.yaml`, `lib/shared/theme/gantt_theme.dart`
**Package added:** `google_fonts: ^6.2.1`

- All 231 hardcoded `fontFamily: 'Inter'` strings removed from every .dart file
- `GanttTheme.dark` now calls `GoogleFonts.interTextTheme()` — Inter applied globally
- Added `GanttTheme.inter(...)` static helper for one-off TextStyle construction
- No font asset files required; google_fonts loads from network with disk cache

---

## Fix 3 — Monte Carlo Overlay Actually Runs (was: return null stub)

**File:** `lib/features/portfolio/portfolio_view.dart`

`_monteCarloResultProvider` always returned null. Now calls:

    MonteCarloEngine.run(tasks, simulations: 2000)

The portfolio S-curve view now shows live P50/P80/P90 markers and histogram
computed from real task data.

---

## Fix 4 — Task Validation (was: no guards)

**New file:** `lib/core/utils/task_validator.dart` (152 lines)
**Updated:** gantt_providers.dart, gantt_toolbar.dart, task_detail_panel.dart

TaskValidator.validate() checks:
- Title: required, 2-200 chars
- Dates: end >= start, duration <= 5 years
- Estimated hours: 0-100,000
- Progress: 0.0-1.0
- MC 3-point estimates: optimistic <= likely, pessimistic >= likely
- Constraints: date required for mustStartOn / mustFinishOn / SNET / FNLT
- Dependencies: no self-dep, detects 2-node cycles

TasksNotifier.addTask() and updateTask() now return TaskValidationResult.
Invalid tasks are silently dropped — callers inspect the result.

AddTaskDialog shows inline errorText on title, date, and hours fields.

---

## Fix 5 — Unit Tests (was: zero test files)

6 new test files, ~1,150 lines, 112 test cases:

  test/core/utils/critical_path_test.dart     - 14 tests (CPM algorithm)
  test/core/utils/auto_scheduler_test.dart    - 15 tests (FS/SS/FF, chains, constraints)
  test/core/utils/resource_leveler_test.dart  - 11 tests (overload, priority, locking)
  test/core/utils/monte_carlo_test.dart       - 17 tests (percentiles, histogram, chains)
  test/core/utils/task_validator_test.dart    - 32 tests (all validation rules)
  test/core/providers/gantt_providers_test.dart - 23 tests (notifier integration)

Run with: flutter test

---

## Dependency changes (pubspec.yaml)

Added:
  share_plus: ^10.0.0
  google_fonts: ^6.2.1

No packages removed.
