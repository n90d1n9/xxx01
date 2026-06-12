import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_station_load.dart';
import 'kitchen_ticket_queue.dart';

/// Derives dashboard-ready load, summary, filter, and priority state for stations.
class KitchenStationBoard {
  KitchenStationBoard({required Iterable<KitchenStationLoad> loads})
    : loads = List<KitchenStationLoad>.unmodifiable(loads);

  factory KitchenStationBoard.fromQueue({
    required Iterable<FnbKitchenStation> stations,
    required KitchenTicketQueue queue,
  }) {
    return KitchenStationBoard(
      loads: [
        for (final station in stations)
          KitchenStationLoad.fromQueue(station: station, queue: queue),
      ],
    );
  }

  final List<KitchenStationLoad> loads;

  List<FnbKitchenStation> get stationSnapshots {
    return loads.map((load) => load.stationSnapshot).toList(growable: false);
  }

  FnbKitchenStationSummary get summary {
    return FnbKitchenStationSummary.fromStations(stationSnapshots);
  }

  FnbKitchenStationPriorityQueue get priorityQueue {
    return FnbKitchenStationPriorityQueue.fromStations(stationSnapshots);
  }

  FnbKitchenStationPressureSignal get pressureSignal {
    return FnbKitchenStationPressureSignal.fromStations(stationSnapshots);
  }

  KitchenStationLoad? get topLoad {
    final station = priorityQueue.topStation;
    if (station == null) return null;

    for (final load in loads) {
      if (load.station.id == station.id) return load;
    }
    return null;
  }

  int get activeTicketCount {
    return loads.fold(0, (total, load) => total + load.activeTicketCount);
  }

  int get lateTicketCount {
    return loads.fold(0, (total, load) => total + load.lateTicketCount);
  }

  int get readyTicketCount {
    return loads.fold(0, (total, load) => total + load.readyTicketCount);
  }

  int get itemCount {
    return loads.fold(0, (total, load) => total + load.itemCount);
  }

  List<KitchenStationLoad> filteredLoads(FnbKitchenStationFilter filter) {
    return loads
        .where((load) => filter.includes(load.stationSnapshot))
        .toList(growable: false);
  }
}
