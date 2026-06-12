import 'service_alert.dart';
import 'service_alert_lifecycle.dart';
import 'service_status.dart';

/// Connects a service alert to the operational source that carries it.
class FnbServiceAlertEntry {
  const FnbServiceAlertEntry({
    required this.sourceId,
    required this.sourceLabel,
    required this.alert,
    this.contextLabel,
    this.dueAt,
    this.serviceStatus = FnbServiceStatus.calm,
    this.lifecycle = const FnbServiceAlertLifecycle(),
  }) : assert(sourceId != '', 'sourceId must not be empty.'),
       assert(sourceLabel != '', 'sourceLabel must not be empty.');

  /// Stable identifier for the source record, such as a ticket or reservation.
  final String sourceId;

  /// Human-readable source label, such as a table, guest, or ticket label.
  final String sourceLabel;

  /// Optional operating context, such as a station, zone, or channel.
  final String? contextLabel;

  /// Structured service alert that should be surfaced to operators.
  final FnbServiceAlert alert;

  /// Current pressure state of the source carrying this alert.
  final FnbServiceStatus serviceStatus;

  /// Optional due time used to break ties between similarly urgent alerts.
  final DateTime? dueAt;

  /// Lifecycle state used for ownership, snooze, resolve, and audit handling.
  final FnbServiceAlertLifecycle lifecycle;

  /// Display title for compact alert rows and tiles.
  String get titleLabel => alert.compactLabel;

  /// Display subtitle that combines context and source labels.
  String get subtitleLabel {
    final context = contextLabel?.trim();
    if (context == null || context.isEmpty) return sourceLabel;
    return '$context - $sourceLabel';
  }

  /// Optional alert guidance or operating note.
  String? get descriptionLabel => alert.descriptionLabel;

  /// Combined priority score for deterministic alert ordering.
  int get priorityScore => alert.priorityScore + serviceStatus.priorityScore;

  String get lifecycleLabel => lifecycle.statusLabel;

  bool isActionableAt(DateTime now) => lifecycle.isActionableAt(now);

  FnbServiceAlertEntry copyWith({
    String? sourceId,
    String? sourceLabel,
    String? contextLabel,
    FnbServiceAlert? alert,
    FnbServiceStatus? serviceStatus,
    DateTime? dueAt,
    FnbServiceAlertLifecycle? lifecycle,
  }) {
    return FnbServiceAlertEntry(
      sourceId: sourceId ?? this.sourceId,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      contextLabel: contextLabel ?? this.contextLabel,
      alert: alert ?? this.alert,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      dueAt: dueAt ?? this.dueAt,
      lifecycle: lifecycle ?? this.lifecycle,
    );
  }
}

/// Orders service alerts by alert priority, source pressure, due time, and label.
int compareFnbServiceAlertEntries(
  FnbServiceAlertEntry first,
  FnbServiceAlertEntry second,
) {
  final lifecycleComparison = second.lifecycle.status.attentionWeight.compareTo(
    first.lifecycle.status.attentionWeight,
  );
  if (lifecycleComparison != 0) return lifecycleComparison;

  final alertComparison = second.alert.priorityScore.compareTo(
    first.alert.priorityScore,
  );
  if (alertComparison != 0) return alertComparison;

  final statusComparison = second.serviceStatus.priorityScore.compareTo(
    first.serviceStatus.priorityScore,
  );
  if (statusComparison != 0) return statusComparison;

  final firstDueAt = first.dueAt;
  final secondDueAt = second.dueAt;
  if (firstDueAt != null && secondDueAt != null) {
    final dueComparison = firstDueAt.compareTo(secondDueAt);
    if (dueComparison != 0) return dueComparison;
  } else if (firstDueAt != null) {
    return -1;
  } else if (secondDueAt != null) {
    return 1;
  }

  final sourceComparison = first.sourceLabel.compareTo(second.sourceLabel);
  if (sourceComparison != 0) return sourceComparison;

  return first.titleLabel.compareTo(second.titleLabel);
}
