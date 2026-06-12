import 'kitchen_station.dart';
import 'service_status.dart';

/// Aggregates shared kitchen station load for service dashboards and planning.
class FnbKitchenStationSummary {
  const FnbKitchenStationSummary({
    required this.stationCount,
    required this.pressureCount,
    required this.delayedCount,
    required this.calmCount,
    required this.totalTickets,
    required this.averageFireMinutes,
  });

  static const defaultDelayedFireMinuteThreshold = 15;

  factory FnbKitchenStationSummary.fromStations(
    Iterable<FnbKitchenStation> stations, {
    int delayedFireMinuteThreshold = defaultDelayedFireMinuteThreshold,
  }) {
    var stationCount = 0;
    var pressureCount = 0;
    var delayedCount = 0;
    var totalTickets = 0;
    var fireMinutesTotal = 0;

    for (final station in stations) {
      stationCount += 1;
      if (station.status != FnbServiceStatus.calm) pressureCount += 1;
      if (station.averageFireMinutes >= delayedFireMinuteThreshold) {
        delayedCount += 1;
      }
      totalTickets += station.ticketsInProgress;
      fireMinutesTotal += station.averageFireMinutes;
    }

    return FnbKitchenStationSummary(
      stationCount: stationCount,
      pressureCount: pressureCount,
      delayedCount: delayedCount,
      calmCount: stationCount - pressureCount,
      totalTickets: totalTickets,
      averageFireMinutes: stationCount == 0
          ? 0
          : (fireMinutesTotal / stationCount).round(),
    );
  }

  final int stationCount;
  final int pressureCount;
  final int delayedCount;
  final int calmCount;
  final int totalTickets;
  final int averageFireMinutes;

  double get pressureRate {
    if (stationCount == 0) return 0;
    return pressureCount / stationCount;
  }

  String get pressureLabel {
    return pressureCount == 1
        ? '1 station warm'
        : '$pressureCount stations warm';
  }
}
