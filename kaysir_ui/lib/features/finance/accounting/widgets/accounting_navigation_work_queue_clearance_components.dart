import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_clearance_checklist.dart';

class AccountingNavigationWorkQueueClearancePanel extends StatelessWidget {
  const AccountingNavigationWorkQueueClearancePanel({
    required this.checklist,
    this.onCopyBrief,
    super.key,
  });

  final AccountingWorkspaceWorkQueueClearanceChecklist checklist;
  final VoidCallback? onCopyBrief;

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
                  Icons.playlist_add_check_rounded,
                  color: colorScheme.primary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Clearance checklist',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  checklist.summaryLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _ClearanceReadinessMeter(
              checklist: checklist,
              onCopyBrief: onCopyBrief,
            ),
            const SizedBox(height: 10),
            for (final step in checklist.steps) ...[
              _ClearanceStepRow(step: step),
              if (step != checklist.steps.last)
                Divider(height: 14, color: colorScheme.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClearanceReadinessMeter extends StatelessWidget {
  const _ClearanceReadinessMeter({
    required this.checklist,
    required this.onCopyBrief,
  });

  final AccountingWorkspaceWorkQueueClearanceChecklist checklist;
  final VoidCallback? onCopyBrief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _readinessAccentColor(colorScheme, checklist);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed_rounded, color: accentColor, size: 16),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    checklist.readinessLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${checklist.readinessPercent}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (onCopyBrief != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    key: const ValueKey(
                      'accounting-work-queue-clearance-copy-brief',
                    ),
                    tooltip: 'Copy clearance plan',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    onPressed: onCopyBrief,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              key: const ValueKey(
                'accounting-work-queue-clearance-readiness-meter',
              ),
              value: checklist.readinessRatio.clamp(0, 1),
              minHeight: 6,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: accentColor,
            ),
            const SizedBox(height: 6),
            Text(
              checklist.nextActionLabel,
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
    );
  }
}

class _ClearanceStepRow extends StatelessWidget {
  const _ClearanceStepRow({required this.step});

  final AccountingWorkspaceWorkQueueClearanceStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final contentColor = _statusContentColor(colorScheme, step.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_statusIcon(step.status), color: contentColor, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(step: step),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                step.ownerLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                step.evidenceLabel,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.step});

  final AccountingWorkspaceWorkQueueClearanceStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _statusContainerColor(colorScheme, step.status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          step.statusLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _statusContentColor(colorScheme, step.status),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

IconData _statusIcon(AccountingWorkspaceWorkQueueClearanceStatus status) {
  switch (status) {
    case AccountingWorkspaceWorkQueueClearanceStatus.blocked:
      return Icons.block_rounded;
    case AccountingWorkspaceWorkQueueClearanceStatus.waiting:
      return Icons.hourglass_top_rounded;
    case AccountingWorkspaceWorkQueueClearanceStatus.ready:
      return Icons.check_circle_rounded;
  }
}

Color _statusContainerColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueClearanceStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueClearanceStatus.blocked:
      return colorScheme.errorContainer;
    case AccountingWorkspaceWorkQueueClearanceStatus.waiting:
      return colorScheme.secondaryContainer;
    case AccountingWorkspaceWorkQueueClearanceStatus.ready:
      return colorScheme.tertiaryContainer;
  }
}

Color _statusContentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueClearanceStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueClearanceStatus.blocked:
      return colorScheme.onErrorContainer;
    case AccountingWorkspaceWorkQueueClearanceStatus.waiting:
      return colorScheme.onSecondaryContainer;
    case AccountingWorkspaceWorkQueueClearanceStatus.ready:
      return colorScheme.onTertiaryContainer;
  }
}

Color _readinessAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueClearanceChecklist checklist,
) {
  if (checklist.blockedCount > 0) return colorScheme.error;
  if (checklist.waitingCount > 0) return colorScheme.secondary;

  return colorScheme.tertiary;
}
