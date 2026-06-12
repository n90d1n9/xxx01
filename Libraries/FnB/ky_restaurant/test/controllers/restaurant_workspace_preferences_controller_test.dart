import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace preferences controller manages view and lens state', () {
    final controller = RestaurantWorkspacePreferencesController(
      initialPreferences: const RestaurantWorkspacePreferences(
        view: RestaurantWorkspaceView.menu,
        filters: RestaurantWorkspacePanelFilters(
          menu: RestaurantMenuFilter.risk,
          menuSearchQuery: 'rendang',
          reservationSearchQuery: 'Terrace',
          menuSort: RestaurantMenuSort.risk,
        ),
      ),
    );
    var changes = 0;
    controller.addListener(() => changes++);

    expect(controller.selectedView, RestaurantWorkspaceView.menu);
    expect(controller.filters.menu, RestaurantMenuFilter.risk);
    expect(controller.filters.menuSearchQuery, 'rendang');
    expect(
      controller.clearLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.menuSort,
          label: 'Menu sort: Risk',
        ),
      ),
      isTrue,
    );
    expect(controller.filters.menuSort, RestaurantMenuSort.demand);

    expect(controller.clearMenuSearch(), isTrue);
    expect(controller.filters.menuSearchQuery, isEmpty);
    expect(
      controller.clearLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.reservationSearch,
          label: 'Zone: Terrace',
        ),
      ),
      isTrue,
    );
    expect(controller.filters.reservationSearchQuery, isEmpty);

    expect(controller.selectView(RestaurantWorkspaceView.kitchen), isTrue);
    expect(controller.selectedView, RestaurantWorkspaceView.kitchen);

    expect(controller.resetFilters(), isTrue);
    expect(controller.filters, const RestaurantWorkspacePanelFilters());
    expect(controller.resetFilters(), isFalse);
    expect(changes, 5);

    controller.dispose();
  });

  test('workspace preferences controller applies panel filter commands', () {
    final controller = RestaurantWorkspacePreferencesController();
    var changes = 0;
    controller.addListener(() => changes++);

    expect(
      controller.selectFloorFilter(RestaurantFloorFilter.waitlist),
      isTrue,
    );
    expect(
      controller.selectFloorFilter(RestaurantFloorFilter.waitlist),
      isFalse,
    );
    expect(
      controller.selectKitchenFilter(RestaurantKitchenFilter.delayed),
      isTrue,
    );
    expect(
      controller.selectReservationFilter(RestaurantReservationFilter.late),
      isTrue,
    );
    expect(controller.selectMenuFilter(RestaurantMenuFilter.risk), isTrue);
    expect(controller.setMenuSearchQuery('rib'), isTrue);
    expect(controller.setMenuSearchQuery('rib'), isFalse);
    expect(controller.setReservationSearchQuery('wijaya'), isTrue);
    expect(controller.setReservationSearchQuery('wijaya'), isFalse);
    expect(controller.selectMenuSort(RestaurantMenuSort.risk), isTrue);
    expect(controller.selectTaskFilter(RestaurantTaskFilter.open), isTrue);
    expect(
      controller.selectActivityFilter(RestaurantActivityFilter.menu),
      isTrue,
    );

    expect(
      controller.filters,
      const RestaurantWorkspacePanelFilters(
        floor: RestaurantFloorFilter.waitlist,
        kitchen: RestaurantKitchenFilter.delayed,
        reservations: RestaurantReservationFilter.late,
        menu: RestaurantMenuFilter.risk,
        task: RestaurantTaskFilter.open,
        activity: RestaurantActivityFilter.menu,
        menuSearchQuery: 'rib',
        reservationSearchQuery: 'wijaya',
        menuSort: RestaurantMenuSort.risk,
      ),
    );
    expect(changes, 9);

    controller.dispose();
  });

  test('workspace preferences controller applies insight targets', () {
    final controller = RestaurantWorkspacePreferencesController();
    var changes = 0;
    controller.addListener(() => changes++);
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

    expect(controller.selectInsight(insight), isTrue);
    expect(controller.selectInsight(insight), isFalse);
    expect(
      controller.preferences,
      const RestaurantWorkspacePreferences(
        view: RestaurantWorkspaceView.menu,
        filters: RestaurantWorkspacePanelFilters(
          menu: RestaurantMenuFilter.risk,
          activity: RestaurantActivityFilter.menu,
          menuSort: RestaurantMenuSort.risk,
        ),
      ),
    );
    expect(changes, 1);

    controller.dispose();
  });

  test('workspace preferences controller applies navigation targets', () {
    final controller = RestaurantWorkspacePreferencesController();
    var changes = 0;
    controller.addListener(() => changes++);
    const target = RestaurantWorkspaceNavigationTarget(
      view: RestaurantWorkspaceView.kitchen,
      filters: RestaurantWorkspacePanelFilters(
        kitchen: RestaurantKitchenFilter.pressure,
        activity: RestaurantActivityFilter.kitchen,
      ),
      focus: RestaurantWorkspacePanelFocus(
        kind: RestaurantWorkspacePanelFocusKind.kitchenStation,
        targetId: 'grill',
      ),
    );

    expect(controller.selectNavigationTarget(target), isTrue);
    expect(controller.selectNavigationTarget(target), isFalse);
    expect(controller.preferences.view, RestaurantWorkspaceView.kitchen);
    expect(
      controller.preferences.filters.kitchen,
      RestaurantKitchenFilter.pressure,
    );
    expect(
      controller.preferences.filters.activity,
      RestaurantActivityFilter.kitchen,
    );
    expect(controller.focus?.targetId, 'grill');
    expect(
      controller.focus?.kind,
      RestaurantWorkspacePanelFocusKind.kitchenStation,
    );

    expect(controller.selectView(RestaurantWorkspaceView.menu), isTrue);
    expect(controller.focus, isNull);
    expect(changes, 2);

    controller.dispose();
  });
}
