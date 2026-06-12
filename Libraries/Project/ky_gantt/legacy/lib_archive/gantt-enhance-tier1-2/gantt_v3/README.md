# Enterprise Gantt Chart — Flutter

A production-grade, feature-complete Gantt chart application built with Flutter and Riverpod.

## ✨ Features

### Core Gantt
- **4 view modes**: Day, Week, Month, Quarter — auto-adjusts column widths
- **Hierarchical tasks**: Parent/child with expand/collapse, WBS codes (1.2.3)
- **Drag & drop rescheduling**: Smooth drag with snap-to-day precision
- **Resize bars**: Drag right edge to extend end date
- **Milestone diamonds**: Animated hover glow, diamond rotation

### Dependencies
- **4 dependency types**: FS, SS, FF, SF (Finish-to-Start, etc.)
- **Lag/lead support**: Positive or negative day offsets
- **Curved SVG arrows**: Route around tight spaces, red on critical path

### Critical Path Method (CPM)
- **Forward + backward pass**: Correct float calculation
- **Topological sort**: Handles complex dependency graphs
- **Visual overlay**: Red bars + arrows for zero-float tasks

### Analytics
- **Burndown chart**: Actual vs ideal remaining work
- **Earned Value Management**: PV, EV, AC, SPI, CPI, SV, CV, EAC
- **Activity heatmap**: GitHub-style 12-week completion grid

### Resource Management
- **Per-day load histogram**: Stacked hours per assignee
- **Capacity lines**: Dashed capacity indicator
- **Overload detection**: Hatched bars when >100% allocated
- **Color coding**: Green / amber / red thresholds

### Task Detail Panel
- **Inline progress slider**: Updates in real-time
- **3 tabs**: Details, Activity (comments), Time logging
- **Checklist**: Per-item toggle with progress bar
- **Baseline comparison**: Slip days calculation
- **Comment threads**: Timestamp + avatar
- **Time entries**: Log & display actual hours

### Export
- **CSV**: Full task data, WBS, dates, progress, assignees
- **JSON**: Structured export with project metadata
- **PDF preview**: Formatted report with EVM summary stats

### UX Polish
- **Keyboard shortcuts**: ⌘Z undo, ⌘⇧Z redo, Esc deselect, Del delete, / search, N new task
- **Undo/redo**: 100-deep command history (Command pattern)
- **Baseline mode**: Ghost bars showing original schedule
- **Context menu**: Right-click / long-press on any bar
- **Mini-map scrubber**: Draggable viewport navigator
- **Status bar**: Live KPIs (tasks, done, overdue, overall %)
- **Filter sheet**: Status, priority, risk level chips
- **Animated panels**: Slide-in task detail, animated toolbar

## 📦 Dependencies

```yaml
flutter_riverpod: ^2.5.1   # State management (no build_runner)
uuid: ^4.4.0               # ID generation
intl: ^0.19.0              # Date formatting
collection: ^1.18.0        # Collection utilities
path_provider: ^2.1.3      # File export (mobile)
```

## 🗂 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── commands/
│   │   └── gantt_commands.dart         # Command pattern (Undo/Redo)
│   ├── models/
│   │   └── task_model.dart             # All data models
│   ├── providers/
│   │   └── gantt_providers.dart        # Riverpod state
│   └── utils/
│       ├── critical_path.dart          # CPM algorithm
│       ├── date_utils.dart             # Date helpers
│       └── sample_data.dart            # 24 realistic tasks + WBS
├── features/
│   ├── analytics/
│   │   └── analytics_panel.dart        # Burndown, EVM, Heatmap
│   ├── export/
│   │   └── gantt_exporter.dart         # CSV/JSON/PDF export
│   ├── gantt/
│   │   ├── dependency_arrow_painter.dart  # SVG dependency arrows
│   │   ├── gantt_chart_viewport.dart      # Main scrollable chart
│   │   ├── gantt_grid_painter.dart        # Background grid
│   │   ├── gantt_header.dart              # Month/week/day header
│   │   ├── gantt_screen.dart              # Root screen + shortcuts
│   │   ├── gantt_status_bar.dart          # Bottom KPI bar
│   │   ├── gantt_toolbar.dart             # Top toolbar
│   │   ├── task_bar_widget.dart           # Bar/milestone widgets
│   │   └── task_detail_panel.dart         # Slide-in detail panel
│   └── resource/
│       └── resource_histogram.dart        # Load histogram
└── shared/
    └── theme/
        └── gantt_theme.dart           # Dark theme + animations
```

## 🚀 Getting Started

```bash
flutter pub get
flutter run -d chrome   # Web (recommended for desktop features)
flutter run             # Native desktop/mobile
```

## 🎨 Design System

- **Font**: Inter (included in assets)
- **Theme**: Dark-first with indigo accent (`#6366F1`)
- **Color semantics**: Success green, warning amber, danger red, info cyan

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘Z` / `Ctrl+Z` | Undo |
| `⌘⇧Z` / `Ctrl+Shift+Z` | Redo |
| `Esc` | Deselect task |
| `Del` / `Backspace` | Delete selected task |
| `/` | Focus search |
| `N` | New task dialog |

## 📐 Architecture Notes

- **Riverpod** with `StateNotifierProvider` — no `build_runner` or code gen
- **Command pattern** for undo/redo with 100-entry history
- **Virtual scrolling** — only visible rows are rendered
- **Custom painters** for grid, headers, arrows (no canvas libraries)
- **WBS auto-calculation** on every state change
- **Derived providers** for filtered tasks, critical path, resource load
