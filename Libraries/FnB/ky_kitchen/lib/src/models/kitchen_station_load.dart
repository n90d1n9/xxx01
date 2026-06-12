import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_ticket.dart';
import 'kitchen_ticket_queue.dart';

/// Summarizes ticket pressure for one shared kitchen station.
class KitchenStationLoad {
  const KitchenStationLoad({
    required this.station,
    required this.activeTicketCount,
    required this.lateTicketCount,
    required this.readyTicketCount,
    required this.itemCount,
    required this.status,
  });

  final FnbKitchenStation station;
  final int activeTicketCount;
  final int lateTicketCount;
  final int readyTicketCount;
  final int itemCount;
  final FnbServiceStatus status;

  /// Creates a shared station snapshot that can feed cross-package summaries.
  FnbKitchenStation get stationSnapshot {
    return station.copyWith(
      ticketsInProgress: activeTicketCount,
      queueLabel: queueLabel,
      status: status,
    );
  }

  String get queueLabel {
    if (lateTicketCount > 0) return '$lateTicketCount late';
    if (readyTicketCount > 0) return '$readyTicketCount ready';
    return '$activeTicketCount active';
  }

  static KitchenStationLoad fromQueue({
    required FnbKitchenStation station,
    required KitchenTicketQueue queue,
  }) {
    final tickets = queue.ticketsForStation(station.id);
    final activeTicketCount = tickets.length;
    final lateTicketCount = tickets.where((ticket) {
      return ticket.isLateAt(queue.now);
    }).length;
    final readyTicketCount = tickets.where((ticket) {
      return ticket.stage == KitchenTicketStage.ready;
    }).length;
    final itemCount = tickets.fold(0, (total, ticket) {
      return total + ticket.itemCount;
    });
    final ticketStatus = lateTicketCount > 0
        ? FnbServiceStatus.critical
        : activeTicketCount > 0
        ? FnbServiceStatus.busy
        : FnbServiceStatus.calm;
    final status = station.status.mostUrgent(ticketStatus);

    return KitchenStationLoad(
      station: station,
      activeTicketCount: activeTicketCount,
      lateTicketCount: lateTicketCount,
      readyTicketCount: readyTicketCount,
      itemCount: itemCount,
      status: status,
    );
  }
}
