import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollControlReviewPanel extends StatelessWidget {
  final PayrollControlReviewSummary summary;
  final VoidCallback onReviewControls;
  final VoidCallback onReopenReview;

  const PayrollControlReviewPanel({
    super.key,
    required this.summary,
    required this.onReviewControls,
    required this.onReopenReview,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _summaryStatusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.policy_outlined,
      title: 'Payroll control review',
      subtitle:
          '${summary.reviewId} - ${DateFormat('MMM d, yyyy').format(summary.reviewDate)}',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        HrisStatusPill(
                          label: summary.status.label,
                          color: statusColor,
                        ),
                        _MetricChip(
                          icon: Icons.task_alt_outlined,
                          label:
                              '${summary.reviewedCount}/${summary.items.length} signed off',
                        ),
                        _MetricChip(
                          icon: Icons.playlist_add_check_outlined,
                          label: '${summary.readyCount} ready',
                        ),
                        _MetricChip(
                          icon: Icons.warning_amber_outlined,
                          label:
                              '${summary.criticalBlockedCount} critical blocked',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (summary.status == PayrollControlReviewStatus.reviewed)
                    OutlinedButton.icon(
                      onPressed: onReopenReview,
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: summary.canReview ? onReviewControls : null,
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text('Sign off controls'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _summaryIcon(summary.status),
                    color: statusColor,
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
        for (final item in summary.items) _ControlReviewTile(item: item),
      ],
    );
  }
}

class _ControlReviewTile extends StatelessWidget {
  final PayrollControlReviewItem item;

  const _ControlReviewTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _itemColor(item);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_itemIcon(item), color: color, size: 20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            item.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: item.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.controlLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.security_outlined,
                      label: item.severity.label,
                    ),
                    _MetricChip(
                      icon: Icons.description_outlined,
                      label: item.evidenceLabel,
                    ),
                  ],
                ),
                if (item.hasBlockers) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.blockers.first,
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
      ),
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

Color _summaryStatusColor(PayrollControlReviewStatus status) {
  return switch (status) {
    PayrollControlReviewStatus.blocked => const Color(0xFFB91C1C),
    PayrollControlReviewStatus.ready => const Color(0xFF2563EB),
    PayrollControlReviewStatus.reviewed => const Color(0xFF15803D),
  };
}

IconData _summaryIcon(PayrollControlReviewStatus status) {
  return switch (status) {
    PayrollControlReviewStatus.blocked => Icons.lock_outlined,
    PayrollControlReviewStatus.ready => Icons.playlist_add_check_outlined,
    PayrollControlReviewStatus.reviewed => Icons.verified_outlined,
  };
}

Color _itemColor(PayrollControlReviewItem item) {
  if (item.isReviewed) return const Color(0xFF15803D);
  if (item.hasBlockers) return const Color(0xFFB91C1C);
  return const Color(0xFF2563EB);
}

IconData _itemIcon(PayrollControlReviewItem item) {
  if (item.isReviewed) return Icons.verified_outlined;
  if (item.hasBlockers) return Icons.warning_amber_outlined;
  return Icons.policy_outlined;
}
