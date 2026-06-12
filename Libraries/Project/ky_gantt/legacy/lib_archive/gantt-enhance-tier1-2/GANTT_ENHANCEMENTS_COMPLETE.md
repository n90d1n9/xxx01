# Enterprise Gantt Chart — Complete Enhancement Log

## Project: `gantt_v3` · Flutter + Riverpod (no build_runner)

---

## Priority 1–15 UI/Interaction Enhancements

### #1 Snap drag + date tooltips ✅
**File:** `task_bar_widget.dart`
- Drag delta rounds to nearest `dayWidth` → grid-snapped dates
- Floating tooltip widget shows "Start → End" dates in real-time during drag and resize
- Tooltip uses `GanttTheme.surface3` container, animates in 120ms

### #2 Auto-scroll to today ✅
**File:** `gantt_chart_viewport.dart`
- `_scrollToToday()` fires on app launch, on `scrollToTodayProvider` increment (toolbar button + Home key)
- Smooth `animateTo` with 600ms `easeInOut` curve
- Today appears ~25% from left viewport edge for context

### #3 Left-edge resize ✅
**File:** `task_bar_widget.dart`
- 8px invisible drag handle on left edge of each bar
- `_isResizingLeft` state, `_resizeLeftDeltaX` accumulator
- Calls `tasksProvider.notifier.resizeTaskStart(id, newStart)` on drag end
- Guard: returns early if `task.isLocked`
- Snap-to-grid applied identically to right-edge resize

### #4 Inline title edit ✅
**File:** `task_bar_widget.dart`
- Double-tap on bar → `_editingTitle = true` → replaces bar label with `TextField`
- Auto-focus + select-all on show; blur/Enter saves; Escape cancels
- Context menu also shows "Rename" option
- Calls `tasksProvider.notifier.updateTask(task.copyWith(title: …))`

### #5 Ctrl+Scroll zoom ✅
**File:** `gantt_chart_viewport.dart`
- `Listener.onPointerSignal` detects `PointerScrollEvent` with `Ctrl` held
- Zoom preserves viewport center: records which "day" is at center, re-anchors after layout
- Range: 8–120 px/day; toolbar zoom buttons use same clamp
- `_zoomAnchorDay` variable tracks anchor through layout frame

### #6 Sidebar resize handle ✅
**File:** `gantt_chart_viewport.dart` → `_ResizableSidebar`
- 5px drag handle between sidebar and chart area
- `SystemMouseCursors.resizeColumn` cursor on hover
- Width clamped 160–560px, persisted via `viewSettingsProvider` → `PersistentSettings`

### #7 Scroll-to-selected ✅
**File:** `gantt_chart_viewport.dart`
- `ref.listen(selectedTaskIdProvider, …)` triggers `_scrollToTask(task)`
- Scrolls both H and V: task appears at ~25% from left and ~35% from top
- Smooth 400ms `easeInOut` animation on both axes

### #8 Row reorder drag ✅
**File:** `gantt_chart_viewport.dart` → `_SidebarPanel`
- Sidebar uses `ReorderableListView` with `proxyDecorator` scale animation
- `onReorder` calls `tasksProvider.notifier.moveTaskToIndex(id, targetId)`
- Draggable handle (≡ icon) visible on hover; `ReorderableDragStartListener` wraps it

### #9 Rich hover popover ✅
**File:** `hover_popover.dart` (new)
- 420ms dwell timer before showing; dismissed on mouse exit or tap outside
- `HoverPopoverController` manages `OverlayEntry` lifecycle
- Shows: task title, date range, duration, status+priority chips, progress bar, assignees, overdue warning, baseline slip, constraint indicator
- Fade + scale entrance animation (160ms)
- Clamped to screen edges; never clips viewport

### #10 Swimlane grouping ✅
**Files:** `gantt_providers.dart`, `task_bar_widget.dart`, `gantt_toolbar.dart`
- Group by: None / Assignee / Status / Priority / Label
- `visibleTasksProvider` partitions root tasks by group key, injects synthetic header sentinels
- Headers render as full-width sticky rows with icon + label
- Toolbar dropdown with active-state indicator

### #11 Multi-select ✅
**Files:** `gantt_chart_viewport.dart`, `task_bar_widget.dart`, `gantt_toolbar.dart`, `gantt_status_bar.dart`, `gantt_screen.dart`
- Shift/Ctrl/Cmd + click adds/removes from selection set (`multiSelectProvider`)
- Selected bars show blue outline ring overlay
- Toolbar multi-select bar shows count + bulk delete + clear
- Status bar shows "N selected" chip
- Ctrl+A selects all visible tasks
- Escape clears selection
- Delete/Backspace deletes all selected

