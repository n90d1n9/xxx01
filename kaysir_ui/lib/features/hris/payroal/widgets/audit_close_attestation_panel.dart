import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'audit_close_attestation_form.dart';

/// Shows and captures the final payroll audit close attestation.
class AuditCloseAttestationPanel extends StatelessWidget {
  final AuditCloseAttestationSummary summary;
  final ValueChanged<String> onSignedByChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSubmit;
  final VoidCallback onReopen;

  const AuditCloseAttestationPanel({
    super.key,
    required this.summary,
    required this.onSignedByChanged,
    required this.onRoleChanged,
    required this.onNoteChanged,
    required this.onSubmit,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        summary.isSigned
            ? const Color(0xFF15803D)
            : summary.canSign
            ? const Color(0xFF2563EB)
            : const Color(0xFFB91C1C);

    return HrisSectionPanel(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Audit close attestation',
      subtitle: summary.periodLabel,
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
                    icon: Icons.rule_folder_outlined,
                    label:
                        '${(summary.signoff.readinessRate * 100).round()}% gates ready',
                  ),
                  if (summary.record != null)
                    _MetricChip(
                      icon: Icons.how_to_reg_outlined,
                      label: summary.record!.signedBy,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.isSigned
                        ? Icons.verified_user_outlined
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
        if (summary.isSigned)
          HrisListSurface(
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onReopen,
                icon: const Icon(Icons.undo_outlined, size: 18),
                label: const Text('Reopen attestation'),
              ),
            ),
          )
        else
          AuditCloseAttestationForm(
            draft: summary.draft,
            enabled: summary.canSign,
            onSignedByChanged: onSignedByChanged,
            onRoleChanged: onRoleChanged,
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
