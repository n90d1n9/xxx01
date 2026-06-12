import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollPayslipPackagePanel extends StatelessWidget {
  final PayrollPayslipPackageSummary summary;
  final VoidCallback onPublishPayslips;
  final VoidCallback onReopenPublishing;

  const PayrollPayslipPackagePanel({
    super.key,
    required this.summary,
    required this.onPublishPayslips,
    required this.onReopenPublishing,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _packageStatusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.article_outlined,
      title: 'Payslip publishing',
      subtitle:
          '${summary.packageId} - ${DateFormat('MMM d, yyyy').format(summary.payDate)}',
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
                              '${summary.publishedCount}/${summary.lines.length} published',
                        ),
                        _MetricChip(
                          icon: Icons.pending_actions_outlined,
                          label: '${summary.pendingCount} pending',
                        ),
                        _MetricChip(
                          icon: Icons.savings_outlined,
                          label:
                              '${payrollCurrencyFormat.format(summary.publishedNet)} delivered',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (summary.status == PayrollPayslipPackageStatus.published)
                    OutlinedButton.icon(
                      onPressed: onReopenPublishing,
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: summary.canPublish ? onPublishPayslips : null,
                      icon: const Icon(Icons.publish_outlined),
                      label: const Text('Publish payslips'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _packageIcon(summary.status),
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
        for (final line in summary.lines) _PayslipLineTile(line: line),
      ],
    );
  }
}

class _PayslipLineTile extends StatelessWidget {
  final PayrollPayslipLine line;

  const _PayslipLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _lineStatusColor(line);

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
            child: Icon(_lineStatusIcon(line), color: color, size: 20),
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
                            line.employeeName,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            line.statementId,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.savings_outlined,
                      label: payrollCurrencyFormat.format(line.netAmount),
                    ),
                    _MetricChip(
                      icon: Icons.outbox_outlined,
                      label: line.channel.label,
                    ),
                    _MetricChip(
                      icon: Icons.alternate_email_outlined,
                      label: line.destinationLabel,
                    ),
                    _MetricChip(
                      icon: Icons.confirmation_number_outlined,
                      label: line.paymentReferenceCode,
                    ),
                  ],
                ),
                if (line.hasBlockers) ...[
                  const SizedBox(height: 8),
                  Text(
                    line.blockers.first,
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

Color _packageStatusColor(PayrollPayslipPackageStatus status) {
  return switch (status) {
    PayrollPayslipPackageStatus.blocked => const Color(0xFFB91C1C),
    PayrollPayslipPackageStatus.ready => const Color(0xFF2563EB),
    PayrollPayslipPackageStatus.publishing => const Color(0xFFB45309),
    PayrollPayslipPackageStatus.published => const Color(0xFF15803D),
  };
}

IconData _packageIcon(PayrollPayslipPackageStatus status) {
  return switch (status) {
    PayrollPayslipPackageStatus.blocked => Icons.lock_outlined,
    PayrollPayslipPackageStatus.ready => Icons.playlist_add_check_outlined,
    PayrollPayslipPackageStatus.publishing => Icons.sync_outlined,
    PayrollPayslipPackageStatus.published => Icons.verified_outlined,
  };
}

Color _lineStatusColor(PayrollPayslipLine line) {
  if (line.isPublished) return const Color(0xFF15803D);
  if (line.hasBlockers) return const Color(0xFFB91C1C);
  return const Color(0xFF2563EB);
}

IconData _lineStatusIcon(PayrollPayslipLine line) {
  if (line.isPublished) return Icons.verified_outlined;
  if (line.hasBlockers) return Icons.warning_amber_outlined;
  return Icons.article_outlined;
}
