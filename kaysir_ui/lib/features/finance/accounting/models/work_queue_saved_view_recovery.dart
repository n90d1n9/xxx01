import 'work_queue_saved_view.dart';
import 'work_queue_saved_view_manager_audit.dart';

/// Maximum display length for custom accounting work queue saved-view names.
const workQueueSavedViewLabelLimit = 36;

/// Restorable saved-view payload with the label that will be used on restore.
class WorkQueueSavedViewRecoveryCandidate {
  const WorkQueueSavedViewRecoveryCandidate({
    required this.sourceView,
    required this.restoredView,
  });

  final AccountingWorkspaceWorkQueueSavedView sourceView;
  final AccountingWorkspaceWorkQueueSavedView restoredView;

  bool get labelChanged => sourceView.label != restoredView.label;
}

/// Builds recoverable saved-view candidates with conflict-free restored names.
List<WorkQueueSavedViewRecoveryCandidate> workQueueSavedViewRecoveryCandidates({
  required Iterable<AccountingWorkspaceWorkQueueSavedView> recoverableViews,
  required Iterable<AccountingWorkspaceWorkQueueSavedView> activeViews,
  int labelLimit = workQueueSavedViewLabelLimit,
}) {
  final reservedLabels = _reservedSavedViewLabels(activeViews);

  return List<WorkQueueSavedViewRecoveryCandidate>.unmodifiable([
    for (final view in recoverableViews)
      if (view.isCustom)
        WorkQueueSavedViewRecoveryCandidate(
          sourceView: view,
          restoredView: _restoredViewWithAvailableLabel(
            view: view,
            reservedLabels: reservedLabels,
            labelLimit: labelLimit,
          ),
        ),
  ]);
}

/// Returns deleted saved-view history payloads that can still be restored.
List<AccountingWorkspaceWorkQueueSavedView>
workQueueSavedViewRecoverableHistoryViews({
  required Iterable<WorkQueueSavedViewManagerAuditEvent> auditEvents,
  required Iterable<AccountingWorkspaceWorkQueueSavedView> activeViews,
}) {
  final blockedViewIds = activeViews.map((view) => view.id).toSet();
  final recoverableViews = <AccountingWorkspaceWorkQueueSavedView>[];

  for (final event in auditEvents) {
    final eventViewId = _auditEventViewId(event);
    if (eventViewId == null || blockedViewIds.contains(eventViewId)) {
      continue;
    }

    switch (event.action) {
      case WorkQueueSavedViewManagerAuditAction.restored:
        blockedViewIds.add(eventViewId);
        if (event.savedView case final restoredView?) {
          blockedViewIds.add(restoredView.id);
        }
        break;
      case WorkQueueSavedViewManagerAuditAction.deleted:
        final savedView = event.savedView;
        if (savedView != null && savedView.isCustom) {
          recoverableViews.add(savedView);
          blockedViewIds
            ..add(eventViewId)
            ..add(savedView.id);
        }
        break;
      case WorkQueueSavedViewManagerAuditAction.renamed:
        break;
    }
  }

  return List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(
    recoverableViews,
  );
}

/// Normalizes saved-view labels for duplicate detection.
String? workQueueSavedViewNormalizedLabel(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized.isEmpty ? null : normalized;
}

String? _auditEventViewId(WorkQueueSavedViewManagerAuditEvent event) {
  final viewId = event.viewId?.trim();
  if (viewId != null && viewId.isNotEmpty) return viewId;

  final savedViewId = event.savedView?.id.trim();
  if (savedViewId == null || savedViewId.isEmpty) return null;

  return savedViewId;
}

Set<String> _reservedSavedViewLabels(
  Iterable<AccountingWorkspaceWorkQueueSavedView> views,
) {
  return {
    for (final view in views)
      if (workQueueSavedViewNormalizedLabel(view.label) case final label?)
        label,
  };
}

AccountingWorkspaceWorkQueueSavedView _restoredViewWithAvailableLabel({
  required AccountingWorkspaceWorkQueueSavedView view,
  required Set<String> reservedLabels,
  required int labelLimit,
}) {
  final normalizedLabel = workQueueSavedViewNormalizedLabel(view.label);
  if (normalizedLabel != null && reservedLabels.add(normalizedLabel)) {
    return view;
  }

  final availableLabel = _availableRestoredViewLabel(
    label: view.label,
    reservedLabels: reservedLabels,
    labelLimit: labelLimit,
  );
  reservedLabels.add(workQueueSavedViewNormalizedLabel(availableLabel)!);

  return view.copyWith(label: availableLabel);
}

String _availableRestoredViewLabel({
  required String label,
  required Set<String> reservedLabels,
  required int labelLimit,
}) {
  final baseLabel = label.trim().isEmpty ? 'Restored view' : label.trim();

  for (var index = 1; index < 100; index += 1) {
    final suffix = index == 1 ? ' (restored)' : ' (restored $index)';
    final candidate = _labelWithSuffix(
      label: baseLabel,
      suffix: suffix,
      labelLimit: labelLimit,
    );
    final normalizedCandidate = workQueueSavedViewNormalizedLabel(candidate);
    if (normalizedCandidate != null &&
        !reservedLabels.contains(normalizedCandidate)) {
      return candidate;
    }
  }

  return _labelWithSuffix(
    label: baseLabel,
    suffix: ' (restored)',
    labelLimit: labelLimit,
  );
}

String _labelWithSuffix({
  required String label,
  required String suffix,
  required int labelLimit,
}) {
  final maxBaseLength = labelLimit - suffix.length;
  if (maxBaseLength <= 0) return suffix.trim();

  final normalizedBase =
      label.length <= maxBaseLength
          ? label
          : label.substring(0, maxBaseLength).trimRight();
  final effectiveBase = normalizedBase.trim().isEmpty ? 'View' : normalizedBase;

  return '$effectiveBase$suffix';
}
