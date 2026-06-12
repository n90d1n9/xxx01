# ky_scrumboard

Reusable Flutter scrumboard package for Kaysir delivery workflows.

## Features

- Testable `ScrumBoardController` for task add, edit, delete, move, filtering, and board metrics.
- Repository boundary for loading and persisting tasks without coupling the board to API or local storage.
- Activity history for task create, update, move, reorder, priority, note, delete, and board replacement events.
- Activity timeline filters summarize recent activity types for faster board auditing.
- Board configuration for titles, subtitles, visible lanes, custom status labels, filters, policies, and insights visibility.
- Reusable board filter model for query, status, priority, assignee, task sorting, and saved view presets.
- Active filter chips expose current search, lane, priority, assignee, and sort facets with one-tap removal.
- Status filter chips show live lane counts, reflecting active search, priority, and assignee facets.
- Filter-aware empty lanes explain hidden work and offer a lane-level way back to all tasks.
- Stable lane ordering with drag-and-drop placement before cards or at the end of a lane.
- WIP-limited lanes include compact capacity meters for fast workload scanning.
- Lane health chips summarize overdue, due-soon, and aging review work directly in column headers.
- Collapsible lanes keep dense boards scannable while preserving task and story point summaries.
- Board-level collapse and expand controls make dense visible lanes easier to scan in one action.
- Task details open in a responsive side panel for faster review without losing board context.
- Task detail panels include quick lane move and priority menus for lightweight triage.
- Task detail panels capture lightweight notes directly into task activity history.
- Task detail panels reuse filterable activity timelines for per-task audit review.
- Task details reuse delivery signal badges so due-date and lane-age context follows the card into the dialog.
- Bulk move previews show movable, unchanged, and WIP-blocked selections before applying changes.
- Bulk task selection, including lane-level visible selection, for moving work, changing priority, or deleting multiple cards with confirmation and undo recovery.
- Task cards surface planned, due-soon, and overdue date badges for faster delivery scanning.
- Task cards surface in-progress and review aging badges using activity-derived lane age.
- Sprint model for goal, date window, capacity, velocity target, and sprint health insights.
- Public task models for status, priority, labels, story points, assignee, and dates.
- Workflow policy support for advisory or enforced WIP limits, due-soon thresholds, aged review warnings, and workload signals.
- Responsive Material 3 board screen with searchable columns, drag-and-drop movement, task dialogs, and sprint intelligence.

## Usage

```dart
import 'package:ky_scrumboard/ky_scrumboard.dart';

const ScrumBoardScreen();
```

Use `ScrumBoardController` when the host app needs to seed tasks or connect the board to persistence.

```dart
final repository = InMemoryScrumTaskRepository(initialTasks: tasks);
final activityRepository = InMemoryScrumActivityRepository();
final controller = ScrumBoardController(
  repository: repository,
  activityRepository: activityRepository,
  activityActor: 'Delivery Lead',
);

await controller.loadBoard();
```

```dart
final config = ScrumBoardConfig(
  policy: ScrumWorkflowPolicy(
    enforceWipLimits: true,
    wipLimits: {ScrumTaskStatus.inProgress: 4},
  ),
);

final controller = ScrumBoardController(config: config, initialTasks: tasks);
final result = controller.placeTaskWithResult(
  taskId,
  ScrumTaskStatus.inProgress,
);

if (!result.accepted) {
  debugPrint(result.message);
}
```

```dart
const ScrumBoardScreen(
  config: ScrumBoardConfig(
    title: 'Ops Sprint',
    statuses: [ScrumTaskStatus.todo, ScrumTaskStatus.inProgress],
    statusLabels: {ScrumTaskStatus.todo: 'Ready'},
    activityFeedLimit: 3,
    showPriorityFilter: true,
    showAssigneeFilter: true,
    showSortControl: true,
    showViewPresets: true,
    showBulkActions: true,
    showInsights: false,
  ),
);
```

```dart
const ScrumBoardScreen(
  config: ScrumBoardConfig(
    initialViewPresetId: 'my-critical',
    viewPresets: [
      ScrumBoardViewPreset(
        id: 'my-critical',
        label: 'My Critical',
        description: 'Critical work assigned to Alya.',
        filter: ScrumBoardFilter(
          priorities: {ScrumTaskPriority.critical},
          assignees: {'Alya'},
          sort: ScrumTaskSort.priority,
        ),
      ),
    ],
  ),
);
```

```dart
final filteredTasks = controller.filteredTasks(
  const ScrumBoardFilter(
    status: ScrumTaskStatus.todo,
    priorities: {ScrumTaskPriority.critical},
    assignees: {'Alya'},
    sort: ScrumTaskSort.dueDate,
  ),
);
```

```dart
ScrumBoardScreen(
  config: ScrumBoardConfig(
    sprint: ScrumSprint(
      id: 'sprint-1',
      name: 'Foundation Sprint',
      goal: 'Make delivery visible',
      startAt: DateTime(2026, 1, 1),
      endAt: DateTime(2026, 1, 14),
      capacityStoryPoints: 24,
      velocityTargetStoryPoints: 18,
    ),
  ),
);
```
