# Production-Grade Gantt Chart — Flutter

A fully production-ready, enterprise-grade Gantt chart built with Flutter + Riverpod.
No `build_runner` required. Zero code generation dependencies.

---

## Architecture Overview

```
lib/
├── core/
│   ├── models/
│   │   └── task_model.dart          ← All data models (Task, Assignee, Comment, etc.)
│   ├── providers/
│   │   └── gantt_providers.dart     ← All Riverpod providers (NotifierProvider, StateProvider, etc.)
│   └── utils/
│       ├── date_utils.dart          ← Date math, formatting, pixel-offset helpers
│       └── critical_path.dart       ← CPM algorithm (forward/backward pass)
│
├── features/
│   └── gantt/
│       ├── gantt_screen.dart        ← Top-level screen, assembles everything
│       ├── gantt_toolbar.dart       ← Toolbar: search, filter, zoom, view mode, add task
│       ├── gantt_chart_viewport.dart← Main chart area: synchronized scroll, rows, bars
│       ├── gantt_header.dart        ← Month/week/day header (CustomPainter)
│       ├── gantt_grid_painter.dart  ← Background grid (weekends, today, gridlines)
│       ├── task_bar_widget.dart     ← Individual task bar (drag, resize, milestone)
│       ├── dependency_arrow_painter.dart ← CPM dependency arrows (orthogonal + arrowhead)
│       ├── task_detail_panel.dart   ← Slide-in right panel (details, comments, progress)
│       └── gantt_status_bar.dart    ← Bottom stats bar
│
├── shared/
│   └── theme/
│       └── gantt_theme.dart         ← Full ThemeData, colors, typography, animations
│
└── main.dart                        ← App entry point (ProviderScope)
```

---

## Key Features

### ✅ Core Functionality
- **Hierarchical tasks** — parent/child with expand/collapse tree
- **Drag to reschedule** — horizontal drag moves task dates
- **Drag to resize** — right-edge handle extends task duration
- **Milestone markers** — diamond shape with glow effect
- **Dependency arrows** — orthogonal arrows with arrowheads between tasks
- **Critical Path Method (CPM)** — forward/backward pass, zero-float highlighting

### ✅ View Controls
- **4 view modes**: Day, Week, Month, Quarter (adjusts `dayWidth`)
- **Zoom in/out** — pixel-level day width control (16px–80px)
- **Toggle weekends** — hide/show weekend shading
- **Toggle critical path** — red highlights on critical tasks
- **Toggle dependencies** — show/hide arrow overlays
- **Collapsible sidebar** — animated show/hide

### ✅ Filtering & Search
- Real-time search across title and description
- Multi-select status filter chips
- Multi-select priority filter chips
- Active filter badge on toolbar button
- Filter count indicator

### ✅ Task Detail Panel
- Slide-in animated side panel
- Inline title editing
- Progress slider (syncs with task status)
- Status & priority chips
- Timeline display (start, end, duration)
- Description text field
- Assignee list with avatars
- Label chips
- Dependency list (with live task references)
- Comments tab with add comment

### ✅ Performance
- `ListView.builder` with `itemExtent` for O(1) row layout
- `CustomPainter` for grid and header (no widget tree per cell)
- `SingleTickerProviderStateMixin` per task bar (no global animation controller)
- `Provider.family` for depth calculation
- Derived providers (filteredTasksProvider, visibleTasksProvider, etc.) only recompute when their inputs change
- `ValueKey` on task bars to preserve widget state across rebuilds

### ✅ Scroll Synchronization
The viewport uses 4 synchronized scroll controllers:
- `_hScrollCtrl` — chart body horizontal
- `_headerScrollCtrl` — header horizontal (mirrors body)
- `_vScrollCtrl` — chart body vertical
- `_sidebarScrollCtrl` — sidebar vertical (mirrors body)

Sync uses mutex booleans (`_syncingHScroll`, `_syncingVScroll`) to prevent recursive callbacks.

---

## State Management (Riverpod, no build_runner)

