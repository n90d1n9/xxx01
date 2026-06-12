import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_risk_summary.dart';

class AccountingNavigationWorkQueueRiskSummaryPanel extends StatelessWidget {
  const AccountingNavigationWorkQueueRiskSummaryPanel({
    required this.summary,
    super.key,
  });

  final AccountingWorkspaceWorkQueueRiskSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _riskContentColor(colorScheme, summary.level);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.query_stats_rounded,
                  color: colorScheme.primary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Risk & materiality',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                _RiskScoreBadge(summary: summary),
              ],
            ),
            const SizedBox(height: 9),
            _RiskLine(
              icon: Icons.warning_amber_rounded,
              label: 'Exposure',
              value: summary.exposureLabel,
              color: accentColor,
            ),
            const SizedBox(height: 7),
            _RiskLine(
              icon: Icons.balance_rounded,
              label: 'Materiality',
              value: summary.materialityLabel,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 7),
            _RiskLine(
              icon: Icons.security_rounded,
              label: 'Control risk',
              value: summary.controlRiskLabel,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 7),
            _RiskLine(
              icon: Icons.fact_check_rounded,
              label: 'Audit response',
              value: summary.auditResponse,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskScoreBadge extends StatelessWidget {
  const _RiskScoreBadge({required this.summary});

  final AccountingWorkspaceWorkQueueRiskSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final containerColor = _riskContainerColor(colorScheme, summary.level);
    final contentColor = _riskContentColor(colorScheme, summary.level);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          '${summary.levelLabel} ${summary.score}/100',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RiskLine extends StatelessWidget {
  const _RiskLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color _riskContainerColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueRiskLevel level,
) {
  switch (level) {
    case AccountingWorkspaceWorkQueueRiskLevel.critical:
    case AccountingWorkspaceWorkQueueRiskLevel.high:
      return colorScheme.errorContainer;
    case AccountingWorkspaceWorkQueueRiskLevel.medium:
      return colorScheme.secondaryContainer;
    case AccountingWorkspaceWorkQueueRiskLevel.low:
      return colorScheme.tertiaryContainer;
  }
}

Color _riskContentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueRiskLevel level,
) {
  switch (level) {
    case AccountingWorkspaceWorkQueueRiskLevel.critical:
    case AccountingWorkspaceWorkQueueRiskLevel.high:
      return colorScheme.onErrorContainer;
    case AccountingWorkspaceWorkQueueRiskLevel.medium:
      return colorScheme.onSecondaryContainer;
    case AccountingWorkspaceWorkQueueRiskLevel.low:
      return colorScheme.onTertiaryContainer;
  }
}
