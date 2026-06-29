import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollPayslipDistributionPanel extends StatelessWidget {
  final PayrollPayslipDistributionSummary summary;
  final VoidCallback onDispatchStatements;
  final VoidCallback onResetDelivery;

  const PayrollPayslipDistributionPanel({
    super.key,
    required this.summary,
    required this.onDispatchStatements,
    required this.onResetDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _summaryStatusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.outbox_outlined,
      title: 'Statement distribution',
      subtitle: '${summary.package.packageId} - delivery control',
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
                          icon: Icons.send_outlined,
                          label: '${summary.dispatchedCount} dispatched',
                        ),
                        _MetaChip(
                          icon: Icons.mark_email_read_outlined,
                          label: '${summary.acknowledgedCount} acknowledged',
                        ),
                        _MetaChip(
                          icon: Icons.report_problem_outlined,
                          label: '${summary.failedCount} failed',
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
                        onPressed: summary.hasReceipts ? onResetDelivery : null,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Reset'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed:
                            summary.canDispatch ? onDispatchStatements : null,
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Dispatch'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: summary.deliveryProgress,
                color: statusColor,
                label:
                    '${NumberFormat.percentPattern().format(summary.deliveryProgress)} delivered',
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_summaryStatusIcon(summary.status), color: statusColor),
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
        for (final line in summary.lines) _DistributionLineTile(line: line),
      ],
    );
  }
}

class _DistributionLineTile extends StatelessWidget {
  final PayrollPayslipDistributionLine line;

  const _DistributionLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _lineStatusColor(line.status);

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
            child: Icon(_lineStatusIcon(line.status), color: color, size: 20),
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
                            line.payslip.employeeName,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            line.payslip.statementId,
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.outbox_outlined,
                      label: line.payslip.channel.label,
                    ),
                    _MetaChip(
                      icon: Icons.alternate_email_outlined,
                      label: line.payslip.destinationLabel,
                    ),
                    _MetaChip(
                      icon: Icons.confirmation_number_outlined,
                      label: line.payslip.paymentReferenceCode,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.nextAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        line.status ==
                                PayrollPayslipDistributionLineStatus.failed
                            ? const Color(0xFFB91C1C)
                            : HrisColors.muted,
                    fontWeight: FontWeight.w800,
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

Color _summaryStatusColor(PayrollPayslipDistributionStatus status) {
  return switch (status) {
    PayrollPayslipDistributionStatus.waitingForPublish => const Color(
      0xFF64748B,
    ),
    PayrollPayslipDistributionStatus.ready => const Color(0xFF2563EB),
    PayrollPayslipDistributionStatus.dispatching => const Color(0xFFB45309),
    PayrollPayslipDistributionStatus.needsAttention => const Color(0xFFB91C1C),
    PayrollPayslipDistributionStatus.complete => const Color(0xFF15803D),
  };
}

IconData _summaryStatusIcon(PayrollPayslipDistributionStatus status) {
  return switch (status) {
    PayrollPayslipDistributionStatus.waitingForPublish =>
      Icons.schedule_outlined,
    PayrollPayslipDistributionStatus.ready => Icons.playlist_add_check_outlined,
    PayrollPayslipDistributionStatus.dispatching => Icons.sync_outlined,
    PayrollPayslipDistributionStatus.needsAttention =>
      Icons.warning_amber_outlined,
    PayrollPayslipDistributionStatus.complete => Icons.verified_outlined,
  };
}

Color _lineStatusColor(PayrollPayslipDistributionLineStatus status) {
  return switch (status) {
    PayrollPayslipDistributionLineStatus.waitingForPublish => const Color(
      0xFF64748B,
    ),
    PayrollPayslipDistributionLineStatus.readyToSend => const Color(0xFF2563EB),
    PayrollPayslipDistributionLineStatus.sent => const Color(0xFFB45309),
    PayrollPayslipDistributionLineStatus.failed => const Color(0xFFB91C1C),
    PayrollPayslipDistributionLineStatus.acknowledged => const Color(
      0xFF15803D,
    ),
  };
}

IconData _lineStatusIcon(PayrollPayslipDistributionLineStatus status) {
  return switch (status) {
    PayrollPayslipDistributionLineStatus.waitingForPublish =>
      Icons.schedule_outlined,
    PayrollPayslipDistributionLineStatus.readyToSend => Icons.outbox_outlined,
    PayrollPayslipDistributionLineStatus.sent =>
      Icons.mark_email_unread_outlined,
    PayrollPayslipDistributionLineStatus.failed =>
      Icons.report_problem_outlined,
    PayrollPayslipDistributionLineStatus.acknowledged =>
      Icons.mark_email_read_outlined,
  };
}
