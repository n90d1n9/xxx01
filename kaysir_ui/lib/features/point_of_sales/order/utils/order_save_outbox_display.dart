import '../../cashier/utils/pos_formatters.dart';
import 'order_display.dart';
import 'order_save_outbox.dart';
import 'order_save_outbox_error_copy.dart';

enum POSOrderSaveOutboxViewFilter { attention, queued, syncing, synced, all }

class POSOrderSaveOutboxEntryDisplay {
  final String orderLabel;
  final String statusLabel;
  final String lineSummary;
  final String totalLabel;
  final String terminalLabel;
  final String attemptsLabel;
  final String queuedLabel;
  final String? errorLabel;

  const POSOrderSaveOutboxEntryDisplay({
    required this.orderLabel,
    required this.statusLabel,
    required this.lineSummary,
    required this.totalLabel,
    required this.terminalLabel,
    required this.attemptsLabel,
    required this.queuedLabel,
    this.errorLabel,
  });

  factory POSOrderSaveOutboxEntryDisplay.fromEntry(
    POSOrderSaveOutboxEntry entry,
  ) {
    final payload = entry.envelope.payload;
    final orderId = _stringValue(payload['id']) ?? entry.idempotencyKey;
    final lineCount = _lineCount(payload['items']);
    final total = _total(payload['totals']);
    final terminalLabel =
        _nestedStringValue(payload['terminal'], 'name') ?? 'Unknown terminal';

    return POSOrderSaveOutboxEntryDisplay(
      orderLabel: 'Order #${shortPOSOrderId(orderId)}',
      statusLabel: posOrderSaveOutboxStatusLabel(entry.status),
      lineSummary:
          '$lineCount line${lineCount == 1 ? '' : 's'} | ${formatPOSCurrency(total)}',
      totalLabel: formatPOSCurrency(total),
      terminalLabel: terminalLabel,
      attemptsLabel:
          entry.attempts == 0
              ? 'No attempts'
              : '${entry.attempts} attempt${entry.attempts == 1 ? '' : 's'}',
      queuedLabel: 'Queued ${_clockLabel(entry.queuedAt)}',
      errorLabel: _errorLabel(entry.lastError),
    );
  }
}

String? _errorLabel(String? error) {
  if (error == null || error.trim().isEmpty) return null;
  return friendlyPOSOrderSaveFailureMessage(error);
}

String posOrderSaveOutboxViewFilterLabel(POSOrderSaveOutboxViewFilter filter) {
  switch (filter) {
    case POSOrderSaveOutboxViewFilter.attention:
      return 'Attention';
    case POSOrderSaveOutboxViewFilter.queued:
      return 'Queued';
    case POSOrderSaveOutboxViewFilter.syncing:
      return 'Syncing';
    case POSOrderSaveOutboxViewFilter.synced:
      return 'Synced';
    case POSOrderSaveOutboxViewFilter.all:
      return 'All';
  }
}

List<POSOrderSaveOutboxEntry> sortPOSOrderSaveOutboxEntries(
  Iterable<POSOrderSaveOutboxEntry> entries,
) {
  final next = [...entries];
  next.sort((left, right) {
    final statusComparison = _statusRank(
      left.status,
    ).compareTo(_statusRank(right.status));
    if (statusComparison != 0) return statusComparison;

    return left.queuedAt.compareTo(right.queuedAt);
  });
  return List.unmodifiable(next);
}

List<POSOrderSaveOutboxEntry> filterPOSOrderSaveOutboxEntries(
  Iterable<POSOrderSaveOutboxEntry> entries,
  POSOrderSaveOutboxViewFilter filter, {
  String query = '',
}) {
  return List.unmodifiable(
    entries.where((entry) {
      if (!matchesPOSOrderSaveOutboxViewFilter(entry, filter)) return false;
      return matchesPOSOrderSaveOutboxQuery(entry, query);
    }),
  );
}

bool matchesPOSOrderSaveOutboxViewFilter(
  POSOrderSaveOutboxEntry entry,
  POSOrderSaveOutboxViewFilter filter,
) {
  switch (filter) {
    case POSOrderSaveOutboxViewFilter.attention:
      return entry.status == POSOrderSaveOutboxStatus.failed;
    case POSOrderSaveOutboxViewFilter.queued:
      return entry.status == POSOrderSaveOutboxStatus.pending;
    case POSOrderSaveOutboxViewFilter.syncing:
      return entry.status == POSOrderSaveOutboxStatus.sending;
    case POSOrderSaveOutboxViewFilter.synced:
      return entry.status == POSOrderSaveOutboxStatus.sent;
    case POSOrderSaveOutboxViewFilter.all:
      return true;
  }
}

int countPOSOrderSaveOutboxEntriesForFilter(
  Iterable<POSOrderSaveOutboxEntry> entries,
  POSOrderSaveOutboxViewFilter filter,
) {
  return entries
      .where((entry) => matchesPOSOrderSaveOutboxViewFilter(entry, filter))
      .length;
}

bool matchesPOSOrderSaveOutboxQuery(
  POSOrderSaveOutboxEntry entry,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  final display = POSOrderSaveOutboxEntryDisplay.fromEntry(entry);
  final searchableValues = <String?>[
    display.orderLabel,
    display.statusLabel,
    display.lineSummary,
    display.totalLabel,
    display.terminalLabel,
    display.attemptsLabel,
    display.queuedLabel,
    display.errorLabel,
    entry.idempotencyKey,
  ];

  return searchableValues.whereType<String>().any(
    (value) => value.toLowerCase().contains(normalizedQuery),
  );
}

String posOrderSaveOutboxStatusLabel(POSOrderSaveOutboxStatus status) {
  switch (status) {
    case POSOrderSaveOutboxStatus.pending:
      return 'Queued';
    case POSOrderSaveOutboxStatus.sending:
      return 'Syncing';
    case POSOrderSaveOutboxStatus.sent:
      return 'Synced';
    case POSOrderSaveOutboxStatus.failed:
      return 'Failed';
  }
}

int _statusRank(POSOrderSaveOutboxStatus status) {
  switch (status) {
    case POSOrderSaveOutboxStatus.failed:
      return 0;
    case POSOrderSaveOutboxStatus.pending:
      return 1;
    case POSOrderSaveOutboxStatus.sending:
      return 2;
    case POSOrderSaveOutboxStatus.sent:
      return 3;
  }
}

String? _stringValue(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

String? _nestedStringValue(Object? value, String field) {
  if (value is! Map) return null;
  return _stringValue(value[field]);
}

int _lineCount(Object? value) {
  if (value is List) return value.length;
  return 0;
}

double _total(Object? value) {
  if (value is Map) {
    final total = value['total'];
    if (total is num) return total.toDouble();
  }
  return 0;
}

String _clockLabel(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
