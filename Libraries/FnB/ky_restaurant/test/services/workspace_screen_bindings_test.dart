import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace controller binding wires controller and dispatcher', () {
    var changes = 0;
    final binding = RestaurantWorkspaceControllerBinding(
      onChanged: () => changes++,
    );

    binding.attach(
      repository: const DemoRestaurantSnapshotRepository(),
      snapshot: restaurantDemoSnapshot,
    );

    expect(
      binding.controller.state.status,
      RestaurantWorkspaceLoadStatus.ready,
    );
    expect(
      binding.actionDispatcher
          .updateStationStatus('grill', RestaurantServiceStatus.calm)
          .changed,
      isTrue,
    );
    expect(changes, 1);

    binding.detach();
  });

  test(
    'workspace controller binding applies snapshot and repository changes',
    () {
      final binding = RestaurantWorkspaceControllerBinding(onChanged: () {});

      binding.attach(
        repository: const DemoRestaurantSnapshotRepository(),
        snapshot: restaurantDemoSnapshot,
      );
      binding.applySnapshotOrRepository(
        snapshot: restaurantDemoSnapshot.copyWith(
          locationName: 'Updated Floor',
        ),
        repository: const DemoRestaurantSnapshotRepository(),
      );

      expect(binding.controller.state.snapshot?.locationName, 'Updated Floor');

      binding.detach();
    },
  );

  test(
    'workspace preferences binding normalizes unavailable selected views',
    () {
      var changes = 0;
      final preferences = RestaurantWorkspacePreferencesController(
        initialPreferences: const RestaurantWorkspacePreferences(
          view: RestaurantWorkspaceView.kitchen,
        ),
      );
      final binding = RestaurantWorkspacePreferencesBinding(
        onChanged: () => changes++,
      );

      final normalized = binding.attach(
        controller: preferences,
        initialView: RestaurantWorkspaceView.menu,
        initialFilters: const RestaurantWorkspacePanelFilters(),
        viewAvailability: RestaurantWorkspaceViewAvailability.fromViews([
          RestaurantWorkspaceView.menu,
        ]),
      );

      expect(normalized, isTrue);
      expect(binding.selectedView, RestaurantWorkspaceView.menu);
      expect(changes, 0);

      binding.controller.selectMenuFilter(RestaurantMenuFilter.risk);

      expect(changes, 1);

      binding.detach();
      preferences.dispose();
    },
  );

  test('workspace preferences binding updates owned initial preferences', () {
    final binding = RestaurantWorkspacePreferencesBinding(onChanged: () {});

    binding.attach(
      initialView: RestaurantWorkspaceView.pulse,
      initialFilters: const RestaurantWorkspacePanelFilters(),
      viewAvailability: RestaurantWorkspaceViewAvailability.fromViews(
        RestaurantWorkspaceView.values,
      ),
    );
    binding.updateOwnedInitialPreferences(
      initialView: RestaurantWorkspaceView.menu,
      previousInitialView: RestaurantWorkspaceView.pulse,
      initialFilters: RestaurantWorkspacePreset.menuRisk.filters,
      previousInitialFilters: const RestaurantWorkspacePanelFilters(),
    );

    expect(binding.selectedView, RestaurantWorkspaceView.menu);
    expect(binding.filters, RestaurantWorkspacePreset.menuRisk.filters);

    binding.detach();
  });
}
