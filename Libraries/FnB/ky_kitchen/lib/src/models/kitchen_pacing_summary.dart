import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_ticket.dart';
import 'kitchen_ticket_queue.dart';

/// Summarizes kitchen timing pressure for active production tickets.
class KitchenPacingSummary {
  KitchenPacingSummary({
    required Iterable<KitchenTicket> tickets,
    required this.now,
  }) : tickets = List<KitchenTicket>.unmodifiable(tickets);

  /// Builds a pacing summary from an active kitchen queue.
  factory KitchenPacingSummary.fromQueue(
    KitchenTicketQueue queue, {
    String? stationId,
  }) {
    return KitchenPacingSummary(
      tickets: stationId == null
          ? queue.openTickets
          : queue.ticketsForStation(stationId),
      now: queue.now,
    );
  }

  final List<KitchenTicket> tickets;
  final DateTime now;

  /// Open tickets ordered by due time.
  List<KitchenTicket> get dueTickets {
    final due = tickets
        .where((ticket) => ticket.isOpen)
        .toList(growable: false);
    due.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return List<KitchenTicket>.unmodifiable(due);
  }

  /// Open tickets currently past their due time.
  List<KitchenTicket> get lateTickets {
    return dueTickets
        .where((ticket) => ticket.isLateAt(now))
        .toList(growable: false);
  }

  int get activeCount => dueTickets.length;

  int get lateCount => lateTickets.length;

  int get readyCount {
    return dueTickets
        .where((ticket) => ticket.stage == KitchenTicketStage.ready)
        .length;
  }

  int get averageDelayMinutes {
    if (lateTickets.isEmpty) return 0;
    final totalDelay = lateTickets.fold<int>(
      0,
      (total, ticket) => total + now.difference(ticket.dueAt).inMinutes,
    );
    return (totalDelay / lateTickets.length).round();
  }

  KitchenTicket? get nextDueTicket => dueTickets.firstOrNull;

  FnbServiceStatus get serviceStatus {
    if (lateCount > 0) return FnbServiceStatus.critical;
    if (activeCount > 0) return FnbServiceStatus.busy;
    return FnbServiceStatus.calm;
  }

  String get statusLabel {
    return switch (serviceStatus) {
      FnbServiceStatus.critical => 'Behind pace',
      FnbServiceStatus.busy => 'On pace',
      FnbServiceStatus.blocked => 'Blocked',
      FnbServiceStatus.calm => 'Clear',
    };
  }

  String get activeCountLabel {
    return activeCount == 1 ? '1 active' : '$activeCount active';
  }

  String get lateCountLabel {
    return lateCount == 1 ? '1 late' : '$lateCount late';
  }

  String get readyCountLabel {
    return readyCount == 1 ? '1 ready' : '$readyCount ready';
  }

  String get averageDelayLabel {
    if (averageDelayMinutes == 0) return 'No delay';
    return '${averageDelayMinutes}m avg delay';
  }

  String get nextDueLabel {
    final ticket = nextDueTicket;
    if (ticket == null) return 'No open tickets';
    return '${ticket.customerLabel} - ${ticket.timingLabel(now)}';
  }
}
