import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollCostCenterBudgetPanel extends StatelessWidget {
  final PayrollCostCenterBudgetSummary summary;
  final ValueChanged<String> onApproveCostCenter;
  final ValueChanged<String> onReopenCostCenter;

  const PayrollCostCenterBudgetPanel({
    super.key,
    required this.summary,
    required this.onApproveCostCenter,
    required this.onReopenCostCenter,
  });

  @override
  Widget build(BuildContext context) {
    final balanceColor =
        summary.totalRemainingBudget < 0
            ? const Color(0xFFB91C1C)
            : const Color(0xFF15803D);

    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Cost center budget control',
      subtitle: summary.periodLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Budget',
              value: payrollCurrencyFormat.format(summary.totalBudget),
            ),
            HrisMetricStripItem(
              label: 'Allocated',
              value: payrollCurrencyFormat.format(summary.totalGrossPayroll),
            ),
            HrisMetricStripItem(
              label: 'Balance',
              value: payrollCurrencyFormat.format(summary.totalRemainingBudget),
            ),
            HrisMetricStripItem(
              label: 'Pending',
              value: '${summary.pendingApprovalCount}',
            ),
            HrisMetricStripItem(
              label: 'Approved',
              value: '${summary.approvedReleaseCount}',
            ),
            HrisMetricStripItem(
              label: 'Evidence',
              value:
                  '${summary.readyEvidenceCount}/${summary.requiredEvidenceCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                summary.overBudgetCount > 0
                    ? Icons.warning_amber_outlined
                    : Icons.verified_outlined,
                color: balanceColor,
                size: 20,
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
        ),
        for (final line in summary.lines)
          _BudgetLineTile(
            line: line,
            onApproveCostCenter: onApproveCostCenter,
            onReopenCostCenter: onReopenCostCenter,
          ),
      ],
    );
  }
}

class _BudgetLineTile extends StatelessWidget {
  final PayrollCostCenterBudgetLine line;
  final ValueChanged<String> onApproveCostCenter;
  final ValueChanged<String> onReopenCostCenter;

  const _BudgetLineTile({
    required this.line,
    required this.onApproveCostCenter,
    required this.onReopenCostCenter,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(line.status);

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
            child: Icon(Icons.pie_chart_outline, color: color, size: 20),
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
                            line.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            line.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      children: [
                        HrisStatusPill(label: line.status.label, color: color),
                        if (line.isApprovedForRelease)
                          const HrisStatusPill(
                            label: 'Approved',
                            color: Color(0xFF15803D),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                HrisProgressBar(
                  value: line.utilization.clamp(0, 1),
                  color: color,
                  label:
                      '${(line.utilization * 100).round()}% of ${line.label} payroll budget allocated',
                ),
                const SizedBox(height: 8),
                HrisProgressBar(
                  value: line.evidenceCompletionRate,
                  color:
                      line.evidenceCompletionRate == 1
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB45309),
                  label:
                      '${line.readyEvidenceCount}/${line.requiredEvidenceCount} approval evidence items ready',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.group_outlined,
                      label: '${line.employeeCount} employees',
                    ),
                    _MetricChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: payrollCurrencyFormat.format(line.budget),
                    ),
                    _MetricChip(
                      icon:
                          line.remainingBudget < 0
                              ? Icons.trending_down_outlined
                              : Icons.savings_outlined,
                      label:
                          '${payrollCurrencyFormat.format(line.remainingBudget)} balance',
                    ),
                    _MetricChip(
                      icon: Icons.report_problem_outlined,
                      label: '${line.riskCount} risks',
                    ),
                    _MetricChip(
                      icon: Icons.inventory_2_outlined,
                      label:
                          '${line.readyEvidenceCount}/${line.requiredEvidenceCount} evidence',
                    ),
                  ],
                ),
                if (line.evidenceItems.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final item in line.evidenceItems)
                        HrisStatusPill(
                          label: item.title,
                          color:
                              item.isReady
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                        ),
                    ],
                  ),
                ],
                if (line.needsReleaseApproval || line.isApprovedForRelease) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                        line.isApprovedForRelease
                            ? OutlinedButton.icon(
                              onPressed: () => onReopenCostCenter(line.id),
                              icon: const Icon(Icons.undo_outlined, size: 18),
                              label: const Text('Reopen approval'),
                            )
                            : OutlinedButton.icon(
                              onPressed: () => onApproveCostCenter(line.id),
                              icon: const Icon(
                                Icons.verified_user_outlined,
                                size: 18,
                              ),
                              label: const Text('Approve release'),
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

Color _statusColor(PayrollCostCenterBudgetStatus status) {
  switch (status) {
    case PayrollCostCenterBudgetStatus.onTrack:
      return const Color(0xFF15803D);
    case PayrollCostCenterBudgetStatus.watch:
      return const Color(0xFFB45309);
    case PayrollCostCenterBudgetStatus.overBudget:
      return const Color(0xFFB91C1C);
  }
}
