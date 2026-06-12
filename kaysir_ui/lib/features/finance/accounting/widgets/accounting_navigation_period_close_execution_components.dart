import 'package:flutter/material.dart';

import '../models/accounting_workspace_period_close_execution.dart';

class AccountingNavigationPeriodCloseExecution extends StatelessWidget {
  const AccountingNavigationPeriodCloseExecution({
    required this.execution,
    this.onOpenWorkflow,
    this.onReviewNext,
    this.onReviewOwner,
    this.onStepSelected,
    this.onCopyOwnerHandoff,
    this.onCopyBrief,
    super.key,
  });

  final AccountingWorkspacePeriodCloseExecution execution;
  final VoidCallback? onOpenWorkflow;
  final VoidCallback? onReviewNext;
  final VoidCallback? onReviewOwner;
  final ValueChanged<AccountingWorkspacePeriodCloseExecutionStep>?
  onStepSelected;
  final VoidCallback? onCopyOwnerHandoff;
  final VoidCallback? onCopyBrief;

  @override
  Widget build(BuildContext context) {
    if (!execution.hasQueues) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _stateAccentColor(colorScheme, execution.state);

    return DecoratedBox(
      key: const ValueKey('accounting-period-close-execution'),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 780;
            final heading = _PeriodCloseExecutionHeading(
              execution: execution,
              accentColor: accentColor,
              onCopyBrief: onCopyBrief,
            );
            final actions = _PeriodCloseExecutionActions(
              execution: execution,
              accentColor: accentColor,
              onOpenWorkflow: onOpenWorkflow,
              onReviewNext: execution.hasReviewAction ? onReviewNext : null,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [heading, const SizedBox(height: 10), actions],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: heading),
                      const SizedBox(width: 14),
                      actions,
                    ],
                  ),
                const SizedBox(height: 10),
                _PeriodCloseExecutionProgress(
                  execution: execution,
                  accentColor: accentColor,
                ),
                if (execution.ownerHandoff != null) ...[
                  const SizedBox(height: 10),
                  _PeriodCloseExecutionOwnerHandoff(
                    handoff: execution.ownerHandoff!,
                    accentColor: accentColor,
                    onReviewOwner: onReviewOwner,
                    onCopyOwnerHandoff: onCopyOwnerHandoff,
                  ),
                ],
                const SizedBox(height: 10),
                _PeriodCloseExecutionSteps(
                  steps: execution.steps,
                  onStepSelected: onStepSelected,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PeriodCloseExecutionHeading extends StatelessWidget {
  const _PeriodCloseExecutionHeading({
    required this.execution,
    required this.accentColor,
    required this.onCopyBrief,
  });

  final AccountingWorkspacePeriodCloseExecution execution;
  final Color accentColor;
  final VoidCallback? onCopyBrief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(Icons.lock_clock_rounded, color: accentColor, size: 18),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period Close Execution',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                execution.statusLabel,
                key: const ValueKey('accounting-period-close-execution-status'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                execution.detailLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          key: const ValueKey('accounting-period-close-execution-copy'),
          tooltip: 'Copy period close execution brief',
          visualDensity: VisualDensity.compact,
          iconSize: 17,
          onPressed: onCopyBrief,
          icon: Icon(Icons.copy_rounded, color: accentColor),
        ),
      ],
    );
  }
}

class _PeriodCloseExecutionActions extends StatelessWidget {
  const _PeriodCloseExecutionActions({
    required this.execution,
    required this.accentColor,
    required this.onOpenWorkflow,
    required this.onReviewNext,
  });

  final AccountingWorkspacePeriodCloseExecution execution;
  final Color accentColor;
  final VoidCallback? onOpenWorkflow;
  final VoidCallback? onReviewNext;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (onReviewNext != null)
          TextButton.icon(
            key: const ValueKey('accounting-period-close-execution-review'),
            onPressed: onReviewNext,
            icon: const Icon(Icons.manage_search_rounded, size: 16),
            label: Text(execution.reviewActionLabel ?? 'Review next'),
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              visualDensity: VisualDensity.compact,
            ),
          ),
        FilledButton.icon(
          key: const ValueKey('accounting-period-close-execution-open'),
          onPressed: onOpenWorkflow,
          icon: const Icon(Icons.playlist_add_check_rounded, size: 16),
          label: Text(execution.primaryActionLabel),
          style: FilledButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _PeriodCloseExecutionProgress extends StatelessWidget {
  const _PeriodCloseExecutionProgress({
    required this.execution,
    required this.accentColor,
  });

  final AccountingWorkspacePeriodCloseExecution execution;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: execution.progressValue,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                color: accentColor,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              execution.progressLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PeriodCloseExecutionPill(
              label: execution.stepSummaryLabel,
              color: accentColor,
            ),
            _PeriodCloseExecutionPill(
              label: execution.attentionLabel,
              color: colorScheme.tertiary,
            ),
          ],
        ),
      ],
    );
  }
}

