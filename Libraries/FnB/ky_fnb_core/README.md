# ky_fnb_core

Shared FnB operating models for Kaysir restaurant and kitchen packages. The
package keeps cross-module concepts in one place so restaurant workspaces,
kitchen boards, and future FnB surfaces can rank and display operational
pressure consistently.

## Public API

- `FnbAttentionSignal` and `FnbAttentionSignalQueue` normalize service alerts,
  kitchen pressure, menu risks, catalog gaps, recipe review, and external
  workflow records into one ranked attention feed.
- `FnbServiceStatus` models shared pressure states and priority ordering.
- `FnbServiceAlert` and `FnbServiceContext` carry guest, reservation, allergy,
  dietary, timing, and service notes across modules.
- `FnbServiceAlertEntry` and `FnbServiceAlertSummary` rank alert-bearing
  tickets, reservations, zones, or other operational sources with consistent
  counts and urgency labels.
- `FnbServiceAlertLifecycle` tracks acknowledge, snooze, resolve, reopen,
  ownership, and audit events for shared alert action flows.
- `FnbMenu`, `FnbMenuCategory`, `FnbMenuItem`, and `FnbMenuAvailability`
  describe reusable menu books, sellable items, display ordering, kitchen
  routing, and availability state.
- `FnbMenuRecipeReadiness` evaluates menu item recipe linkage, gross margin,
  allergen exposure, and kitchen station routing for restaurant and kitchen
  surfaces.
- `FnbMenuCatalogEntry` and `FnbMenuCatalogSummary` rank shared menu catalog
  readiness, review state, recipe linkage, route gaps, and station load.
- `FnbMenuSignal`, `FnbMenuSignalSummary`, `FnbMenuSignalFilter`, and
  `FnbMenuSignalSort` describe reusable live menu demand, risk, margin, prep,
  and restock lenses.
- `FnbRecipe` and `FnbRecipeIngredient` describe recipe timing, yield,
  production steps, dietary tags, ingredient quantities, and costing.
- `FnbRecipeProductionEntry` pairs a recipe with its sellable menu item for
  shared production review, margin, allergen, and linkage labels.
- `FnbRecipeProductionSummary` builds station-scoped production review
  summaries from shared recipe and menu catalogs.
- `FnbKitchenStation` describes station metadata, lead ownership, queue load,
  average fire time, and operating status.
- `FnbKitchenStationSummary` aggregates station pressure, delayed stations,
  total tickets, and average fire time.
- `FnbKitchenStationPriorityQueue` ranks stations that need operating
  attention.
- `FnbKitchenStationPressureSignal` turns the top pressure station into
  reusable operator-facing labels and actions.
- `FnbKitchenStationFilter` provides shared station lenses for dashboards,
  chips, and saved preferences.

## Example

```dart
final summary = FnbKitchenStationSummary.fromStations(stations);
final pressureSignal = FnbKitchenStationPressureSignal.fromStations(stations);

if (pressureSignal.hasPressure) {
  print(pressureSignal.titleLabel);
  print(pressureSignal.actionLabel);
}

final delayedStations = stations.where(FnbKitchenStationFilter.delayed.includes);
```
