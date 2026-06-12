import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Shows final payroll audit close readiness before sign-off.
class AuditCloseSignoffPanel extends StatelessWidget {
  final AuditCloseSignoffSummary summary;

  const AuditCloseSignoffPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color =
        summary.blockedCount > 0
            ? const Color(0xFFB91C1C)
            : summary.actionCount > 0
            ? const Color(0xFF2563EB)
            : const Color(0xFF15803D);

    return HrisSectionPanel(
      icon: Icons.verified_user_outlined,
      title: 'Audit close sign-off',
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
                  HrisStatusPill(
                    label: summary.canSignOff ? 'Ready' : 'In progress',
                    color: color,
                  ),
                  _MetricChip(
                    icon: Icons.block_outlined,
                    label: '${summary.blockedCount} blocked',
                  ),
                  _MetricChip(
                    icon: Icons.playlist_add_check_outlined,
                    label: '${summary.actionCount} actions',
                  ),
                  _MetricChip(
                    icon: Icons.verified_outlined,
                    label: '${summary.readyCount} ready',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              HrisProgressBar(
                value: summary.readinessRate,
                color: color,
                label:
                    '${(summary.readinessRate * 100).round()}% sign-off readiness',
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.canSignOff
                        ? Icons.verified_user_outlined
                        : Icons.rule_folder_outlined,
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
            ],
          ),
        ),
        HrisListSurface(
          child: Column(
            children: [
              for (var index = 0; index < summary.gates.length; index++) ...[
                _SignoffGateRow(gate: summary.gates[index]),
                if (index < summary.gates.length - 1)
                  const Divider(height: 22, color: HrisColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SignoffGateRow extends StatelessWidget {
  final AuditCloseSignoffGate gate;

  const _SignoffGateRow({required this.gate});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(gate.status);

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
          child: Icon(_statusIcon(gate.status), color: color, size: 20),
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
                      gate.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: gate.status.label, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(
                    icon: Icons.person_pin_circle_outlined,
                    label: gate.owner,
                  ),
                  _MetricChip(
                    icon: Icons.inventory_2_outlined,
                    label: gate.evidenceLabel,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                gate.nextAction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
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

Color _statusColor(AuditCloseSignoffGateStatus status) {
  return switch (status) {
    AuditCloseSignoffGateStatus.blocked => const Color(0xFFB91C1C),
    AuditCloseSignoffGateStatus.actionNeeded => const Color(0xFF2563EB),
    AuditCloseSignoffGateStatus.ready => const Color(0xFF15803D),
  };
}

IconData _statusIcon(AuditCloseSignoffGateStatus status) {
  return switch (status) {
    AuditCloseSignoffGateStatus.blocked => Icons.block_outlined,
    AuditCloseSignoffGateStatus.actionNeeded =>
      Icons.playlist_add_check_outlined,
    AuditCloseSignoffGateStatus.ready => Icons.verified_outlined,
  };
}
