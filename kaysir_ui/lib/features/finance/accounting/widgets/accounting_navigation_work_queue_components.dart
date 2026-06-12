import 'package:flutter/material.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_close_command_center.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_close_readiness.dart';
import '../models/accounting_workspace_work_queue_detail.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_health.dart';
import '../models/accounting_workspace_work_queue_owner_summary.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_exception_register.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_evidence_review_state.dart';
import '../models/work_queue_note.dart';
import '../models/work_queue_close_packet_evidence_summary.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_resolution_state.dart';
import '../models/work_queue_resolution_summary.dart';
import '../models/work_queue_saved_view.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../models/accounting_workspace_work_queue_sla_summary.dart';
import 'accounting_navigation_work_queue_close_readiness_components.dart';
import 'accounting_navigation_work_queue_detail_components.dart';
import 'accounting_navigation_work_queue_owner_components.dart';
import 'accounting_navigation_work_queue_sort_components.dart';
import 'work_queue_evidence_exception_register_components.dart';
import 'work_queue_evidence_readiness_components.dart';
import 'work_queue_resolution_summary_components.dart';
import 'work_queue_saved_view_components.dart';
import 'accounting_navigation_work_queue_sla_components.dart';

/// Work queue operating panel for close blockers, owners, SLA, and review work.
class AccountingNavigationWorkQueues extends StatelessWidget {
  const AccountingNavigationWorkQueues({
    required this.queues,
    required this.health,
    required this.slaSummary,
    required this.ownerSummary,
    required this.closeReadiness,
    required this.savedViews,
    this.hasManagedSavedViewHistory = false,
    required this.query,
    required this.scope,
    required this.rolePreset,
    this.activeGateReview,
    required this.ownerFilter,
    required this.selectedQueueId,
    required this.selectedQueue,
    required this.selectedQueueDetail,
    required this.selectedQueueDetailSection,
    required this.selectedQueueActivityActionState,
    required this.selectedQueueReviewerSignOffState,
    required this.selectedQueueResolutionState,
    required this.selectedQueueEvidenceLinks,
    required this.selectedQueueEvidenceReviewStates,
    required this.selectedQueueExecutionNotes,
    required this.queueResolutionStates,
    required this.queueResolutionSnapshots,
    required this.queueEvidenceReadiness,
    required this.evidenceExceptionRegister,
    required this.resolutionSummary,
    required this.resolutionFilter,
    required this.resolutionEvidenceSummary,
    required this.resolutionNextAction,
    required this.sort,
    required this.focus,
    required this.onFocusChanged,
    required this.onOwnerFilterChanged,
    required this.onSortChanged,
    required this.onSavedViewSelected,
    required this.onViewReset,
    this.onCurrentViewSaved,
    this.onSavedViewsManaged,
    this.onSavedViewDeleted,
    required this.onSelected,
    required this.onOpenQueue,
    required this.onCopyBrief,
    required this.onCopyEvidenceRequest,
    required this.onCopyLink,
    required this.onCopyActivityAuditBrief,
    required this.onCopyClearancePlan,
    required this.onCopyCloseReadinessBrief,
    required this.onCopyEvidenceExceptionRegister,
    required this.onCopyResolutionSummaryBrief,
    required this.onResolutionFilterChanged,
    this.onNextResolutionSelected,
    required this.onDetailSectionChanged,
    required this.onActivityOwnerAcknowledged,
    required this.onActivityEvidenceReceived,
    required this.onActivityEscalationLogged,
    required this.onEvidenceLinkAdded,
    required this.onEvidenceLinkReviewDecisionChanged,
    required this.onCopyEvidenceLinks,
    required this.onExecutionNoteAdded,
    required this.onCopyExecutionNotes,
    required this.onReviewerApproved,
    required this.onReviewerReturned,
    required this.onReviewerBlocked,
    required this.onQueueCleared,
    this.onGateReviewCleared,
    required this.onSelectionCleared,
    super.key,
  });

