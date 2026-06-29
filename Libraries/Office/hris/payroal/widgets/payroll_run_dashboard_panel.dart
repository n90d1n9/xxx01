import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollRunDashboardPanel extends StatelessWidget {
  final PayrollRunDashboard dashboard;

  const PayrollRunDashboardPanel({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(dashboard.status);

    return Column(
      children: [
        HrisSectionPanel(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Payroll run dashboard',
          subtitle: dashboard.periodLabel,
          children: [
            HrisListSurface(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final score = _ReadinessScore(
                    score: dashboard.readinessScore,
                    color: statusColor,
                  );
                  final detail = _RunDetail(dashboard: dashboard);
                  final action = _RunAction(dashboard: dashboard);

                  if (constraints.maxWidth < 760) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        score,
                        const SizedBox(height: 12),
                        detail,
                        const SizedBox(height: 12),
                        action,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      score,
                      const SizedBox(width: 16),
                      Expanded(child: detail),
                      const SizedBox(width: 16),
                      Expanded(child: action),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        HrisSummaryGrid(
          metrics: [
            HrisSummaryMetric(
              title: 'Run gross',
              value: payrollCurrencyFormat.format(dashboard.grossPayroll),
              detail: '${dashboard.employeeCount} employees',
              icon: Icons.payments_outlined,
              color: const Color(0xFF2563EB),
            ),
            HrisSummaryMetric(
              title: 'Run net',
              value: payrollCurrencyFormat.format(dashboard.netPayroll),
              detail: 'after approved adjustments',
              icon: Icons.account_balance_outlined,
              color: const Color(0xFF059669),
            ),
            HrisSummaryMetric(
              title: 'Adjustments',
              value: payrollCurrencyFormat.format(
                dashboard.approvedAdjustmentTotal,
              ),
              detail: '${dashboard.pendingAdjustmentCount} pending approval',
              icon: Icons.tune_outlined,
              color: const Color(0xFF7C3AED),
            ),
            HrisSummaryMetric(
              title: 'Exceptions',
              value: '${dashboard.openExceptionCount}',
              detail: '${dashboard.criticalExceptionCount} critical',
              icon: Icons.warning_amber_outlined,
              color: const Color(0xFFB91C1C),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReadinessScore extends StatelessWidget {
  final int score;
  final Color color;

  const _ReadinessScore({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Readiness',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RunDetail extends StatelessWidget {
  final PayrollRunDashboard dashboard;

  const _RunDetail({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        HrisStatusPill(
          label: dashboard.status.label,
          color: _statusColor(dashboard.status),
        ),
        _MetaChip(
          icon: Icons.event_available_outlined,
          label: DateFormat('MMM d, yyyy').format(dashboard.payDate),
        ),
        _MetaChip(
          icon: Icons.pending_actions_outlined,
          label: '${dashboard.pendingPaymentCount} unpaid',
        ),
      ],
    );
  }
}

class _RunAction extends StatelessWidget {
  final PayrollRunDashboard dashboard;

  const _RunAction({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.flag_circle_outlined,
          color: HrisColors.primary,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            dashboard.nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollRunStatus status) {
  return switch (status) {
    PayrollRunStatus.draft => const Color(0xFF64748B),
    PayrollRunStatus.needsReview => const Color(0xFFB45309),
    PayrollRunStatus.ready => const Color(0xFF2563EB),
    PayrollRunStatus.approved => const Color(0xFF0F766E),
    PayrollRunStatus.paid => const Color(0xFF15803D),
  };
}
