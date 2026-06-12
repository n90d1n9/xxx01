import 'kitchen_ticket.dart';
import 'kitchen_ticket_action.dart';

/// Grouping lenses for kitchen activity history review.
enum KitchenActivityGroupScope {
  ticket,
  station;

  String get label => switch (this) {
    KitchenActivityGroupScope.ticket => 'Ticket',
    KitchenActivityGroupScope.station => 'Station',
  };
}

/// Summarizes related kitchen action history results under one activity group.
class KitchenActivityGroup {
  KitchenActivityGroup({
    required this.scope,
    required this.key,
    required this.label,
    required Iterable<KitchenTicketActionResult> results,
    this.subtitle,
  }) : results = List<KitchenTicketActionResult>.unmodifiable(results);

  final KitchenActivityGroupScope scope;
  final String key;
  final String label;
  final String? subtitle;
  final List<KitchenTicketActionResult> results;

  KitchenTicketActionResult? get latest => results.firstOrNull;

  int get actionCount => results.length;

  int get appliedCount {
    return results.where((result) => result.applied).length;
  }

  int get issueCount {
    return results.where((result) => !result.applied).length;
  }

  bool get hasIssues => issueCount > 0;

  String get actionCountLabel {
    return actionCount == 1 ? '1 action' : '$actionCount actions';
  }

  String get issueCountLabel {
    return issueCount == 1 ? '1 issue' : '$issueCount issues';
  }
}

/// Creates ticket and station groupings from recent kitchen action history.
class KitchenActivityGrouping {
  KitchenActivityGrouping({
    Iterable<KitchenTicketActionResult> results = const [],
  }) : results = List<KitchenTicketActionResult>.unmodifiable(results);

  /// Builds grouped activity from a history object and the active filter lens.
  factory KitchenActivityGrouping.fromHistory(
    KitchenTicketActionHistory history, {
    KitchenTicketActionHistoryFilter filter =
        KitchenTicketActionHistoryFilter.all,
    String? ticketId,
  }) {
    return KitchenActivityGrouping(
      results: history.filtered(filter: filter, ticketId: ticketId),
    );
  }

  final List<KitchenTicketActionResult> results;

  bool get isEmpty => results.isEmpty;

  bool get isNotEmpty => results.isNotEmpty;

  List<KitchenActivityGroup> groupsBy(
    KitchenActivityGroupScope scope, {
    int? limit,
  }) {
    final groupedResults = <String, List<KitchenTicketActionResult>>{};

    for (final result in results) {
      final key = _groupKey(result, scope);
      groupedResults.putIfAbsent(key, () => []).add(result);
    }

    final groups = groupedResults.entries
        .map((entry) => _groupFromEntry(entry.key, entry.value, scope))
        .toList(growable: false);

    if (limit == null || groups.length <= limit) {
      return List<KitchenActivityGroup>.unmodifiable(groups);
    }

    return List<KitchenActivityGroup>.unmodifiable(groups.take(limit));
  }
}

KitchenActivityGroup _groupFromEntry(
  String key,
  List<KitchenTicketActionResult> results,
  KitchenActivityGroupScope scope,
) {
  final latest = results.first;

  return KitchenActivityGroup(
    scope: scope,
    key: key,
    label: _groupLabel(latest, scope),
    subtitle: _groupSubtitle(latest, scope),
    results: results,
  );
}

String _groupKey(
  KitchenTicketActionResult result,
  KitchenActivityGroupScope scope,
) {
  return switch (scope) {
    KitchenActivityGroupScope.ticket => result.ticketId ?? 'unselected-ticket',
    KitchenActivityGroupScope.station =>
      _ticketForResult(result)?.stationId ?? 'unassigned-station',
  };
}

String _groupLabel(
  KitchenTicketActionResult result,
  KitchenActivityGroupScope scope,
) {
  final ticket = _ticketForResult(result);

  return switch (scope) {
    KitchenActivityGroupScope.ticket =>
      ticket?.customerLabel ?? result.ticketId ?? 'No ticket selected',
    KitchenActivityGroupScope.station => ticket?.stationName ?? 'Unassigned',
  };
}

String? _groupSubtitle(
  KitchenTicketActionResult result,
  KitchenActivityGroupScope scope,
) {
  final ticket = _ticketForResult(result);
  if (ticket == null) return result.message;

  return switch (scope) {
    KitchenActivityGroupScope.ticket =>
      '${ticket.stationName} - ${ticket.orderId}',
    KitchenActivityGroupScope.station => result.message,
  };
}

KitchenTicket? _ticketForResult(KitchenTicketActionResult result) {
  return result.updatedTicket ?? result.previousTicket;
}
