import '../models/restaurant_models.dart';
import '../models/restaurant_operational_insight.dart';
import 'menu_signal_selector.dart';
import 'operational_insight_factory.dart';
import 'restaurant_priority_selector.dart';

/// Builds prioritized operational insights for the restaurant workspace.
class RestaurantOperationalInsightBuilder {
  const RestaurantOperationalInsightBuilder({
    this.prioritySelector = const RestaurantPrioritySelector(),
    this.menuSignalSelector = const RestaurantMenuSignalSelector(),
    this.insightFactory = const RestaurantOperationalInsightFactory(),
  });

  final RestaurantPrioritySelector prioritySelector;
  final RestaurantMenuSignalSelector menuSignalSelector;
  final RestaurantOperationalInsightFactory insightFactory;

  List<RestaurantOperationalInsight> build(
    RestaurantOperatingSnapshot snapshot,
  ) {
    final kitchenPressure = prioritySelector.kitchenPressureSignal(
      snapshot.stations,
    );

    return [
      if (prioritySelector.topReservation(snapshot.reservations)
          case final reservation?)
        insightFactory.reservationRisk(reservation),
      if (menuSignalSelector.topRisk(snapshot.menuSignals) case final signal?)
        insightFactory.menuRisk(signal),
      if (menuSignalSelector.highestMargin(snapshot.menuSignals)
          case final signal?)
        insightFactory.marginLeader(signal),
      if (menuSignalSelector.quickestPrep(snapshot.menuSignals)
          case final signal?)
        insightFactory.quickPrep(signal),
      if (kitchenPressure.hasPressure)
        insightFactory.kitchenPressure(kitchenPressure),
    ];
  }
}
