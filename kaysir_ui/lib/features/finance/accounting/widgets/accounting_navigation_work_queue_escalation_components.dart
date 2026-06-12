import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_escalation_plan.dart';

class AccountingNavigationWorkQueueEscalationPanel extends StatelessWidget {
  const AccountingNavigationWorkQueueEscalationPanel({
    required this.plan,
    super.key,
  });

  final AccountingWorkspaceWorkQueueEscalationPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _tierContentColor(colorScheme, plan.tier);

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
                Icon(Icons.route_rounded, color: colorScheme.primary, size: 17),
                const SizedBox(width: 7),
                Text(
                  'Escalation plan',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                _TierBadge(plan: plan),
              ],
            ),
            const SizedBox(height: 9),
            _EscalationLine(
              icon: Icons.supervisor_account_rounded,
              label: 'Owner path',
              value: plan.escalationOwner,
              color: accentColor,
            ),
            const SizedBox(height: 7),
            _EscalationLine(
              icon: Icons.sync_rounded,
              label: 'Cadence',
              value: plan.cadenceLabel,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 7),
            _EscalationLine(
              icon: Icons.event_busy_rounded,
              label: 'Deadline',
              value: plan.deadlineLabel,
              color: accentColor,
            ),
            const SizedBox(height: 7),
            _EscalationLine(
              icon: Icons.gavel_rounded,
              label: 'Governance',
              value: plan.governanceNote,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.plan});

  final AccountingWorkspaceWorkQueueEscalationPlan plan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final containerColor = _tierContainerColor(colorScheme, plan.tier);
    final contentColor = _tierContentColor(colorScheme, plan.tier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          plan.tierLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EscalationLine extends StatelessWidget {
  const _EscalationLine({
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

Color _tierContainerColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueEscalationTier tier,
) {
  switch (tier) {
    case AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker:
    case AccountingWorkspaceWorkQueueEscalationTier.managementEscalation:
      return colorScheme.errorContainer;
    case AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp:
      return colorScheme.secondaryContainer;
    case AccountingWorkspaceWorkQueueEscalationTier.monitor:
      return colorScheme.tertiaryContainer;
  }
}

Color _tierContentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueEscalationTier tier,
) {
  switch (tier) {
    case AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker:
    case AccountingWorkspaceWorkQueueEscalationTier.managementEscalation:
      return colorScheme.onErrorContainer;
    case AccountingWorkspaceWorkQueueEscalationTier.ownerFollowUp:
      return colorScheme.onSecondaryContainer;
    case AccountingWorkspaceWorkQueueEscalationTier.monitor:
      return colorScheme.onTertiaryContainer;
  }
}