  final List<AccountingWorkspaceWorkQueue> queues;
  final AccountingWorkspaceWorkQueueHealth health;
  final AccountingWorkspaceWorkQueueSlaSummary slaSummary;
  final AccountingWorkspaceWorkQueueOwnerSummary ownerSummary;
  final AccountingWorkspaceWorkQueueCloseReadiness closeReadiness;
  final List<AccountingWorkspaceWorkQueueSavedView> savedViews;
  final bool hasManagedSavedViewHistory;
  final String query;
  final AccountingMenuSearchScope scope;
  final AccountingWorkspaceRolePreset rolePreset;
  final AccountingWorkspaceCloseCommandCenterGateCheck? activeGateReview;
  final String? ownerFilter;
  final String? selectedQueueId;
  final AccountingWorkspaceWorkQueue? selectedQueue;
  final AccountingWorkspaceWorkQueueDetail? selectedQueueDetail;
  final AccountingWorkspaceWorkQueueDetailSection selectedQueueDetailSection;
  final AccountingWorkspaceWorkQueueActivityActionState?
  selectedQueueActivityActionState;
  final AccountingWorkspaceWorkQueueReviewerSignOffState?
  selectedQueueReviewerSignOffState;
  final AccountingWorkspaceWorkQueueResolutionState?
  selectedQueueResolutionState;
  final List<AccountingWorkspaceWorkQueueEvidenceLink>
  selectedQueueEvidenceLinks;
  final Map<String, AccountingWorkspaceWorkQueueEvidenceReviewState>
  selectedQueueEvidenceReviewStates;
  final List<AccountingWorkspaceWorkQueueNote> selectedQueueExecutionNotes;
  final Map<String, AccountingWorkspaceWorkQueueResolutionState>
  queueResolutionStates;
  final Map<String, AccountingWorkspaceWorkQueueResolutionSnapshot>
  queueResolutionSnapshots;
  final Map<String, AccountingWorkspaceWorkQueueEvidenceReadiness>
  queueEvidenceReadiness;
  final AccountingWorkspaceWorkQueueEvidenceExceptionRegister
  evidenceExceptionRegister;
  final AccountingWorkspaceWorkQueueResolutionSummary resolutionSummary;
  final AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter;
  final AccountingWorkspaceWorkQueueClosePacketEvidenceSummary
  resolutionEvidenceSummary;
  final AccountingWorkspaceWorkQueueResolutionNextAction? resolutionNextAction;
  final AccountingWorkspaceWorkQueueSort sort;
  final AccountingWorkspaceWorkQueueFocus focus;
  final ValueChanged<AccountingWorkspaceWorkQueueFocus> onFocusChanged;
  final ValueChanged<String?> onOwnerFilterChanged;
  final ValueChanged<AccountingWorkspaceWorkQueueSort> onSortChanged;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView> onSavedViewSelected;
  final VoidCallback onViewReset;
  final VoidCallback? onCurrentViewSaved;
  final VoidCallback? onSavedViewsManaged;
  final ValueChanged<AccountingWorkspaceWorkQueueSavedView>? onSavedViewDeleted;
  final ValueChanged<AccountingWorkspaceWorkQueue> onSelected;
  final ValueChanged<AccountingWorkspaceWorkQueue> onOpenQueue;
  final ValueChanged<AccountingWorkspaceWorkQueueDetail> onCopyBrief;
  final ValueChanged<AccountingWorkspaceWorkQueueDetail> onCopyEvidenceRequest;
  final ValueChanged<AccountingWorkspaceWorkQueue> onCopyLink;
  final ValueChanged<AccountingWorkspaceWorkQueueDetail>
  onCopyActivityAuditBrief;
  final ValueChanged<AccountingWorkspaceWorkQueueDetail> onCopyClearancePlan;
  final ValueChanged<AccountingWorkspaceWorkQueueCloseReadiness>
  onCopyCloseReadinessBrief;
  final ValueChanged<AccountingWorkspaceWorkQueueEvidenceExceptionRegister>
  onCopyEvidenceExceptionRegister;
  final VoidCallback onCopyResolutionSummaryBrief;
  final ValueChanged<AccountingWorkspaceWorkQueueResolutionFilter>
  onResolutionFilterChanged;
  final VoidCallback? onNextResolutionSelected;
  final ValueChanged<AccountingWorkspaceWorkQueueDetailSection>
  onDetailSectionChanged;
  final ValueChanged<AccountingWorkspaceWorkQueue> onActivityOwnerAcknowledged;
  final ValueChanged<AccountingWorkspaceWorkQueue> onActivityEvidenceReceived;
  final ValueChanged<AccountingWorkspaceWorkQueue> onActivityEscalationLogged;
  final void Function(
    AccountingWorkspaceWorkQueue queue,
    AccountingWorkspaceWorkQueueEvidenceLinkDraft draft,
  )
  onEvidenceLinkAdded;
  final void Function(
    AccountingWorkspaceWorkQueue queue,
    AccountingWorkspaceWorkQueueEvidenceLink link,
    AccountingWorkspaceWorkQueueEvidenceReviewDraft draft,
  )
  onEvidenceLinkReviewDecisionChanged;
  final ValueChanged<AccountingWorkspaceWorkQueue> onCopyEvidenceLinks;
  final void Function(
    AccountingWorkspaceWorkQueue queue,
    AccountingWorkspaceWorkQueueNoteDraft draft,
  )
  onExecutionNoteAdded;
  final ValueChanged<AccountingWorkspaceWorkQueue> onCopyExecutionNotes;
  final ValueChanged<AccountingWorkspaceWorkQueue> onReviewerApproved;
  final ValueChanged<AccountingWorkspaceWorkQueue> onReviewerReturned;
  final ValueChanged<AccountingWorkspaceWorkQueue> onReviewerBlocked;
  final ValueChanged<AccountingWorkspaceWorkQueue> onQueueCleared;
  final VoidCallback? onGateReviewCleared;
  final VoidCallback onSelectionCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeQueue = selectedQueue;
    final activeDetail = selectedQueueDetail;
    final activeActivityActionState = selectedQueueActivityActionState;
    final activeReviewerSignOffState = selectedQueueReviewerSignOffState;
    final activeResolutionState = selectedQueueResolutionState;
    final readinessNextQueue = _queueById(
      queues,
      closeReadiness.nextAction?.queueId,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_late_rounded,
                  color: colorScheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Work Queues',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (activeGateReview != null) ...[
              _WorkQueueGateReviewStrip(
                gate: activeGateReview!,
                onClear: onGateReviewCleared,
              ),
              const SizedBox(height: 10),
            ],
            if (savedViews.isNotEmpty) ...[
              AccountingNavigationWorkQueueSavedViews(
                views: savedViews,
                query: query,
                scope: scope,
                rolePreset: rolePreset,
                focus: focus,
                sort: sort,
                ownerFilter: ownerFilter,
                resolutionFilter: resolutionFilter,
                selectedQueueId: selectedQueueId ?? activeQueue?.id,
                selectedQueueLabel: activeQueue?.title,
                detailSection: selectedQueueDetailSection,
                onSelected: onSavedViewSelected,
                hasManagedViewHistory: hasManagedSavedViewHistory,
                onFocusCleared:
                    focus == AccountingWorkspaceWorkQueueFocus.all
                        ? null
                        : () => onFocusChanged(
                          AccountingWorkspaceWorkQueueFocus.all,
                        ),
                onSortCleared:
                    sort == AccountingWorkspaceWorkQueueSort.workflow
                        ? null
                        : () => onSortChanged(
                          AccountingWorkspaceWorkQueueSort.workflow,
                        ),
                onOwnerFilterCleared:
                    ownerFilter == null
                        ? null
                        : () => onOwnerFilterChanged(null),
                onResolutionFilterCleared:
                    resolutionFilter.isDefault
                        ? null
                        : () => onResolutionFilterChanged(
                          AccountingWorkspaceWorkQueueResolutionFilter.all,
                        ),
                onQueueSelectionCleared:
                    (selectedQueueId ?? activeQueue?.id) == null
                        ? null
                        : onSelectionCleared,
                onDetailSectionCleared:
                    selectedQueueDetailSection ==
                            AccountingWorkspaceWorkQueueDetailSection.overview
                        ? null
                        : () => onDetailSectionChanged(
                          AccountingWorkspaceWorkQueueDetailSection.overview,
                        ),
                onContextReset: onViewReset,
                onSaveCurrent: onCurrentViewSaved,
                onManageViews: onSavedViewsManaged,
                onDeleted: onSavedViewDeleted,
              ),
              const SizedBox(height: 10),
            ],
            if (health.hasQueues) ...[
              _WorkQueueHealthStrip(health: health),
              const SizedBox(height: 10),
              AccountingNavigationWorkQueueCloseReadinessStrip(
                readiness: closeReadiness,
                onCopyBrief: () => onCopyCloseReadinessBrief(closeReadiness),
                onNextActionSelected:
                    readinessNextQueue == null
                        ? null
                        : () => onSelected(readinessNextQueue),
              ),
              const SizedBox(height: 10),
              AccountingNavigationWorkQueueResolutionSummaryStrip(
                summary: resolutionSummary,
                filter: resolutionFilter,
                evidenceSummary: resolutionEvidenceSummary,
                nextAction: resolutionNextAction,
                onCopyBrief: onCopyResolutionSummaryBrief,
                onFilterChanged: onResolutionFilterChanged,
                onNextActionSelected: onNextResolutionSelected,
              ),
              const SizedBox(height: 10),
              AccountingNavigationWorkQueueEvidenceExceptionRegister(
                register: evidenceExceptionRegister,
                onCopyBrief:
                    () => onCopyEvidenceExceptionRegister(
                      evidenceExceptionRegister,
                    ),
                onExceptionSelected: (queueId) {
                  final queue = _queueById(queues, queueId);
                  if (queue == null) return;

                  onSelected(queue);
                  onDetailSectionChanged(
                    AccountingWorkspaceWorkQueueDetailSection.request,
                  );
                },
                onOwnerSelected: onOwnerFilterChanged,
              ),
              if (evidenceExceptionRegister.hasExceptions)
                const SizedBox(height: 10),
              AccountingNavigationWorkQueueSlaStrip(summary: slaSummary),
              const SizedBox(height: 10),
              AccountingNavigationWorkQueueOwnerStrip(
                summary: ownerSummary,
                selectedOwnerLabel: ownerFilter,
                onOwnerSelected: onOwnerFilterChanged,
              ),
              const SizedBox(height: 10),
              AccountingNavigationWorkQueueSortSelector(
                value: sort,
                onChanged: onSortChanged,
              ),
              const SizedBox(height: 10),
              _WorkQueueFocusSelector(value: focus, onChanged: onFocusChanged),
              const SizedBox(height: 10),
            ],
            if (activeQueue != null && activeDetail != null) ...[
              AccountingNavigationWorkQueueDetailPanel(
                queue: activeQueue,
                detail: activeDetail,
                section: selectedQueueDetailSection,
                onOpen: () => onOpenQueue(activeQueue),
                onCopyBrief: () => onCopyBrief(activeDetail),
                onCopyEvidenceRequest:
                    () => onCopyEvidenceRequest(activeDetail),
                onCopyLink: () => onCopyLink(activeQueue),
                onCopyActivityAuditBrief:
                    () => onCopyActivityAuditBrief(activeDetail),
                onCopyClearancePlan: () => onCopyClearancePlan(activeDetail),
                onSectionChanged: onDetailSectionChanged,
                activityActionState:
                    activeActivityActionState ??
                    AccountingWorkspaceWorkQueueActivityActionState(
                      queueId: activeQueue.id,
                    ),
                reviewerSignOffState:
                    activeReviewerSignOffState ??
                    AccountingWorkspaceWorkQueueReviewerSignOffState(
                      queueId: activeQueue.id,
                    ),
                resolutionState:
                    activeResolutionState ??
                    AccountingWorkspaceWorkQueueResolutionState(
                      queueId: activeQueue.id,
                    ),
                evidenceLinks: selectedQueueEvidenceLinks,
                evidenceReviewStates: selectedQueueEvidenceReviewStates,
                executionNotes: selectedQueueExecutionNotes,
                onActivityOwnerAcknowledged:
                    () => onActivityOwnerAcknowledged(activeQueue),
                onActivityEvidenceReceived:
                    () => onActivityEvidenceReceived(activeQueue),
                onActivityEscalationLogged:
                    () => onActivityEscalationLogged(activeQueue),
                onEvidenceLinkAdded:
                    (draft) => onEvidenceLinkAdded(activeQueue, draft),
                onEvidenceLinkReviewDecisionChanged:
                    (link, draft) => onEvidenceLinkReviewDecisionChanged(
                      activeQueue,
                      link,
                      draft,
                    ),
                onCopyEvidenceLinks: () => onCopyEvidenceLinks(activeQueue),
                onExecutionNoteAdded:
                    (draft) => onExecutionNoteAdded(activeQueue, draft),
                onCopyExecutionNotes: () => onCopyExecutionNotes(activeQueue),
                onReviewerApproved: () => onReviewerApproved(activeQueue),
                onReviewerReturned: () => onReviewerReturned(activeQueue),
                onReviewerBlocked: () => onReviewerBlocked(activeQueue),
                onQueueCleared: () => onQueueCleared(activeQueue),
                onClose: onSelectionCleared,
              ),
              const SizedBox(height: 10),
            ],
            if (queues.isEmpty)
              _WorkQueuesEmptyState(
                hasQueues: health.hasQueues,
                resolutionFilter: resolutionFilter,
                onResolutionFilterCleared:
                    resolutionFilter.isDefault
                        ? null
                        : () => onResolutionFilterChanged(
                          AccountingWorkspaceWorkQueueResolutionFilter.all,
                        ),
              )
            else
              Column(
                children: [
                  for (final queue in queues) ...[
                    _WorkQueueRow(
                      queue: queue,
                      resolutionState: queueResolutionStates[queue.id],
                      resolutionSnapshot: queueResolutionSnapshots[queue.id],
                      evidenceReadiness: queueEvidenceReadiness[queue.id],
                      isSelected: activeQueue?.id == queue.id,
                      onSelected: onSelected,
                    ),
                    if (queue != queues.last)
                      Divider(height: 1, color: colorScheme.outlineVariant),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkQueueFocusSelector extends StatelessWidget {
  const _WorkQueueFocusSelector({required this.value, required this.onChanged});

  final AccountingWorkspaceWorkQueueFocus value;
  final ValueChanged<AccountingWorkspaceWorkQueueFocus> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<AccountingWorkspaceWorkQueueFocus>(
        key: const ValueKey('accounting-work-queue-focus-selector'),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueFocus.all,
            icon: Icon(Icons.select_all_rounded),
            label: Text('All'),
          ),
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueFocus.blocked,
            icon: Icon(Icons.priority_high_rounded),
            label: Text('Blocked'),
          ),
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueFocus.review,
            icon: Icon(Icons.rate_review_rounded),
            label: Text('Review'),
          ),
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueFocus.monitor,
            icon: Icon(Icons.visibility_rounded),
            label: Text('Monitor'),
          ),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}

class _WorkQueueGateReviewStrip extends StatelessWidget {
  const _WorkQueueGateReviewStrip({required this.gate, required this.onClear});

