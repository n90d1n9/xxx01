import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollExceptionResolutionPanel extends StatelessWidget {
  final PayrollExceptionResolutionSummary summary;

  const PayrollExceptionResolutionPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.manage_search_outlined,
      title: 'Exception resolution',
      subtitle: 'Cross-module payroll blockers',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(
                    label: summary.status.label,
                    color: statusColor,
                  ),
                  _MetaChip(
                    icon: Icons.priority_high_outlined,
                    label: '${summary.criticalCount} critical',
                  ),
                  _MetaChip(
                    icon: Icons.warning_amber_outlined,
                    label: '${summary.warningCount} warnings',
                  ),
                  _MetaChip(
                    icon: Icons.payments_outlined,
                    label: payrollCurrencyFormat.format(
                      summary.financialExposure,
                    ),
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
        if (summary.lines.isEmpty)
          const HrisEmptyState(message: 'No payroll exception blockers remain')
        else
          for (final line in summary.lines.take(8))
            _ExceptionResolutionLineTile(line: line),
      ],
    );
  }
}

class _ExceptionResolutionLineTile extends StatelessWidget {
  final PayrollExceptionResolutionLine line;

  const _ExceptionResolutionLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(line.severity);

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
            child: Icon(_severityIcon(line.severity), color: color, size: 20),
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
                            '${line.source.label} - ${line.owner}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.severity.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetaChip(icon: Icons.task_outlined, label: line.action),
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.amount),
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

Color _statusColor(PayrollExceptionResolutionStatus status) {
  return switch (status) {
    PayrollExceptionResolutionStatus.blocked => const Color(0xFFB91C1C),
    PayrollExceptionResolutionStatus.clear => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollExceptionResolutionStatus status) {
  return switch (status) {
    PayrollExceptionResolutionStatus.blocked => Icons.warning_amber_outlined,
    PayrollExceptionResolutionStatus.clear => Icons.verified_outlined,
  };
}

Color _severityColor(PayrollExceptionSeverity severity) {
  return switch (severity) {
    PayrollExceptionSeverity.critical => const Color(0xFFB91C1C),
    PayrollExceptionSeverity.warning => const Color(0xFFB45309),
    PayrollExceptionSeverity.info => const Color(0xFF2563EB),
  };
}

IconData _severityIcon(PayrollExceptionSeverity severity) {
  return switch (severity) {
    PayrollExceptionSeverity.critical => Icons.priority_high_outlined,
    PayrollExceptionSeverity.warning => Icons.warning_amber_outlined,
    PayrollExceptionSeverity.info => Icons.info_outline,
  };
}
