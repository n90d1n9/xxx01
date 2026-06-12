import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/restaurant/repositories/restaurant_workspace_preferences_repository.dart';
import 'package:kaysir/features/restaurant/services/restaurant_workspace_preferences_autosave.dart';
import 'package:kaysir/features/restaurant/widgets/restaurant_workspace_route_screen.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test(
    'restaurant preferences repository persists workspace controls',
    () async {
      final store = MemoryRestaurantWorkspacePreferencesSnapshotStore();
      final repository = RestaurantWorkspacePreferencesRepository(store: store);
      const preferences = RestaurantWorkspacePreferences(
        view: RestaurantWorkspaceView.menu,
        filters: RestaurantWorkspacePanelFilters(
          menuSearchQuery: 'cheese',
          menuSort: RestaurantMenuSort.prep,
        ),
      );

      await repository.save(preferences);

      expect(await repository.load(), preferences);
      expect(store.snapshot?['view'], RestaurantWorkspaceView.menu.id);
    },
  );

  test('restaurant preferences autosave coalesces rapid writes', () async {
    final store = _CountingRestaurantWorkspacePreferencesSnapshotStore();
    final autosave = RestaurantWorkspacePreferencesAutosave(
      repository: RestaurantWorkspacePreferencesRepository(store: store),
      delay: const Duration(milliseconds: 30),
    );

    autosave.schedule(
      const RestaurantWorkspacePreferences(view: RestaurantWorkspaceView.floor),
    );
    autosave.schedule(
      const RestaurantWorkspacePreferences(view: RestaurantWorkspaceView.menu),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(store.writeCount, 0);

    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(store.writeCount, 1);
    expect(store.snapshot?['view'], RestaurantWorkspaceView.menu.id);

    autosave.dispose();
  });

  testWidgets('restaurant route restores saved root workspace preferences', (
    tester,
  ) async {
    final store = MemoryRestaurantWorkspacePreferencesSnapshotStore(
      initialSnapshot:
          const RestaurantWorkspacePreferences(
            view: RestaurantWorkspaceView.menu,
            filters: RestaurantWorkspacePanelFilters(menuSearchQuery: 'cheese'),
          ).toJson(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceRouteScreen(
          initialView: RestaurantWorkspaceView.pulse,
          restoreSavedView: true,
          autosaveDelay: Duration.zero,
          preferencesRepository: RestaurantWorkspacePreferencesRepository(
            store: store,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('Burnt Cheesecake'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsNothing);
  });

  testWidgets('restaurant child route overrides saved view and keeps filters', (
    tester,
  ) async {
    final store = MemoryRestaurantWorkspacePreferencesSnapshotStore(
      initialSnapshot:
          const RestaurantWorkspacePreferences(
            view: RestaurantWorkspaceView.kitchen,
            filters: RestaurantWorkspacePanelFilters(menuSearchQuery: 'cheese'),
          ).toJson(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceRouteScreen(
          initialView: RestaurantWorkspaceView.menu,
          autosaveDelay: Duration.zero,
          preferencesRepository: RestaurantWorkspacePreferencesRepository(
            store: store,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final snapshot = store.snapshot;
    final filters = snapshot?['filters'] as Map<String, Object?>?;

    expect(find.text('Menu mix'), findsOneWidget);
    expect(find.text('Burnt Cheesecake'), findsOneWidget);
    expect(snapshot?['view'], RestaurantWorkspaceView.menu.id);
    expect(filters?['menuSearchQuery'], 'cheese');
  });
}

class _CountingRestaurantWorkspacePreferencesSnapshotStore
    implements RestaurantWorkspacePreferencesSnapshotStore {
  Map<String, Object?>? _snapshot;
  var writeCount = 0;

  Map<String, Object?>? get snapshot {
    final value = _snapshot;
    if (value == null) return null;

    return Map<String, Object?>.unmodifiable(value);
  }

  @override
  Future<Map<String, Object?>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    writeCount += 1;
    _snapshot = Map<String, Object?>.unmodifiable(snapshot);
  }
}
