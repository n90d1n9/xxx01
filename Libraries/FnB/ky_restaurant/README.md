`ky_restaurant` provides reusable restaurant operations UI for Kaysir-style
apps. It exposes route metadata, typed snapshot models, demo operating data, and
a responsive `RestaurantWorkspaceScreen`.

## Features

- Service pulse view for floor, kitchen, menu, and shift attention.
- Actionable operational briefing recommendations with priority and reason
  signals derived from each live snapshot.
- Compact priority watch strip for fast triage and view switching.
- Operational insight cards with deep links for menu risk, margin, prep speed,
  and kitchen load.
- Workspace command center for active lenses, menu search, refresh state,
  responsive signal chips, per-lens/search clearing, and quick reset.
- Quick view presets for rush watch, floor recovery, menu risk, margin focus,
  and kitchen load lenses.
- Shared panel header and badge primitives for consistent scan-friendly cards.
- Shared empty-state treatment with quick filter recovery actions.
- Menu search field with clearable, filter-aware results.
- Menu sort modes for demand, risk, margin, and prep-time decisions.
- Menu signal, summary, filter, and sort names are compatibility aliases for
  shared `FnbMenuSignal*` core models.
- Shared menu, item, category, availability, and recipe aliases from
  `ky_fnb_core` for menu management workflows.
- Catalog readiness widgets that use shared menu and recipe data to surface
  missing recipe links, allergen paths, availability gaps, and margin context.
- Restaurant catalog entry and summary names are compatibility aliases for the
  shared `FnbMenuCatalogEntry` and `FnbMenuCatalogSummary` core models.
- Floor plan readiness panels with occupancy summary and pressure filters.
- Menu mix panels with availability watch, margin, prep, and restock filters.
- Kitchen flow panels with pressure summary, top-station pressure callout, and
  station filters.
- Shift follow-up task progress with open, attention, and done filters.
- Filterable recent action timeline for task, floor, kitchen, and menu updates.
- Workspace-level panel filter preferences that persist across view changes.
- Workspace-level menu search persistence across restaurant views.
- Serializable workspace preferences controller for host-managed persistence.
- Snapshot freshness indicators for updated, refreshing, and stale data states.
- One-step undo feedback for successful workspace commands.
- Reusable action dispatcher for routing workspace commands outside the screen.
- Shared priority selector for floor, kitchen, menu, and task attention.
- Route definitions that host apps can adapt into their own router/sidebar.

## Usage

```dart
import 'package:ky_restaurant/ky_restaurant.dart';

RestaurantWorkspaceScreen(
  initialView: RestaurantWorkspaceView.floor,
  onViewChanged: (view) => router.go(RestaurantRoutes.pathForView(view)),
);
```

Pass a `RestaurantWorkspacePreferencesController` when a host app wants to keep
the selected view and active lenses alive across route rebuilds:

```dart
final preferences = RestaurantWorkspacePreferencesController(
  initialPreferences: RestaurantWorkspacePreferences.fromJson(savedJson),
);

RestaurantWorkspaceScreen(
  preferencesController: preferences,
  onPreferencesChanged: (next) => saveJson(next.toJson()),
);
```

Use `preferences.preferences.toJson()` and
`RestaurantWorkspacePreferences.fromJson(savedJson)` to bridge into whatever
storage the host app already uses. Restored views are normalized against the
screen's `views` list, so hidden modules do not become active accidentally.

Use a repository when the workspace should load live data:

```dart
RestaurantWorkspaceScreen(
  repository: CallbackRestaurantSnapshotRepository(() {
    return api.fetchRestaurantSnapshot();
  }),
);
```

Host apps can use `restaurantRouteDefinitions` to add menu entries and router
targets without duplicating labels, paths, or descriptions.

Controller actions such as `completeTask`, `updateZoneStatus`,
`updateStationStatus`, and `resolveMenuRisk` update the snapshot and append a
bounded `RestaurantOperationActivity` entry for the visible action timeline.

## Structure

- `lib/src/models`: immutable snapshot and view models.
- `lib/src/data`: demo data for previews and tests.
- `lib/src/widgets`: reusable workspace widgets.
- `legacy`: archived prototypes excluded from analysis.
