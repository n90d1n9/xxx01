import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_ticket.dart';
import 'kitchen_ticket_queue.dart';

/// Summarizes ready kitchen tickets that need service handoff.
class KitchenDispatchSummary {
  KitchenDispatchSummary({
    required Iterable<KitchenTicket> tickets,
    required this.now,
  }) : tickets = List<KitchenTicket>.unmodifiable(tickets);

  /// Builds a dispatch summary from an active kitchen queue.
  factory KitchenDispatchSummary.fromQueue(
    KitchenTicketQueue queue, {
    String? stationId,
  }) {
    return KitchenDispatchSummary(
      tickets: stationId == null
          ? queue.openTickets
          : queue.ticketsForStation(stationId),
      now: queue.now,
    );
  }

  final List<KitchenTicket> tickets;
  final DateTime now;

  /// Open tickets already marked ready, ordered by due time.
  List<KitchenTicket> get readyTickets {
    final ready = tickets
        .where((ticket) => ticket.stage == KitchenTicketStage.ready)
        .toList(growable: false);
    ready.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return List<KitchenTicket>.unmodifiable(ready);
  }

  /// Open tickets still moving through production before handoff.
  List<KitchenTicket> get productionTickets {
    return tickets
        .where((ticket) => ticket.stage != KitchenTicketStage.ready)
        .toList(growable: false);
  }

  int get readyCount => readyTickets.length;

  int get lateReadyCount {
    return readyTickets.where((ticket) => ticket.isLateAt(now)).length;
  }

  int get productionCount => productionTickets.length;

  int get readyItemCount {
    return readyTickets.fold(0, (total, ticket) => total + ticket.itemCount);
  }

  bool get hasReadyTickets => readyCount > 0;

  KitchenTicket? get nextReadyTicket => readyTickets.firstOrNull;

  FnbServiceStatus get serviceStatus {
    if (lateReadyCount > 0) return FnbServiceStatus.critical;
    if (readyCount > 0) return FnbServiceStatus.busy;
    return FnbServiceStatus.calm;
  }

  String get readyCountLabel {
    return readyCount == 1 ? '1 ready' : '$readyCount ready';
  }

  String get lateReadyLabel {
    return lateReadyCount == 1 ? '1 late' : '$lateReadyCount late';
  }

  String get productionCountLabel {
    return productionCount == 1
        ? '1 in production'
        : '$productionCount in production';
  }

  String get readyItemCountLabel {
    return readyItemCount == 1 ? '1 item' : '$readyItemCount items';
  }
}
