import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace preference coordinator selects views once', () {
    final controller = RestaurantWorkspacePreferencesController();
    final viewChanges = <RestaurantWorkspaceView>[];
    final coordinator = RestaurantWorkspacePreferenceCoordinator(
      controller: controller,
      viewAvailability: RestaurantWorkspaceViewAvailability.fromViews(
        RestaurantWorkspaceView.values,
      ),
      onViewChanged: viewChanges.add,
    );

    coordinator.selectView(RestaurantWorkspaceView.menu);
    coordinator.selectView(RestaurantWorkspaceView.menu);

    expect(controller.selectedView, RestaurantWorkspaceView.menu);
    expect(viewChanges, [RestaurantWorkspaceView.menu]);

    controller.dispose();
  });

  test(
    'workspace preference coordinator reports preset and insight view changes',
    () {
      final controller = RestaurantWorkspacePreferencesController();
      final viewChanges = <RestaurantWorkspaceView>[];
      final coordinator = RestaurantWorkspacePreferenceCoordinator(
        controller: controller,
        viewAvailability: RestaurantWorkspaceViewAvailability.fromViews(
          RestaurantWorkspaceView.values,
        ),
        onViewChanged: viewChanges.add,
      );
      const insight = RestaurantOperationalInsight(
        id: 'menu-risk',
        kind: RestaurantOperationalInsightKind.menuRisk,
        title: 'Menu risk',
        valueLabel: '72% risk',
        detail: 'Short rib needs prep attention',
        status: RestaurantServiceStatus.critical,
        targetView: RestaurantWorkspaceView.menu,
        targetFilters: RestaurantWorkspacePanelFilters(
          menu: RestaurantMenuFilter.risk,
          activity: RestaurantActivityFilter.menu,
          menuSort: RestaurantMenuSort.risk,
        ),
      );

      coordinator.selectPreset(RestaurantWorkspacePreset.menuRisk);
      coordinator.selectInsight(insight);

      expect(controller.selectedView, RestaurantWorkspaceView.menu);
      expect(controller.filters, insight.targetFilters);
      expect(viewChanges, [RestaurantWorkspaceView.menu]);

      controller.dispose();
    },
  );

  test(
    'workspace preference coordinator routes attention signals through targets',
    () {
      final controller = RestaurantWorkspacePreferencesController();
      final viewChanges = <RestaurantWorkspaceView>[];
      final coordinator = RestaurantWorkspacePreferenceCoordinator(
        controller: controller,
        viewAvailability: RestaurantWorkspaceViewAvailability.fromViews(
          RestaurantWorkspaceView.values,
        ),
        onViewChanged: viewChanges.add,
      );
      final signal = const RestaurantAttentionSignalBuilder()
          .build(restaurantDemoSnapshot)
          .topSignal!;

      coordinator.selectAttentionSignal(signal);
      coordinator.selectAttentionSignal(signal);

      expect(controller.selectedView, RestaurantWorkspaceView.menu);
      expect(controller.filters.menu, RestaurantMenuFilter.risk);
      expect(controller.filters.menuSort, RestaurantMenuSort.risk);
      expect(controller.filters.activity, RestaurantActivityFilter.menu);
      expect(
        controller.focus?.kind,
        RestaurantWorkspacePanelFocusKind.menuSignal,
      );
      expect(controller.focus?.targetId, 'short-rib-rendang');
      expect(viewChanges, [RestaurantWorkspaceView.menu]);

      coordinator.selectView(RestaurantWorkspaceView.menu);

      expect(controller.focus, isNull);
      expect(viewChanges, [RestaurantWorkspaceView.menu]);

      controller.dispose();
    },
  );

  test(
    'workspace preference coordinator routes briefing items and active lenses',
    () {
      final controller = RestaurantWorkspacePreferencesController();
      final viewChanges = <RestaurantWorkspaceView>[];
      final coordinator = RestaurantWorkspacePreferenceCoordinator(
        controller: controller,
        viewAvailability: RestaurantWorkspaceViewAvailability.fromViews([
          RestaurantWorkspaceView.pulse,
          RestaurantWorkspaceView.reservations,
        ]),
        onViewChanged: viewChanges.add,
      );

      coordinator.selectBriefingItem(
        const RestaurantBriefingItem(
          id: 'late-arrival',
          category: RestaurantBriefingCategory.reservations,
          status: RestaurantServiceStatus.busy,
          title: 'Recover arrival',
          description: 'Late arrival needs attention',
          actionLabel: 'Open reservations',
        ),
      );
      coordinator.selectActiveLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.menuSearch,
          label: 'Menu search: rib',
        ),
      );
      coordinator.selectActiveLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.reservationSearch,
          label: 'Zone: Terrace',
        ),
      );

      expect(controller.selectedView, RestaurantWorkspaceView.reservations);
      expect(viewChanges, [RestaurantWorkspaceView.reservations]);

      controller.dispose();
    },
  );

  test(
    'workspace preference coordinator reports reset only when filters change',
    () {
      var resetCount = 0;
      final controller = RestaurantWorkspacePreferencesController(
        initialPreferences: const RestaurantWorkspacePreferences(
          filters: RestaurantWorkspacePanelFilters(menuSearchQuery: 'cheese'),
        ),
      );
      final coordinator = RestaurantWorkspacePreferenceCoordinator(
        controller: controller,
        viewAvailability: RestaurantWorkspaceViewAvailability.fromViews(
          RestaurantWorkspaceView.values,
        ),
        onResetConfirmed: () => resetCount++,
      );

      coordinator.resetFilters();
      coordinator.resetFilters();

      expect(controller.filters, const RestaurantWorkspacePanelFilters());
      expect(resetCount, 1);

      controller.dispose();
    },
  );
}
