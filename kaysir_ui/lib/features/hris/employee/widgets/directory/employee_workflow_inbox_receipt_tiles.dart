import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_next_action_models.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_receipt_models.dart';

/// Summary metrics for completed HR workflow inbox actions.
class EmployeeWorkflowInboxReceiptSummaryStrip extends StatelessWidget {
  final EmployeeWorkflowInboxReceiptProfile profile;

  const EmployeeWorkflowInboxReceiptSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Receipts', value: '${profile.totalCount}'),
        HrisMetricStripItem(
          label: 'Governed',
          value: '${profile.governedCount}',
        ),
        HrisMetricStripItem(label: 'Payroll', value: '${profile.payrollCount}'),
        HrisMetricStripItem(label: 'Sources', value: '${profile.sourceCount}'),
      ],
    );
  }
}

/// Compact receipt tile for one completed HR workflow inbox action.
class EmployeeWorkflowInboxReceiptTile extends StatelessWidget {
  final EmployeeWorkflowInboxActionReceipt receipt;

  const EmployeeWorkflowInboxReceiptTile({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final actionColor = _actionColor(receipt.action);

    return HrisListSurface(
      key: ValueKey('employee-workflow-inbox-receipt-${receipt.id}'),
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
                  color: actionColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _actionIcon(receipt.action),
                  color: actionColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      receipt.summaryLabel,
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
              HrisStatusPill(label: receipt.actionLabel, color: actionColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ReceiptMetaChip(
                icon: _sourceIcon(receipt.source),
                label: receipt.sourceLabel,
              ),
              _ReceiptMetaChip(
                icon: Icons.person_outline,
                label: receipt.ownershipLabel,
                color: HrisColors.ink,
              ),
              _ReceiptMetaChip(
                icon: Icons.history_toggle_off_outlined,
                label: 'Was ${receipt.previousStatus}',
              ),
              _ReceiptMetaChip(
                icon: Icons.category_outlined,
                label: receipt.area.label,
              ),
              _ReceiptMetaChip(
                icon: Icons.event_available_outlined,
                label: _formatDate(receipt.decidedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee workflow inbox receipt summary')
Widget employeeWorkflowInboxReceiptSummaryStripPreview() {
  final profile = EmployeeWorkflowInboxReceiptProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    receipts: [_previewReceipt],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxReceiptSummaryStrip(profile: profile),
      ),
    ),
  );
}

@Preview(name: 'Employee workflow inbox receipt tile')
Widget employeeWorkflowInboxReceiptTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxReceiptTile(receipt: _previewReceipt),
      ),
    ),
  );
}

/// Compact metadata chip used by employee workflow inbox receipt cards.
class _ReceiptMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ReceiptMetaChip({
    required this.icon,
    required this.label,
    this.color = HrisColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
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

EmployeeWorkflowInboxActionReceipt get _previewReceipt {
  return EmployeeWorkflowInboxActionReceipt(
    id: 'EWI-4-001',
    employeeId: '4',
    employeeName: 'David Kim',
    workflowItemId: 'profile-change-EPC-4-001',
    sourceRecordId: 'EPC-4-001',
    title: 'Manager change',
    source: EmployeeWorkflowInboxSource.profileChange,
    action: EmployeeWorkflowInboxAction.apply,
    area: EmployeeNextActionArea.work,
    actor: 'People Operations',
    owner: 'People Operations',
    previousStatus: 'Scheduled',
    decidedAt: DateTime(2026, 6, 1),
  );
}

Color _actionColor(EmployeeWorkflowInboxAction action) {
  return switch (action) {
    EmployeeWorkflowInboxAction.none => HrisColors.muted,
    EmployeeWorkflowInboxAction.start => HrisColors.primary,
    EmployeeWorkflowInboxAction.complete => const Color(0xFF0F766E),
    EmployeeWorkflowInboxAction.review => const Color(0xFFB45309),
    EmployeeWorkflowInboxAction.approve => const Color(0xFF15803D),
    EmployeeWorkflowInboxAction.schedule => const Color(0xFF7C3AED),
    EmployeeWorkflowInboxAction.apply => const Color(0xFF15803D),
    EmployeeWorkflowInboxAction.activate => const Color(0xFF0369A1),
  };
}

IconData _actionIcon(EmployeeWorkflowInboxAction action) {
  return switch (action) {
    EmployeeWorkflowInboxAction.none => Icons.more_horiz,
    EmployeeWorkflowInboxAction.start => Icons.play_arrow_outlined,
    EmployeeWorkflowInboxAction.complete => Icons.check_circle_outline,
    EmployeeWorkflowInboxAction.review => Icons.rate_review_outlined,
    EmployeeWorkflowInboxAction.approve => Icons.verified_outlined,
    EmployeeWorkflowInboxAction.schedule => Icons.event_available_outlined,
    EmployeeWorkflowInboxAction.apply => Icons.publish_outlined,
    EmployeeWorkflowInboxAction.activate => Icons.bolt_outlined,
  };
}

IconData _sourceIcon(EmployeeWorkflowInboxSource source) {
  return switch (source) {
    EmployeeWorkflowInboxSource.actionWorkflow => Icons.task_alt_outlined,
    EmployeeWorkflowInboxSource.profileChange => Icons.rule_folder_outlined,
    EmployeeWorkflowInboxSource.dataCorrection => Icons.edit_note_outlined,
    EmployeeWorkflowInboxSource.jobAssignment => Icons.badge_outlined,
  };
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
