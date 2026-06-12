import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('activity filters group operation activity kinds', () {
    final createdAt = DateTime(2026, 1, 1, 12);
    RestaurantOperationActivity activity(RestaurantOperationActivityKind kind) {
      return RestaurantOperationActivity(
        id: kind.name,
        kind: kind,
        title: kind.label,
        description: 'Updated during service.',
        createdAt: createdAt,
      );
    }

    final floor = activity(RestaurantOperationActivityKind.zoneStatusChanged);
    final reservation = activity(
      RestaurantOperationActivityKind.reservationStatusChanged,
    );
    final kitchen = activity(
      RestaurantOperationActivityKind.stationStatusChanged,
    );
    final menu = activity(RestaurantOperationActivityKind.menuRiskResolved);
    final catalog = activity(
      RestaurantOperationActivityKind.menuCatalogReviewed,
    );
    final recipe = activity(
      RestaurantOperationActivityKind.recipeProductionReviewed,
    );
    final task = activity(RestaurantOperationActivityKind.taskCompleted);

    expect(RestaurantActivityFilter.all.includes(floor), isTrue);
    expect(RestaurantActivityFilter.floor.includes(floor), isTrue);
    expect(RestaurantActivityFilter.floor.includes(kitchen), isFalse);
    expect(RestaurantActivityFilter.reservations.includes(reservation), isTrue);
    expect(RestaurantActivityFilter.reservations.includes(floor), isFalse);
    expect(RestaurantActivityFilter.kitchen.includes(kitchen), isTrue);
    expect(RestaurantActivityFilter.kitchen.includes(recipe), isTrue);
    expect(RestaurantActivityFilter.menu.includes(menu), isTrue);
    expect(RestaurantActivityFilter.menu.includes(catalog), isTrue);
    expect(RestaurantActivityFilter.menu.includes(recipe), isFalse);
    expect(RestaurantActivityFilter.tasks.includes(task), isTrue);
    expect(RestaurantActivityFilter.tasks.includes(menu), isFalse);
  });

  test('task summary and filters group follow-up work', () {
    const tasks = [
      RestaurantShiftTask(
        id: 'open',
        title: 'Reset patio section',
        owner: 'Floor team',
        dueLabel: 'Due in 12m',
        progress: .45,
        status: RestaurantServiceStatus.busy,
      ),
      RestaurantShiftTask(
        id: 'attention',
        title: 'Restock dessert station',
        owner: 'Pastry',
        dueLabel: 'Due now',
        progress: .2,
        status: RestaurantServiceStatus.critical,
      ),
      RestaurantShiftTask(
        id: 'done',
        title: 'Confirm VIP setup',
        owner: 'Host',
        dueLabel: 'Done',
        progress: 1,
        status: RestaurantServiceStatus.calm,
      ),
    ];

    final summary = RestaurantTaskSummary.fromTasks(tasks);

    expect(summary.totalCount, 3);
    expect(summary.completedCount, 1);
    expect(summary.openCount, 2);
    expect(summary.attentionCount, 2);
    expect(summary.completionLabel, '33% complete');
    expect(tasks.where(RestaurantTaskFilter.open.includes), hasLength(2));
    expect(tasks.where(RestaurantTaskFilter.attention.includes), hasLength(2));
    expect(tasks.where(RestaurantTaskFilter.done.includes), hasLength(1));

    final focusedData = RestaurantTaskPanelData.fromTasks(
      tasks: tasks,
      selectedFilter: RestaurantTaskFilter.done,
      focusedTaskId: 'attention',
    );
    expect(focusedData.visibleTasks.map((task) => task.id), [
      'attention',
      'done',
    ]);
  });

  test('menu summary and filters group menu availability signals', () {
    const signals = [
      RestaurantMenuSignal(
        id: 'risk',
        name: 'Short Rib Rendang',
        category: 'Main',
        orders: 32,
        grossMarginPercent: 71,
        soldOutRiskPercent: 78,
        prepMinutes: 18,
        tags: ['Low stock'],
      ),
      RestaurantMenuSignal(
        id: 'quick',
        name: 'Pandan Spritz',
        category: 'Beverage',
        orders: 24,
        grossMarginPercent: 68,
        soldOutRiskPercent: 18,
        prepMinutes: 5,
        tags: ['Fast'],
      ),
      RestaurantMenuSignal(
        id: 'restocked',
        name: 'Burnt Cheesecake',
        category: 'Dessert',
        orders: 18,
        grossMarginPercent: 62,
        soldOutRiskPercent: 12,
        prepMinutes: 7,
        tags: ['Restocked'],
      ),
    ];

    final summary = RestaurantMenuSummary.fromSignals(signals);

    expect(summary.totalCount, 3);
    expect(summary.riskCount, 1);
    expect(summary.highMarginCount, 2);
    expect(summary.quickPrepCount, 2);
    expect(summary.restockedCount, 1);
    expect(summary.averageMarginPercent, 67);
    expect(summary.riskLabel, '1 at risk');
    expect(signals.where(RestaurantMenuFilter.risk.includes), hasLength(1));
    expect(signals.where(RestaurantMenuFilter.margin.includes), hasLength(2));
    expect(signals.where(RestaurantMenuFilter.quick.includes), hasLength(2));
    expect(
      signals.where(RestaurantMenuFilter.restocked.includes),
      hasLength(1),
    );
  });

  test('menu sort ranks signals for operating decisions', () {
    const signals = [
      RestaurantMenuSignal(
        id: 'slow-risk',
        name: 'Slow Risk',
        category: 'Main',
        orders: 12,
        grossMarginPercent: 61,
        soldOutRiskPercent: 88,
        prepMinutes: 18,
        tags: [],
      ),
      RestaurantMenuSignal(
        id: 'fast-margin',
        name: 'Fast Margin',
        category: 'Dessert',
        orders: 10,
        grossMarginPercent: 72,
        soldOutRiskPercent: 18,
        prepMinutes: 5,
        tags: [],
      ),
      RestaurantMenuSignal(
        id: 'demand',
        name: 'High Demand',
        category: 'Beverage',
        orders: 30,
        grossMarginPercent: 65,
        soldOutRiskPercent: 40,
        prepMinutes: 7,
        tags: [],
      ),
    ];

    expect(
      sortRestaurantMenuSignals(
        signals,
        RestaurantMenuSort.demand,
      ).map((signal) => signal.id),
      ['demand', 'slow-risk', 'fast-margin'],
    );
    expect(
      sortRestaurantMenuSignals(
        signals,
        RestaurantMenuSort.risk,
      ).map((signal) => signal.id),
      ['slow-risk', 'demand', 'fast-margin'],
    );
    expect(
      sortRestaurantMenuSignals(
        signals,
        RestaurantMenuSort.margin,
      ).map((signal) => signal.id),
      ['fast-margin', 'demand', 'slow-risk'],
    );
    expect(
      sortRestaurantMenuSignals(
        signals,
        RestaurantMenuSort.prep,
      ).map((signal) => signal.id),
      ['fast-margin', 'demand', 'slow-risk'],
    );
  });

  test('menu panel data derives sorted searchable presentation state', () {
    const signals = [
      RestaurantMenuSignal(
        id: 'risk',
        name: 'Short Rib Rendang',
        category: 'Main',
        orders: 32,
        grossMarginPercent: 71,
        soldOutRiskPercent: 78,
        prepMinutes: 18,
        tags: ['Low stock'],
      ),
      RestaurantMenuSignal(
        id: 'quick',
        name: 'Pandan Spritz',
        category: 'Beverage',
        orders: 24,
        grossMarginPercent: 68,
        soldOutRiskPercent: 18,
        prepMinutes: 5,
        tags: ['Fast'],
      ),
      RestaurantMenuSignal(
        id: 'restocked',
        name: 'Burnt Cheesecake',
        category: 'Dessert',
        orders: 18,
        grossMarginPercent: 62,
        soldOutRiskPercent: 12,
        prepMinutes: 7,
        tags: ['Restocked'],
      ),
    ];

    final data = RestaurantMenuPanelData.fromSignals(
      signals: signals,
      selectedFilter: RestaurantMenuFilter.quick,
      selectedSort: RestaurantMenuSort.prep,
      searchQuery: 'dessert',
    );

    expect(data.hasSignals, isTrue);
    expect(data.hasSearch, isTrue);
    expect(data.summary.totalCount, 3);
    expect(data.summary.highMarginCount, 2);
    expect(data.sortedSignals.map((signal) => signal.id), [
      'quick',
      'restocked',
      'risk',
    ]);
    expect(data.filteredSignals.map((signal) => signal.id), [
      'quick',
      'restocked',
    ]);
    expect(data.visibleSignals.map((signal) => signal.id), ['restocked']);
    final focusedData = RestaurantMenuPanelData.fromSignals(
      signals: signals,
      selectedFilter: RestaurantMenuFilter.quick,
      selectedSort: RestaurantMenuSort.prep,
      searchQuery: 'dessert',
      focusedSignalId: 'risk',
    );
    expect(focusedData.visibleSignals.map((signal) => signal.id), [
      'risk',
      'restocked',
    ]);
    expect(
      RestaurantMenuPanelData.matchesSearch(signals.first, 'low stock'),
      isTrue,
    );
    expect(
      RestaurantMenuPanelData.matchesSearch(signals[1], 'beverage'),
      isTrue,
    );
    expect(RestaurantMenuPanelData.matchesSearch(signals[1], 'spritz'), isTrue);
  });

  test('restaurant menu aliases expose shared menu and recipe core', () {
    const recipe = RestaurantRecipe(
      id: 'spritz-recipe',
      name: 'Pandan Spritz',
      categoryId: 'beverage',
      stationId: 'bar',
      prepMinutes: 4,
      fireMinutes: 0,
      yieldQuantity: 1,
      yieldUnit: 'glass',
      costCents: 320,
    );
    const item = RestaurantMenuItem(
      id: 'spritz',
      name: 'Pandan Spritz',
      categoryId: 'beverage',
      priceCents: 850,
      recipeId: 'spritz-recipe',
      stationId: 'bar',
      availability: RestaurantMenuAvailability.available,
      dietaryTags: {RestaurantDietaryTag.vegan},
    );
    const menu = RestaurantMenu(
      id: 'drinks',
      name: 'Drinks',
      categories: [RestaurantMenuCategory(id: 'beverage', name: 'Beverage')],
      items: [item],
    );

    expect(recipe.totalTimeLabel, '4m total');
    expect(item.priceLabel, r'$8.50');
    expect(item.dietaryLabel, 'Vegan');
    expect(menu.availabilitySummaryLabel, '1 available, 0 need attention');

    final alertSummary = RestaurantServiceAlertSummary.fromEntries([
      RestaurantServiceAlertEntry(
        sourceId: 'reservation-12',
        sourceLabel: 'Ayu Rahma',
        contextLabel: 'Patio',
        serviceStatus: RestaurantServiceStatus.busy,
        lifecycle: const RestaurantServiceAlertLifecycle().applyAction(
          RestaurantServiceAlertLifecycleAction.acknowledge,
          at: DateTime(2026, 6, 10, 18, 30),
          actorLabel: 'Host lead',
        ),
        alert: const RestaurantServiceAlert(
          type: RestaurantServiceAlertType.accessibility,
          label: 'Wheelchair access',
        ),
      ),
    ]);

    expect(alertSummary.alertCountLabel, '1 alert');
    expect(alertSummary.topEntry?.subtitleLabel, 'Patio - Ayu Rahma');
    expect(
      alertSummary.topEntry?.lifecycle.status,
      RestaurantServiceAlertLifecycleStatus.acknowledged,
    );
  });

  test('operating snapshot carries shared menu catalog data', () {
    expect(restaurantDemoSnapshot.menu?.id, 'dinner');
    expect(restaurantDemoSnapshot.recipes, isNotEmpty);

    final summary = RestaurantMenuCatalogSummary.fromMenu(
      menu: restaurantDemoSnapshot.menu!,
      recipes: restaurantDemoSnapshot.recipes,
      stations: restaurantDemoSnapshot.stations,
    );

    expect(summary.itemCount, 5);
    expect(summary.linkedRecipeCount, 4);
    expect(summary.reviewCount, 3);
    expect(summary.topReviewEntry?.id, 'nasi-ulam');
    expect(
      summary.entries
          .firstWhere((entry) => entry.id == 'short-rib-rendang')
          .routeLabel,
      'Grill station',
    );

    final cleared = restaurantDemoSnapshot.copyWith(
      menu: null,
      recipes: const [],
    );

    expect(cleared.menu, isNull);
    expect(cleared.recipes, isEmpty);
  });

  test('kitchen summary and filters group station pressure', () {
    const stations = [
      RestaurantKitchenStation(
        id: 'grill',
        name: 'Grill',
        lead: 'Ari',
        ticketsInProgress: 12,
        averageFireMinutes: 21,
        queueLabel: 'Steaks',
        status: RestaurantServiceStatus.critical,
      ),
      RestaurantKitchenStation(
        id: 'wok',
        name: 'Wok',
        lead: 'Mei',
        ticketsInProgress: 8,
        averageFireMinutes: 15,
        queueLabel: 'Noodles',
        status: RestaurantServiceStatus.busy,
      ),
      RestaurantKitchenStation(
        id: 'cold',
        name: 'Cold Pass',
        lead: 'Dimas',
        ticketsInProgress: 5,
        averageFireMinutes: 8,
        queueLabel: 'Salads',
        status: RestaurantServiceStatus.calm,
      ),
    ];

    final summary = RestaurantKitchenSummary.fromStations(stations);

    expect(summary.stationCount, 3);
    expect(summary.pressureCount, 2);
    expect(summary.delayedCount, 2);
    expect(summary.calmCount, 1);
    expect(summary.totalTickets, 25);
    expect(summary.averageFireMinutes, 15);
    expect(summary.pressureLabel, '2 stations warm');
    expect(
      stations.where(RestaurantKitchenFilter.pressure.includes),
      hasLength(2),
    );
    expect(
      stations.where(RestaurantKitchenFilter.delayed.includes),
      hasLength(2),
    );
    expect(stations.where(RestaurantKitchenFilter.calm.includes), hasLength(1));
    final focusedData = RestaurantKitchenPanelData.fromStations(
      stations: stations,
      selectedFilter: RestaurantKitchenFilter.calm,
      focusedStationId: 'grill',
    );
    expect(focusedData.visibleStations.map((station) => station.id), [
      'grill',
      'cold',
    ]);
  });

  test('floor summary and filters group zone readiness', () {
    const zones = [
      RestaurantServiceZone(
        id: 'main-floor',
        name: 'Main Floor',
        section: 'Dining',
        occupiedTables: 18,
        totalTables: 22,
        covers: 72,
        waitList: 6,
        ticketMinutes: 17,
        status: RestaurantServiceStatus.busy,
      ),
      RestaurantServiceZone(
        id: 'terrace',
        name: 'Terrace',
        section: 'Outdoor',
        occupiedTables: 9,
        totalTables: 14,
        covers: 34,
        waitList: 2,
        ticketMinutes: 14,
        status: RestaurantServiceStatus.calm,
      ),
      RestaurantServiceZone(
        id: 'private-room',
        name: 'Private Room',
        section: 'Events',
        occupiedTables: 4,
        totalTables: 4,
        covers: 28,
        waitList: 0,
        ticketMinutes: 22,
        status: RestaurantServiceStatus.critical,
      ),
    ];

    final summary = RestaurantFloorSummary.fromZones(zones);

    expect(summary.zoneCount, 3);
    expect(summary.attentionCount, 2);
    expect(summary.waitlistCount, 2);
    expect(summary.calmCount, 1);
    expect(summary.occupiedTables, 31);
    expect(summary.totalTables, 40);
    expect(summary.totalCovers, 134);
    expect(summary.totalWaitList, 8);
    expect(summary.averageTicketMinutes, 18);
    expect(summary.readinessLabel, '2 zones need attention');
    expect(zones.where(RestaurantFloorFilter.attention.includes), hasLength(2));
    expect(zones.where(RestaurantFloorFilter.waitlist.includes), hasLength(2));
    expect(zones.where(RestaurantFloorFilter.calm.includes), hasLength(1));
    final focusedData = RestaurantFloorPanelData.fromZones(
      zones: zones,
      selectedFilter: RestaurantFloorFilter.calm,
      focusedZoneId: 'private-room',
    );
    expect(focusedData.visibleZones.map((zone) => zone.id), [
      'private-room',
      'terrace',
    ]);
  });

  test('workspace panel filters copy focused filter preferences', () {
    const filters = RestaurantWorkspacePanelFilters(
      floor: RestaurantFloorFilter.waitlist,
      kitchen: RestaurantKitchenFilter.pressure,
      reservations: RestaurantReservationFilter.late,
      menu: RestaurantMenuFilter.risk,
      task: RestaurantTaskFilter.open,
      activity: RestaurantActivityFilter.kitchen,
      menuSearchQuery: 'rendang',
      reservationSearchQuery: 'Terrace',
    );

    final updated = filters.copyWith(
      floor: RestaurantFloorFilter.attention,
      task: RestaurantTaskFilter.done,
      menuSearchQuery: 'spritz',
    );

    expect(updated.floor, RestaurantFloorFilter.attention);
    expect(updated.kitchen, RestaurantKitchenFilter.pressure);
    expect(updated.reservations, RestaurantReservationFilter.late);
    expect(updated.menu, RestaurantMenuFilter.risk);
    expect(updated.task, RestaurantTaskFilter.done);
    expect(updated.activity, RestaurantActivityFilter.kitchen);
    expect(updated.menuSearchQuery, 'spritz');
    expect(updated.reservationSearchQuery, 'Terrace');
    expect(updated.menuSort, RestaurantMenuSort.demand);
    expect(updated.activeFilterCount, 6);
    expect(updated.filterSummary.activeFilterCount, updated.activeFilterCount);
    expect(updated.filterSummary.hasMenuSearchQuery, isTrue);
    expect(updated.activeLensLabels, [
      'Floor: Attention',
      'Reservations: Late',
      'Kitchen: Pressure',
      'Menu: Risk',
      'Tasks: Done',
      'Activity: Kitchen',
    ]);
    expect(updated.lensSet.labels, updated.activeLensLabels);
    expect(updated.activeLenses.map((lens) => lens.kind), [
      RestaurantWorkspaceLensKind.floor,
      RestaurantWorkspaceLensKind.reservations,
      RestaurantWorkspaceLensKind.kitchen,
      RestaurantWorkspaceLensKind.menu,
      RestaurantWorkspaceLensKind.task,
      RestaurantWorkspaceLensKind.activity,
    ]);
    expect(
      updated.withoutLens(RestaurantWorkspaceLensKind.menu).menu,
      RestaurantMenuFilter.all,
    );
    expect(
      updated.withoutLens(RestaurantWorkspaceLensKind.menu).floor,
      RestaurantFloorFilter.attention,
    );
    expect(
      updated
          .withoutLens(RestaurantWorkspaceLensKind.menuSearch)
          .menuSearchQuery,
      isEmpty,
    );
    expect(
      updated
          .withoutLens(RestaurantWorkspaceLensKind.reservationSearch)
          .reservationSearchQuery,
      isEmpty,
    );
    expect(updated.hasActivePreferences, isTrue);
    expect(const RestaurantWorkspacePanelFilters().activeFilterCount, 0);
    expect(
      const RestaurantWorkspacePanelFilters().hasActivePreferences,
      isFalse,
    );
    expect(updated, isNot(filters));
    expect(
      const RestaurantWorkspacePanelFilters(),
      const RestaurantWorkspacePanelFilters(),
    );
  });

  test('workspace preferences serialize with safe fallbacks', () {
    const preferences = RestaurantWorkspacePreferences(
      view: RestaurantWorkspaceView.menu,
      filters: RestaurantWorkspacePanelFilters(
        floor: RestaurantFloorFilter.waitlist,
        kitchen: RestaurantKitchenFilter.delayed,
        menu: RestaurantMenuFilter.risk,
        task: RestaurantTaskFilter.attention,
        activity: RestaurantActivityFilter.menu,
        menuSearchQuery: 'cheese',
        menuSort: RestaurantMenuSort.risk,
      ),
      focus: RestaurantWorkspacePanelFocus(
        kind: RestaurantWorkspacePanelFocusKind.menuSignal,
        targetId: 'short-rib-rendang',
        sourceId: 'menu-risk-short-rib-rendang',
      ),
    );

    final json = preferences.toJson();
    final restored = RestaurantWorkspacePreferences.fromJson(json);

    expect(restored, preferences);
    expect(json, {
      'view': 'menu',
      'filters': {
        'floor': 'waitlist',
        'kitchen': 'delayed',
        'reservations': 'all',
        'menu': 'risk',
        'task': 'attention',
        'activity': 'menu',
        'menuSearchQuery': 'cheese',
        'reservationSearchQuery': '',
        'menuSort': 'risk',
      },
      'focus': {
        'kind': 'menuSignal',
        'targetId': 'short-rib-rendang',
        'sourceId': 'menu-risk-short-rib-rendang',
      },
    });

    final fallback = RestaurantWorkspacePreferences.fromJson({
      'view': 'unknown',
      'filters': {
        'floor': 'retired-filter',
        'kitchen': 42,
        'reservations': 'vip',
        'menu': 'margin',
        'task': null,
        'activity': 'kitchen',
        'menuSearchQuery': 99,
        'reservationSearchQuery': 'wijaya',
        'menuSort': 'retired-sort',
      },
      'focus': {'kind': 'retired-focus', 'targetId': ''},
    });

    expect(fallback.view, RestaurantWorkspaceView.pulse);
    expect(fallback.filters.floor, RestaurantFloorFilter.all);
    expect(fallback.filters.kitchen, RestaurantKitchenFilter.all);
    expect(fallback.filters.reservations, RestaurantReservationFilter.vip);
    expect(fallback.filters.menu, RestaurantMenuFilter.margin);
    expect(fallback.filters.task, RestaurantTaskFilter.all);
    expect(fallback.filters.activity, RestaurantActivityFilter.kitchen);
    expect(fallback.filters.menuSearchQuery, isEmpty);
    expect(fallback.filters.reservationSearchQuery, 'wijaya');
    expect(fallback.filters.menuSort, RestaurantMenuSort.demand);
    expect(fallback.focus, isNull);
  });

  test('workspace presets compose view and operating lenses', () {
    final menuRisk = RestaurantWorkspacePreset.menuRisk;

    expect(menuRisk.view, RestaurantWorkspaceView.menu);
    expect(menuRisk.filters.menu, RestaurantMenuFilter.risk);
    expect(menuRisk.filters.activity, RestaurantActivityFilter.menu);
    expect(menuRisk.filters.menuSort, RestaurantMenuSort.risk);
    expect(menuRisk.filters.activeFilterCount, 3);
    expect(
      menuRisk.matches(
        selectedView: RestaurantWorkspaceView.menu,
        filters: menuRisk.filters,
      ),
      isTrue,
    );
    expect(
      RestaurantWorkspacePreset.selectedFor(
        selectedView: RestaurantWorkspaceView.menu,
        filters: menuRisk.filters,
      ),
      menuRisk,
    );
    expect(
      RestaurantWorkspacePreset.selectedFor(
        selectedView: RestaurantWorkspaceView.menu,
        filters: const RestaurantWorkspacePanelFilters(menuSearchQuery: 'rib'),
      ),
      isNull,
    );
    expect(
      RestaurantWorkspacePreset.servicePulse.filters.hasActivePreferences,
      isFalse,
    );
  });

  test('workspace command summary describes active operating controls', () {
    const searchLensSet = RestaurantWorkspaceSearchLensSet(
      menuSearchQuery: ' cheese ',
      reservationSearchQuery: ' terrace ',
      reservationZoneLabels: ['Main Floor', 'Terrace'],
    );
    final summary = RestaurantWorkspaceCommandSummary.fromWorkspace(
      selectedView: RestaurantWorkspaceView.menu,
      filters: const RestaurantWorkspacePanelFilters(
        menu: RestaurantMenuFilter.risk,
        menuSearchQuery: ' cheese ',
        reservationSearchQuery: ' terrace ',
      ),
      isRefreshing: true,
      reservationZoneLabels: const ['Main Floor', 'Terrace'],
    );

    expect(searchLensSet.normalizedMenuSearchQuery, 'cheese');
    expect(searchLensSet.labels, ['Menu search: cheese', 'Zone: Terrace']);
    expect(summary.hasActiveState, isTrue);
    expect(summary.activeFilterCount, 1);
    expect(summary.activeLenses.map((lens) => lens.kind), [
      RestaurantWorkspaceLensKind.menu,
      RestaurantWorkspaceLensKind.menuSearch,
      RestaurantWorkspaceLensKind.reservationSearch,
    ]);
    expect(summary.activeLensLabels, [
      'Menu: Risk',
      'Menu search: cheese',
      'Zone: Terrace',
    ]);
    expect(summary.menuSearchQuery, 'cheese');
    expect(summary.reservationSearchQuery, 'terrace');
    expect(summary.activeStateLabel, '3 active lenses');
    expect(
      summary.activeLensDetailLabel,
      'Menu: Risk, Menu search: cheese, Zone: Terrace',
    );
    expect(summary.signals.map((signal) => signal.label), [
      'View',
      'Lenses',
      'Refresh',
    ]);
    expect(summary.signals.map((signal) => signal.value), [
      'Menu Mix',
      '3 active lenses',
      'Refreshing',
    ]);
  });

  test('snapshot freshness evaluates update age and refresh state', () {
    final now = DateTime(2026, 1, 1, 12);

    final fresh = RestaurantSnapshotFreshness.evaluate(
      updatedAt: now.subtract(const Duration(minutes: 2)),
      now: now,
    );
    final aging = RestaurantSnapshotFreshness.evaluate(
      updatedAt: now.subtract(const Duration(minutes: 8)),
      now: now,
    );
    final stale = RestaurantSnapshotFreshness.evaluate(
      updatedAt: now.subtract(const Duration(minutes: 22)),
      now: now,
    );
    final refreshing = RestaurantSnapshotFreshness.evaluate(
      updatedAt: now.subtract(const Duration(minutes: 22)),
      now: now,
      isRefreshing: true,
    );
    final unknown = RestaurantSnapshotFreshness.evaluate(
      updatedAt: null,
      now: now,
    );

    expect(fresh.status, RestaurantSnapshotFreshnessStatus.fresh);
    expect(fresh.detail, 'Updated 2m ago');
    expect(fresh.serviceStatus, RestaurantServiceStatus.calm);
    expect(aging.status, RestaurantSnapshotFreshnessStatus.aging);
    expect(stale.status, RestaurantSnapshotFreshnessStatus.stale);
    expect(stale.serviceStatus, RestaurantServiceStatus.critical);
    expect(refreshing.status, RestaurantSnapshotFreshnessStatus.refreshing);
    expect(refreshing.detail, 'Updating from source');
    expect(unknown.status, RestaurantSnapshotFreshnessStatus.unknown);
  });

  test('reservation summary and filters group booking flow', () {
    const reservations = [
      RestaurantReservation(
        id: 'late',
        guestName: 'Wijaya Family',
        partySize: 8,
        timeLabel: '19:05',
        arrivalMinutesFromNow: -8,
        zoneLabel: 'Terrace',
        status: RestaurantReservationStatus.late,
        source: RestaurantReservationSource.phone,
      ),
      RestaurantReservation(
        id: 'vip',
        guestName: 'Sari Putri',
        partySize: 6,
        timeLabel: '19:15',
        arrivalMinutesFromNow: 12,
        zoneLabel: 'Main Floor',
        status: RestaurantReservationStatus.confirmed,
        source: RestaurantReservationSource.online,
        isVip: true,
      ),
      RestaurantReservation(
        id: 'seated',
        guestName: 'Andini',
        partySize: 2,
        timeLabel: '19:20',
        arrivalMinutesFromNow: 18,
        zoneLabel: 'Bar Counter',
        status: RestaurantReservationStatus.seated,
        source: RestaurantReservationSource.walkIn,
      ),
      RestaurantReservation(
        id: 'no-show',
        guestName: 'No Show',
        partySize: 4,
        timeLabel: '18:40',
        arrivalMinutesFromNow: -25,
        zoneLabel: 'Main Floor',
        status: RestaurantReservationStatus.noShow,
        source: RestaurantReservationSource.concierge,
      ),
    ];

    final summary = RestaurantReservationSummary.fromReservations(reservations);

    expect(summary.reservationCount, 4);
    expect(summary.expectedCovers, 16);
    expect(summary.upcomingCount, 1);
    expect(summary.seatedCount, 1);
    expect(summary.lateCount, 1);
    expect(summary.vipCount, 1);
    expect(summary.closedCount, 1);
    expect(summary.attentionCount, 2);

    final actionSummary =
        RestaurantReservationActionQueueSummary.fromReservations(reservations);
    expect(actionSummary.actionCount, 3);
    expect(actionSummary.coverCount, 16);
    expect(actionSummary.actionLabel, '3 open actions');
    expect(actionSummary.coverLabel, '16 action covers');
    expect(actionSummary.buckets.map((bucket) => bucket.kind), [
      RestaurantReservationActionBucketKind.confirmRequests,
      RestaurantReservationActionBucketKind.recoverLate,
      RestaurantReservationActionBucketKind.greetDue,
      RestaurantReservationActionBucketKind.seatArrivals,
      RestaurantReservationActionBucketKind.closeSeated,
    ]);
    expect(
      RestaurantReservationActionBucketKind.confirmRequests.targetFilter,
      RestaurantReservationFilter.upcoming,
    );
    expect(
      RestaurantReservationActionBucketKind.recoverLate.targetFilter,
      RestaurantReservationFilter.late,
    );
    expect(
      RestaurantReservationActionBucketKind.greetDue.targetFilter,
      RestaurantReservationFilter.upcoming,
    );
    expect(
      RestaurantReservationActionBucketKind.seatArrivals.targetFilter,
      RestaurantReservationFilter.arrived,
    );
    expect(
      RestaurantReservationActionBucketKind.closeSeated.targetFilter,
      RestaurantReservationFilter.seated,
    );
    expect(
      actionSummary.buckets
          .singleWhere(
            (bucket) =>
                bucket.kind ==
                RestaurantReservationActionBucketKind.recoverLate,
          )
          .reservations
          .single
          .id,
      'late',
    );
    expect(
      actionSummary.buckets
          .singleWhere(
            (bucket) =>
                bucket.kind == RestaurantReservationActionBucketKind.greetDue,
          )
          .coverLabel,
      '6 covers',
    );
    expect(
      actionSummary.buckets
          .singleWhere(
            (bucket) =>
                bucket.kind ==
                RestaurantReservationActionBucketKind.closeSeated,
          )
          .bookingLabel,
      '1 booking',
    );

    final priorityQueue = RestaurantReservationPriorityQueue.fromReservations(
      reservations,
    );
    expect(priorityQueue.count, 3);
    expect(priorityQueue.itemLabel, '3 priority bookings');
    expect(priorityQueue.items.map((item) => item.reservation.id), [
      'late',
      'vip',
      'seated',
    ]);
    expect(
      priorityQueue.items.first.actionKind,
      RestaurantReservationActionBucketKind.recoverLate,
    );
    expect(priorityQueue.items.first.urgencyLabel, '8m late');
    expect(priorityQueue.items[1].actionLabel, 'Mark arrived');
    expect(priorityQueue.items[1].urgencyLabel, 'Due in 12m');
    expect(priorityQueue.items.last.actionLabel, 'Complete');

    final windows = RestaurantReservationArrivalWindow.windowsFor(reservations);
    expect(windows.map((window) => window.kind), [
      RestaurantReservationArrivalWindowKind.late,
      RestaurantReservationArrivalWindowKind.dueNow,
      RestaurantReservationArrivalWindowKind.upcoming,
      RestaurantReservationArrivalWindowKind.inHouse,
      RestaurantReservationArrivalWindowKind.closed,
    ]);
    expect(
      RestaurantReservationArrivalWindowKind.late.targetFilter,
      RestaurantReservationFilter.late,
    );
    expect(
      RestaurantReservationArrivalWindowKind.dueNow.targetFilter,
      RestaurantReservationFilter.upcoming,
    );
    expect(
      RestaurantReservationArrivalWindowKind.upcoming.targetFilter,
      RestaurantReservationFilter.upcoming,
    );
    expect(
      RestaurantReservationArrivalWindowKind.inHouse.targetFilter,
      RestaurantReservationFilter.inHouse,
    );
    expect(
      RestaurantReservationArrivalWindowKind.closed.targetFilter,
      RestaurantReservationFilter.closed,
    );
    expect(
      windows
          .singleWhere(
            (window) =>
                window.kind == RestaurantReservationArrivalWindowKind.late,
          )
          .reservations
          .single
          .id,
      'late',
    );
    expect(
      windows
          .singleWhere(
            (window) =>
                window.kind == RestaurantReservationArrivalWindowKind.dueNow,
          )
          .coverLabel,
      '6 covers',
    );
    expect(
      windows
          .singleWhere(
            (window) =>
                window.kind == RestaurantReservationArrivalWindowKind.upcoming,
          )
          .count,
      0,
    );
    expect(
      windows
          .singleWhere(
            (window) =>
                window.kind == RestaurantReservationArrivalWindowKind.inHouse,
          )
          .bookingLabel,
      '1 booking',
    );
    expect(
      windows
          .singleWhere(
            (window) =>
                window.kind == RestaurantReservationArrivalWindowKind.closed,
          )
          .covers,
      4,
    );

    final zoneLoads = RestaurantReservationZoneLoad.loadsFor(reservations);
    expect(zoneLoads.map((load) => load.zoneLabel), [
      'Terrace',
      'Main Floor',
      'Bar Counter',
    ]);
    expect(zoneLoads.first.serviceStatus, RestaurantServiceStatus.critical);
    expect(zoneLoads.first.coverLabel, '8 covers');
    expect(zoneLoads.first.pressureLabel, '1 late');
    expect(zoneLoads.first.lateCount, 1);
    expect(zoneLoads[1].serviceStatus, RestaurantServiceStatus.busy);
    expect(zoneLoads[1].dueSoonCount, 1);
    expect(zoneLoads[1].vipCount, 1);
    expect(zoneLoads[1].bookingLabel, '1 booking');
    expect(zoneLoads.last.inHouseCount, 1);
    expect(zoneLoads.last.coverCount, 2);
    expect(
      reservations.where(RestaurantReservationFilter.late.includes).single.id,
      'late',
    );
    expect(
      reservations.where(RestaurantReservationFilter.vip.includes).single.id,
      'vip',
    );
    expect(
      reservations
          .where(RestaurantReservationFilter.inHouse.includes)
          .single
          .id,
      'seated',
    );
    expect(
      reservations.where(RestaurantReservationFilter.closed.includes).length,
      1,
    );
  });

  test('reservation status actions describe reusable next steps', () {
    expect(RestaurantReservationStatus.requested.nextActions, [
      RestaurantReservationStatusAction.confirm,
      RestaurantReservationStatusAction.cancel,
    ]);
    expect(RestaurantReservationStatus.confirmed.nextActions, [
      RestaurantReservationStatusAction.markArrived,
      RestaurantReservationStatusAction.markNoShow,
    ]);
    expect(RestaurantReservationStatus.late.nextActions, [
      RestaurantReservationStatusAction.markArrived,
      RestaurantReservationStatusAction.markNoShow,
    ]);
    expect(RestaurantReservationStatus.arrived.nextActions, [
      RestaurantReservationStatusAction.seat,
      RestaurantReservationStatusAction.cancel,
    ]);
    expect(RestaurantReservationStatus.seated.nextActions, [
      RestaurantReservationStatusAction.complete,
    ]);
    expect(RestaurantReservationStatus.completed.nextActions, isEmpty);
    expect(RestaurantReservationStatus.cancelled.nextActions, isEmpty);
    expect(RestaurantReservationStatus.noShow.nextActions, isEmpty);

    expect(RestaurantReservationStatusAction.confirm.label, 'Confirm');
    expect(
      RestaurantReservationStatusAction.confirm.targetStatus,
      RestaurantReservationStatus.confirmed,
    );
    expect(
      RestaurantReservationStatusAction.markNoShow.targetStatus,
      RestaurantReservationStatus.noShow,
    );
    expect(
      RestaurantReservationStatusAction.complete.targetStatus,
      RestaurantReservationStatus.completed,
    );
    expect(
      RestaurantReservationStatus.requested.serviceStatus,
      RestaurantServiceStatus.busy,
    );
    expect(
      RestaurantReservationStatus.late.serviceStatus,
      RestaurantServiceStatus.critical,
    );
    expect(
      RestaurantReservationStatus.cancelled.serviceStatus,
      RestaurantServiceStatus.blocked,
    );
  });

  test('reservation intake actions expose QR alternatives', () {
    expect(RestaurantReservationSource.qrCode.label, 'QR code');
    expect(
      RestaurantReservationIntakeAction.phone.source,
      RestaurantReservationSource.phone,
    );
    expect(
      RestaurantReservationIntakeAction.online.source,
      RestaurantReservationSource.online,
    );
    expect(
      RestaurantReservationIntakeAction.qrBooking.source,
      RestaurantReservationSource.qrCode,
    );
    expect(
      RestaurantReservationIntakeAction.qrWaitlist.source,
      RestaurantReservationSource.qrCode,
    );
    expect(
      RestaurantReservationIntakeAction.qrCheckIn.source,
      RestaurantReservationSource.qrCode,
    );
    expect(
      RestaurantReservationIntakeAction.qrBooking.qrIntent,
      RestaurantReservationQrIntent.booking,
    );
    expect(
      RestaurantReservationIntakeAction.qrWaitlist.qrIntent,
      RestaurantReservationQrIntent.waitlist,
    );
    expect(
      RestaurantReservationIntakeAction.qrCheckIn.qrIntent,
      RestaurantReservationQrIntent.checkIn,
    );
    expect(RestaurantReservationIntakeAction.qrBooking.usesQrCode, isTrue);
    expect(RestaurantReservationIntakeAction.qrWaitlist.usesQrCode, isTrue);
    expect(RestaurantReservationIntakeAction.qrCheckIn.usesQrCode, isTrue);
    expect(RestaurantReservationIntakeAction.manual.source, isNull);
    expect(RestaurantReservationIntakeAction.manual.qrIntent, isNull);
  });

  test('reservation late recovery lens catches past pending arrivals', () {
    const pastDue = RestaurantReservation(
      id: 'past-due',
      guestName: 'Past Due',
      partySize: 4,
      timeLabel: '19:00',
      arrivalMinutesFromNow: -4,
      zoneLabel: 'Terrace',
      status: RestaurantReservationStatus.confirmed,
      source: RestaurantReservationSource.online,
    );
    const future = RestaurantReservation(
      id: 'future',
      guestName: 'Future Guest',
      partySize: 2,
      timeLabel: '19:20',
      arrivalMinutesFromNow: 16,
      zoneLabel: 'Main Floor',
      status: RestaurantReservationStatus.confirmed,
      source: RestaurantReservationSource.phone,
    );

    expect(pastDue.isPendingArrival, isTrue);
    expect(pastDue.needsLateRecovery, isTrue);
    expect(future.needsLateRecovery, isFalse);
    expect(RestaurantReservationFilter.late.includes(pastDue), isTrue);

    final summary = RestaurantReservationSummary.fromReservations([
      pastDue,
      future,
    ]);
    expect(summary.lateCount, 1);

    final actionSummary =
        RestaurantReservationActionQueueSummary.fromReservations([
          pastDue,
          future,
        ]);
    expect(
      actionSummary.buckets
          .singleWhere(
            (bucket) =>
                bucket.kind ==
                RestaurantReservationActionBucketKind.recoverLate,
          )
          .reservations
          .single
          .id,
      'past-due',
    );

    final windows = RestaurantReservationArrivalWindow.windowsFor([
      pastDue,
      future,
    ]);
    expect(
      windows
          .singleWhere(
            (window) =>
                window.kind == RestaurantReservationArrivalWindowKind.late,
          )
          .reservations
          .single
          .id,
      'past-due',
    );
  });

  test('reservation panel data derives searchable presentation state', () {
    const reservations = [
      RestaurantReservation(
        id: 'request',
        guestName: 'Rafi Santoso',
        partySize: 4,
        timeLabel: '18:55',
        arrivalMinutesFromNow: 6,
        zoneLabel: 'Main Floor',
        tableLabel: 'T4',
        phoneNumber: '+62 812 0000 4411',
        emailAddress: 'rafi@example.test',
        status: RestaurantReservationStatus.requested,
        source: RestaurantReservationSource.phone,
        notes: 'Needs booster seat.',
      ),
      RestaurantReservation(
        id: 'late',
        guestName: 'Nadia',
        partySize: 8,
        timeLabel: '18:40',
        arrivalMinutesFromNow: -8,
        zoneLabel: 'Terrace',
        status: RestaurantReservationStatus.confirmed,
        source: RestaurantReservationSource.online,
      ),
      RestaurantReservation(
        id: 'vip',
        guestName: 'Sari Putri',
        partySize: 6,
        timeLabel: '19:15',
        arrivalMinutesFromNow: 12,
        zoneLabel: 'Main Floor',
        status: RestaurantReservationStatus.confirmed,
        source: RestaurantReservationSource.online,
        isVip: true,
      ),
      RestaurantReservation(
        id: 'arrived',
        guestName: 'Andini',
        partySize: 2,
        timeLabel: '19:20',
        arrivalMinutesFromNow: 18,
        zoneLabel: 'Bar Counter',
        status: RestaurantReservationStatus.arrived,
        source: RestaurantReservationSource.walkIn,
      ),
      RestaurantReservation(
        id: 'closed',
        guestName: 'No Show',
        partySize: 4,
        timeLabel: '18:35',
        arrivalMinutesFromNow: -25,
        zoneLabel: 'Main Floor',
        status: RestaurantReservationStatus.noShow,
        source: RestaurantReservationSource.concierge,
      ),
    ];

    final data = RestaurantReservationPanelData.fromReservations(
      reservations: reservations,
      selectedFilter: RestaurantReservationFilter.all,
      searchQuery: 'main',
    );

    expect(data.hasReservations, isTrue);
    expect(data.hasSearch, isTrue);
    expect(data.summary.reservationCount, 5);
    expect(data.actionQueueSummary.actionCount, 4);
    expect(data.zoneLoads.map((load) => load.zoneLabel), [
      'Terrace',
      'Main Floor',
      'Bar Counter',
    ]);
    expect(data.visibleReservations.map((reservation) => reservation.id), [
      'closed',
      'request',
      'vip',
    ]);
    final focusedData = RestaurantReservationPanelData.fromReservations(
      reservations: reservations,
      selectedFilter: RestaurantReservationFilter.all,
      searchQuery: 'main',
      focusedReservationId: 'arrived',
    );
    expect(
      focusedData.visibleReservations.map((reservation) => reservation.id),
      ['arrived', 'closed', 'request', 'vip'],
    );
    expect(data.priorityQueue.items.map((item) => item.reservation.id), [
      'request',
      'vip',
    ]);
    expect(data.selectedActionBucketKind, isNull);
    expect(data.selectedArrivalWindowKind, isNull);
    expect(
      RestaurantReservationPanelData.matchesSearch(
        reservations.first,
        'booster',
      ),
      isTrue,
    );
    expect(
      RestaurantReservationPanelData.matchesSearch(reservations.first, 't4'),
      isTrue,
    );
    expect(
      RestaurantReservationPanelData.matchesSearch(
        reservations.first,
        'requested',
      ),
      isTrue,
    );
    expect(
      RestaurantReservationPanelData.matchesSearch(reservations.first, 'phone'),
      isTrue,
    );
    expect(
      RestaurantReservationPanelData.matchesSearch(reservations.first, '4411'),
      isTrue,
    );
    expect(
      RestaurantReservationPanelData.matchesSearch(reservations.first, 'rafi@'),
      isTrue,
    );
  });

  test('reservation panel data maps filters to selected operating lanes', () {
    final lateData = RestaurantReservationPanelData.fromReservations(
      reservations: const [
        RestaurantReservation(
          id: 'late',
          guestName: 'Nadia',
          partySize: 8,
          timeLabel: '18:40',
          arrivalMinutesFromNow: -8,
          zoneLabel: 'Terrace',
          status: RestaurantReservationStatus.confirmed,
          source: RestaurantReservationSource.online,
        ),
      ],
      selectedFilter: RestaurantReservationFilter.late,
    );
    final arrivedData = RestaurantReservationPanelData.fromReservations(
      reservations: const [],
      selectedFilter: RestaurantReservationFilter.arrived,
    );
    final closedData = RestaurantReservationPanelData.fromReservations(
      reservations: const [],
      selectedFilter: RestaurantReservationFilter.closed,
    );

    expect(
      lateData.selectedActionBucketKind,
      RestaurantReservationActionBucketKind.recoverLate,
    );
    expect(
      lateData.selectedArrivalWindowKind,
      RestaurantReservationArrivalWindowKind.late,
    );
    expect(lateData.visibleReservations.single.id, 'late');
    expect(
      arrivedData.selectedActionBucketKind,
      RestaurantReservationActionBucketKind.seatArrivals,
    );
    expect(arrivedData.selectedArrivalWindowKind, isNull);
    expect(closedData.selectedActionBucketKind, isNull);
    expect(
      closedData.selectedArrivalWindowKind,
      RestaurantReservationArrivalWindowKind.closed,
    );
  });

  test('restaurant route definitions map sidebar destinations to views', () {
    expect(restaurantRouteDefinitions.map((route) => route.path), [
      RestaurantRoutes.workspacePath,
      RestaurantRoutes.floorPath,
      RestaurantRoutes.reservationsPath,
      RestaurantRoutes.menuPath,
      RestaurantRoutes.kitchenPath,
    ]);
    expect(
      restaurantRouteDefinitions.map((route) => route.path),
      isNot(contains(RestaurantRoutes.reservationQrPath)),
    );
    expect(RestaurantRoutes.reservationQrPath, '/restaurant/reservations/qr');
    expect(
      restaurantRouteDefinitions.first.view,
      RestaurantWorkspaceView.pulse,
    );
    expect(restaurantRouteDefinitions.last.icon, 'restaurant-kitchen');
    expect(
      RestaurantRoutes.pathForView(RestaurantWorkspaceView.reservations),
      RestaurantRoutes.reservationsPath,
    );
    expect(
      RestaurantRoutes.pathForView(RestaurantWorkspaceView.menu),
      RestaurantRoutes.menuPath,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forActiveLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.floor,
          label: 'Floor: Waitlist',
        ),
      ).view,
      RestaurantWorkspaceView.floor,
    );
    expect(
      const RestaurantWorkspaceActiveLens(
        kind: RestaurantWorkspaceLensKind.floor,
        label: 'Floor: Waitlist',
      ).targetView,
      RestaurantWorkspaceView.floor,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forActiveLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.reservationSearch,
          label: 'Zone: Terrace',
        ),
      ).view,
      RestaurantWorkspaceView.reservations,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forActiveLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.menuSearch,
          label: 'Menu search: cheese',
        ),
      ).view,
      RestaurantWorkspaceView.menu,
    );
    expect(
      RestaurantWorkspaceNavigationTarget.forActiveLens(
        const RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.activity,
          label: 'Activity: Kitchen',
        ),
      ).view,
      RestaurantWorkspaceView.pulse,
    );
    expect(
      restaurantWorkspaceViewFromPath(RestaurantRoutes.reservationsPath),
      RestaurantWorkspaceView.reservations,
    );
    expect(
      restaurantWorkspaceViewFromPath(RestaurantRoutes.kitchenPath),
      RestaurantWorkspaceView.kitchen,
    );
    expect(
      restaurantWorkspaceViewFromPath('/unknown'),
      RestaurantWorkspaceView.pulse,
    );
  });
}
