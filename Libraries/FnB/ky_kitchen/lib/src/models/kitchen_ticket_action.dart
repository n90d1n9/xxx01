import 'kitchen_ticket.dart';

/// Resolves why a ticket action should be disabled, or null when available.
typedef KitchenTicketActionBlockReason =
    String? Function(KitchenTicket ticket, KitchenTicketAction action);

/// Operator commands that move a kitchen ticket through production stages.
enum KitchenTicketAction {
  startFiring,
  moveToPlating,
  markReady,
  serve,
  cancel,
}

/// Outcome categories for applying kitchen ticket workflow actions.
enum KitchenTicketActionOutcome {
  applied,
  noSelectedTicket,
  ticketNotFound,
  unavailable,
}

/// Filter lenses for reviewing kitchen ticket action history.
enum KitchenTicketActionHistoryFilter {
  all,
  applied,
  issues,
  ticket;

  String get label => switch (this) {
    KitchenTicketActionHistoryFilter.all => 'All',
    KitchenTicketActionHistoryFilter.applied => 'Applied',
    KitchenTicketActionHistoryFilter.issues => 'Issues',
    KitchenTicketActionHistoryFilter.ticket => 'Ticket',
  };

  bool includes(KitchenTicketActionResult result, {String? ticketId}) {
    return switch (this) {
      KitchenTicketActionHistoryFilter.all => true,
      KitchenTicketActionHistoryFilter.applied => result.applied,
      KitchenTicketActionHistoryFilter.issues => !result.applied,
      KitchenTicketActionHistoryFilter.ticket =>
        ticketId != null && result.ticketId == ticketId,
    };
  }
}

/// Result object for ticket action attempts across controllers and services.
class KitchenTicketActionResult {
  const KitchenTicketActionResult({
    required this.action,
    required this.outcome,
    required this.ticketId,
    this.occurredAt,
    this.previousTicket,
    this.updatedTicket,
  });

  final KitchenTicketAction action;
  final KitchenTicketActionOutcome outcome;
  final String? ticketId;
  final DateTime? occurredAt;
  final KitchenTicket? previousTicket;
  final KitchenTicket? updatedTicket;

  bool get applied => outcome == KitchenTicketActionOutcome.applied;

  bool get canRestorePreviousTicket {
    return applied && previousTicket != null && updatedTicket != null;
  }

  String get message {
    return switch (outcome) {
      KitchenTicketActionOutcome.applied =>
        '${action.label} applied to ${updatedTicket?.customerLabel ?? ticketId}.',
      KitchenTicketActionOutcome.noSelectedTicket =>
        'Select a ticket before applying ${action.label.toLowerCase()}.',
      KitchenTicketActionOutcome.ticketNotFound =>
        ticketId == null
            ? 'Ticket is no longer available.'
            : 'Ticket $ticketId is no longer available.',
      KitchenTicketActionOutcome.unavailable =>
        '${action.label} is not available for this ticket.',
    };
  }
}

/// Bounded, newest-first history of kitchen ticket action outcomes.
class KitchenTicketActionHistory {
  KitchenTicketActionHistory({
    Iterable<KitchenTicketActionResult> results = const [],
  }) : results = List<KitchenTicketActionResult>.unmodifiable(results);

  final List<KitchenTicketActionResult> results;

  bool get isEmpty => results.isEmpty;

  bool get isNotEmpty => results.isNotEmpty;

  int get appliedCount {
    return results.where((result) => result.applied).length;
  }

  int get issueCount {
    return results.where((result) => !result.applied).length;
  }

  KitchenTicketActionResult? get latest {
    return results.firstOrNull;
  }

  KitchenTicketActionHistorySummary summary({String? ticketId}) {
    return KitchenTicketActionHistorySummary(
      totalCount: results.length,
      appliedCount: appliedCount,
      issueCount: issueCount,
      ticketCount: ticketId == null ? 0 : forTicket(ticketId).length,
    );
  }

  KitchenTicketActionHistory record(
    KitchenTicketActionResult result, {
    int limit = 20,
  }) {
    assert(limit > 0, 'limit must be greater than zero.');

    return KitchenTicketActionHistory(
      results: [result, ...results].take(limit),
    );
  }

  KitchenTicketActionHistory clear() {
    return KitchenTicketActionHistory();
  }

