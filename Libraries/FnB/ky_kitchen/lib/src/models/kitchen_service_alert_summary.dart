import 'package:ky_fnb_core/ky_fnb_core.dart';

import 'kitchen_ticket.dart';
import 'kitchen_ticket_queue.dart';

/// Connects one service alert to the active kitchen ticket that carries it.
class KitchenServiceAlertEntry {
  const KitchenServiceAlertEntry({required this.ticket, required this.signal});

  /// Builds a kitchen alert entry from a ticket and one of its service alerts.
  factory KitchenServiceAlertEntry.fromTicket({
    required KitchenTicket ticket,
    required FnbServiceAlert alert,
    required DateTime now,
    FnbServiceAlertLifecycle lifecycle = const FnbServiceAlertLifecycle(),
  }) {
    return KitchenServiceAlertEntry(
      ticket: ticket,
      signal: FnbServiceAlertEntry(
        sourceId: ticket.id,
        sourceLabel: ticket.customerLabel,
        contextLabel: ticket.stationName,
        alert: alert,
        serviceStatus: ticket.serviceStatusAt(now),
        dueAt: ticket.dueAt,
        lifecycle: lifecycle,
      ),
    );
  }

  final KitchenTicket ticket;
  final FnbServiceAlertEntry signal;

  FnbServiceAlert get alert => signal.alert;

  FnbServiceAlertLifecycle get lifecycle => signal.lifecycle;

  String get titleLabel => signal.titleLabel;

  String get subtitleLabel => signal.subtitleLabel;

  String? get descriptionLabel => signal.descriptionLabel;

  bool isActionableAt(DateTime now) => signal.isActionableAt(now);
}

/// Summarizes structured service alerts across active kitchen tickets.
class KitchenServiceAlertSummary {
  KitchenServiceAlertSummary({
    required Iterable<KitchenServiceAlertEntry> entries,
    required this.now,
  }) : entries = _sortedKitchenEntries(entries),
       coreSummary = FnbServiceAlertSummary.fromEntries(
         entries.map((entry) => entry.signal),
       );

  /// Builds an alert summary from open tickets in a kitchen queue.
  factory KitchenServiceAlertSummary.fromQueue(
    KitchenTicketQueue queue, {
    String? stationId,
  }) {
    final tickets = stationId == null
        ? queue.openTickets
        : queue.ticketsForStation(stationId);
    final entries = <KitchenServiceAlertEntry>[];

    for (final ticket in tickets) {
      final alerts = ticket.serviceContext?.priorityAlerts ?? const [];
      for (final alert in alerts) {
        entries.add(
          KitchenServiceAlertEntry.fromTicket(
            ticket: ticket,
            alert: alert,
            now: queue.now,
          ),
        );
      }
    }

    return KitchenServiceAlertSummary(entries: entries, now: queue.now);
  }

  final List<KitchenServiceAlertEntry> entries;
  final FnbServiceAlertSummary coreSummary;
  final DateTime now;

  bool get hasAlerts => coreSummary.hasAlerts;

  int get alertCount => coreSummary.alertCount;

  int get criticalAlertCount => coreSummary.criticalAlertCount;

  int get ticketCount => coreSummary.sourceCount;

  KitchenServiceAlertEntry? get topEntry => entries.firstOrNull;

  List<KitchenServiceAlertEntry> get actionableEntries {
    return List<KitchenServiceAlertEntry>.unmodifiable(
      entries.where((entry) => entry.isActionableAt(now)),
    );
  }

  int get actionableAlertCount => coreSummary.actionableAlertCountAt(now);

  int get snoozedAlertCount => coreSummary.snoozedAlertCountAt(now);

  int get resolvedAlertCount => coreSummary.resolvedAlertCount;

  FnbServiceStatus get serviceStatus => coreSummary.serviceStatus;

  String get alertCountLabel => coreSummary.alertCountLabel;

  String get actionableAlertCountLabel {
    return coreSummary.actionableAlertCountLabelAt(now);
  }

  String get criticalAlertLabel => coreSummary.criticalAlertLabel;

  String get resolvedAlertCountLabel => coreSummary.resolvedAlertCountLabel();

  String get ticketCountLabel =>
      coreSummary.sourceCountLabel(singular: 'ticket');
}

List<KitchenServiceAlertEntry> _sortedKitchenEntries(
  Iterable<KitchenServiceAlertEntry> entries,
) {
  return List<KitchenServiceAlertEntry>.unmodifiable(
    [...entries]..sort((first, second) {
      return compareFnbServiceAlertEntries(first.signal, second.signal);
    }),
  );
}
