import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_compliance_guardrail.dart';

class AccountingNavigationWorkQueueCompliancePanel extends StatelessWidget {
  const AccountingNavigationWorkQueueCompliancePanel({
    required this.guardrail,
    super.key,
  });

  final AccountingWorkspaceWorkQueueComplianceGuardrail guardrail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  Icons.assured_workload_rounded,
                  color: colorScheme.primary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Standards & filing',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _ComplianceLine(
              icon: Icons.menu_book_rounded,
              label: 'Framework',
              value: guardrail.frameworkLabel,
            ),
            const SizedBox(height: 7),
            _ComplianceLine(
              icon: Icons.account_balance_rounded,
              label: 'Local rule',
              value: guardrail.localRuleLabel,
            ),
            const SizedBox(height: 7),
            _ComplianceLine(
              icon: Icons.inventory_2_rounded,
              label: 'Retention',
              value: guardrail.retentionLabel,
            ),
            const SizedBox(height: 7),
            _ComplianceLine(
              icon: Icons.outbox_rounded,
              label: 'Filing impact',
              value: guardrail.filingImpactLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplianceLine extends StatelessWidget {
  const _ComplianceLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 16),
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
