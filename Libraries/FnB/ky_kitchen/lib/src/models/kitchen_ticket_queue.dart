import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_ticket.dart';

/// Derives kitchen queue pressure, counts, and priority ticket ordering.
class KitchenTicketQueue {
  KitchenTicketQueue({
    required Iterable<KitchenTicket> tickets,
    required this.now,
  }) : tickets = List<KitchenTicket>.unmodifiable(tickets);

  final List<KitchenTicket> tickets;
  final DateTime now;

  List<KitchenTicket> get openTickets {
    return tickets.where((ticket) => ticket.isOpen).toList(growable: false);
  }

  int get activeTicketCount => openTickets.length;

  int get lateTicketCount {
    return openTickets.where((ticket) => ticket.isLateAt(now)).length;
  }

  int get readyTicketCount {
    return openTickets
        .where((ticket) => ticket.stage == KitchenTicketStage.ready)
        .length;
  }

  int get totalItemCount {
    return openTickets.fold(0, (total, ticket) => total + ticket.itemCount);
  }

  FnbServiceStatus get serviceStatus {
    if (lateTicketCount > 0) return FnbServiceStatus.critical;
    if (activeTicketCount > 0) return FnbServiceStatus.busy;
    return FnbServiceStatus.calm;
  }

  List<KitchenTicket> get priorityTickets {
    final prioritized = openTickets.toList();
    prioritized.sort((a, b) {
      final statusComparison = b
          .serviceStatusAt(now)
          .priorityScore
          .compareTo(a.serviceStatusAt(now).priorityScore);
      if (statusComparison != 0) return statusComparison;
      return a.dueAt.compareTo(b.dueAt);
    });
    return List<KitchenTicket>.unmodifiable(prioritized);
  }

  List<KitchenTicket> ticketsForStation(String stationId) {
    return openTickets
        .where((ticket) => ticket.stationId == stationId)
        .toList(growable: false);
  }
}
