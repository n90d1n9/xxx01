# ky_kitchen

Reusable kitchen management models for Kaysir FnB operations. The package
focuses on ticket queues, station load, shared FnB pressure states, and
dashboard-ready station board data that can be consumed by kitchen and
restaurant modules.

## Public API

- `KitchenBoardController` coordinates board state, station filters, station
  selection, ticket selection, and visible ticket lists.
- `KitchenBoardScreen` composes the controller with reusable station and ticket
  widgets into a responsive operator surface.
- `KitchenTicket` and `KitchenTicketQueue` model ticket timing, stages, and
  priority ordering.
- `KitchenTicketActionPlan` centralizes legal ticket workflow transitions for
  screens, services, and tests.
- `KitchenTicketActionResult` describes applied, missing, and unavailable action
  outcomes for feedback surfaces and integration logs.
- `KitchenTicketActionFeedbackBanner` renders action outcome feedback with
  optional local undo and dismiss affordances.
- `KitchenTicketActionHistory` and `KitchenTicketActionHistoryList` provide a
  bounded, newest-first operator activity trail.
- `FnbAttentionSignal` and `FnbAttentionSignalQueue` are re-exported for
  kitchen boards that need to contribute to cross-FnB attention feeds.
- `KitchenOperatorContext` identifies the current staff/operator for auditable
  handoff verification records.
- `KitchenHandoffAuditEntry` and `KitchenHandoffAuditList` retain recently
  served handoff verification summaries after active checklist state is pruned.
- `KitchenStationLoad` derives per-station pressure from open tickets.
- `KitchenStationBoard` turns station metadata plus a queue into summaries,
  filters, priority queues, and dashboard-ready totals.
- `KitchenServiceAlertSummary` adapts active tickets into the shared
  `FnbServiceAlertSummary` rollup for consistent alert triage across FnB
  surfaces, including shared lifecycle counts for actionable, snoozed, and
  resolved alerts.
- `KitchenStationPressureCallout` presents the shared top-station pressure
  signal as a focused operator shortcut.
- `KitchenTicketCard` and `KitchenTicketQueueList` provide reusable production
  queue surfaces for station dashboards and operator screens.
- Shared station, pressure, menu, and recipe models are re-exported from
  `ky_fnb_core`.
- `KitchenRecipeProductionEntry` is a kitchen-facing alias for the shared
  `FnbRecipeProductionEntry` core model.
- `KitchenRecipeProductionSummary` is a kitchen-facing alias for the shared
  `FnbRecipeProductionSummary` core model.
- `KitchenRecipeProductionSummary`, `KitchenRecipeProductionPanel`, and
  `KitchenRecipeProductionTile` turn shared menu and recipe data into a compact
  kitchen production review surface.
- `KitchenBoardController` and `KitchenBoardScreen` can consume shared recipe
  and menu catalogs to show station-scoped production review inside the kitchen
  board.

## Migration note

Older prototype screens remain in `lib/` while the package is being migrated to
the modular API. They are intentionally excluded from analysis until they are
rebuilt as small screens, widgets, controllers, and providers on top of the
clean model layer.

## Example

```dart
final board = KitchenStationBoard.fromQueue(
  stations: stations,
  queue: KitchenTicketQueue(tickets: tickets, now: DateTime.now()),
);

final topStation = board.priorityQueue.topStation;
final pressureLoads = board.filteredLoads(FnbKitchenStationFilter.pressure);

const operator = KitchenOperatorContext(
  id: 'expo-lead',
  displayName: 'Dimas',
  roleLabel: 'Expo lead',
);

final controller = KitchenBoardController(stations: stations, queue: queue);
controller.selectFilter(FnbKitchenStationFilter.pressure);
final result = controller.applySelectedTicketActionResult(
  KitchenTicketAction.startFiring,
);
controller.undoLastTicketAction();
final recentActivity = controller.actionHistory.results;
final production = controller.scopedRecipeProductionSummary;

KitchenBoardScreen(controller: controller, operatorContext: operator);
KitchenTicketAction.startFiring.applyTo(ticket);
KitchenTicketQueueList(queue: queue, onTicketSelected: openTicket);
```
