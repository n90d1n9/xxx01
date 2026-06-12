import 'service_alert_entry.dart';
import 'service_status.dart';

/// Summarizes structured service alerts across tickets, reservations, or zones.
class FnbServiceAlertSummary {
  FnbServiceAlertSummary({required Iterable<FnbServiceAlertEntry> entries})
    : entries = _sortedEntries(entries);

  /// Builds an alert summary from unsorted operational alert entries.
  factory FnbServiceAlertSummary.fromEntries(
    Iterable<FnbServiceAlertEntry> entries,
  ) {
    return FnbServiceAlertSummary(entries: entries);
  }

  /// Alert entries ordered by priority, source pressure, and due time.
  final List<FnbServiceAlertEntry> entries;

  bool get hasAlerts => entries.isNotEmpty;

  int get alertCount => entries.length;

  int get criticalAlertCount {
    return entries.where((entry) => entry.alert.critical).length;
  }

  int get sourceCount {
    return entries.map((entry) => entry.sourceId).toSet().length;
  }

  FnbServiceAlertEntry? get topEntry => entries.firstOrNull;

  int get resolvedAlertCount {
    return entries.where((entry) => entry.lifecycle.isResolved).length;
  }

  int snoozedAlertCountAt(DateTime now) {
    return entries.where((entry) => entry.lifecycle.isSnoozedAt(now)).length;
  }

  int actionableAlertCountAt(DateTime now) {
    return entries.where((entry) => entry.isActionableAt(now)).length;
  }

  List<FnbServiceAlertEntry> actionableEntriesAt(DateTime now) {
    return List<FnbServiceAlertEntry>.unmodifiable(
      entries.where((entry) => entry.isActionableAt(now)),
    );
  }

  FnbServiceStatus get serviceStatus {
    if (criticalAlertCount > 0) return FnbServiceStatus.critical;
    if (alertCount > 0) return FnbServiceStatus.busy;
    return FnbServiceStatus.calm;
  }

  String get alertCountLabel {
    return alertCount == 1 ? '1 alert' : '$alertCount alerts';
  }

  String get criticalAlertLabel {
    return criticalAlertCount == 1
        ? '1 critical'
        : '$criticalAlertCount critical';
  }

  String sourceCountLabel({String singular = 'source', String? plural}) {
    final pluralLabel = plural ?? '${singular}s';
    return sourceCount == 1 ? '1 $singular' : '$sourceCount $pluralLabel';
  }

  String actionableAlertCountLabelAt(DateTime now) {
    final count = actionableAlertCountAt(now);
    return count == 1 ? '1 actionable' : '$count actionable';
  }

  String resolvedAlertCountLabel() {
    return resolvedAlertCount == 1
        ? '1 resolved'
        : '$resolvedAlertCount resolved';
  }
}

List<FnbServiceAlertEntry> _sortedEntries(
  Iterable<FnbServiceAlertEntry> entries,
) {
  return List<FnbServiceAlertEntry>.unmodifiable(
    List<FnbServiceAlertEntry>.of(entries)..sort(compareFnbServiceAlertEntries),
  );
}