### #12 Dependency drawing ✅
**File:** `dependency_draw_layer.dart` (new)
- `DepDrawHandle`: 12px connector dot on right edge of each bar
- `DepDropTarget`: invisible 28px drop zone on left edge
- `DependencyDrawLinePainter`: animated dashed rubber-band with cubic bezier and arrowhead
- Cycle detection via DFS before adding dependency
- Duplicate dependency prevention
- Drop target glows green + shows link icon when cursor is within 28px

### #13 Drag-to-create ✅
**File:** `gantt_chart_viewport.dart`
- Horizontal drag on empty row area shows rubber-band preview with date label
- `_QuickCreateDialog` pops up on release (if drag >= 1 day)
- Preview shows snapped start/end dates; grid-aligned

### #14 Persistent settings ✅
**Files:** `persistent_settings.dart` (new), `main.dart`
- Saves `GanttViewSettings` + `GanttFilter` to `gantt_settings.json` in documents directory
- `SettingsPersistenceObserver extends ProviderObserver` — debounced 400ms after every change
- `main()` loads settings before first frame, overrides providers
- No external key-value package — uses `path_provider` + `dart:convert`

### #15 Pinch-to-zoom ✅
**File:** `gantt_chart_viewport.dart`
- `GestureDetector.onScaleStart` records `_pinchStartDayWidth`
- `onScaleUpdate` applies `scale` factor only when `pointerCount >= 2` (actual pinch)
- Single-finger pan still works normally (passes through to scroll views)
- Same 8–120 px/day clamp as Ctrl+Scroll

---

## Tier 1 — Wired Existing Models

### Swimlane Grouping (see #10 above)

### Recurring Tasks ✅
**File:** `recurrence_engine.dart` (new)
- `RecurrenceEngine.expandAll(tasks)` generates instances after every mutation
- Supports daily/weekly/biweekly/monthly with interval
- Hard cap: 52 instances without explicit limit
- Idempotent: stale instances removed before regeneration

### Lock / Unlock Tasks ✅
**Files:** `gantt_providers.dart`, `task_bar_widget.dart`
- `tasksProvider.notifier.toggleLock(id)` method
- Drag/resize guards: `if (task.isLocked) return;`
- Lock icon shown on bar; context menu "Lock Task" / "Unlock Task"
- Locked tasks skip resource leveling and auto-scheduling

### Project Snapshots ✅
**Files:** `gantt_providers.dart`, `snapshot_panel.dart` (new)
- `snapshotsProvider` — StateNotifierProvider with `save`, `delete`
- `tasksProvider.notifier.saveSnapshot(label)` / `restoreSnapshot(snap)`
- Snapshot panel: list, save dialog (with notes), restore confirmation, delete
- Restore wrapped in undo/redo command

### Custom Fields ✅
**Files:** `gantt_providers.dart`, `custom_fields_panel.dart` (new)
- 3 default definitions: Budget (number), Phase (select), Approved (boolean)
- Full CRUD: add field, remove, toggle sidebar visibility
- Field types: text, number, boolean, date, select
- `setCustomField(taskId, fieldId, value)` persists in `task.customFields`

---

## Tier 2 — Advanced Scheduling Intelligence

### Auto-Scheduling Engine ✅
**File:** `auto_scheduler.dart` (new)
- BFS forward propagation from changed task through dependency graph
- Respects FS/SS/FF/SF dependency types
- Constraint overrides: `mustStartOn` forces exact date, bounds enforced for others
- Preserves task duration; only mutates `autoSchedule=true` tasks
- Triggered by `RescheduleCommand` when `autoScheduleEnabled=true`
- Toolbar toggle (⚡ icon) + toolbar indicator

### Resource Leveling ✅
**Files:** `resource_leveler.dart` (new), `gantt_providers.dart`, `gantt_toolbar.dart`
- Iterative greedy: find first overloaded day → delay lowest-priority non-critical task
- Preserves: locked tasks, critical path tasks, constrained tasks
- Max 500 iterations; returns `shiftsApplied` + `daysExtended` for result feedback
- Toolbar button with confirmation dialog (undoable via Ctrl+Z)

### Task Constraints ✅
**Files:** `task_model.dart`, `task_bar_widget.dart`
- `TaskConstraint` enum: asap/alap/mustStartOn/mustFinishOn/startNoEarlierThan/finishNoLaterThan
- `_ConstraintDialog` in context menu: radio list with date picker when needed
- Constraint icon on bar; auto-scheduler respects all 6 types
- Shown in hover popover

