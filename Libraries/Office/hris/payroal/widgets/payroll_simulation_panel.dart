import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollSimulationPanel extends StatelessWidget {
  final PayrollSimulationSummary summary;
  final VoidCallback onReview;
  final VoidCallback onApply;
  final VoidCallback onReopen;

  const PayrollSimulationPanel({
    super.key,
    required this.summary,
    required this.onReview,
    required this.onApply,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.science_outlined,
      title: 'Payroll simulation',
      subtitle: 'What-if impact before payroll release',
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
                        _MetaChip(
                          icon: Icons.trending_up_outlined,
                          label: payrollCurrencyFormat.format(
                            summary.grossDelta,
                          ),
                        ),
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: payrollCurrencyFormat.format(summary.netDelta),
                        ),
                        _MetaChip(
                          icon: Icons.warning_amber_outlined,
                          label: '${summary.blockerCount} blockers',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed:
                            summary.status ==
                                        PayrollSimulationStatus.reviewed ||
                                    summary.status ==
                                        PayrollSimulationStatus.applied
                                ? onReopen
                                : null,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Reopen'),
                      ),
                      OutlinedButton.icon(
                        onPressed: summary.canApply ? onApply : null,
                        icon: const Icon(Icons.playlist_add_check_outlined),
                        label: const Text('Apply'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: summary.canReview ? onReview : null,
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Review'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisMetricStrip(
                items: [
                  HrisMetricStripItem(
                    label: 'Base gross',
                    value: payrollCurrencyFormat.format(
                      summary.baseSummary.totalGross,
                    ),
                  ),
                  HrisMetricStripItem(
                    label: 'Projected gross',
                    value: payrollCurrencyFormat.format(summary.projectedGross),
                  ),
                  HrisMetricStripItem(
                    label: 'Projected net',
                    value: payrollCurrencyFormat.format(summary.projectedNet),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_statusIcon(summary.status), color: statusColor),
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
        for (final line in summary.impactLines)
          _SimulationImpactTile(line: line),
      ],
    );
  }
}

class _SimulationImpactTile extends StatelessWidget {
  final PayrollSimulationImpactLine line;

  const _SimulationImpactTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color =
        line.isBlocking
            ? const Color(0xFFB91C1C)
            : line.amount < 0
            ? const Color(0xFFB45309)
            : const Color(0xFF15803D);

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
            child: Icon(
              line.isBlocking
                  ? Icons.warning_amber_outlined
                  : line.amount < 0
                  ? Icons.south_east_outlined
                  : Icons.north_east_outlined,
              color: color,
              size: 20,
            ),
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
                        line.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: payrollCurrencyFormat.format(line.amount),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  line.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollSimulationStatus status) {
  return switch (status) {
    PayrollSimulationStatus.blocked => const Color(0xFFB91C1C),
    PayrollSimulationStatus.draft => const Color(0xFFB45309),
    PayrollSimulationStatus.reviewed => const Color(0xFF2563EB),
    PayrollSimulationStatus.applied => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollSimulationStatus status) {
  return switch (status) {
    PayrollSimulationStatus.blocked => Icons.warning_amber_outlined,
    PayrollSimulationStatus.draft => Icons.science_outlined,
    PayrollSimulationStatus.reviewed => Icons.fact_check_outlined,
    PayrollSimulationStatus.applied => Icons.verified_outlined,
  };
}
