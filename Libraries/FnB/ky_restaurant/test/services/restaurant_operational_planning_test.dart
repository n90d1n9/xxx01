import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('demo snapshot exposes operational attention signals', () {
    expect(restaurantDemoSnapshot.activeCovers, 148);
    expect(restaurantDemoSnapshot.blockedOrCriticalZones, 1);
    expect(restaurantDemoSnapshot.delayedStations, 2);
    expect(restaurantDemoSnapshot.topMenuSignal.name, 'Citrus Pandan Spritz');
  });

  test('priority selector ranks shared operating attention targets', () {
    final selector = const RestaurantPrioritySelector();

    expect(
      selector
          .attentionZones(restaurantDemoSnapshot.zones)
          .map((zone) => zone.id),
      ['private-room', 'main-floor'],
    );
    expect(selector.topZone(restaurantDemoSnapshot.zones)?.id, 'private-room');
    expect(
      selector
          .attentionReservations(restaurantDemoSnapshot.reservations)
          .map((reservation) => reservation.id),
      ['wijaya-family', 'sari-party', 'private-dining'],
    );
    expect(
      selector.topReservation(restaurantDemoSnapshot.reservations)?.id,
      'wijaya-family',
    );
    expect(
      selector
          .delayedStations(restaurantDemoSnapshot.stations)
          .map((station) => station.id),
      ['grill', 'wok'],
    );
    expect(selector.topStation(restaurantDemoSnapshot.stations)?.id, 'grill');
    expect(
      selector
          .kitchenPressureSignal(restaurantDemoSnapshot.stations)
          .titleLabel,
      'Recover Grill',
    );
    expect(
      selector.topMenuRisk(restaurantDemoSnapshot.menuSignals)?.id,
      'short-rib-rendang',
    );
    expect(
      selector.topOpenTask(restaurantDemoSnapshot.tasks)?.id,
      'rendang-par',
    );
  });

  test('attention signal builder ranks cross-functional feed', () {
    final queue = const RestaurantAttentionSignalBuilder().build(
      restaurantDemoSnapshot,
    );

    expect(queue.hasAttention, isTrue);
    expect(queue.serviceStatus, RestaurantServiceStatus.critical);
    expect(queue.topSignal?.id, 'menu-risk-short-rib-rendang');
    expect(queue.topAttention(limit: 4).map((signal) => signal.kind), [
      RestaurantAttentionSignalKind.menuRisk,
      RestaurantAttentionSignalKind.reservation,
      RestaurantAttentionSignalKind.kitchenStation,
      RestaurantAttentionSignalKind.floorZone,
    ]);
    expect(
      queue.attentionCountForKind(RestaurantAttentionSignalKind.menuCatalog),
      3,
    );
    expect(
      queue.signalsForKind(RestaurantAttentionSignalKind.recipeProduction),
      hasLength(4),
    );
    expect(
      queue.attentionCountForKind(
        RestaurantAttentionSignalKind.recipeProduction,
      ),
      2,
    );
    expect(
      queue.signalsForKind(RestaurantAttentionSignalKind.shiftTask),
      hasLength(3),
    );
    expect(queue.attentionCountLabel, '17 signals need attention');
  });

  test('attention signal target resolver maps signals to workspace lenses', () {
    final queue = const RestaurantAttentionSignalBuilder().build(
      restaurantDemoSnapshot,
    );
    const resolver = RestaurantAttentionSignalTargetResolver();

    final menuTarget = resolver.resolve(queue.topSignal!);
    final reservationTarget = resolver.resolve(
      queue.signalsForKind(RestaurantAttentionSignalKind.reservation).first,
    );
    final kitchenTarget = resolver.resolve(
      queue.signalsForKind(RestaurantAttentionSignalKind.kitchenStation).first,
    );
    final catalogSignal = queue
        .signalsForKind(RestaurantAttentionSignalKind.menuCatalog)
        .last;
    final catalogTarget = resolver.resolve(catalogSignal);
    final recipeSignal = queue
        .signalsForKind(RestaurantAttentionSignalKind.recipeProduction)
        .first;
    final recipeTarget = resolver.resolve(recipeSignal);
    final selectedSignal = resolver.selectedSignalFor(
      selectedView: RestaurantWorkspaceView.menu,
      selectedFilters: menuTarget.filters,
      signals: queue.attentionSignals,
    );
    final selectedCatalogSignal = resolver.selectedSignalFor(
      selectedView: RestaurantWorkspaceView.menu,
      selectedFilters: catalogTarget.filters,
      selectedFocus: catalogTarget.focus,
      signals: queue.signals,
    );
    final selectedRecipeSignal = resolver.selectedSignalFor(
      selectedView: RestaurantWorkspaceView.kitchen,
      selectedFilters: recipeTarget.filters,
      selectedFocus: recipeTarget.focus,
      signals: queue.signals,
    );

    expect(menuTarget.view, RestaurantWorkspaceView.menu);
    expect(menuTarget.filters.menu, RestaurantMenuFilter.risk);
    expect(menuTarget.filters.menuSort, RestaurantMenuSort.risk);
    expect(menuTarget.filters.activity, RestaurantActivityFilter.menu);
    expect(
      menuTarget.focus?.kind,
      RestaurantWorkspacePanelFocusKind.menuSignal,
    );
    expect(menuTarget.focus?.targetId, 'short-rib-rendang');
    expect(reservationTarget.view, RestaurantWorkspaceView.reservations);
    expect(
      reservationTarget.filters.reservations,
      RestaurantReservationFilter.late,
    );
    expect(
      reservationTarget.focus?.kind,
      RestaurantWorkspacePanelFocusKind.reservation,
    );
    expect(reservationTarget.focus?.targetId, 'wijaya-family');
    expect(kitchenTarget.view, RestaurantWorkspaceView.kitchen);
    expect(kitchenTarget.filters.kitchen, RestaurantKitchenFilter.pressure);
    expect(
      kitchenTarget.focus?.kind,
      RestaurantWorkspacePanelFocusKind.kitchenStation,
    );
    expect(kitchenTarget.focus?.targetId, 'grill');
    expect(recipeTarget.view, RestaurantWorkspaceView.kitchen);
    expect(recipeTarget.filters.kitchen, RestaurantKitchenFilter.pressure);
    expect(
      recipeTarget.focus?.kind,
      RestaurantWorkspacePanelFocusKind.recipeProduction,
    );
    expect(recipeTarget.focus?.targetId, recipeSignal.targetId);
    expect(selectedSignal?.id, queue.topSignal?.id);
    expect(selectedCatalogSignal?.id, catalogSignal.id);
    expect(selectedRecipeSignal?.id, recipeSignal.id);
  });

  test('service pulse builder derives cross-functional metrics', () {
    final metrics = const RestaurantServicePulseBuilder().build(
      restaurantDemoSnapshot,
    );

    expect(metrics.map((metric) => metric.kind), [
      RestaurantServicePulseMetricKind.floor,
      RestaurantServicePulseMetricKind.reservations,
      RestaurantServicePulseMetricKind.kitchen,
      RestaurantServicePulseMetricKind.menu,
    ]);
    expect(metrics.map((metric) => metric.value), [
      '2 zones need attention',
      '3 bookings need host focus',
      '2 stations running warm',
      'Citrus Pandan Spritz',
    ]);
    expect(metrics.map((metric) => metric.status), [
      RestaurantServiceStatus.critical,
      RestaurantServiceStatus.critical,
      RestaurantServiceStatus.critical,
      RestaurantServiceStatus.calm,
    ]);
    expect(
      metrics[2].detail,
      'Steaks and skewers with 12 tickets, 21m average fire. Lead Ari.',
    );
  });

  test('menu signal selector ranks insight candidates', () {
    final selector = const RestaurantMenuSignalSelector();

    expect(
      selector.topRisk(restaurantDemoSnapshot.menuSignals)?.id,
      'short-rib-rendang',
    );
    expect(
      selector.highestMargin(restaurantDemoSnapshot.menuSignals)?.id,
      'citrus-pandan-spritz',
    );
    expect(
      selector.quickestPrep(restaurantDemoSnapshot.menuSignals)?.id,
      'citrus-pandan-spritz',
    );
    expect(selector.topRisk(const []), isNull);
  });

  test('operational insight factory maps entities to target lenses', () {
    const factory = RestaurantOperationalInsightFactory();
    final lateReservation = restaurantDemoSnapshot.reservations.singleWhere(
      (reservation) => reservation.id == 'wijaya-family',
    );
    final riskSignal = restaurantDemoSnapshot.menuSignals.singleWhere(
      (signal) => signal.id == 'short-rib-rendang',
    );
    final station = restaurantDemoSnapshot.stations.singleWhere(
      (station) => station.id == 'grill',
    );

    expect(
      factory.reservationRisk(lateReservation).targetFilters.reservations,
      RestaurantReservationFilter.late,
    );
    expect(
      factory.menuRisk(riskSignal).targetFilters.menuSort,
      RestaurantMenuSort.risk,
    );
    expect(
      factory.kitchenBottleneck(station).targetView,
      RestaurantWorkspaceView.kitchen,
    );
    expect(
      factory.kitchenBottleneck(station).targetFilters.kitchen,
      RestaurantKitchenFilter.pressure,
    );
    expect(factory.kitchenBottleneck(station).title, 'Recover Grill');
  });

  test('operational insight builder ranks shift decisions', () {
    final insights = const RestaurantOperationalInsightBuilder().build(
      restaurantDemoSnapshot,
    );

    expect(insights.map((insight) => insight.id), [
      'reservation-risk-wijaya-family',
      'menu-risk-short-rib-rendang',
      'margin-leader-citrus-pandan-spritz',
      'quick-prep-citrus-pandan-spritz',
      'kitchen-bottleneck-grill',
    ]);
    expect(insights.map((insight) => insight.valueLabel), [
      '8m late',
      '72% risk',
      '71% margin',
      '5m prep',
      '21m fire',
    ]);
    expect(insights[4].title, 'Recover Grill');
    expect(insights[4].detail, 'Send support to Grill, 12 tickets');
    expect(insights.map((insight) => insight.status), [
      RestaurantServiceStatus.critical,
      RestaurantServiceStatus.critical,
      RestaurantServiceStatus.calm,
      RestaurantServiceStatus.calm,
      RestaurantServiceStatus.critical,
    ]);
    expect(insights.map((insight) => insight.targetView), [
      RestaurantWorkspaceView.reservations,
      RestaurantWorkspaceView.menu,
      RestaurantWorkspaceView.menu,
      RestaurantWorkspaceView.menu,
      RestaurantWorkspaceView.kitchen,
    ]);
    expect(
      insights[0].targetFilters.reservations,
      RestaurantReservationFilter.late,
    );
    expect(
      insights[0].targetFilters.activity,
      RestaurantActivityFilter.reservations,
    );
    expect(insights[1].targetFilters.menu, RestaurantMenuFilter.risk);
    expect(insights[1].targetFilters.activity, RestaurantActivityFilter.menu);
    expect(insights[1].targetFilters.menuSort, RestaurantMenuSort.risk);
    expect(insights[2].targetFilters.menu, RestaurantMenuFilter.margin);
    expect(insights[2].targetFilters.menuSort, RestaurantMenuSort.margin);
    expect(insights[3].targetFilters.menu, RestaurantMenuFilter.quick);
    expect(insights[3].targetFilters.menuSort, RestaurantMenuSort.prep);
    expect(insights[4].targetFilters.kitchen, RestaurantKitchenFilter.pressure);
    expect(
      insights[4].targetFilters.activity,
      RestaurantActivityFilter.kitchen,
    );
    expect(
      RestaurantOperationalInsight.selectedFor(
        selectedView: RestaurantWorkspaceView.menu,
        filters: insights[1].targetFilters,
        insights: insights,
      )?.id,
      'menu-risk-short-rib-rendang',
    );
    expect(
      RestaurantOperationalInsight.selectedFor(
        selectedView: RestaurantWorkspaceView.floor,
        filters: insights[1].targetFilters,
        insights: insights,
      ),
      isNull,
    );
  });

  test('operational insight builder skips calm kitchen stations', () {
    final calmSnapshot = restaurantDemoSnapshot.copyWith(
      stations: [
        for (final station in restaurantDemoSnapshot.stations)
          station.copyWith(
            status: RestaurantServiceStatus.calm,
            ticketsInProgress: 2,
            averageFireMinutes: 6,
          ),
      ],
    );

    final insights = const RestaurantOperationalInsightBuilder().build(
      calmSnapshot,
    );

    expect(
      insights.map((insight) => insight.kind),
      isNot(contains(RestaurantOperationalInsightKind.kitchenBottleneck)),
    );
    expect(calmSnapshot.delayedStations, 0);
  });

  test('briefing builder ranks next operational moves', () {
    final items = const RestaurantBriefingBuilder().build(
      restaurantDemoSnapshot,
    );

    expect(items.map((item) => item.id), [
      'zone-private-room',
      'reservation-wijaya-family',
      'station-grill',
      'menu-short-rib-rendang',
    ]);
    expect(items.map((item) => item.priorityLabel), [
      'Priority 1',
      'Priority 2',
      'Priority 3',
      'Priority 4',
    ]);
    expect(items.first.title, contains('Private Room'));
    expect(items.first.status, RestaurantServiceStatus.critical);
    expect(items.first.reasonLabel, '22m tickets, 0 waiting');
    expect(
      items.first.action?.kind,
      RestaurantBriefingActionKind.stabilizeZone,
    );
    expect(items.first.action?.targetId, 'private-room');
    expect(items[1].category, RestaurantBriefingCategory.reservations);
    expect(items[1].reasonLabel, '8m late, 8 guests');
    expect(
      items[1].action?.kind,
      RestaurantBriefingActionKind.markReservationArrived,
    );
    expect(items[1].action?.targetId, 'wijaya-family');
    expect(
      items[2].action?.kind,
      RestaurantBriefingActionKind.rebalanceStation,
    );
    expect(items[2].action?.targetId, 'grill');
    expect(items[2].title, 'Recover Grill');
    expect(items[2].description, contains('Steaks and skewers'));
    expect(items[2].actionLabel, 'Send support to Grill');
    expect(items[2].reasonLabel, '21m fire, 12 tickets');
  });

  test('briefing builder returns steady overview when service is calm', () {
    final calmSnapshot = restaurantDemoSnapshot.copyWith(
      zones: [
        for (final zone in restaurantDemoSnapshot.zones)
          zone.copyWith(
            status: RestaurantServiceStatus.calm,
            waitList: 0,
            ticketMinutes: 8,
          ),
      ],
      stations: [
        for (final station in restaurantDemoSnapshot.stations)
          station.copyWith(
            status: RestaurantServiceStatus.calm,
            ticketsInProgress: 2,
            averageFireMinutes: 6,
          ),
      ],
      menuSignals: [
        for (final signal in restaurantDemoSnapshot.menuSignals)
          signal.copyWith(soldOutRiskPercent: 12),
      ],
      tasks: [
        for (final task in restaurantDemoSnapshot.tasks)
          task.copyWith(
            dueLabel: 'Done',
            progress: 1,
            status: RestaurantServiceStatus.calm,
          ),
      ],
      reservations: [
        for (final reservation in restaurantDemoSnapshot.reservations)
          reservation.copyWith(
            status: RestaurantReservationStatus.completed,
            isVip: false,
          ),
      ],
    );

    final items = const RestaurantBriefingBuilder().build(calmSnapshot);

    expect(items, hasLength(1));
    expect(items.single.category, RestaurantBriefingCategory.overview);
    expect(items.single.status, RestaurantServiceStatus.calm);
    expect(items.single.priorityLabel, 'Priority 1');
    expect(items.single.reasonLabel, isNull);
  });
}
