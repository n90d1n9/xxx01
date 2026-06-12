import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollFundingForecastPanel extends StatelessWidget {
  final PayrollFundingForecastSummary summary;

  const PayrollFundingForecastPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Funding forecast',
      subtitle: summary.accountLabel,
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
                          icon: Icons.savings_outlined,
                          label:
                              '${payrollCurrencyFormat.format(summary.availableFunding)} available',
                        ),
                        _MetricChip(
                          icon: Icons.receipt_long_outlined,
                          label:
                              '${payrollCurrencyFormat.format(summary.totalRequiredFunding)} needed',
                        ),
                        _MetricChip(
                          icon:
                              summary.shortfall > 0
                                  ? Icons.warning_amber_outlined
                                  : Icons.verified_outlined,
                          label:
                              summary.shortfall > 0
                                  ? '${payrollCurrencyFormat.format(summary.shortfall)} short'
                                  : '${payrollCurrencyFormat.format(summary.buffer)} buffer',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: summary.utilizationRatio,
                color: statusColor,
                label:
                    '${(summary.utilizationRatio * 100).round()}% of available payroll funding allocated',
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _statusIcon(summary.status),
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
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Settled',
              value:
                  '${summary.settledObligationCount}/${summary.obligations.length}',
            ),
            HrisMetricStripItem(
              label: 'Pending',
              value: '${summary.pendingObligationCount}',
            ),
            HrisMetricStripItem(label: 'Period', value: summary.periodLabel),
          ],
        ),
        for (final obligation in summary.obligations)
          _FundingObligationTile(obligation: obligation),
      ],
    );
  }
}

class _FundingObligationTile extends StatelessWidget {
  final PayrollFundingObligation obligation;

  const _FundingObligationTile({required this.obligation});

  @override
  Widget build(BuildContext context) {
    final color =
        obligation.isSettled
            ? const Color(0xFF15803D)
            : const Color(0xFF2563EB);

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
              obligation.isSettled
                  ? Icons.verified_outlined
                  : Icons.schedule_outlined,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obligation.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            obligation.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: obligation.isSettled ? 'Settled' : 'Pending',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                HrisProgressBar(
                  value: obligation.progress,
                  color: color,
                  label: obligation.detail,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(
                        obligation.pendingAmount,
                      ),
                    ),
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat(
                        'MMM d, yyyy',
                      ).format(obligation.dueDate),
                    ),
                  ],
                ),
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

Color _statusColor(PayrollFundingStatus status) {
  return switch (status) {
    PayrollFundingStatus.shortfall => const Color(0xFFB91C1C),
    PayrollFundingStatus.watch => const Color(0xFFB45309),
    PayrollFundingStatus.ready => const Color(0xFF2563EB),
    PayrollFundingStatus.settled => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollFundingStatus status) {
  return switch (status) {
    PayrollFundingStatus.shortfall => Icons.warning_amber_outlined,
    PayrollFundingStatus.watch => Icons.troubleshoot_outlined,
    PayrollFundingStatus.ready => Icons.task_alt_outlined,
    PayrollFundingStatus.settled => Icons.verified_outlined,
  };
}
