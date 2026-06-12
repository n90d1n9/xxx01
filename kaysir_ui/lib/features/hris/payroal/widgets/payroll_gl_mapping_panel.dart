import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollGlMappingPanel extends StatelessWidget {
  final PayrollGlMappingSummary summary;

  const PayrollGlMappingPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'GL mapping center',
      subtitle: 'Payroll chart of accounts readiness',
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
                    icon: Icons.link_outlined,
                    label:
                        '${summary.mappedCount}/${summary.lines.length} mapped',
                  ),
                  _MetaChip(
                    icon: Icons.account_balance_outlined,
                    label: payrollCurrencyFormat.format(summary.mappedAmount),
                  ),
                  _MetaChip(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${payrollCurrencyFormat.format(summary.unmappedAmount)} unmapped',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: summary.readinessRate,
                color: statusColor,
                label: '${(summary.readinessRate * 100).round()}% GL coverage',
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
        for (final line in summary.lines) _GlMappingLineTile(line: line),
      ],
    );
  }
}

class _GlMappingLineTile extends StatelessWidget {
  final PayrollGlMappingLine line;

  const _GlMappingLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color =
        line.isMapped ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

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
              line.isMapped
                  ? Icons.account_balance_outlined
                  : Icons.link_off_outlined,
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
                            line.sourceLabel,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            line.category.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: line.isMapped ? 'Mapped' : 'Missing',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.account_balance_outlined,
                      label: line.accountLabel,
                    ),
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      label: payrollCurrencyFormat.format(line.amount),
                    ),
                  ],
                ),
                if (!line.isMapped) ...[
                  const SizedBox(height: 8),
                  Text(
                    line.blocker,
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

Color _statusColor(PayrollGlMappingStatus status) {
  return switch (status) {
    PayrollGlMappingStatus.blocked => const Color(0xFFB91C1C),
    PayrollGlMappingStatus.ready => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollGlMappingStatus status) {
  return switch (status) {
    PayrollGlMappingStatus.blocked => Icons.warning_amber_outlined,
    PayrollGlMappingStatus.ready => Icons.verified_outlined,
  };
}