  List<KitchenTicketActionResult> forTicket(String ticketId) {
    return results
        .where((result) => result.ticketId == ticketId)
        .toList(growable: false);
  }

  List<KitchenTicketActionResult> filtered({
    KitchenTicketActionHistoryFilter filter =
        KitchenTicketActionHistoryFilter.all,
    String? ticketId,
  }) {
    return results
        .where((result) => filter.includes(result, ticketId: ticketId))
        .toList(growable: false);
  }
}

/// Count summary for action history filter chips and activity headers.
class KitchenTicketActionHistorySummary {
  const KitchenTicketActionHistorySummary({
    required this.totalCount,
    required this.appliedCount,
    required this.issueCount,
    required this.ticketCount,
  });

  final int totalCount;
  final int appliedCount;
  final int issueCount;
  final int ticketCount;

  int countFor(KitchenTicketActionHistoryFilter filter) {
    return switch (filter) {
      KitchenTicketActionHistoryFilter.all => totalCount,
      KitchenTicketActionHistoryFilter.applied => appliedCount,
      KitchenTicketActionHistoryFilter.issues => issueCount,
      KitchenTicketActionHistoryFilter.ticket => ticketCount,
    };
  }
}

/// Labels, descriptions, and transition helpers for kitchen ticket actions.
extension KitchenTicketActionDetails on KitchenTicketAction {
  String get label => switch (this) {
    KitchenTicketAction.startFiring => 'Start firing',
    KitchenTicketAction.moveToPlating => 'Move to plating',
    KitchenTicketAction.markReady => 'Mark ready',
    KitchenTicketAction.serve => 'Serve',
    KitchenTicketAction.cancel => 'Cancel',
  };

  String get description => switch (this) {
    KitchenTicketAction.startFiring => 'Move the ticket from queue to fire.',
    KitchenTicketAction.moveToPlating => 'Move the ticket into plating.',
    KitchenTicketAction.markReady => 'Mark the ticket ready for service.',
    KitchenTicketAction.serve => 'Close the ticket as served.',
    KitchenTicketAction.cancel => 'Close the ticket as cancelled.',
  };

  KitchenTicketStage get resultStage => switch (this) {
    KitchenTicketAction.startFiring => KitchenTicketStage.firing,
    KitchenTicketAction.moveToPlating => KitchenTicketStage.plating,
    KitchenTicketAction.markReady => KitchenTicketStage.ready,
    KitchenTicketAction.serve => KitchenTicketStage.served,
    KitchenTicketAction.cancel => KitchenTicketStage.cancelled,
  };

  bool get isDestructive => this == KitchenTicketAction.cancel;

  bool canApplyTo(KitchenTicket ticket) {
    return KitchenTicketActionPlan.availableFor(ticket).contains(this);
  }

  KitchenTicket applyTo(KitchenTicket ticket) {
    return KitchenTicketActionPlan.apply(ticket: ticket, action: this);
  }
}

/// Centralizes legal kitchen ticket stage transitions for UI and services.
class KitchenTicketActionPlan {
  const KitchenTicketActionPlan._();

  static List<KitchenTicketAction> availableFor(KitchenTicket ticket) {
    return switch (ticket.stage) {
      KitchenTicketStage.queued => const [
        KitchenTicketAction.startFiring,
        KitchenTicketAction.cancel,
      ],
      KitchenTicketStage.firing => const [
        KitchenTicketAction.moveToPlating,
        KitchenTicketAction.markReady,
        KitchenTicketAction.cancel,
      ],
      KitchenTicketStage.plating => const [
        KitchenTicketAction.markReady,
        KitchenTicketAction.cancel,
      ],
      KitchenTicketStage.ready => const [
        KitchenTicketAction.serve,
        KitchenTicketAction.cancel,
      ],
      KitchenTicketStage.served || KitchenTicketStage.cancelled => const [],
    };
  }

  static KitchenTicketAction? primaryFor(KitchenTicket ticket) {
    final actions = availableFor(ticket);
    for (final action in actions) {
      if (!action.isDestructive) return action;
    }
    return actions.firstOrNull;
  }

  static KitchenTicket apply({
    required KitchenTicket ticket,
    required KitchenTicketAction action,
  }) {
    if (!availableFor(ticket).contains(action)) return ticket;
    return ticket.copyWith(stage: action.resultStage);
  }
}
