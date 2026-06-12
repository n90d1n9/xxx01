import 'accounting_workspace_role_preset.dart';
import 'work_queue_saved_view.dart';

/// Type of custom queue view management change captured in a dialog session.
enum WorkQueueSavedViewManagerAuditAction { renamed, deleted, restored }

/// Captures a management change made to a custom accounting queue view.
class WorkQueueSavedViewManagerAuditEvent {
  const WorkQueueSavedViewManagerAuditEvent({
    required this.action,
    required this.previousLabel,
    this.viewId,
    this.rolePreset,
    this.nextLabel,
    this.occurredAt,
    this.savedView,
  });

  final WorkQueueSavedViewManagerAuditAction action;
  final String previousLabel;
  final String? viewId;
  final AccountingWorkspaceRolePreset? rolePreset;
  final String? nextLabel;
  final DateTime? occurredAt;
  final AccountingWorkspaceWorkQueueSavedView? savedView;

  Map<String, Object?> toJson() {
    return {
      'action': action.storageValue,
      'previousLabel': previousLabel,
      if (viewId case final id? when id.trim().isNotEmpty) 'viewId': id.trim(),
      if (rolePreset case final role?) 'rolePreset': role.storageValue,
      if (nextLabel case final label? when label.trim().isNotEmpty)
        'nextLabel': label.trim(),
      if (occurredAt case final recordedAt?)
        'occurredAt': recordedAt.toIso8601String(),
      if (savedView case final view? when view.isCustom)
        'savedView': view.toJson(),
    };
  }

  String get auditBrief {
    final baseBrief = switch (action) {
      WorkQueueSavedViewManagerAuditAction.renamed =>
        '- Renamed "$previousLabel" to "${nextLabel ?? previousLabel}"',
      WorkQueueSavedViewManagerAuditAction.deleted =>
        '- Deleted "$previousLabel"',
      WorkQueueSavedViewManagerAuditAction.restored =>
        '- Restored "$previousLabel"',
    };
    final recordedAt = occurredAt;
    final viewReference = _viewReference;
    if (recordedAt == null) return '$baseBrief$viewReference';

    return '$baseBrief$viewReference '
        '(recorded ${_auditBriefTimestamp(recordedAt)})';
  }

  String get title {
    switch (action) {
      case WorkQueueSavedViewManagerAuditAction.renamed:
        return 'Renamed $previousLabel to ${nextLabel ?? previousLabel}';
      case WorkQueueSavedViewManagerAuditAction.deleted:
        return 'Deleted $previousLabel';
      case WorkQueueSavedViewManagerAuditAction.restored:
        return 'Restored $previousLabel';
    }
  }

  String get supportLabel {
    switch (action) {
      case WorkQueueSavedViewManagerAuditAction.renamed:
        return 'Name updated for this custom queue view';
      case WorkQueueSavedViewManagerAuditAction.deleted:
        return 'Custom queue view removed from this workspace';
      case WorkQueueSavedViewManagerAuditAction.restored:
        return 'Custom queue view restored to this workspace';
    }
  }

  String get _viewReference {
    final id = viewId?.trim();
    if (id == null || id.isEmpty) return '';

    return ' [view: $id]';
  }
}

/// Restores a persisted saved queue view management audit event.
WorkQueueSavedViewManagerAuditEvent?
workQueueSavedViewManagerAuditEventFromJson(Map<String, Object?> json) {
  final action = workQueueSavedViewManagerAuditActionFromStorage(
    json['action'],
  );
  final previousLabel = _trimmedString(json['previousLabel']);
  if (action == null || previousLabel == null) return null;
  final savedView = _savedViewValue(json['savedView']);

  return WorkQueueSavedViewManagerAuditEvent(
    action: action,
    previousLabel: previousLabel,
    viewId: _trimmedString(json['viewId']),
    rolePreset: accountingWorkspaceRolePresetFromStorage(json['rolePreset']),
    nextLabel: _trimmedString(json['nextLabel']),
    occurredAt: _dateTimeValue(json['occurredAt']),
    savedView: savedView,
  );
}

