import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Shows the reviewer-ready payroll audit handoff package.
class AuditHandoffPackagePanel extends StatelessWidget {
  final AuditHandoffPackageSummary summary;

  const AuditHandoffPackagePanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color =
        summary.blockedCount > 0
            ? const Color(0xFFB91C1C)
            : summary.pendingCount > 0
            ? const Color(0xFF2563EB)
            : const Color(0xFF15803D);

    return HrisSectionPanel(
      icon: Icons.inventory_2_outlined,
      title: 'Audit handoff package',
      subtitle: summary.packageId,
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
                    label: summary.canHandoff ? 'Ready' : 'Preparing',
                    color: color,
                  ),
                  _MetricChip(
                    icon: Icons.verified_outlined,
                    label: '${summary.readyCount} ready',
                  ),
                  _MetricChip(
                    icon: Icons.pending_actions_outlined,
                    label: '${summary.pendingCount} pending',
                  ),
                  _MetricChip(
                    icon: Icons.block_outlined,
                    label: '${summary.blockedCount} blocked',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              HrisProgressBar(
                value: summary.readinessRate,
                color: color,
                label:
                    '${(summary.readinessRate * 100).round()}% handoff package ready',
              ),
              const SizedBox(height: 12),
              _MetricChip(
                icon: Icons.forward_to_inbox_outlined,
                label: summary.recipientLabel,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.canHandoff
                        ? Icons.send_time_extension_outlined
                        : Icons.inventory_2_outlined,
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
              for (var index = 0; index < summary.lines.length; index++) ...[
                _HandoffLineRow(line: summary.lines[index]),
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

class _HandoffLineRow extends StatelessWidget {
  final AuditHandoffPackageLine line;

  const _HandoffLineRow({required this.line});

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
                      line.title,
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(
                    icon: Icons.person_pin_circle_outlined,
                    label: line.owner,
                  ),
                  _MetricChip(
                    icon: Icons.description_outlined,
                    label: line.detail,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                line.nextAction,
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

Color _statusColor(AuditHandoffPackageLineStatus status) {
  return switch (status) {
    AuditHandoffPackageLineStatus.blocked => const Color(0xFFB91C1C),
    AuditHandoffPackageLineStatus.pending => const Color(0xFF2563EB),
    AuditHandoffPackageLineStatus.ready => const Color(0xFF15803D),
  };
}

IconData _statusIcon(AuditHandoffPackageLineStatus status) {
  return switch (status) {
    AuditHandoffPackageLineStatus.blocked => Icons.block_outlined,
    AuditHandoffPackageLineStatus.pending => Icons.pending_actions_outlined,
    AuditHandoffPackageLineStatus.ready => Icons.verified_outlined,
  };
}
