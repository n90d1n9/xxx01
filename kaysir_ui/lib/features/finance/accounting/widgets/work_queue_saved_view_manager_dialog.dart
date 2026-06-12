import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_saved_view.dart';
import '../models/work_queue_saved_view_manager_filter.dart';
import '../models/work_queue_saved_view_manager_audit.dart';
import '../models/work_queue_saved_view_manager_group.dart';
import '../models/work_queue_saved_view_manager_pending_edits.dart';
import '../models/work_queue_saved_view_manager_session.dart';
import '../models/work_queue_saved_view_recovery.dart';
import 'work_queue_saved_view_manager_audit_components.dart';
import 'work_queue_saved_view_manager_edit_components.dart';
import 'work_queue_saved_view_manager_filter_components.dart';
import 'work_queue_saved_view_manager_recovery_components.dart';

/// Dialog for renaming and deleting user-defined accounting queue views.
class AccountingWorkQueueSavedViewManagerDialog extends StatefulWidget {
  const AccountingWorkQueueSavedViewManagerDialog({
    required this.views,
    this.auditEvents = const [],
    required this.onRenamed,
    required this.onDeleted,
    required this.onRestored,
    super.key,
  });

  final List<AccountingWorkspaceWorkQueueSavedView> views;
  final List<WorkQueueSavedViewManagerAuditEvent> auditEvents;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView> onRenamed;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView> onDeleted;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView> onRestored;

  @override
  State<AccountingWorkQueueSavedViewManagerDialog> createState() =>
      _AccountingWorkQueueSavedViewManagerDialogState();
}