```dart
// Read tasks
final tasks = ref.watch(tasksProvider);

// Add a task
ref.read(tasksProvider.notifier).addTask(task);

// Select a task (opens detail panel)
ref.read(selectedTaskIdProvider.notifier).state = taskId;

// Change view mode
ref.read(viewSettingsProvider.notifier).update(
  (s) => s.copyWith(viewMode: GanttViewMode.month, dayWidth: 20),
);

// Apply filter
ref.read(filterProvider.notifier).update(
  (f) => f.copyWith(statuses: {TaskStatus.inProgress}),
);
```

### Provider Graph
```
tasksProvider (NotifierProvider)
    └── filteredTasksProvider (Provider) ← filterProvider
        └── visibleTasksProvider (Provider) ← expand/collapse state
            └── Used by GanttChartViewport + GanttSidebar

criticalPathIdsProvider (Provider)
    ← tasksProvider + viewSettingsProvider.showCriticalPath

projectDateRangeProvider (Provider) ← tasksProvider
    └── Used by GanttChartViewport for total canvas size

selectedTaskProvider (Provider) ← selectedTaskIdProvider + tasksProvider
    └── Used by TaskDetailPanel
```

---

## Task Model Fields

```dart
Task({
  required String id,
  required String title,
  String? description,
  required DateTime startDate,
  required DateTime endDate,
  TaskStatus status,           // backlog/todo/inProgress/review/done/onHold/cancelled
  TaskPriority priority,       // low/medium/high/urgent/critical
  double progress,             // 0.0 – 1.0
  Color? color,                // custom bar color (fallback: priority.color)
  bool isMilestone,            // renders as diamond
  String? parentId,            // for tree hierarchy
  List<String> dependencyIds,  // task IDs this task depends on (finish-to-start)
  List<Assignee> assignees,
  List<TaskAttachment> attachments,
  List<TaskComment> comments,
  List<String> labels,
  bool isExpanded,             // controls child visibility
  DateTime? reminderDate,
  required DateTime createdAt,
  required DateTime updatedAt,
})
```

---

## Integration into Existing App

### 1. Add dependencies to `pubspec.yaml`
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  uuid: ^4.4.0
```

### 2. Wrap app with `ProviderScope`
```dart
void main() => runApp(ProviderScope(child: MyApp()));
```

### 3. Use `GanttScreen` anywhere
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => const GanttScreen()));
```

### 4. Pre-populate with your own tasks
Override `TasksNotifier.build()` to load from your data source:
```dart
class MyTasksNotifier extends TasksNotifier {
  @override
  List<Task> build() => myRepository.loadTasks();
}

// Override the provider:
final tasksProvider = NotifierProvider<MyTasksNotifier, List<Task>>(
  MyTasksNotifier.new,
);
```

### 5. Persist tasks (Hive / SQLite / REST)
```dart
class PersistedTasksNotifier extends TasksNotifier {
  @override
  List<Task> build() {
    // Load async — use AsyncNotifier for production
    return [];
  }

  @override
  Future<void> addTask(Task task) async {
    await db.insert(task.toJson());
    super.addTask(task);
  }
}
```

---

## Fonts

The theme uses **Inter** (by Rasmus Andersson).
Download from https://rsms.me/inter/ and place in `assets/fonts/`:
- `Inter-Regular.ttf` (400)
- `Inter-Medium.ttf` (500)
- `Inter-SemiBold.ttf` (600)
- `Inter-Bold.ttf` (700)

Or replace `fontFamily: 'Inter'` in `GanttTheme` with a Google Fonts package.

---

## Extending

### Add a new view mode (e.g., Year)
1. Add `year` to `GanttViewMode` enum
2. Handle in `_ViewModeSwitcher.onTap` with `dayWidth = 6`
3. Add rendering logic in `GanttHeaderPainter._drawTopRow` for quarters

### Add drag-to-create
Wrap the grid in a `GestureDetector`, track `onHorizontalDragStart`/`End`, 
compute dates from pixel positions using `GanttDateUtils.dayOffset`, then call
`ref.read(tasksProvider.notifier).addTask(...)`.

### Add resource/swimlane rows
Add a `groupBy` field to tasks and a `groupedTasksProvider` that partitions
`visibleTasksProvider` by assignee. Render a group header row between groups.

### Export to PDF/Excel
Use the existing `ExportButton` widget pattern. Wire it to the `tasksProvider`
and use packages like `pdf` or `excel`.