  final AccountingWorkspaceCloseCommandCenterGateCheck gate;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _gateStatusColor(colorScheme, gate.status);

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-gate-review'),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.filter_alt_rounded, color: accentColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gate review: ${gate.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${gate.statusLabel} · ${gate.detailLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              key: const ValueKey('accounting-work-queue-gate-review-clear'),
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AccountingWorkspaceWorkQueue? _queueById(
  Iterable<AccountingWorkspaceWorkQueue> queues,
  String? queueId,
) {
  if (queueId == null) return null;

  for (final queue in queues) {
    if (queue.id == queueId) return queue;
  }

  return null;
}

Color _gateStatusColor(
  ColorScheme colorScheme,
  AccountingWorkspaceCloseCommandCenterGateStatus status,
) {
  switch (status) {
    case AccountingWorkspaceCloseCommandCenterGateStatus.clear:
      return colorScheme.tertiary;
    case AccountingWorkspaceCloseCommandCenterGateStatus.watch:
      return colorScheme.secondary;
    case AccountingWorkspaceCloseCommandCenterGateStatus.blocked:
      return colorScheme.error;
  }
}

class _WorkQueueHealthStrip extends StatelessWidget {
  const _WorkQueueHealthStrip({required this.health});

  final AccountingWorkspaceWorkQueueHealth health;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _WorkQueueHealthMetric(
          key: const ValueKey('accounting-work-queue-health-open'),
          icon: Icons.pending_actions_rounded,
          value: health.totalItems,
          label: 'Open',
        ),
        _WorkQueueHealthMetric(
          key: const ValueKey('accounting-work-queue-health-blocked'),
          icon: Icons.priority_high_rounded,
          value: health.blockedItems,
          label: 'Blocked',
          severity: AccountingWorkspaceWorkQueueSeverity.critical,
        ),
        _WorkQueueHealthMetric(
          key: const ValueKey('accounting-work-queue-health-review'),
          icon: Icons.rate_review_rounded,
          value: health.reviewItems,
          label: 'Review',
          severity: AccountingWorkspaceWorkQueueSeverity.warning,
        ),
        _WorkQueueHealthMetric(
          key: const ValueKey('accounting-work-queue-health-monitor'),
          icon: Icons.visibility_rounded,
          value: health.monitorItems,
          label: 'Monitor',
          severity: AccountingWorkspaceWorkQueueSeverity.info,
        ),
      ],
    );
  }
}

