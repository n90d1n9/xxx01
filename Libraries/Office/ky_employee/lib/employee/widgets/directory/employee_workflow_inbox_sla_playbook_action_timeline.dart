import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_models.dart';
import 'employee_workflow_inbox_sla_playbook_action_filters.dart';

/// Timeline showing the latest employee workflow inbox SLA playbook decisions.
class EmployeeWorkflowInboxSlaPlaybookActionTimeline extends StatefulWidget {
  final EmployeeWorkflowInboxSlaPlaybookActionProfile profile;
  final int maxReceipts;
  final ValueChanged<EmployeeWorkflowInboxSlaPlaybookActionReceipt>?
  onCorrectReason;

  const EmployeeWorkflowInboxSlaPlaybookActionTimeline({
    super.key,
    required this.profile,
    this.maxReceipts = 4,
    this.onCorrectReason,
  });

  @override
  State<EmployeeWorkflowInboxSlaPlaybookActionTimeline> createState() =>
      _EmployeeWorkflowInboxSlaPlaybookActionTimelineState();
}

/// Holds local filters for the workflow inbox SLA playbook audit timeline.
class _EmployeeWorkflowInboxSlaPlaybookActionTimelineState
    extends State<EmployeeWorkflowInboxSlaPlaybookActionTimeline> {
  var _filter = EmployeeWorkflowInboxSlaPlaybookActionAuditFilter.all;

  @override
  void didUpdateWidget(
    covariant EmployeeWorkflowInboxSlaPlaybookActionTimeline oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    var nextFilter = _filter;
    if (nextFilter.actionType != null &&
        !widget.profile.actionTypes.contains(nextFilter.actionType)) {
      nextFilter = nextFilter.withActionType(null);
    }
    if (nextFilter.owner != null &&
        !widget.profile.ownerNames.contains(nextFilter.owner)) {
      nextFilter = nextFilter.withOwner(null);
    }
    if (nextFilter.actionType != _filter.actionType ||
        nextFilter.owner != _filter.owner) {
      _filter = nextFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredReceipts = widget.profile.receiptsForFilter(_filter);
    final receipts = filteredReceipts.take(widget.maxReceipts).toList();

    return HrisListSurface(
      key: const ValueKey(
        'employee-workflow-inbox-sla-playbook-action-timeline',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history_edu_outlined,
                  color: HrisColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Playbook audit trail',
                      key: const ValueKey(
                        'employee-workflow-inbox-sla-playbook-action-timeline-heading',
                      ),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.profile.auditSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: widget.profile.ownerCoverageLabel,
                color: HrisColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AuditMetaChip(
                icon: Icons.task_alt_outlined,
                label: widget.profile.nextAction,
                color: HrisColors.primary,
              ),
              _AuditMetaChip(
                icon: Icons.priority_high_outlined,
                label:
                    '${widget.profile.escalationCount} escalation${widget.profile.escalationCount == 1 ? '' : 's'}',
                color:
                    widget.profile.escalationCount > 0
                        ? const Color(0xFFB91C1C)
                        : HrisColors.muted,
              ),
              _AuditMetaChip(
                icon: Icons.update_outlined,
                label: widget.profile.latestActionLabel,
                color: const Color(0xFF15803D),
              ),
              _AuditMetaChip(
                icon: Icons.notes_outlined,
                label: widget.profile.reasonCoverageLabel,
                color: HrisColors.ink,
              ),
              _AuditMetaChip(
                icon: Icons.edit_note_outlined,
                label:
                    '${widget.profile.correctionCount} correction${widget.profile.correctionCount == 1 ? '' : 's'}',
                color:
                    widget.profile.correctionCount > 0
                        ? const Color(0xFFD97706)
                        : HrisColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          EmployeeWorkflowInboxSlaPlaybookActionFilterStrip(
            profile: widget.profile,
            filter: _filter,
            onChanged: (filter) => setState(() => _filter = filter),
          ),
          const SizedBox(height: 12),
          if (receipts.isEmpty)
            const HrisEmptyState(
              message: 'No playbook audit events match these filters',
            )
          else
            for (final receipt in receipts) ...[
              _PlaybookActionTimelineEntry(
                receipt: receipt,
                onCorrectReason: widget.onCorrectReason,
              ),
              if (receipt != receipts.last)
                const Divider(height: 18, color: HrisColors.border),
            ],
          if (filteredReceipts.length > receipts.length) ...[
            const SizedBox(height: 10),
            Text(
              '${filteredReceipts.length - receipts.length} older matching audit '
              'event${filteredReceipts.length - receipts.length == 1 ? '' : 's'} hidden',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Employee workflow inbox SLA playbook audit timeline')
Widget employeeWorkflowInboxSlaPlaybookActionTimelinePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaPlaybookActionTimeline(
          profile: _previewActionProfile,
        ),
      ),
    ),
  );
}

/// One chronological event inside the workflow inbox SLA playbook audit trail.
class _PlaybookActionTimelineEntry extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt;
  final ValueChanged<EmployeeWorkflowInboxSlaPlaybookActionReceipt>?
  onCorrectReason;

  const _PlaybookActionTimelineEntry({
    required this.receipt,
    this.onCorrectReason,
  });

  @override
  Widget build(BuildContext context) {
    final color = _actionColor(receipt.actionType);

    return Row(
      key: ValueKey(
        'employee-workflow-inbox-sla-playbook-action-timeline-entry-${receipt.id}',
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_actionIcon(receipt.actionType), color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      receipt.actionLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(receipt.decidedAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                receipt.stepTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (receipt.hasReason) ...[
                const SizedBox(height: 8),
                Container(
                  key: ValueKey(
                    'employee-workflow-inbox-sla-playbook-action-reason-${receipt.id}',
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF15803D).withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes_outlined,
                        size: 16,
                        color: Color(0xFF15803D),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          receipt.reasonLabel,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (receipt.isCorrection && receipt.hasPreviousReason) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.history_outlined,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Previous: ${receipt.previousReasonLabel}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _AuditMetaChip(
                    icon: Icons.person_outline,
                    label: receipt.actor,
                    color: HrisColors.ink,
                  ),
                  _AuditMetaChip(
                    icon: Icons.badge_outlined,
                    label: receipt.owner,
                  ),
                  _AuditMetaChip(
                    icon: Icons.format_list_numbered_outlined,
                    label: receipt.itemCountLabel,
                  ),
                  _AuditMetaChip(
                    icon: Icons.hub_outlined,
                    label: receipt.sourceLabel,
                  ),
                ],
              ),
              if (onCorrectReason != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: ValueKey(
                      'employee-workflow-inbox-sla-playbook-correct-reason-${receipt.id}',
                    ),
                    onPressed: () => onCorrectReason!(receipt),
                    icon: const Icon(Icons.edit_note_outlined, size: 18),
                    label: const Text('Correct reason'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Small metadata chip for dense workflow inbox SLA playbook audit details.
class _AuditMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AuditMetaChip({
    required this.icon,
    required this.label,
    this.color = HrisColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

EmployeeWorkflowInboxSlaPlaybookActionProfile get _previewActionProfile {
  return EmployeeWorkflowInboxSlaPlaybookActionProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    receipts: [
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-002',
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'ready',
        stepTitle: 'Clear ready inbox actions',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
        actor: 'People Operations',
        owner: 'People Operations',
        itemCount: 2,
        sources: const [EmployeeWorkflowInboxSource.profileChange],
        reason: 'Recovery started to prevent SLA drift',
        decidedAt: DateTime(2026, 6, 1),
      ),
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'rebalance',
        stepTitle: 'Balance inbox owner load',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup,
        actor: 'HR Lead',
        owner: 'HR Business Partner',
        itemCount: 3,
        sources: const [
          EmployeeWorkflowInboxSource.actionWorkflow,
          EmployeeWorkflowInboxSource.jobAssignment,
        ],
        reason: 'Backup reviewer needed to protect SLA',
        decidedAt: DateTime(2026, 5, 31),
      ),
    ],
  );
}

IconData _actionIcon(EmployeeWorkflowInboxSlaPlaybookActionType action) {
  return switch (action) {
    EmployeeWorkflowInboxSlaPlaybookActionType.markEscalated =>
      Icons.priority_high_outlined,
    EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup =>
      Icons.group_add_outlined,
    EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery =>
      Icons.play_arrow_outlined,
    EmployeeWorkflowInboxSlaPlaybookActionType.confirmProgress =>
      Icons.check_circle_outline,
  };
}

Color _actionColor(EmployeeWorkflowInboxSlaPlaybookActionType action) {
  return switch (action) {
    EmployeeWorkflowInboxSlaPlaybookActionType.markEscalated => const Color(
      0xFFB91C1C,
    ),
    EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup =>
      HrisColors.primary,
    EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery => const Color(
      0xFF15803D,
    ),
    EmployeeWorkflowInboxSlaPlaybookActionType.confirmProgress => const Color(
      0xFF0F766E,
    ),
  };
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
