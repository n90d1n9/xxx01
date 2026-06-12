import 'work_queue_saved_view.dart';
import 'work_queue_saved_view_manager_audit.dart';
import 'work_queue_saved_view_recovery.dart';

/// Pure state manager for editing custom accounting work queue saved views.
class WorkQueueSavedViewManagerSession {
  WorkQueueSavedViewManagerSession._({
    required Iterable<AccountingWorkspaceWorkQueueSavedView> views,
    required Iterable<WorkQueueSavedViewManagerAuditEvent> auditEvents,
    required Map<String, String> errors,
    this.lastDeletedView,
    this.lastDeletedIndex,
  }) : views = List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(views),
       auditEvents = List<WorkQueueSavedViewManagerAuditEvent>.unmodifiable(
         auditEvents,
       ),
       errors = Map<String, String>.unmodifiable(errors);

  /// Creates an editable saved-view session from persisted workspace state.
  factory WorkQueueSavedViewManagerSession.create({
    required Iterable<AccountingWorkspaceWorkQueueSavedView> views,
    required Iterable<WorkQueueSavedViewManagerAuditEvent> auditEvents,
  }) {
    return WorkQueueSavedViewManagerSession._(
      views: views.where((view) => view.isCustom),
      auditEvents: auditEvents,
      errors: const {},
    );
  }

  /// Custom saved views that are currently visible in the manager.
  final List<AccountingWorkspaceWorkQueueSavedView> views;

  /// Recent saved-view management events shown in the audit trail.
  final List<WorkQueueSavedViewManagerAuditEvent> auditEvents;

  /// Inline validation errors keyed by saved-view id.
  final Map<String, String> errors;

  /// Most recently deleted custom saved view that can be restored with undo.
  final AccountingWorkspaceWorkQueueSavedView? lastDeletedView;

  /// Previous position of [lastDeletedView] before deletion.
  final int? lastDeletedIndex;

  /// Deleted custom saved views from history that can be restored safely.
  List<WorkQueueSavedViewRecoveryCandidate> get recoveryCandidates {
    return workQueueSavedViewRecoveryCandidates(
      recoverableViews: workQueueSavedViewRecoverableHistoryViews(
        auditEvents: auditEvents,
        activeViews: views,
      ),
      activeViews: views,
    );
  }

  /// Returns a user-facing rename validation message, if the label is invalid.
  String? renameError({
    required AccountingWorkspaceWorkQueueSavedView view,
    required String nextLabel,
  }) {
    final normalizedLabel = workQueueSavedViewNormalizedLabel(nextLabel);
    if (normalizedLabel == null) return 'Enter a view name.';

    for (final currentView in views) {
      if (currentView.id == view.id) continue;
      if (workQueueSavedViewNormalizedLabel(currentView.label) ==
          normalizedLabel) {
        return 'Use a unique view name.';
      }
    }

    return null;
  }

  /// Attempts to rename a custom saved view and records a successful change.
  WorkQueueSavedViewManagerRenameResult rename({
    required AccountingWorkspaceWorkQueueSavedView view,
    required String nextLabel,
    DateTime? occurredAt,
  }) {
    final currentIndex = _indexOf(view.id);
    if (currentIndex == -1) {
      return WorkQueueSavedViewManagerRenameResult(session: this);
    }

    final validationError = renameError(view: view, nextLabel: nextLabel);
    if (validationError != null) {
      return WorkQueueSavedViewManagerRenameResult(
        session: _withError(view.id, validationError),
        errorText: validationError,
      );
    }

    final currentView = views[currentIndex];
    final trimmedLabel = nextLabel.trim();
    if (trimmedLabel == currentView.label) {
      return WorkQueueSavedViewManagerRenameResult(
        session: clearError(view.id),
      );
    }

    final renamedView = currentView.copyWith(label: trimmedLabel);
    final nextViews = [...views];
    nextViews[currentIndex] = renamedView;
    final nextErrors = {...errors}..remove(renamedView.id);
    final event = _auditEvent(
      action: WorkQueueSavedViewManagerAuditAction.renamed,
      previousLabel: currentView.label,
      nextLabel: renamedView.label,
      view: renamedView,
      occurredAt: occurredAt,
    );

    return WorkQueueSavedViewManagerRenameResult(
      session: _copyWith(
        views: nextViews,
        auditEvents: _auditEventsWith(event),
        errors: nextErrors,
      ),
      renamedView: renamedView,
    );
  }