class _PeriodCloseExecutionOwnerHandoff extends StatelessWidget {
  const _PeriodCloseExecutionOwnerHandoff({
    required this.handoff,
    required this.accentColor,
    required this.onReviewOwner,
    required this.onCopyOwnerHandoff,
  });

  final AccountingWorkspacePeriodCloseExecutionOwnerHandoff handoff;
  final Color accentColor;
  final VoidCallback? onReviewOwner;
  final VoidCallback? onCopyOwnerHandoff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      key: const ValueKey('accounting-period-close-execution-owner-handoff'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.assignment_ind_rounded,
                  color: accentColor,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owner handoff: ${handoff.ownerLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${handoff.riskLabel} · ${handoff.loadLabel}',
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
            const SizedBox(width: 8),
            IconButton(
              key: const ValueKey(
                'accounting-period-close-execution-owner-copy',
              ),
              tooltip: 'Copy owner handoff brief',
              visualDensity: VisualDensity.compact,
              iconSize: 17,
              onPressed: onCopyOwnerHandoff,
              icon: Icon(Icons.copy_rounded, color: accentColor),
            ),
            const SizedBox(width: 2),
            TextButton.icon(
              key: const ValueKey(
                'accounting-period-close-execution-owner-review',
              ),
              onPressed: onReviewOwner,
              icon: const Icon(Icons.filter_alt_rounded, size: 16),
              label: Text(handoff.actionLabel),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodCloseExecutionSteps extends StatelessWidget {
  const _PeriodCloseExecutionSteps({
    required this.steps,
    required this.onStepSelected,
  });

  final List<AccountingWorkspacePeriodCloseExecutionStep> steps;
  final ValueChanged<AccountingWorkspacePeriodCloseExecutionStep>?
  onStepSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final step in steps)
          _PeriodCloseExecutionStepChip(
            step: step,
            color: _stepStatusColor(colorScheme, step.status),
            onSelected:
                onStepSelected == null ? null : () => onStepSelected!(step),
          ),
      ],
    );
  }
}

class _PeriodCloseExecutionStepChip extends StatelessWidget {
  const _PeriodCloseExecutionStepChip({
    required this.step,
    required this.color,
    required this.onSelected,
  });

  final AccountingWorkspacePeriodCloseExecutionStep step;
  final Color color;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        child: Row(
          children: [
            Icon(_stepStatusIcon(step.status), size: 15, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.status.label,
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
    );

    return ConstrainedBox(
      key: ValueKey('accounting-period-close-execution-step-${step.id}'),
      constraints: const BoxConstraints(maxWidth: 230),
      child:
          onSelected == null
              ? content
              : Tooltip(
                message: 'Review ${step.label.toLowerCase()}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onSelected,
                  child: content,
                ),
              ),
    );
  }
}

class _PeriodCloseExecutionPill extends StatelessWidget {
  const _PeriodCloseExecutionPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

Color _stateAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspacePeriodCloseExecutionState state,
) {
  switch (state) {
    case AccountingWorkspacePeriodCloseExecutionState.ready:
      return colorScheme.primary;
    case AccountingWorkspacePeriodCloseExecutionState.watch:
      return colorScheme.tertiary;
    case AccountingWorkspacePeriodCloseExecutionState.review:
      return colorScheme.secondary;
    case AccountingWorkspacePeriodCloseExecutionState.blocked:
      return colorScheme.error;
  }
}

Color _stepStatusColor(
  ColorScheme colorScheme,
  AccountingWorkspacePeriodCloseExecutionStepStatus status,
) {
  switch (status) {
    case AccountingWorkspacePeriodCloseExecutionStepStatus.complete:
      return colorScheme.primary;
    case AccountingWorkspacePeriodCloseExecutionStepStatus.active:
      return colorScheme.tertiary;
    case AccountingWorkspacePeriodCloseExecutionStepStatus.queued:
      return colorScheme.secondary;
    case AccountingWorkspacePeriodCloseExecutionStepStatus.blocked:
      return colorScheme.error;
  }
}

IconData _stepStatusIcon(
  AccountingWorkspacePeriodCloseExecutionStepStatus status,
) {
  switch (status) {
    case AccountingWorkspacePeriodCloseExecutionStepStatus.complete:
      return Icons.check_circle_rounded;
    case AccountingWorkspacePeriodCloseExecutionStepStatus.active:
      return Icons.radio_button_checked_rounded;
    case AccountingWorkspacePeriodCloseExecutionStepStatus.queued:
      return Icons.schedule_rounded;
    case AccountingWorkspacePeriodCloseExecutionStepStatus.blocked:
      return Icons.block_rounded;
  }
}
