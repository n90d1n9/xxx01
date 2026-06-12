import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollInputChangePanel extends StatelessWidget {
  final PayrollInputChangeSummary summary;
  final VoidCallback onApproveReady;
  final VoidCallback onApplyApproved;
  final VoidCallback onReopen;

  const PayrollInputChangePanel({
    super.key,
    required this.summary,
    required this.onApproveReady,
    required this.onApplyApproved,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.input_outlined,
      title: 'Payroll input changes',
      subtitle:
          summary.selectedEmployeeId == null
              ? '${summary.lines.length} pending inputs'
              : '${summary.visibleLines.length} selected employee inputs',
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
                          icon: Icons.pending_actions_outlined,
                          label: '${summary.pendingCount} pending',
                        ),
                        _MetaChip(
                          icon: Icons.task_alt_outlined,
                          label: '${summary.approvedCount} approved',
                        ),
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: payrollCurrencyFormat.format(
                            summary.grossImpact,
                          ),
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
                            summary.appliedCount > 0 ||
                                    summary.approvedCount > 0
                                ? onReopen
                                : null,
                        icon: const Icon(Icons.undo_outlined),
                        label: const Text('Reopen'),
                      ),
                      OutlinedButton.icon(
                        onPressed: summary.canApply ? onApplyApproved : null,
                        icon: const Icon(Icons.playlist_add_check_outlined),
                        label: const Text('Apply'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: summary.canApprove ? onApproveReady : null,
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('Approve'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: summary.readinessRate,
                color: statusColor,
                label:
                    '${(summary.readinessRate * 100).round()}% ready for payroll',
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
        if (summary.visibleLines.isEmpty)
          const HrisEmptyState(
            message: 'No payroll input changes for the selected employee',
          )
        else
          for (final line in summary.visibleLines)
            _InputChangeLineTile(line: line),
      ],
    );
  }
}

class _InputChangeLineTile extends StatelessWidget {
  final PayrollInputChangeLine line;

  const _InputChangeLineTile({required this.line});

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
            child: Icon(_statusIcon(line.status), color: color, size: 20),
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
                            line.request.type.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${line.employeeName} - ${line.position}',
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
                      icon: Icons.source_outlined,
                      label: line.request.sourceLabel,
                    ),
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.payrollImpact),
                    ),
                    _MetaChip(
                      icon: Icons.description_outlined,
                      label:
                          line.request.hasSupportingDocument
                              ? 'Documented'
                              : 'Needs document',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.nextAction,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        line.hasBlockers
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

Color _statusColor(PayrollInputChangeStatus status) {
  return switch (status) {
    PayrollInputChangeStatus.blocked => const Color(0xFFB91C1C),
    PayrollInputChangeStatus.pending => const Color(0xFFB45309),
    PayrollInputChangeStatus.approved => const Color(0xFF2563EB),
    PayrollInputChangeStatus.applied => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollInputChangeStatus status) {
  return switch (status) {
    PayrollInputChangeStatus.blocked => Icons.warning_amber_outlined,
    PayrollInputChangeStatus.pending => Icons.pending_actions_outlined,
    PayrollInputChangeStatus.approved => Icons.fact_check_outlined,
    PayrollInputChangeStatus.applied => Icons.verified_outlined,
  };
}
