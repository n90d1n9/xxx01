import 'package:flutter/material.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_detail.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_evidence_review_state.dart';
import '../models/work_queue_note.dart';
import '../models/work_queue_reviewer_sign_off_guard.dart';
import '../models/work_queue_resolution_state.dart';
import '../services/accounting_workspace_work_queue_clearance_action_sync.dart';
import '../services/work_queue_resolution_gate_service.dart';
import 'accounting_navigation_work_queue_action_progress_components.dart';
import 'accounting_navigation_work_queue_accounting_impact_components.dart';
import 'accounting_navigation_work_queue_activity_components.dart';
import 'accounting_navigation_work_queue_clearance_components.dart';
import 'accounting_navigation_work_queue_compliance_components.dart';
import 'accounting_navigation_work_queue_escalation_components.dart';
import 'accounting_navigation_work_queue_evidence_request_components.dart';
import 'accounting_navigation_work_queue_reviewer_sign_off_components.dart';
import 'work_queue_resolution_gate_components.dart';
import 'accounting_navigation_work_queue_risk_components.dart';

/// Work queue detail panel for evidence, controls, risks, and activity.
class AccountingNavigationWorkQueueDetailPanel extends StatelessWidget {
  const AccountingNavigationWorkQueueDetailPanel({
    required this.queue,
    required this.detail,
    required this.section,
    required this.onOpen,
    required this.onCopyBrief,
    required this.onCopyEvidenceRequest,
    required this.onCopyLink,
    required this.onCopyActivityAuditBrief,
    required this.onCopyClearancePlan,
    required this.onSectionChanged,
    required this.activityActionState,
    required this.reviewerSignOffState,
    required this.resolutionState,
    required this.evidenceLinks,
    required this.evidenceReviewStates,
    required this.executionNotes,
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
    required this.onClose,
    super.key,
  });

  static const _clearanceActionSync =
      AccountingWorkspaceWorkQueueClearanceActionSync();
  static const _resolutionGateService =
      AccountingWorkspaceWorkQueueResolutionGateService();

  final AccountingWorkspaceWorkQueue queue;
  final AccountingWorkspaceWorkQueueDetail detail;
  final AccountingWorkspaceWorkQueueDetailSection section;
  final VoidCallback onOpen;
  final VoidCallback onCopyBrief;
  final VoidCallback onCopyEvidenceRequest;
  final VoidCallback onCopyLink;
  final VoidCallback onCopyActivityAuditBrief;
  final VoidCallback onCopyClearancePlan;
  final ValueChanged<AccountingWorkspaceWorkQueueDetailSection>
  onSectionChanged;
  final AccountingWorkspaceWorkQueueActivityActionState activityActionState;
  final AccountingWorkspaceWorkQueueReviewerSignOffState reviewerSignOffState;
  final AccountingWorkspaceWorkQueueResolutionState resolutionState;
  final List<AccountingWorkspaceWorkQueueEvidenceLink> evidenceLinks;
  final Map<String, AccountingWorkspaceWorkQueueEvidenceReviewState>
  evidenceReviewStates;
  final List<AccountingWorkspaceWorkQueueNote> executionNotes;
  final VoidCallback onActivityOwnerAcknowledged;
  final VoidCallback onActivityEvidenceReceived;
  final VoidCallback onActivityEscalationLogged;
  final ValueChanged<AccountingWorkspaceWorkQueueEvidenceLinkDraft>
  onEvidenceLinkAdded;
  final void Function(
    AccountingWorkspaceWorkQueueEvidenceLink link,
    AccountingWorkspaceWorkQueueEvidenceReviewDraft draft,
  )
  onEvidenceLinkReviewDecisionChanged;
  final VoidCallback onCopyEvidenceLinks;
  final ValueChanged<AccountingWorkspaceWorkQueueNoteDraft>
  onExecutionNoteAdded;
  final VoidCallback onCopyExecutionNotes;
  final VoidCallback onReviewerApproved;
  final VoidCallback onReviewerReturned;
  final VoidCallback onReviewerBlocked;
  final VoidCallback onQueueCleared;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final queue = this.queue;
    final detail = this.detail;
    final severityColor = _severityContentColor(colorScheme, queue.severity);