/// State holder for editable custom queue view names and validation feedback.
class _AccountingWorkQueueSavedViewManagerDialogState
    extends State<AccountingWorkQueueSavedViewManagerDialog> {
  late WorkQueueSavedViewManagerSession _session;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _draftLabels = {};
  final TextEditingController _filterController = TextEditingController();
  String _filterQuery = '';

  @override
  void initState() {
    super.initState();
    _session = WorkQueueSavedViewManagerSession.create(
      views: widget.views,
      auditEvents: widget.auditEvents,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recoveryCandidates = _session.recoveryCandidates;
    final filteredViews = filterWorkQueueSavedViewManagerViews(
      views: _session.views,
      query: _filterQuery,
    );
    final viewGroups = groupWorkQueueSavedViewManagerViews(
      views: filteredViews,
    );
    final pendingRenames = workQueueSavedViewManagerPendingRenames(
      views: _session.views,
      draftLabels: _draftLabels,
    );
    final hasFilter = _filterQuery.trim().isNotEmpty;
    final showFilter = _session.views.length > 1;
    final showRoleHeaders = viewGroups.length > 1;

    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Icon(Icons.tune_rounded, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          const Text('Manage Queue Views'),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_session.views.isEmpty)
              const WorkQueueSavedViewManagerEmptyState()
            else ...[
              if (pendingRenames.isNotEmpty) ...[
                WorkQueueSavedViewManagerPendingChangesNotice(
                  pendingCount: pendingRenames.length,
                  onSave: _savePendingRenames,
                  onDiscard: _discardPendingRenames,
                ),
                const SizedBox(height: 12),
              ],
              if (showFilter) ...[
                WorkQueueSavedViewManagerFilterField(
                  controller: _filterController,
                  resultCount: filteredViews.length,
                  totalCount: _session.views.length,
                  onChanged: _updateFilter,
                  onClear: _clearFilter,
                ),
                const SizedBox(height: 12),
              ],
              if (filteredViews.isEmpty && hasFilter)
                WorkQueueSavedViewManagerFilterEmptyState(
                  query: _filterQuery.trim(),
                  onClear: _clearFilter,
                )
              else
                for (final group in viewGroups) ...[
                  if (showRoleHeaders) ...[
                    WorkQueueSavedViewManagerRoleGroupHeader(
                      rolePreset: group.rolePreset,
                      viewCount: group.viewCount,
                    ),
                    const SizedBox(height: 8),
                  ],
                  for (final view in group.views) ...[
                    WorkQueueSavedViewManagerRow(
                      view: view,
                      controller: _controllerFor(view),
                      errorText: _session.errors[view.id],
                      onChanged:
                          (nextLabel) => _updateDraftLabel(view.id, nextLabel),
                      onRenamed: () => _rename(view),
                      onDeleted: () => _delete(view),
                    ),
                    if (!_isLastVisibleView(
                      group: group,
                      groups: viewGroups,
                      view: view,
                    ))
                      const Divider(height: 16),
                  ],
                ],
            ],
            if (_session.lastDeletedView case final deletedView?) ...[
              const SizedBox(height: 12),
              WorkQueueSavedViewManagerUndoDeleteNotice(
                view: deletedView,
                onUndo: _restoreLastDeletedView,
              ),
            ] else if (recoveryCandidates.isNotEmpty) ...[
              const SizedBox(height: 12),
              WorkQueueSavedViewManagerHistoryRecoveryNotice(
                candidates: recoveryCandidates,
                onRestore: _restoreHistoryDeletedView,
                onRestoreAll: _restoreHistoryDeletedViews,
              ),
            ],
            if (_session.auditEvents.isNotEmpty) ...[
              const SizedBox(height: 12),
              WorkQueueSavedViewManagerAuditTrail(
                events: _session.auditEvents,
                onCopyBrief: _copyAuditBrief,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('accounting-work-queue-saved-view-manager-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  TextEditingController _controllerFor(
    AccountingWorkspaceWorkQueueSavedView view,
  ) {
    return _controllers.putIfAbsent(
      view.id,
      () => TextEditingController(text: view.label),
    );
  }

  bool _isLastVisibleView({
    required WorkQueueSavedViewManagerRoleGroup group,
    required List<WorkQueueSavedViewManagerRoleGroup> groups,
    required AccountingWorkspaceWorkQueueSavedView view,
  }) {
    return identical(group, groups.last) && view == group.views.last;
  }

  void _rename(AccountingWorkspaceWorkQueueSavedView view) {
    final nextLabel = _controllerFor(view).text.trim();
    final result = _session.rename(view: view, nextLabel: nextLabel);
    final isValidNoop = result.errorText == null && result.renamedView == null;
    setState(() {
      _session = result.session;
      if (result.renamedView case final renamedView?) {
        _controllerFor(renamedView).text = renamedView.label;
        _draftLabels.remove(renamedView.id);
      } else if (isValidNoop) {
        _draftLabels.remove(view.id);
      }
    });

    if (result.renamedView case final renamedView?) {
      widget.onRenamed(renamedView);
    }
  }

  void _delete(AccountingWorkspaceWorkQueueSavedView view) {
    final result = _session.delete(view: view);
    final deletedView = result.deletedView;
    if (deletedView == null) return;

    setState(() {
      _session = result.session;
      _controllers.remove(deletedView.id)?.dispose();
      _draftLabels.remove(deletedView.id);
    });
    widget.onDeleted(deletedView);
  }

  void _restoreLastDeletedView() {
    final view = _session.lastDeletedView;
    if (view == null) return;

    _restoreDeletedView(
      view,
      _session.lastDeletedIndex ?? _session.views.length,
    );
  }

  void _restoreHistoryDeletedView(
    WorkQueueSavedViewRecoveryCandidate candidate,
  ) {
    _restoreDeletedView(candidate.restoredView, _session.views.length);
  }

  void _restoreHistoryDeletedViews(
    List<WorkQueueSavedViewRecoveryCandidate> candidates,
  ) {
    final result = _session.restoreMany(candidates: candidates);
    if (result.restoredViews.isEmpty) return;

    setState(() {
      _session = result.session;
      for (final view in result.restoredViews) {
        _draftLabels.remove(view.id);
      }
    });
    for (final view in result.restoredViews) {
      widget.onRestored(view);
    }
  }

  void _restoreDeletedView(
    AccountingWorkspaceWorkQueueSavedView view,
    int deletedIndex,
  ) {
    final result = _session.restore(view: view, insertionIndex: deletedIndex);
    final restoredView = result.restoredView;
    if (restoredView == null) return;

    setState(() {
      _session = result.session;
      _draftLabels.remove(restoredView.id);
    });
    widget.onRestored(restoredView);
  }

  Future<void> _copyAuditBrief() async {
    await Clipboard.setData(
      ClipboardData(
        text: workQueueSavedViewManagerAuditBrief(_session.auditEvents),
      ),
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Recent queue view changes copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateFilter(String query) {
    setState(() {
      _filterQuery = query;
    });
  }

  void _updateDraftLabel(String viewId, String nextLabel) {
    setState(() {
      _draftLabels[viewId] = nextLabel;
      _session = _session.clearError(viewId);
    });
  }

  void _savePendingRenames() {
    final pendingRenames = workQueueSavedViewManagerPendingRenames(
      views: _session.views,
      draftLabels: _draftLabels,
    );
    if (pendingRenames.isEmpty) return;

    final renamedViews = <AccountingWorkspaceWorkQueueSavedView>[];
    setState(() {
      var nextSession = _session;
      for (final pendingRename in pendingRenames) {
        final result = nextSession.rename(
          view: pendingRename.view,
          nextLabel: pendingRename.nextLabel,
        );
        nextSession = result.session;
        if (result.renamedView case final renamedView?) {
          _controllerFor(renamedView).text = renamedView.label;
          _draftLabels.remove(renamedView.id);
          renamedViews.add(renamedView);
        } else if (result.errorText == null) {
          _draftLabels.remove(pendingRename.view.id);
        }
      }
      _session = nextSession;
    });

    for (final renamedView in renamedViews) {
      widget.onRenamed(renamedView);
    }
  }

  void _discardPendingRenames() {
    final pendingRenames = workQueueSavedViewManagerPendingRenames(
      views: _session.views,
      draftLabels: _draftLabels,
    );
    if (pendingRenames.isEmpty) return;

    setState(() {
      var nextSession = _session;
      for (final pendingRename in pendingRenames) {
        _controllerFor(pendingRename.view).text = pendingRename.view.label;
        _draftLabels.remove(pendingRename.view.id);
        nextSession = nextSession.clearError(pendingRename.view.id);
      }
      _session = nextSession;
    });
  }

  void _clearFilter() {
    if (_filterQuery.isEmpty && _filterController.text.isEmpty) return;

    setState(() {
      _filterController.clear();
      _filterQuery = '';
    });
  }
}

@Preview(name: 'Work queue saved view manager')
Widget workQueueSavedViewManagerDialogPreview() {
  final views = [
    AccountingWorkspaceWorkQueueSavedView.custom(
      query: '',
      scope: AccountingMenuSearchScope.all,
      rolePreset: AccountingWorkspaceRolePreset.controller,
      focus: AccountingWorkspaceWorkQueueFocus.blocked,
      sort: AccountingWorkspaceWorkQueueSort.workflow,
      ownerFilter: null,
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
      selectedQueueId: null,
      selectedQueueTitle: null,
      detailSection: AccountingWorkspaceWorkQueueDetailSection.overview,
    ),
    AccountingWorkspaceWorkQueueSavedView.custom(
      query: 'spt',
      scope: AccountingMenuSearchScope.shortcuts,
      rolePreset: AccountingWorkspaceRolePreset.tax,
      focus: AccountingWorkspaceWorkQueueFocus.review,
      sort: AccountingWorkspaceWorkQueueSort.urgent,
      ownerFilter: 'Tax reviewer',
      resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
      selectedQueueId: 'tax-disclosure-review',
      selectedQueueTitle: 'Tax disclosure review',
      detailSection: AccountingWorkspaceWorkQueueDetailSection.request,
    ),
  ];

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: AccountingWorkQueueSavedViewManagerDialog(
          views: views,
          auditEvents: const [
            WorkQueueSavedViewManagerAuditEvent(
              action: WorkQueueSavedViewManagerAuditAction.renamed,
              previousLabel: 'Blocked queues / Workflow',
              nextLabel: 'Month-end blockers',
            ),
          ],
          onRenamed: (_) {},
          onDeleted: (_) {},
          onRestored: (_) {},
        ),
      ),
    ),
  );
}