  /// Deletes a custom saved view and keeps enough state to support undo.
  WorkQueueSavedViewManagerDeleteResult delete({
    required AccountingWorkspaceWorkQueueSavedView view,
    DateTime? occurredAt,
  }) {
    if (!view.isCustom) {
      return WorkQueueSavedViewManagerDeleteResult(session: this);
    }

    final deletedIndex = _indexOf(view.id);
    if (deletedIndex == -1) {
      return WorkQueueSavedViewManagerDeleteResult(session: this);
    }

    final deletedView = views[deletedIndex];
    final nextErrors = {...errors}..remove(deletedView.id);
    final event = _auditEvent(
      action: WorkQueueSavedViewManagerAuditAction.deleted,
      previousLabel: deletedView.label,
      view: deletedView,
      occurredAt: occurredAt,
    );

    return WorkQueueSavedViewManagerDeleteResult(
      session: _copyWith(
        views: [
          for (final currentView in views)
            if (currentView.id != deletedView.id) currentView,
        ],
        auditEvents: _auditEventsWith(event),
        errors: nextErrors,
        lastDeletedView: deletedView,
        lastDeletedIndex: deletedIndex,
      ),
      deletedView: deletedView,
    );
  }

  /// Restores one deleted custom saved view at the requested insertion point.
  WorkQueueSavedViewManagerRestoreResult restore({
    required AccountingWorkspaceWorkQueueSavedView view,
    int? insertionIndex,
    DateTime? occurredAt,
  }) {
    if (!view.isCustom ||
        views.any((currentView) => currentView.id == view.id)) {
      return WorkQueueSavedViewManagerRestoreResult(session: this);
    }

    final candidates = workQueueSavedViewRecoveryCandidates(
      recoverableViews: [view],
      activeViews: views,
    );
    if (candidates.isEmpty) {
      return WorkQueueSavedViewManagerRestoreResult(session: this);
    }

    final restoredView = candidates.single.restoredView;
    final nextViews = [...views];
    nextViews.insert(
      _clampedInsertionIndex(insertionIndex, nextViews.length),
      restoredView,
    );
    final nextErrors = {...errors}..remove(restoredView.id);
    final event = _auditEvent(
      action: WorkQueueSavedViewManagerAuditAction.restored,
      previousLabel: restoredView.label,
      view: restoredView,
      occurredAt: occurredAt,
    );

    return WorkQueueSavedViewManagerRestoreResult(
      session: _copyWith(
        views: nextViews,
        auditEvents: _auditEventsWith(event),
        errors: nextErrors,
        clearLastDeletedView: true,
        clearLastDeletedIndex: true,
      ),
      restoredView: restoredView,
    );
  }

  /// Restores a batch of deleted history candidates while avoiding duplicates.
  WorkQueueSavedViewManagerRestoreManyResult restoreMany({
    required Iterable<WorkQueueSavedViewRecoveryCandidate> candidates,
    DateTime? occurredAt,
  }) {
    final knownViewIds = views.map((view) => view.id).toSet();
    final restoredViews = <AccountingWorkspaceWorkQueueSavedView>[];
    for (final candidate in candidates) {
      final view = candidate.restoredView;
      if (!view.isCustom || !knownViewIds.add(view.id)) continue;

      restoredViews.add(view);
    }
    if (restoredViews.isEmpty) {
      return WorkQueueSavedViewManagerRestoreManyResult(session: this);
    }

    final restoredAt = occurredAt ?? DateTime.now();
    final restoreEvents = [
      for (final view in restoredViews)
        _auditEvent(
          action: WorkQueueSavedViewManagerAuditAction.restored,
          previousLabel: view.label,
          view: view,
          occurredAt: restoredAt,
        ),
    ];
    final nextErrors = {...errors};
    for (final view in restoredViews) {
      nextErrors.remove(view.id);
    }

    return WorkQueueSavedViewManagerRestoreManyResult(
      session: _copyWith(
        views: [...views, ...restoredViews],
        auditEvents: [...restoreEvents, ...auditEvents],
        errors: nextErrors,
        clearLastDeletedView: true,
        clearLastDeletedIndex: true,
      ),
      restoredViews: restoredViews,
    );
  }

