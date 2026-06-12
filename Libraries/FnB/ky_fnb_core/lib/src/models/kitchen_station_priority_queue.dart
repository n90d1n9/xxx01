import 'kitchen_station.dart';
import 'service_status.dart';

/// Ranks kitchen stations that need operating attention during service.
class FnbKitchenStationPriorityQueue {
  FnbKitchenStationPriorityQueue({
    required Iterable<FnbKitchenStation> stations,
  }) : stations = List<FnbKitchenStation>.unmodifiable(stations);

  factory FnbKitchenStationPriorityQueue.fromStations(
    Iterable<FnbKitchenStation> stations,
  ) {
    final ranked = stations
        .where((station) => station.status != FnbServiceStatus.calm)
        .toList(growable: false);

    ranked.sort((a, b) {
      final statusComparison = b.status.priorityScore.compareTo(
        a.status.priorityScore,
      );
      if (statusComparison != 0) return statusComparison;

      final fireComparison = b.averageFireMinutes.compareTo(
        a.averageFireMinutes,
      );
      if (fireComparison != 0) return fireComparison;

      final ticketComparison = b.ticketsInProgress.compareTo(
        a.ticketsInProgress,
      );
      if (ticketComparison != 0) return ticketComparison;

      return a.name.compareTo(b.name);
    });

    return FnbKitchenStationPriorityQueue(stations: ranked);
  }

  final List<FnbKitchenStation> stations;

  int get count => stations.length;

  bool get isEmpty => stations.isEmpty;

  FnbKitchenStation? get topStation {
    if (stations.isEmpty) return null;
    return stations.first;
  }
}
