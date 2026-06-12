# ky_gantt

Reusable Flutter Gantt chart package for Kaysir project-management screens.

The supported package surface is intentionally small:

- `GanttTask` for chart task data.
- `KyGanttViewMode` for day/week/month/quarter density.
- `KyGanttChart` for the interactive timeline.
- `KyGanttDependencyLayer` for reusable dependency connectors.
- `KyGanttGrid` for reusable themed timeline grid layers.
- `KyGanttMilestoneMarker` for reusable milestone diamonds.
- `KyGanttTaskBar` for reusable task bar visuals.
- `KyGanttTaskList` helpers for tested task-list rows.
- `KyGanttTodayMarker` for reusable current-day timeline indicators.
- range-aware task layout utilities for clipping bars to the visible timeline.
- task-tree flattening utilities.

Legacy experiments from earlier Gantt prototypes are preserved under
`legacy/lib_archive`. They are intentionally outside `lib` so package analysis
and downstream app builds only validate the supported API.

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart';

KyGanttChart(
  tasks: [
    GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 5),
      progress: 0.45,
      color: Colors.blue,
    ),
    GanttTask(
      id: 'launch',
      title: 'Launch Readiness',
      startDate: DateTime(2026, 1, 12),
      endDate: DateTime(2026, 1, 12),
      kind: GanttTaskKind.milestone,
      color: Colors.deepPurple,
    ),
  ],
  dateRange: DateTimeRange(
    start: DateTime(2026, 1, 1),
    end: DateTime(2026, 1, 31),
  ),
  viewMode: KyGanttViewMode.week,
  today: DateTime(2026, 1, 12),
  initialFocusDate: DateTime(2026, 1, 12),
  onTaskSelected: (taskId) {},
);
```

Tasks that begin before or end after the supplied `dateRange` are clipped to
the visible range. Tasks fully outside the range remain in the task list, but no
timeline bar is rendered for them.

Date ranges are normalized internally and capped to a practical maximum so
unusually long schedules do not create oversized timeline geometry.

Timeline grid lines and weekend bands are painted instead of inflated as one
widget per day, keeping long schedules lighter to render.

Pass `today` when rendering historical previews, demos, or widget tests that
need a deterministic current-day marker. When omitted, the chart uses the
current local date.

Pass `initialFocusDate` to center the first horizontal viewport near a
milestone, selected task, or current operating date on long timelines.

The task list pane stays fixed while the timeline scrolls horizontally, so task
names remain visible while reviewing long schedules.

When the chart is placed in a bounded-height container, the header remains
visible and the task rows/timeline rows scroll vertically together.