  /// Removes validation feedback for a saved view after the user edits it.
  WorkQueueSavedViewManagerSession clearError(String viewId) {
    if (!errors.containsKey(viewId)) return this;

    final nextErrors = {...errors}..remove(viewId);
    return _copyWith(errors: nextErrors);
  }

  WorkQueueSavedViewManagerSession _withError(String viewId, String errorText) {
    return _copyWith(errors: {...errors, viewId: errorText});
  }

  WorkQueueSavedViewManagerSession _copyWith({
    Iterable<AccountingWorkspaceWorkQueueSavedView>? views,
    Iterable<WorkQueueSavedViewManagerAuditEvent>? auditEvents,
    Map<String, String>? errors,
    AccountingWorkspaceWorkQueueSavedView? lastDeletedView,
    int? lastDeletedIndex,
    bool clearLastDeletedView = false,
    bool clearLastDeletedIndex = false,
  }) {
    return WorkQueueSavedViewManagerSession._(
      views: views ?? this.views,
      auditEvents: auditEvents ?? this.auditEvents,
      errors: errors ?? this.errors,
      lastDeletedView:
          clearLastDeletedView ? null : lastDeletedView ?? this.lastDeletedView,
      lastDeletedIndex:
          clearLastDeletedIndex
              ? null
              : lastDeletedIndex ?? this.lastDeletedIndex,
    );
  }

  List<WorkQueueSavedViewManagerAuditEvent> _auditEventsWith(
    WorkQueueSavedViewManagerAuditEvent event,
  ) {
    return [event, ...auditEvents];
  }

  WorkQueueSavedViewManagerAuditEvent _auditEvent({
    required WorkQueueSavedViewManagerAuditAction action,
    required String previousLabel,
    required AccountingWorkspaceWorkQueueSavedView view,
    String? nextLabel,
    DateTime? occurredAt,
  }) {
    return WorkQueueSavedViewManagerAuditEvent(
      action: action,
      previousLabel: previousLabel,
      viewId: view.id,
      rolePreset: view.rolePreset,
      nextLabel: nextLabel,
      occurredAt: occurredAt ?? DateTime.now(),
      savedView: view,
    );
  }

  int _indexOf(String viewId) {
    return views.indexWhere((view) => view.id == viewId);
  }
}

/// Outcome of a saved-view rename attempt.
class WorkQueueSavedViewManagerRenameResult {
  const WorkQueueSavedViewManagerRenameResult({
    required this.session,
    this.renamedView,
    this.errorText,
  });

  final WorkQueueSavedViewManagerSession session;
  final AccountingWorkspaceWorkQueueSavedView? renamedView;
  final String? errorText;
}

/// Outcome of deleting one custom saved view.
class WorkQueueSavedViewManagerDeleteResult {
  const WorkQueueSavedViewManagerDeleteResult({
    required this.session,
    this.deletedView,
  });

  final WorkQueueSavedViewManagerSession session;
  final AccountingWorkspaceWorkQueueSavedView? deletedView;
}

/// Outcome of restoring one custom saved view.
class WorkQueueSavedViewManagerRestoreResult {
  const WorkQueueSavedViewManagerRestoreResult({
    required this.session,
    this.restoredView,
  });

  final WorkQueueSavedViewManagerSession session;
  final AccountingWorkspaceWorkQueueSavedView? restoredView;
}

/// Outcome of restoring multiple custom saved views from history.
class WorkQueueSavedViewManagerRestoreManyResult {
  WorkQueueSavedViewManagerRestoreManyResult({
    required this.session,
    Iterable<AccountingWorkspaceWorkQueueSavedView> restoredViews = const [],
  }) : restoredViews = List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(
         restoredViews,
       );

  final WorkQueueSavedViewManagerSession session;
  final List<AccountingWorkspaceWorkQueueSavedView> restoredViews;
}

int _clampedInsertionIndex(int? insertionIndex, int itemCount) {
  final index = insertionIndex ?? itemCount;
  if (index < 0 || index > itemCount) return itemCount;

  return index;
}
