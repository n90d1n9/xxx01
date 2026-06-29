import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'audit_reviewer_receipt_form.dart';

/// Shows and captures reviewer acknowledgement for delivered audit packages.
class AuditReviewerReceiptPanel extends StatelessWidget {
  final AuditReviewerReceiptSummary summary;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onReviewerRoleChanged;
  final ValueChanged<AuditReviewerReceiptDecision> onDecisionChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSubmit;
  final VoidCallback onReopen;

  const AuditReviewerReceiptPanel({
    super.key,
    required this.summary,
    required this.onReviewerChanged,
    required this.onReviewerRoleChanged,
    required this.onDecisionChanged,
    required this.onNoteChanged,
    required this.onSubmit,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        summary.needsClarification
            ? const Color(0xFFB45309)
            : summary.isRecorded
            ? const Color(0xFF15803D)
            : summary.canRecord
            ? const Color(0xFF2563EB)
            : const Color(0xFFB91C1C);

    return HrisSectionPanel(
      icon: Icons.mark_email_read_outlined,
      title: 'Audit reviewer receipt',
      subtitle: summary.delivery.package.packageId,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: summary.statusLabel, color: color),
                  _MetricChip(
                    icon: Icons.forward_to_inbox_outlined,
                    label: summary.delivery.package.recipientLabel,
                  ),
                  if (summary.record != null)
                    _MetricChip(
                      icon: Icons.person_search_outlined,
                      label: summary.record!.reviewer,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.isRecorded
                        ? Icons.assignment_turned_in_outlined
                        : Icons.assignment_late_outlined,
                    color: color,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (summary.record != null) ...[
                const SizedBox(height: 8),
                Text(
                  summary.record!.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (summary.isRecorded)
          HrisListSurface(
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onReopen,
                icon: const Icon(Icons.undo_outlined, size: 18),
                label: const Text('Reopen receipt'),
              ),
            ),
          )
        else
          AuditReviewerReceiptForm(
            draft: summary.draft,
            enabled: summary.canRecord,
            onReviewerChanged: onReviewerChanged,
            onReviewerRoleChanged: onReviewerRoleChanged,
            onDecisionChanged: onDecisionChanged,
            onNoteChanged: onNoteChanged,
            onSubmit: onSubmit,
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
