import 'package:flutter/material.dart';

import '../models/accounting_workspace_close_command_center.dart';

class AccountingNavigationCloseCommandCenter extends StatelessWidget {
  const AccountingNavigationCloseCommandCenter({
    required this.commandCenter,
    this.activeGateId,
    this.onCopyBrief,
    this.onGateSelected,
    this.onReviewNext,
    super.key,
  });

  final AccountingWorkspaceCloseCommandCenter commandCenter;
  final String? activeGateId;
  final VoidCallback? onCopyBrief;
  final ValueChanged<AccountingWorkspaceCloseCommandCenterGateCheck>?
  onGateSelected;
  final VoidCallback? onReviewNext;

  @override
  Widget build(BuildContext context) {
    if (!commandCenter.hasQueues) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _stateAccentColor(colorScheme, commandCenter.state);

    return DecoratedBox(
      key: const ValueKey('accounting-close-command-center'),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final heading = _CommandCenterHeading(
              accentColor: accentColor,
              readinessLabel: commandCenter.readinessLabel,
              onCopyBrief: onCopyBrief,
            );
            final decision = _CommandCenterDecision(
              commandCenter: commandCenter,
              accentColor: accentColor,
              onReviewNext: commandCenter.hasNextAction ? onReviewNext : null,
            );
            final gates = _CommandCenterGateChecks(
              commandCenter: commandCenter,
              activeGateId: activeGateId,
              onGateSelected: onGateSelected,
            );
            final metrics = _CommandCenterMetrics(commandCenter: commandCenter);

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading,
                  const SizedBox(height: 10),
                  decision,
                  const SizedBox(height: 10),
                  gates,
                  const SizedBox(height: 10),
                  metrics,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: heading),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: decision),
                  ],
                ),
                const SizedBox(height: 10),
                gates,
                const SizedBox(height: 10),
                metrics,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommandCenterHeading extends StatelessWidget {
  const _CommandCenterHeading({
    required this.accentColor,
    required this.readinessLabel,
    required this.onCopyBrief,
  });

  final Color accentColor;
  final String readinessLabel;
  final VoidCallback? onCopyBrief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              Icons.display_settings_rounded,
              color: accentColor,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Close Command Center',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                readinessLabel,
                key: const ValueKey('accounting-close-command-readiness'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          key: const ValueKey('accounting-close-command-copy-brief'),
          tooltip: 'Copy close decision brief',
          visualDensity: VisualDensity.compact,
          iconSize: 17,
          onPressed: onCopyBrief,
          icon: Icon(Icons.copy_rounded, color: accentColor),
        ),
      ],
    );
  }
}

class _CommandCenterDecision extends StatelessWidget {
  const _CommandCenterDecision({
    required this.commandCenter,
    required this.accentColor,
    required this.onReviewNext,
  });

