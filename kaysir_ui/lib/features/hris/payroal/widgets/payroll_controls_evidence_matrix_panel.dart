import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Shows control-to-evidence coverage for payroll audit readiness.
class PayrollControlsEvidenceMatrixPanel extends StatelessWidget {
  final PayrollControlsEvidenceMatrixSummary summary;

  const PayrollControlsEvidenceMatrixPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Controls evidence matrix',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.coverageRate,
                color: color,
                label:
                    '${(summary.coverageRate * 100).round()}% controls mapped',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: summary.status.label, color: color),
                  _MetricChip(
                    icon: Icons.verified_outlined,
                    label: '${summary.completeCount} complete',
                  ),
                  _MetricChip(
                    icon: Icons.playlist_add_check_outlined,
                    label: '${summary.readyCount} ready',
                  ),
                  _MetricChip(
                    icon: Icons.warning_amber_outlined,
                    label: '${summary.blockedCount} blocked',
                  ),
                  _MetricChip(
                    icon: Icons.link_off_outlined,
                    label: '${summary.missingCount} missing',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_statusIcon(summary.status), color: color, size: 19),
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
            ],
          ),
        ),
        HrisListSurface(
          child: Column(
            children: [
              for (var index = 0; index < summary.lines.length; index++) ...[
                _MatrixRow(line: summary.lines[index]),
                if (index < summary.lines.length - 1)
                  const Divider(height: 22, color: HrisColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MatrixRow extends StatelessWidget {
  final PayrollControlsEvidenceMatrixLine line;

  const _MatrixRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(line.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_statusIcon(line.status), color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      line.control.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: line.status.label, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                line.ownerLabel,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(
                    icon: Icons.policy_outlined,
                    label: line.control.severity.label,
                  ),
                  _MetricChip(
                    icon: Icons.snippet_folder_outlined,
                    label: line.evidenceLabel,
                  ),
                  _MetricChip(
                    icon: Icons.confirmation_number_outlined,
                    label: line.control.evidenceLabel,
                  ),
                ],
              ),
              if (line.blockers.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  line.blockers.first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFB91C1C),
                    fontWeight: FontWeight.w800,
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollControlsEvidenceMatrixStatus status) {
  return switch (status) {
    PayrollControlsEvidenceMatrixStatus.missing => const Color(0xFF9333EA),
    PayrollControlsEvidenceMatrixStatus.blocked => const Color(0xFFB91C1C),
    PayrollControlsEvidenceMatrixStatus.ready => const Color(0xFF2563EB),
    PayrollControlsEvidenceMatrixStatus.complete => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollControlsEvidenceMatrixStatus status) {
  return switch (status) {
    PayrollControlsEvidenceMatrixStatus.missing => Icons.link_off_outlined,
    PayrollControlsEvidenceMatrixStatus.blocked => Icons.warning_amber_outlined,
    PayrollControlsEvidenceMatrixStatus.ready =>
      Icons.playlist_add_check_outlined,
    PayrollControlsEvidenceMatrixStatus.complete => Icons.verified_outlined,
  };
}