class _WorkQueueHealthMetric extends StatelessWidget {
  const _WorkQueueHealthMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.severity,
  });

  final IconData icon;
  final int value;
  final String label;
  final AccountingWorkspaceWorkQueueSeverity? severity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final containerColor =
        severity == null
            ? colorScheme.surfaceContainerLow
            : _severityContainerColor(colorScheme, severity!);
    final contentColor =
        severity == null
            ? colorScheme.onSurface
            : _severityContentColor(colorScheme, severity!);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: contentColor),
            const SizedBox(width: 7),
            Text(
              '$value',
              style: theme.textTheme.titleSmall?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkQueueRow extends StatelessWidget {
  const _WorkQueueRow({
    required this.queue,
    required this.resolutionState,
    required this.resolutionSnapshot,
    required this.evidenceReadiness,
    required this.isSelected,
    required this.onSelected,
  });

  final AccountingWorkspaceWorkQueue queue;
  final AccountingWorkspaceWorkQueueResolutionState? resolutionState;
  final AccountingWorkspaceWorkQueueResolutionSnapshot? resolutionSnapshot;
  final AccountingWorkspaceWorkQueueEvidenceReadiness? evidenceReadiness;
  final bool isSelected;
  final ValueChanged<AccountingWorkspaceWorkQueue> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveSnapshot =
        resolutionSnapshot ??
        (resolutionState?.cleared ?? false
            ? AccountingWorkspaceWorkQueueResolutionSnapshot(
              queueId: queue.id,
              status:
                  AccountingWorkspaceWorkQueueResolutionSnapshotStatus.cleared,
              statusLabel: 'Queue cleared',
              actionLabel: 'Retain evidence and monitor changes',
            )
            : null);
    final isCleared = effectiveSnapshot?.isCleared ?? false;
    final statusColor = _resolutionSnapshotColor(
      colorScheme,
      effectiveSnapshot,
    );
    final rowColor =
        isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.32)
            : isCleared
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.14)
            : Colors.transparent;
    final severityContainerColor =
        isCleared
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.62)
            : _severityContainerColor(colorScheme, queue.severity);
    final severityContentColor =
        isCleared
            ? colorScheme.onTertiaryContainer
            : _severityContentColor(colorScheme, queue.severity);

    return InkWell(
      key: ValueKey('accounting-work-queue-${queue.id}'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => onSelected(queue),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: rowColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: severityContainerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isCleared
                        ? Icons.task_alt_rounded
                        : getIconData(queue.icon),
                    color: severityContentColor,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            queue.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCleared)
                          _QueueResolutionPill(snapshot: effectiveSnapshot)
                        else if (effectiveSnapshot != null)
                          _QueueResolutionPill(snapshot: effectiveSnapshot)
                        else
                          _QueueCountBadge(queue: queue),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      queue.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _QueueSeverityPill(severity: queue.severity),
                        _QueueOwnerPill(ownerLabel: queue.ownerLabel),
                        _QueueSlaPill(queue: queue),
                        if (evidenceReadiness case final readiness?
                            when readiness.status !=
                                AccountingWorkspaceWorkQueueEvidenceReadinessStatus
                                    .ready)
                          AccountingNavigationWorkQueueEvidenceSignalPill(
                            readiness: readiness,
                          ),
                        if (effectiveSnapshot != null)
                          _QueueMetadataPill(
                            icon:
                                isCleared
                                    ? Icons.inventory_2_rounded
                                    : Icons.flag_rounded,
                            label: _resolutionSnapshotActionLabel(
                              effectiveSnapshot,
                            ),
                            containerColor: statusColor.withValues(alpha: 0.10),
                            contentColor: statusColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.manage_search_rounded
                    : Icons.chevron_right_rounded,
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueCountBadge extends StatelessWidget {
  const _QueueCountBadge({required this.queue});

  final AccountingWorkspaceWorkQueue queue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _severityContainerColor(colorScheme, queue.severity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          '${queue.count}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: _severityContentColor(colorScheme, queue.severity),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _QueueResolutionPill extends StatelessWidget {
  const _QueueResolutionPill({required this.snapshot});

  final AccountingWorkspaceWorkQueueResolutionSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final effectiveSnapshot = snapshot;
    if (effectiveSnapshot == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final contentColor = _resolutionSnapshotColor(
      colorScheme,
      effectiveSnapshot,
    );

    return _QueueMetadataPill(
      icon: _resolutionSnapshotIcon(effectiveSnapshot.status),
      label: effectiveSnapshot.badgeLabel,
      containerColor: contentColor.withValues(alpha: 0.12),
      contentColor: contentColor,
    );
  }
}

class _QueueSeverityPill extends StatelessWidget {
  const _QueueSeverityPill({required this.severity});

  final AccountingWorkspaceWorkQueueSeverity severity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _severityContainerColor(colorScheme, severity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          _severityLabel(severity),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _severityContentColor(colorScheme, severity),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _QueueOwnerPill extends StatelessWidget {
  const _QueueOwnerPill({required this.ownerLabel});

  final String ownerLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _QueueMetadataPill(
      icon: Icons.person_rounded,
      label: ownerLabel,
      containerColor: colorScheme.surfaceContainerLow,
      contentColor: colorScheme.onSurfaceVariant,
    );
  }
}

class _QueueSlaPill extends StatelessWidget {
  const _QueueSlaPill({required this.queue});

  final AccountingWorkspaceWorkQueue queue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _QueueMetadataPill(
      icon: Icons.schedule_rounded,
      label: queue.dueLabel,
      containerColor: _slaContainerColor(colorScheme, queue.slaStatus),
      contentColor: _slaContentColor(colorScheme, queue.slaStatus),
    );
  }
}

class _QueueMetadataPill extends StatelessWidget {
  const _QueueMetadataPill({
    required this.icon,
    required this.label,
    required this.containerColor,
    required this.contentColor,
  });

  final IconData icon;
  final String label;
  final Color containerColor;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: contentColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkQueuesEmptyState extends StatelessWidget {
  const _WorkQueuesEmptyState({
    required this.hasQueues,
    required this.resolutionFilter,
    required this.onResolutionFilterCleared,
  });

  final bool hasQueues;
  final AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter;
  final VoidCallback? onResolutionFilterCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final showClearFilter = !resolutionFilter.isDefault;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.task_alt_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              resolutionFilter.emptyStateLabel(hasQueues: hasQueues),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showClearFilter) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              key: const ValueKey(
                'accounting-work-queue-empty-clear-resolution-filter',
              ),
              onPressed: onResolutionFilterCleared,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text(resolutionFilter.clearActionLabel),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _severityLabel(AccountingWorkspaceWorkQueueSeverity severity) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.info:
      return 'Monitor';
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return 'Review';
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return 'Blocked';
  }
}

IconData _resolutionSnapshotIcon(
  AccountingWorkspaceWorkQueueResolutionSnapshotStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.cleared:
      return Icons.task_alt_rounded;
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.ready:
      return Icons.playlist_add_check_circle_rounded;
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.blocked:
      return Icons.report_problem_rounded;
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.waiting:
      return Icons.pending_actions_rounded;
  }
}

Color _resolutionSnapshotColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueResolutionSnapshot? snapshot,
) {
  switch (snapshot?.status) {
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.cleared:
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.ready:
      return colorScheme.tertiary;
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.blocked:
      return colorScheme.error;
    case AccountingWorkspaceWorkQueueResolutionSnapshotStatus.waiting:
      return colorScheme.primary;
    case null:
      return colorScheme.onSurfaceVariant;
  }
}

