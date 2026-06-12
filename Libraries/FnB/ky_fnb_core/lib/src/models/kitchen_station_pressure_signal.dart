import 'kitchen_station.dart';
import 'kitchen_station_priority_queue.dart';
import 'service_status.dart';

/// Describes the highest-priority kitchen station pressure for operator focus.
class FnbKitchenStationPressureSignal {
  const FnbKitchenStationPressureSignal({
    required this.status,
    required this.station,
  });

  /// Builds the top station pressure signal from shared station snapshots.
  factory FnbKitchenStationPressureSignal.fromStations(
    Iterable<FnbKitchenStation> stations,
  ) {
    final topStation = FnbKitchenStationPriorityQueue.fromStations(
      stations,
    ).topStation;

    if (topStation == null) return clear;
    return FnbKitchenStationPressureSignal(
      status: topStation.status,
      station: topStation,
    );
  }

  /// Calm signal used when every station is within normal operating pressure.
  static const clear = FnbKitchenStationPressureSignal(
    status: FnbServiceStatus.calm,
    station: null,
  );

  final FnbServiceStatus status;
  final FnbKitchenStation? station;

  bool get hasPressure => station != null && status != FnbServiceStatus.calm;

  String get titleLabel {
    final stationName = station?.name;
    if (stationName == null) return 'Kitchen flow steady';

    return switch (status) {
      FnbServiceStatus.blocked => 'Unblock $stationName',
      FnbServiceStatus.critical => 'Recover $stationName',
      FnbServiceStatus.busy => 'Watch $stationName',
      FnbServiceStatus.calm => 'Kitchen flow steady',
    };
  }

  String get messageLabel {
    final station = this.station;
    if (station == null) return 'No stations need attention right now.';

    return '${station.queueLabel} with ${station.loadLabel}. '
        'Lead ${station.lead}.';
  }

  String get actionLabel {
    final station = this.station;
    if (station == null) return 'Keep monitoring';

    return switch (status) {
      FnbServiceStatus.blocked => 'Clear blocker with ${station.lead}',
      FnbServiceStatus.critical => 'Send support to ${station.name}',
      FnbServiceStatus.busy => 'Keep ${station.name} paced',
      FnbServiceStatus.calm => 'Keep monitoring',
    };
  }

  String get accessibilityLabel {
    return '$titleLabel, $messageLabel, $actionLabel';
  }
}
