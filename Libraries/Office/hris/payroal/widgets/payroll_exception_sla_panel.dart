import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollExceptionSlaPanel extends StatelessWidget {
  final PayrollExceptionSlaSummary summary;

  const PayrollExceptionSlaPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.timer_outlined,
      title: 'Exception SLA board',
      subtitle:
          'Aging and escalation - ${DateFormat('MMM d, yyyy').format(summary.asOfDate)}',
      emptyMessage: 'No payroll exception SLA items remain',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Open SLA',
              value: summary.items.length.toString(),
            ),
            HrisMetricStripItem(
              label: 'Breached',
              value: summary.breachedCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Due today',
              value: summary.dueTodayCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'At risk',
              value: payrollCurrencyFormat.format(summary.amountAtRisk),
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notification_important_outlined,
                    color: HrisColors.primary,
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
              if (summary.ownerLoads.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    for (final ownerLoad in summary.ownerLoads.take(4))
                      _OwnerLoadChip(ownerLoad: ownerLoad),
                  ],
                ),
              ],
            ],
          ),
        ),
        for (final item in summary.items.take(8))
          _ExceptionSlaTile(item: item, asOfDate: summary.asOfDate),
      ],
    );
  }
}

class _ExceptionSlaTile extends StatelessWidget {
  final PayrollExceptionSlaItem item;
  final DateTime asOfDate;

  const _ExceptionSlaTile({required this.item, required this.asOfDate});

  @override
  Widget build(BuildContext context) {
    final status = item.statusOn(asOfDate);
    final color = _statusColor(status);

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
            child: Icon(_statusIcon(status), color: color, size: 20),
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
                            '${item.sourceLabel} - ${item.owner}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: status.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.priority_high_outlined,
                      label: item.severity.label,
                    ),
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(item.dueDate),
                    ),
                    _MetricChip(
                      icon: Icons.supervisor_account_outlined,
                      label: item.escalationOwner,
                    ),
                    if (item.amount > 0)
                      _MetricChip(
                        icon: Icons.payments_outlined,
                        label: payrollCurrencyFormat.format(item.amount),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.action,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerLoadChip extends StatelessWidget {
  final PayrollExceptionSlaOwnerLoad ownerLoad;

  const _OwnerLoadChip({required this.ownerLoad});

  @override
  Widget build(BuildContext context) {
    final hasBreaches = ownerLoad.breachedCount > 0;
    final color =
        hasBreaches ? const Color(0xFFB91C1C) : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_pin_circle_outlined, color: color, size: 17),
          const SizedBox(width: 6),
          Text(
            '${ownerLoad.owner} - ${ownerLoad.totalCount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
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

Color _statusColor(PayrollExceptionSlaStatus status) {
  return switch (status) {
    PayrollExceptionSlaStatus.breached => const Color(0xFFB91C1C),
    PayrollExceptionSlaStatus.dueToday => const Color(0xFFB45309),
    PayrollExceptionSlaStatus.onTrack => const Color(0xFF2563EB),
  };
}

IconData _statusIcon(PayrollExceptionSlaStatus status) {
  return switch (status) {
    PayrollExceptionSlaStatus.breached => Icons.report_problem_outlined,
    PayrollExceptionSlaStatus.dueToday => Icons.today_outlined,
    PayrollExceptionSlaStatus.onTrack => Icons.schedule_outlined,
  };
}
