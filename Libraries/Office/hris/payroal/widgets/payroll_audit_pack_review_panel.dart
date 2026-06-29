import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Shows reviewer readiness for the retained payroll audit package.
class PayrollAuditPackReviewPanel extends StatelessWidget {
  final PayrollAuditPackReviewSummary summary;

  const PayrollAuditPackReviewPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Audit pack review',
      subtitle:
          '${summary.reviewId} - retain until ${DateFormat('MMM d, yyyy').format(summary.retentionUntil)}',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.readinessRate,
                color: color,
                label:
                    '${(summary.readinessRate * 100).round()}% reviewer-ready',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: summary.status.label, color: color),
                  _MetricChip(
                    icon: Icons.inventory_2_outlined,
                    label: '${summary.retainedCount} retained',
                  ),
                  _MetricChip(
                    icon: Icons.playlist_add_check_outlined,
                    label: '${summary.readyCount} ready',
                  ),
                  _MetricChip(
                    icon: Icons.warning_amber_outlined,
                    label: '${summary.blockedCount} blocked',
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
              for (
                var index = 0;
                index < summary.checkpoints.length;
                index++
              ) ...[
                _ReviewCheckpointRow(checkpoint: summary.checkpoints[index]),
                if (index < summary.checkpoints.length - 1)
                  const Divider(height: 22, color: HrisColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewCheckpointRow extends StatelessWidget {
  final PayrollAuditPackReviewCheckpoint checkpoint;

  const _ReviewCheckpointRow({required this.checkpoint});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(checkpoint.status);

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
          child: Icon(_statusIcon(checkpoint.status), color: color, size: 20),
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
                      checkpoint.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: checkpoint.statusLabel, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                checkpoint.owner,
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
                    icon: Icons.description_outlined,
                    label: checkpoint.evidenceLabel,
                  ),
                  if (checkpoint.hasBlockers)
                    _MetricChip(
                      icon: Icons.report_problem_outlined,
                      label: checkpoint.blockers.first,
                    ),
                ],
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

Color _statusColor(PayrollAuditPackReviewStatus status) {
  return switch (status) {
    PayrollAuditPackReviewStatus.blocked => const Color(0xFFB91C1C),
    PayrollAuditPackReviewStatus.ready => const Color(0xFF2563EB),
    PayrollAuditPackReviewStatus.retained => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollAuditPackReviewStatus status) {
  return switch (status) {
    PayrollAuditPackReviewStatus.blocked => Icons.lock_outlined,
    PayrollAuditPackReviewStatus.ready => Icons.playlist_add_check_outlined,
    PayrollAuditPackReviewStatus.retained => Icons.verified_outlined,
  };
}