  final AccountingWorkspaceCloseCommandCenter commandCenter;
  final Color accentColor;
  final VoidCallback? onReviewNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commandCenter.decisionLabel,
                key: const ValueKey('accounting-close-command-decision'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                commandCenter.decisionDetailLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                commandCenter.primaryActionLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (commandCenter.hasNextAction) ...[
                const SizedBox(height: 5),
                Text(
                  commandCenter.nextActionLabel,
                  key: const ValueKey('accounting-close-command-next-action'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onReviewNext != null) ...[
          const SizedBox(width: 12),
          Tooltip(
            message: 'Review highest-ranked close action',
            child: TextButton.icon(
              key: const ValueKey('accounting-close-command-review-next'),
              onPressed: onReviewNext,
              icon: const Icon(Icons.manage_search_rounded, size: 16),
              label: const Text('Review next'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CommandCenterGateChecks extends StatelessWidget {
  const _CommandCenterGateChecks({
    required this.commandCenter,
    required this.activeGateId,
    required this.onGateSelected,
  });

  final AccountingWorkspaceCloseCommandCenter commandCenter;
  final String? activeGateId;
  final ValueChanged<AccountingWorkspaceCloseCommandCenterGateCheck>?
  onGateSelected;

  @override
  Widget build(BuildContext context) {
    if (!commandCenter.hasGateChecks) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final gate in commandCenter.gateChecks)
          _CommandCenterGateChip(
            key: ValueKey('accounting-close-command-gate-${gate.id}'),
            gate: gate,
            isActive: gate.id == activeGateId,
            onSelected:
                gate.status ==
                            AccountingWorkspaceCloseCommandCenterGateStatus
                                .clear ||
                        onGateSelected == null
                    ? null
                    : () => onGateSelected!(gate),
          ),
      ],
    );
  }
}

class _CommandCenterGateChip extends StatelessWidget {
  const _CommandCenterGateChip({
    super.key,
    required this.gate,
    required this.isActive,
    required this.onSelected,
  });

  final AccountingWorkspaceCloseCommandCenterGateCheck gate;
  final bool isActive;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _gateStatusColor(colorScheme, gate.status);

    final chip = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isActive ? 0.16 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withValues(alpha: isActive ? 0.7 : 0.28),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            children: [
              Icon(_gateStatusIcon(gate.status), color: accentColor, size: 15),
              const SizedBox(width: 6),
              Text(
                gate.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                gate.statusLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  gate.detailLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle_rounded,
                  key: ValueKey(
                    'accounting-close-command-gate-${gate.id}-active',
                  ),
                  color: accentColor,
                  size: 15,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (onSelected == null) return chip;

    return Tooltip(
      message:
          isActive
              ? 'Clear ${gate.label.toLowerCase()} gate review'
              : 'Review ${gate.label.toLowerCase()} gate',
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: chip,
      ),
    );
  }
}

class _CommandCenterMetrics extends StatelessWidget {
  const _CommandCenterMetrics({required this.commandCenter});

  final AccountingWorkspaceCloseCommandCenter commandCenter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _CommandCenterMetric(
          key: const ValueKey('accounting-close-command-open'),
          icon: Icons.pending_actions_rounded,
          label: 'Open',
          valueLabel: commandCenter.openValueLabel,
          detailLabel: commandCenter.openDetailLabel,
          accentColor: colorScheme.primary,
        ),
        _CommandCenterMetric(
          key: const ValueKey('accounting-close-command-evidence'),
          icon: Icons.fact_check_rounded,
          label: 'Evidence',
          valueLabel: commandCenter.evidenceValueLabel,
          detailLabel: commandCenter.evidenceDetailLabel,
          accentColor: colorScheme.error,
        ),
        _CommandCenterMetric(
          key: const ValueKey('accounting-close-command-posting'),
          icon: Icons.rule_rounded,
          label: 'Posting',
          valueLabel: commandCenter.postingValueLabel,
          detailLabel: commandCenter.postingDetailLabel,
          accentColor: colorScheme.secondary,
        ),
        _CommandCenterMetric(
          key: const ValueKey('accounting-close-command-owner'),
          icon: Icons.person_search_rounded,
          label: 'Owner',
          valueLabel: commandCenter.ownerValueLabel,
          detailLabel: commandCenter.ownerDetailLabel,
          accentColor: colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _CommandCenterMetric extends StatelessWidget {
  const _CommandCenterMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.detailLabel,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final String detailLabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(icon, color: accentColor, size: 16),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valueLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detailLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _stateAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceCloseCommandCenterState state,
) {
  switch (state) {
    case AccountingWorkspaceCloseCommandCenterState.ready:
      return colorScheme.tertiary;
    case AccountingWorkspaceCloseCommandCenterState.watch:
      return colorScheme.secondary;
    case AccountingWorkspaceCloseCommandCenterState.managementReview:
      return colorScheme.primary;
    case AccountingWorkspaceCloseCommandCenterState.blocked:
      return colorScheme.error;
  }
}

Color _gateStatusColor(
  ColorScheme colorScheme,
  AccountingWorkspaceCloseCommandCenterGateStatus status,
) {
  switch (status) {
    case AccountingWorkspaceCloseCommandCenterGateStatus.clear:
      return colorScheme.tertiary;
    case AccountingWorkspaceCloseCommandCenterGateStatus.watch:
      return colorScheme.secondary;
    case AccountingWorkspaceCloseCommandCenterGateStatus.blocked:
      return colorScheme.error;
  }
}

IconData _gateStatusIcon(
  AccountingWorkspaceCloseCommandCenterGateStatus status,
) {
  switch (status) {
    case AccountingWorkspaceCloseCommandCenterGateStatus.clear:
      return Icons.check_circle_rounded;
    case AccountingWorkspaceCloseCommandCenterGateStatus.watch:
      return Icons.visibility_rounded;
    case AccountingWorkspaceCloseCommandCenterGateStatus.blocked:
      return Icons.lock_rounded;
  }
}