String _resolutionSnapshotActionLabel(
  AccountingWorkspaceWorkQueueResolutionSnapshot snapshot,
) {
  if (snapshot.isCleared) return 'Retain evidence';
  if (snapshot.isReady) return 'Mark cleared';
  if (snapshot.statusLabel.contains('Evidence')) return 'Evidence gate';
  if (snapshot.statusLabel.contains('Reviewer')) return 'Reviewer sign-off';
  if (snapshot.statusLabel.contains('Clearance')) return 'Clearance step';

  return 'Continue clearance';
}

Color _severityContainerColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueSeverity severity,
) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.info:
      return colorScheme.tertiaryContainer;
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return colorScheme.secondaryContainer;
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return colorScheme.errorContainer;
  }
}

Color _severityContentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueSeverity severity,
) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.info:
      return colorScheme.onTertiaryContainer;
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return colorScheme.onSecondaryContainer;
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return colorScheme.onErrorContainer;
  }
}

Color _slaContainerColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueSlaStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return colorScheme.errorContainer;
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return colorScheme.secondaryContainer;
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return colorScheme.tertiaryContainer;
  }
}

Color _slaContentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueSlaStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return colorScheme.onErrorContainer;
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return colorScheme.onSecondaryContainer;
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return colorScheme.onTertiaryContainer;
  }
}
