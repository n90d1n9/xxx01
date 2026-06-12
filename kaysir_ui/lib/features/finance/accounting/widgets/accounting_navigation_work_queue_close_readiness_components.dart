import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_close_readiness.dart';

class AccountingNavigationWorkQueueCloseReadinessStrip extends StatelessWidget {
  const AccountingNavigationWorkQueueCloseReadinessStrip({
    required this.readiness,
    this.onCopyBrief,
    this.onNextActionSelected,
    super.key,
  });

  final AccountingWorkspaceWorkQueueCloseReadiness readiness;
  final VoidCallback? onCopyBrief;
  final VoidCallback? onNextActionSelected;

  @override
  Widget build(BuildContext context) {
    if (!readiness.hasQueues) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final blocked = readiness.hasReleaseBlockers;
    final containerColor =
        blocked ? colorScheme.errorContainer : colorScheme.surfaceContainerLow;
    final contentColor =
        blocked ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerColor,
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
                Icon(Icons.flag_rounded, color: contentColor, size: 17),
                const SizedBox(width: 7),
                Text(
                  'Close readiness',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  readiness.statusLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey(
                    'accounting-work-queue-readiness-copy-plan',
                  ),
                  tooltip: 'Copy close readiness plan',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCopyBrief,
                  icon: Icon(Icons.copy_rounded, color: contentColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              readiness.actionLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _CloseReadinessDriverLine(
              label: readiness.primaryDriverLabel,
              detail: readiness.primaryDriverDetailLabel,
              contentColor: contentColor,
            ),
            if (readiness.nextAction != null) ...[
              const SizedBox(height: 8),
              _CloseReadinessNextActionRow(
                action: readiness.nextAction!,
                actionCount: readiness.actionPlanCount,
                contentColor: contentColor,
                onSelected: onNextActionSelected,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _CloseReadinessMetric(
                  key: const ValueKey('accounting-work-queue-readiness-score'),
                  label: readiness.lockGateLabel,
                  valueLabel: readiness.scoreLabel,
                  contentColor: contentColor,
                ),
                _CloseReadinessMetric(
                  key: const ValueKey(
                    'accounting-work-queue-readiness-blockers',
                  ),
                  label: 'Blockers',
                  valueLabel: '${readiness.releaseBlockerItems}',
                  contentColor: contentColor,
                ),
                _CloseReadinessMetric(
                  key: const ValueKey(
                    'accounting-work-queue-readiness-evidence',
                  ),
                  label: 'Evidence',
                  valueLabel: '${readiness.evidenceRequestItems}',
                  contentColor: contentColor,
                ),
                _CloseReadinessMetric(
                  key: const ValueKey(
                    'accounting-work-queue-readiness-posting',
                  ),
                  label: 'Posting',
                  valueLabel: '${readiness.postingGateItems}',
                  contentColor: contentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseReadinessNextActionRow extends StatelessWidget {
  const _CloseReadinessNextActionRow({
    required this.action,
    required this.actionCount,
    required this.contentColor,
    required this.onSelected,
  });

  final AccountingWorkspaceWorkQueueCloseReadinessNextAction action;
  final int actionCount;
  final Color contentColor;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      key: const ValueKey('accounting-work-queue-readiness-next-action'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.next_plan_rounded, color: contentColor, size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                action.previewLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: contentColor.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (actionCount > 1) ...[
          Text(
            '$actionCount actions',
            style: theme.textTheme.labelSmall?.copyWith(
              color: contentColor.withValues(alpha: 0.74),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
        ],
        TextButton.icon(
          key: const ValueKey('accounting-work-queue-readiness-review-next'),
          onPressed: onSelected,
          icon: const Icon(Icons.manage_search_rounded, size: 16),
          label: const Text('Review next'),
          style: TextButton.styleFrom(
            foregroundColor: contentColor,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _CloseReadinessDriverLine extends StatelessWidget {
  const _CloseReadinessDriverLine({
    required this.label,
    required this.detail,
    required this.contentColor,
  });

  final String label;
  final String detail;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.trending_down_rounded, color: contentColor, size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '$label · $detail',
            style: theme.textTheme.bodySmall?.copyWith(
              color: contentColor.withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CloseReadinessMetric extends StatelessWidget {
  const _CloseReadinessMetric({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.contentColor,
  });

  final String label;
  final String valueLabel;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          valueLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: contentColor.withValues(alpha: 0.78),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