    return DecoratedBox(
      key: ValueKey('accounting-work-queue-detail-${queue.id}'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _severityContainerColor(colorScheme, queue.severity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      getIconData(queue.icon),
                      color: severityColor,
                      size: 19,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        queue.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _DetailPill(
                            icon: Icons.priority_high_rounded,
                            label: _severityLabel(queue.severity),
                            containerColor: _severityContainerColor(
                              colorScheme,
                              queue.severity,
                            ),
                            contentColor: severityColor,
                          ),
                          _DetailPill(
                            icon: Icons.person_rounded,
                            label: queue.ownerLabel,
                            containerColor: colorScheme.surfaceContainerLow,
                            contentColor: colorScheme.onSurfaceVariant,
                          ),
                          _DetailPill(
                            icon: Icons.schedule_rounded,
                            label: queue.dueLabel,
                            containerColor: _slaContainerColor(
                              colorScheme,
                              queue.slaStatus,
                            ),
                            contentColor: _slaContentColor(
                              colorScheme,
                              queue.slaStatus,
                            ),
                          ),
                          _DetailPill(
                            icon: Icons.format_list_numbered_rounded,
                            label:
                                queue.count == 1
                                    ? '1 item'
                                    : '${queue.count} items',
                            containerColor: colorScheme.surfaceContainerLow,
                            contentColor: colorScheme.onSurfaceVariant,
                          ),
                          if (resolutionState.cleared)
                            _DetailPill(
                              icon: Icons.task_alt_rounded,
                              label: 'Cleared',
                              containerColor: colorScheme.tertiaryContainer,
                              contentColor: colorScheme.onTertiaryContainer,
                            ),
                        ],
                      ),
                      if (activityActionState.hasCapturedActions) ...[
                        const SizedBox(height: 8),
                        AccountingNavigationWorkQueueActionProgressStrip(
                          actionState: activityActionState,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: const ValueKey('accounting-work-queue-detail-close'),
                  tooltip: 'Close queue detail',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailSectionSelector(value: section, onChanged: onSectionChanged),
            const SizedBox(height: 12),
            _activeSection(detail),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('accounting-work-queue-detail-copy'),
                  onPressed: onCopyBrief,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy brief'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('accounting-work-queue-detail-copy-link'),
                  onPressed: onCopyLink,
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text('Copy link'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey(
                    'accounting-work-queue-detail-copy-request',
                  ),
                  onPressed: onCopyEvidenceRequest,
                  icon: const Icon(Icons.outbox_outlined, size: 18),
                  label: const Text('Copy request'),
                ),
                FilledButton.icon(
                  key: const ValueKey('accounting-work-queue-detail-open'),
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open workspace'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeSection(AccountingWorkspaceWorkQueueDetail detail) {
    switch (section) {
      case AccountingWorkspaceWorkQueueDetailSection.overview:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountingNavigationWorkQueueRiskSummaryPanel(
              summary: detail.riskSummary,
            ),
            const SizedBox(height: 12),
            AccountingNavigationWorkQueueEscalationPanel(
              plan: detail.escalationPlan,
            ),
            const SizedBox(height: 12),
            AccountingNavigationWorkQueueAccountingImpactPanel(
              impact: detail.accountingImpact,
            ),
            const SizedBox(height: 12),
            _DetailField(
              icon: Icons.manage_search_rounded,
              label: 'Root cause',
              value: detail.rootCause,
            ),
            const SizedBox(height: 10),
            _DetailField(
              icon: Icons.fact_check_rounded,
              label: 'Evidence needed',
              value: detail.evidenceNeeded,
            ),
            const SizedBox(height: 10),
            _DetailField(
              icon: Icons.task_alt_rounded,
              label: 'Recommended action',
              value: detail.recommendedAction,
            ),
          ],
        );
      case AccountingWorkspaceWorkQueueDetailSection.controls:
        final evidenceReadiness =
            AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
              queueId: detail.queueId,
              request: detail.evidenceRequest,
              links: evidenceLinks,
              reviewStates: evidenceReviewStates.values,
            );
        final clearanceChecklist = _clearanceActionSync.sync(
          checklist: detail.clearanceChecklist,
          actionState: activityActionState,
          reviewerSignOffState: reviewerSignOffState,
          evidenceReadiness: evidenceReadiness,
        );
        final resolutionGate = _resolutionGateService.resolve(
          clearanceChecklist: clearanceChecklist,
          reviewerSignOffState: reviewerSignOffState,
          resolutionState: resolutionState,
          evidenceReadiness: evidenceReadiness,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountingNavigationWorkQueueClearancePanel(
              checklist: clearanceChecklist,
              onCopyBrief: onCopyClearancePlan,
            ),
            const SizedBox(height: 12),
            AccountingNavigationWorkQueueReviewerSignOffPanel(
              state: reviewerSignOffState,
              approvalGuard: AccountingWorkspaceWorkQueueReviewerSignOffGuard(
                readiness: evidenceReadiness,
              ),
              onApproved: onReviewerApproved,
              onReturned: onReviewerReturned,
              onBlocked: onReviewerBlocked,
            ),
            const SizedBox(height: 12),
            AccountingNavigationWorkQueueResolutionGatePanel(
              gate: resolutionGate,
              onClear: onQueueCleared,
            ),
            const SizedBox(height: 12),
            AccountingNavigationWorkQueueCompliancePanel(
              guardrail: detail.complianceGuardrail,
            ),
            const SizedBox(height: 12),
            _DetailField(
              icon: Icons.verified_user_rounded,
              label: 'Control objective',
              value: detail.controlObjective,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final checkpoint in detail.checkpoints)
                  _CheckpointPill(label: checkpoint),
              ],
            ),
          ],
        );
      case AccountingWorkspaceWorkQueueDetailSection.request:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountingNavigationWorkQueueEvidenceRequestPanel(
              request: detail.evidenceRequest,
            ),
            const SizedBox(height: 12),
            _DetailField(
              icon: Icons.task_alt_rounded,
              label: 'Recommended action',
              value: detail.recommendedAction,
            ),
          ],
        );
      case AccountingWorkspaceWorkQueueDetailSection.activity:
        return AccountingNavigationWorkQueueActivityPanel(
          trail: detail.activityTrail,
          evidenceRequest: detail.evidenceRequest,
          actionState: activityActionState,
          evidenceLinks: evidenceLinks,
          evidenceReviewStates: evidenceReviewStates,
          notes: executionNotes,
          onOwnerAcknowledged: onActivityOwnerAcknowledged,
          onEvidenceReceived: onActivityEvidenceReceived,
          onEscalationLogged: onActivityEscalationLogged,
          onEvidenceLinkAdded: onEvidenceLinkAdded,
          onEvidenceLinkReviewDecisionChanged:
              onEvidenceLinkReviewDecisionChanged,
          onCopyEvidenceLinks: onCopyEvidenceLinks,
          onNoteAdded: onExecutionNoteAdded,
          onCopyNotes: onCopyExecutionNotes,
          onCopyAuditBrief: onCopyActivityAuditBrief,
        );
    }
  }
}

class _DetailSectionSelector extends StatelessWidget {
  const _DetailSectionSelector({required this.value, required this.onChanged});

  final AccountingWorkspaceWorkQueueDetailSection value;
  final ValueChanged<AccountingWorkspaceWorkQueueDetailSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<AccountingWorkspaceWorkQueueDetailSection>(
        key: const ValueKey('accounting-work-queue-detail-section-selector'),
        showSelectedIcon: false,
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.single),
        segments: const [
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueDetailSection.overview,
            icon: Icon(Icons.dashboard_rounded),
            label: Text('Overview'),
          ),
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueDetailSection.controls,
            icon: Icon(Icons.verified_user_rounded),
            label: Text('Controls'),
          ),
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueDetailSection.request,
            icon: Icon(Icons.outbox_outlined),
            label: Text('Request'),
          ),
          ButtonSegment(
            value: AccountingWorkspaceWorkQueueDetailSection.activity,
            icon: Icon(Icons.manage_history_rounded),
            label: Text('Activity'),
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckpointPill extends StatelessWidget {
  const _CheckpointPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 13,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
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
