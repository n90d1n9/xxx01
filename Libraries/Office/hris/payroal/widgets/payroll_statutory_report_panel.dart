import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollStatutoryReportPanel extends StatelessWidget {
  final PayrollStatutoryReportSummary summary;
  final VoidCallback onExportPack;
  final VoidCallback onReopenPack;

  const PayrollStatutoryReportPanel({
    super.key,
    required this.summary,
    required this.onExportPack,
    required this.onReopenPack,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.account_balance_outlined,
      title: 'Statutory reporting pack',
      subtitle:
          '${summary.packId} - ${DateFormat('MMM d, yyyy').format(summary.payDate)}',
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
                          icon: Icons.inventory_2_outlined,
                          label: '${summary.lines.length} filings',
                        ),
                        _MetricChip(
                          icon: Icons.task_alt_outlined,
                          label: '${summary.readyCount} ready',
                        ),
                        _MetricChip(
                          icon: Icons.verified_outlined,
                          label: '${summary.exportedCount} exported',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  summary.isExported
                      ? OutlinedButton.icon(
                        onPressed: onReopenPack,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Reopen'),
                      )
                      : FilledButton.tonalIcon(
                        onPressed: summary.canExport ? onExportPack : null,
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text('Export'),
                      ),
                ],
              ),
              const SizedBox(height: 12),
              HrisMetricStrip(
                items: [
                  HrisMetricStripItem(
                    label: 'Total value',
                    value: payrollCurrencyFormat.format(summary.totalAmount),
                  ),
                  HrisMetricStripItem(
                    label: 'Ready',
                    value: summary.readyCount.toString(),
                  ),
                  HrisMetricStripItem(
                    label: 'Blocked',
                    value: summary.blockedCount.toString(),
                  ),
                  HrisMetricStripItem(
                    label: 'Exported',
                    value: summary.exportedCount.toString(),
                  ),
                ],
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
        for (final line in summary.lines) _StatutoryFilingTile(line: line),
      ],
    );
  }
}

class _StatutoryFilingTile extends StatelessWidget {
  final PayrollStatutoryFilingLine line;

  const _StatutoryFilingTile({required this.line});

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
            child: Icon(_typeIcon(line.type), color: color, size: 21),
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
                            line.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            line.recipient,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
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
                      icon: Icons.category_outlined,
                      label: line.type.label,
                    ),
                    _MetricChip(
                      icon: Icons.confirmation_number_outlined,
                      label: line.referenceCode,
                    ),
                    _MetricChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(line.dueDate),
                    ),
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.amount),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.nextAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
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
            color: HrisColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollStatutoryFilingStatus status) {
  return switch (status) {
    PayrollStatutoryFilingStatus.blocked => const Color(0xFFB91C1C),
    PayrollStatutoryFilingStatus.ready => const Color(0xFF2563EB),
    PayrollStatutoryFilingStatus.exported => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollStatutoryFilingStatus status) {
  return switch (status) {
    PayrollStatutoryFilingStatus.blocked => Icons.lock_outlined,
    PayrollStatutoryFilingStatus.ready => Icons.file_download_outlined,
    PayrollStatutoryFilingStatus.exported =>
      Icons.assignment_turned_in_outlined,
  };
}

IconData _typeIcon(PayrollStatutoryFilingType type) {
  return switch (type) {
    PayrollStatutoryFilingType.taxWithholding => Icons.account_balance_outlined,
    PayrollStatutoryFilingType.retirement => Icons.savings_outlined,
    PayrollStatutoryFilingType.healthBenefit =>
      Icons.health_and_safety_outlined,
    PayrollStatutoryFilingType.payrollRegister => Icons.summarize_outlined,
  };
}