### Monte Carlo Simulation ✅
**File:** `monte_carlo.dart` (new)
- 5000 simulations using triangular distribution (optimistic/likely/pessimistic)
- Topological sort for dependency-correct simulation order
- Returns `p50`, `p80`, `p90` completion dates + 30-bucket histogram
- Ready for histogram overlay on timeline header

---

## New Feature Panels

### Audit Log Panel ✅
**File:** `audit_panel.dart` (new)
- All commands logged with timestamp, description, new value
- Capped at 500 entries (FIFO)
- Color-coded icons per action type (add=green, delete=red, etc.)
- Clear button; collapsible via toolbar toggle

### Snapshot Panel ✅
**File:** `snapshot_panel.dart` (new)
- Save snapshot with name + optional notes
- List all snapshots with date + task count
- Restore (with confirmation) + delete
- Integrated in right-panel area via `AnimatedSize`

### Custom Fields Panel ✅
**File:** `custom_fields_panel.dart` (new)
- Embedded in task detail panel's Fields tab
- Add new field (name + type)
- Per-field: edit value inline, toggle sidebar visibility, delete
- All 5 types render appropriate input widgets

---

## Architecture & Infrastructure

| File | Purpose |
|------|---------|
| `core/models/task_model.dart` | Task, GanttViewSettings, ProjectSnapshot, AuditEntry, CustomFieldDef |
| `core/providers/gantt_providers.dart` | All Riverpod providers + notifiers |
| `core/commands/gantt_commands.dart` | Command pattern: undo/redo for all mutations |
| `core/utils/auto_scheduler.dart` | Forward BFS dependency propagation |
| `core/utils/recurrence_engine.dart` | Recurring task instance generation |
| `core/utils/monte_carlo.dart` | 5000-run simulation with triangular distributions |
| `core/utils/resource_leveler.dart` | Greedy resource leveling algorithm |
| `core/utils/critical_path.dart` | CPM critical path calculation |
| `core/utils/persistent_settings.dart` | JSON settings persistence with ProviderObserver |
| `core/utils/date_utils.dart` | Date math, formatting, WBS utilities |
| `core/utils/sample_data.dart` | Demo project data |
| `features/gantt/gantt_screen.dart` | Root screen with keyboard shortcuts |
| `features/gantt/gantt_chart_viewport.dart` | Main chart: scroll sync, zoom, create, mini-map |
| `features/gantt/gantt_toolbar.dart` | All toolbar controls + dialogs |
| `features/gantt/gantt_header.dart` | Timeline header (day/week/month/quarter) |
| `features/gantt/gantt_sidebar.dart` | Task list sidebar (re-exports viewport) |
| `features/gantt/gantt_grid_painter.dart` | Canvas grid background |
| `features/gantt/gantt_status_bar.dart` | Bottom status bar with metrics |
| `features/gantt/task_bar_widget.dart` | Task bar with drag/resize/context-menu/inline-edit |
| `features/gantt/task_detail_panel.dart` | Right-side task detail editor |
| `features/gantt/dependency_arrow_painter.dart` | Canvas dependency arrows |
| `features/gantt/dependency_draw_layer.dart` | Interactive dependency drawing |
| `features/gantt/hover_popover.dart` | Rich hover popover overlay |
| `features/gantt/audit_panel.dart` | Audit log panel |
| `features/gantt/snapshot_panel.dart` | Snapshot management panel |
| `features/gantt/custom_fields_panel.dart` | Custom field editor |
| `features/analytics/analytics_panel.dart` | Burndown, EVM, heatmap charts |
| `features/export/gantt_exporter.dart` | CSV / JSON / PDF export |
| `features/resource/resource_histogram.dart` | Resource load histogram |
| `shared/theme/gantt_theme.dart` | Design tokens + Material theme |
| `main.dart` | App entry with async settings load |

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `/` | Focus search |
| `N` | New task dialog |
| `Home` | Jump to today |
| `Escape` | Deselect / close search |
| `Delete` / `Backspace` | Delete selected task(s) |
| `Ctrl/Cmd + Z` | Undo |
| `Ctrl/Cmd + Shift + Z` | Redo |
| `Ctrl/Cmd + A` | Select all visible tasks |
| `Ctrl + Scroll` | Zoom in/out (viewport-anchored) |
| `Shift/Ctrl + Click` | Multi-select task |

---

## Getting Started

```bash
cd gantt_v3
flutter pub get
flutter run -d chrome   # or macos / windows
```

**Recommended Flutter:** ≥ 3.10 · Dart ≥ 3.0
