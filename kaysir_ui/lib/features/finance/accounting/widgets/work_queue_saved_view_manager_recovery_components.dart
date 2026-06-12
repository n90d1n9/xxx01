import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_saved_view.dart';
import '../models/work_queue_saved_view_recovery.dart';
import 'work_queue_saved_view_summary_chips.dart';

/// Compact history recovery notice for custom queue views deleted earlier.
class WorkQueueSavedViewManagerHistoryRecoveryNotice extends StatelessWidget {
  const WorkQueueSavedViewManagerHistoryRecoveryNotice({
    required this.candidates,
    required this.onRestore,
    required this.onRestoreAll,
    super.key,
  });

  static const _visibleRecoveryLimit = 3;

  final List<WorkQueueSavedViewRecoveryCandidate> candidates;
  final ValueChanged<WorkQueueSavedViewRecoveryCandidate> onRestore;
  final ValueChanged<List<WorkQueueSavedViewRecoveryCandidate>> onRestoreAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleCandidates = candidates
        .take(_visibleRecoveryLimit)
        .toList(growable: false);
    final hiddenCount = candidates.length - visibleCandidates.length;

    return DecoratedBox(
      key: const ValueKey(
        'accounting-work-queue-saved-view-manager-history-restore-notice',
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (candidates.length > 1)
                  TextButton(
                    key: const ValueKey(
                      'accounting-work-queue-saved-view-manager-history-'
                      'restore-all',
                    ),
                    onPressed: () => onRestoreAll(candidates),
                    child: const Text('Restore all'),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            for (final candidate in visibleCandidates)
              _WorkQueueSavedViewManagerHistoryRecoveryRow(
                candidate: candidate,
                useGenericKey: candidates.length == 1,
                onRestore: () => onRestore(candidate),
              ),
            if (hiddenCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 26),
                child: Text(
                  '$hiddenCount more in history',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _title {
    if (candidates.length == 1) {
      return 'Restore ${candidates.single.restoredView.label} from history';
    }

    return '${candidates.length} deleted queue views can be restored';
  }
}

@Preview(name: 'Work queue saved view history recovery')
Widget workQueueSavedViewManagerHistoryRecoveryNoticePreview() {
  final activeView = _controllerBlockedSavedView();
  final recoverableViews = [
    _controllerApproverSavedView().copyWith(label: activeView.label),
    _controllerEvidenceSavedView(),
  ];
  final candidates = workQueueSavedViewRecoveryCandidates(
    recoverableViews: recoverableViews,
    activeViews: [activeView],
  );

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 560,
          child: WorkQueueSavedViewManagerHistoryRecoveryNotice(
            candidates: candidates,
            onRestore: (_) {},
            onRestoreAll: (_) {},
          ),
        ),
      ),
    ),
  );
}

/// Single restorable queue view row inside the history recovery notice.
class _WorkQueueSavedViewManagerHistoryRecoveryRow extends StatelessWidget {
  const _WorkQueueSavedViewManagerHistoryRecoveryRow({
    required this.candidate,
    required this.useGenericKey,
    required this.onRestore,
  });

  final WorkQueueSavedViewRecoveryCandidate candidate;
  final bool useGenericKey;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final view = candidate.restoredView;

    return Padding(
      padding: const EdgeInsets.only(left: 26, top: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  view.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (candidate.labelChanged)
                  Text(
                    'Original: ${candidate.sourceView.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.72,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 6),
                WorkQueueSavedViewSummaryChips(
                  view: view,
                  keyPrefix:
                      'accounting-work-queue-saved-view-manager-history-'
                      'summary',
                ),
              ],
            ),
          ),
          TextButton(
            key: ValueKey(
              useGenericKey
                  ? 'accounting-work-queue-saved-view-manager-history-restore'
                  : 'accounting-work-queue-saved-view-manager-history-restore-'
                      '${view.id}',
            ),
            onPressed: onRestore,
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}

AccountingWorkspaceWorkQueueSavedView _controllerBlockedSavedView() {
  return AccountingWorkspaceWorkQueueSavedView.custom(
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
  ).copyWith(label: 'Month-end blockers');
}

AccountingWorkspaceWorkQueueSavedView _controllerApproverSavedView() {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: '',
    scope: AccountingMenuSearchScope.all,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: AccountingWorkspaceWorkQueueFocus.review,
    sort: AccountingWorkspaceWorkQueueSort.urgent,
    ownerFilter: 'Report approver',
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.all,
    selectedQueueId: 'controller-release-approvals',
    selectedQueueTitle: 'Release approvals',
    detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
  ).copyWith(label: 'Approver pulse');
}

AccountingWorkspaceWorkQueueSavedView _controllerEvidenceSavedView() {
  return AccountingWorkspaceWorkQueueSavedView.custom(
    query: 'evidence',
    scope: AccountingMenuSearchScope.screens,
    rolePreset: AccountingWorkspaceRolePreset.controller,
    focus: AccountingWorkspaceWorkQueueFocus.monitor,
    sort: AccountingWorkspaceWorkQueueSort.largest,
    ownerFilter: 'Reporting team',
    resolutionFilter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
    selectedQueueId: 'controller-reporting-evidence',
    selectedQueueTitle: 'Reporting evidence',
    detailSection: AccountingWorkspaceWorkQueueDetailSection.request,
  ).copyWith(label: 'Evidence follow-up');
}