/// Storage token for a saved queue view management action.
extension WorkQueueSavedViewManagerAuditActionStorage
    on WorkQueueSavedViewManagerAuditAction {
  String get storageValue {
    switch (this) {
      case WorkQueueSavedViewManagerAuditAction.renamed:
        return 'renamed';
      case WorkQueueSavedViewManagerAuditAction.deleted:
        return 'deleted';
      case WorkQueueSavedViewManagerAuditAction.restored:
        return 'restored';
    }
  }
}

/// Converts persisted audit action tokens into typed audit actions.
WorkQueueSavedViewManagerAuditAction?
workQueueSavedViewManagerAuditActionFromStorage(Object? value) {
  switch (_trimmedString(value)) {
    case 'renamed':
      return WorkQueueSavedViewManagerAuditAction.renamed;
    case 'deleted':
      return WorkQueueSavedViewManagerAuditAction.deleted;
    case 'restored':
      return WorkQueueSavedViewManagerAuditAction.restored;
    default:
      return null;
  }
}

/// Builds a paste-ready audit note for recent custom queue view changes.
String workQueueSavedViewManagerAuditBrief(
  Iterable<WorkQueueSavedViewManagerAuditEvent> events,
) {
  final eventList = events.toList(growable: false);
  if (eventList.isEmpty) return 'Custom queue view changes: none';

  final buffer = StringBuffer('Custom queue view changes:');
  for (final event in eventList) {
    buffer
      ..writeln()
      ..write(event.auditBrief);
  }

  return buffer.toString();
}

String? _trimmedString(Object? value) {
  if (value is! String) return null;

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _dateTimeValue(Object? value) {
  final rawValue = _trimmedString(value);
  if (rawValue == null) return null;

  return DateTime.tryParse(rawValue);
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}

AccountingWorkspaceWorkQueueSavedView? _savedViewValue(Object? value) {
  final savedViewJson = _asJsonMap(value);
  if (savedViewJson == null) return null;

  final savedView = accountingWorkspaceWorkQueueSavedViewFromJson(
    savedViewJson,
  );
  if (savedView == null || !savedView.isCustom) return null;

  return savedView;
}

String _auditBriefTimestamp(DateTime value) {
  final localValue = value.toLocal();
  final year = localValue.year.toString().padLeft(4, '0');
  final month = localValue.month.toString().padLeft(2, '0');
  final day = localValue.day.toString().padLeft(2, '0');
  final hour = localValue.hour.toString().padLeft(2, '0');
  final minute = localValue.minute.toString().padLeft(2, '0');

  return '$year-$month-$day $hour:$minute';
}

/// Returns saved queue view audit events that are relevant to a workspace role.
List<WorkQueueSavedViewManagerAuditEvent>
workQueueSavedViewManagerAuditEventsForRole({
  required Iterable<WorkQueueSavedViewManagerAuditEvent> events,
  required AccountingWorkspaceRolePreset rolePreset,
}) {
  final rolePrefix = 'custom-${rolePreset.storageValue}-';

  return List<WorkQueueSavedViewManagerAuditEvent>.unmodifiable([
    for (final event in events)
      if (_isAuditEventForRole(event, rolePrefix, rolePreset)) event,
  ]);
}

bool _isAuditEventForRole(
  WorkQueueSavedViewManagerAuditEvent event,
  String rolePrefix,
  AccountingWorkspaceRolePreset rolePreset,
) {
  final eventRole = event.rolePreset ?? event.savedView?.rolePreset;
  if (eventRole != null) return eventRole == rolePreset;

  final viewId = _eventViewId(event);
  if (viewId == null || viewId.isEmpty) return true;

  return viewId.startsWith(rolePrefix);
}

String? _eventViewId(WorkQueueSavedViewManagerAuditEvent event) {
  final viewId = event.viewId?.trim();
  if (viewId != null && viewId.isNotEmpty) return viewId;

  final savedViewId = event.savedView?.id.trim();
  if (savedViewId == null || savedViewId.isEmpty) return null;

  return savedViewId;
}
