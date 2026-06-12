import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee_document_escalation_plan.dart';
import '../models/employee_document_escalation_preview.dart';

/// Opens a confirmation preview before owner workload escalations are recorded.
Future<bool?> showEmployeeDocumentEscalationPreviewDialog({
  required BuildContext context,
  required EmployeeDocumentEscalationPreview preview,
}) {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => EmployeeDocumentEscalationPreviewDialog(preview: preview),
  );
}

/// Modal preview for employee document owner escalations before confirmation.
class EmployeeDocumentEscalationPreviewDialog extends StatelessWidget {
  final EmployeeDocumentEscalationPreview preview;

  const EmployeeDocumentEscalationPreviewDialog({
    super.key,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return AlertDialog(
      icon: const Icon(Icons.priority_high_outlined),
      title: const Text('Escalation preview'),
      content: SizedBox(
        width: 680,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EscalationPreviewSummary(preview: preview),
                const SizedBox(height: 14),
                for (final owner in preview.owners) ...[
                  _EscalationPreviewOwnerTile(owner: owner),
                  if (owner != preview.owners.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              preview.isEmpty ? null : () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.priority_high_outlined),
          label: Text(
            preview.ownerCount == 1
                ? 'Record escalation'
                : 'Record ${preview.ownerCount} escalations',
          ),
        ),
      ],
    );
  }
}

/// Summary strip for the escalation preview modal.
class _EscalationPreviewSummary extends StatelessWidget {
  final EmployeeDocumentEscalationPreview preview;

  const _EscalationPreviewSummary({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _EscalationPreviewStat(
          label: 'Owners',
          value: '${preview.ownerCount}',
          icon: Icons.supervisor_account_outlined,
          color: HrisColors.primary,
        ),
        _EscalationPreviewStat(
          label: 'Critical',
          value: '${preview.criticalCount}',
          icon: Icons.report_problem_outlined,
          color: Colors.red,
        ),
        _EscalationPreviewStat(
          label: 'Gaps',
          value: '${preview.gapCount}',
          icon: Icons.rule_folder_outlined,
          color: Colors.deepOrange,
        ),
        _EscalationPreviewStat(
          label: 'Missing',
          value: '${preview.missingDocumentCount}',
          icon: Icons.file_present_outlined,
          color: Colors.red,
        ),
        _EscalationPreviewStat(
          label: 'Requests',
          value: '${preview.openRequestCount}',
          icon: Icons.mark_email_unread_outlined,
          color: Colors.indigo,
        ),
      ],
    );
  }
}

/// Compact metric chip for the escalation preview summary.
class _EscalationPreviewStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _EscalationPreviewStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Owner row for the escalation preview modal.
class _EscalationPreviewOwnerTile extends StatelessWidget {
  final EmployeeDocumentEscalationPreviewOwner owner;

  const _EscalationPreviewOwnerTile({required this.owner});

  @override
  Widget build(BuildContext context) {
    final plan = owner.plan;
    final priorityColor = _priorityColor(plan.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${plan.entitySummary} - ${plan.primaryEmployeeLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HrisStatusPill(
                    label: plan.priority.label,
                    color: priorityColor,
                  ),
                  const SizedBox(height: 6),
                  HrisStatusPill(
                    label: plan.escalationFreshnessLabel,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Gaps', value: '${plan.gapCount}'),
              HrisMetricStripItem(
                label: 'Missing',
                value: '${plan.missingDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Requests',
                value: '${plan.openRequestCount}',
              ),
              HrisMetricStripItem(
                label: 'Due risk',
                value: '${plan.overdueCount + plan.dueSoonCount}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            owner.actionSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.rationale,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(EmployeeDocumentEscalationPriority priority) {
  switch (priority) {
    case EmployeeDocumentEscalationPriority.critical:
      return Colors.red;
    case EmployeeDocumentEscalationPriority.high:
      return Colors.orange;
    case EmployeeDocumentEscalationPriority.watchlist:
      return Colors.blueGrey;
  }
}

@Preview(name: 'Employee document escalation preview dialog')
Widget employeeDocumentEscalationPreviewDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: EmployeeDocumentEscalationPreviewDialog(
        preview: EmployeeDocumentEscalationPreview(
          owners: const [
            EmployeeDocumentEscalationPreviewOwner(
              plan: EmployeeDocumentEscalationPlan(
                ownerName: 'Fajar Prakoso',
                entitySummary: 'PT Kaysir Nusantara',
                priority: EmployeeDocumentEscalationPriority.critical,
                workloadScore: 186,
                gapCount: 2,
                criticalCount: 1,
                highCount: 1,
                overdueCount: 1,
                dueSoonCount: 1,
                missingDocumentCount: 9,
                openRequestCount: 2,
                actionLabel: 'Review rejected evidence',
                primaryEmployeeName: 'David Kim',
                digestFreshnessLabel: 'Digest due',
                digestCadenceLabel: 'Daily',
                digestDue: true,
                rationale:
                    '1 critical and 1 overdue document gap need owner escalation.',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
