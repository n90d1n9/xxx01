import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/work_queue_close_packet_evidence_summary.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_resolution_summary.dart';

/// Compact dashboard strip for accounting work queue resolution progress.
class AccountingNavigationWorkQueueResolutionSummaryStrip
    extends StatelessWidget {
  const AccountingNavigationWorkQueueResolutionSummaryStrip({
    required this.summary,
    this.filter = AccountingWorkspaceWorkQueueResolutionFilter.all,
    this.evidenceSummary,
    this.nextAction,
    this.onCopyBrief,
    this.onFilterChanged,
    this.onNextActionSelected,
    super.key,
  });

  final AccountingWorkspaceWorkQueueResolutionSummary summary;
  final AccountingWorkspaceWorkQueueResolutionFilter filter;
  final AccountingWorkspaceWorkQueueClosePacketEvidenceSummary? evidenceSummary;
  final AccountingWorkspaceWorkQueueResolutionNextAction? nextAction;
  final VoidCallback? onCopyBrief;
  final ValueChanged<AccountingWorkspaceWorkQueueResolutionFilter>?
  onFilterChanged;
  final VoidCallback? onNextActionSelected;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasQueues) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _summaryAccentColor(colorScheme, summary);
    final effectiveNextAction = nextAction ?? summary.nextAction;
    bool isFilterAvailable(AccountingWorkspaceWorkQueueResolutionFilter value) {
      return filter == value || value.countFor(summary) > 0;
    }

    VoidCallback? filterCallback(
      AccountingWorkspaceWorkQueueResolutionFilter value,
    ) {
      final handler = onFilterChanged;
      if (handler == null) return null;
      if (!isFilterAvailable(value)) return null;

      return () {
        handler(
          filter == value
              ? AccountingWorkspaceWorkQueueResolutionFilter.all
              : value,
        );
      };
    }

    Widget metricPill({
      required ValueKey<String> key,
      required AccountingWorkspaceWorkQueueResolutionFilter value,
      required IconData icon,
      required Color containerColor,
      required Color contentColor,
    }) {
      return _ResolutionMetricPill(
        key: key,
        icon: icon,
        valueLabel: '${value.countFor(summary)}',
        label: value.label,
        containerColor: containerColor,
        contentColor: contentColor,
        isSelected: filter == value,
        isEnabled: isFilterAvailable(value),
        onSelected: filterCallback(value),
      );
    }

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-resolution-summary'),
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
                Icon(Icons.task_alt_rounded, color: accentColor, size: 17),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Resolution',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 168),
                  child: Text(
                    summary.statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey(
                    'accounting-work-queue-resolution-copy-brief',
                  ),
                  tooltip: 'Copy close packet',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCopyBrief,
                  icon: Icon(Icons.copy_rounded, color: accentColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: summary.clearanceRatio,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    summary.detailLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  summary.clearanceScoreLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            if (evidenceSummary case final posture? when posture.hasQueues) ...[
              _ResolutionEvidencePostureRow(summary: posture),
              const SizedBox(height: 9),
            ],
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                metricPill(
                  key: const ValueKey('accounting-work-queue-resolution-all'),
                  value: AccountingWorkspaceWorkQueueResolutionFilter.all,
                  icon: Icons.select_all_rounded,
                  containerColor: colorScheme.surfaceContainerHighest,
                  contentColor: colorScheme.onSurfaceVariant,
                ),
                metricPill(
                  key: const ValueKey(
                    'accounting-work-queue-resolution-cleared',
                  ),
                  value: AccountingWorkspaceWorkQueueResolutionFilter.cleared,
                  icon: Icons.check_circle_rounded,
                  containerColor: colorScheme.tertiaryContainer,
                  contentColor: colorScheme.onTertiaryContainer,
                ),
                metricPill(
                  key: const ValueKey('accounting-work-queue-resolution-ready'),
                  value: AccountingWorkspaceWorkQueueResolutionFilter.ready,
                  icon: Icons.playlist_add_check_circle_rounded,
                  containerColor: colorScheme.primaryContainer,
                  contentColor: colorScheme.onPrimaryContainer,
                ),
                metricPill(
                  key: const ValueKey('accounting-work-queue-resolution-open'),
                  value: AccountingWorkspaceWorkQueueResolutionFilter.open,
                  icon: Icons.pending_actions_rounded,
                  containerColor: colorScheme.surfaceContainerHighest,
                  contentColor: colorScheme.onSurfaceVariant,
                ),
                if (summary.hasBlockedQueues)
                  metricPill(
                    key: const ValueKey(
                      'accounting-work-queue-resolution-blocked',
                    ),
                    value: AccountingWorkspaceWorkQueueResolutionFilter.blocked,
                    icon: Icons.report_problem_rounded,
                    containerColor: colorScheme.errorContainer,
                    contentColor: colorScheme.onErrorContainer,
                  ),
              ],
            ),
            if (!filter.isDefault) ...[
              const SizedBox(height: 9),
              _ResolutionActiveFilterRow(
                filter: filter,
                onClear: filterCallback(
                  AccountingWorkspaceWorkQueueResolutionFilter.all,
                ),
              ),
            ],
            if (effectiveNextAction != null) ...[
              const SizedBox(height: 9),
              _ResolutionNextActionRow(
                action: effectiveNextAction,
                onSelected: onNextActionSelected,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Work queue resolution summary')
Widget workQueueResolutionSummaryStripPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: AccountingNavigationWorkQueueResolutionSummaryStrip(
          summary: AccountingWorkspaceWorkQueueResolutionSummary(
            queueCount: 4,
            clearedQueueCount: 1,
            readyToClearQueueCount: 2,
            blockedQueueCount: 1,
            waitingQueueCount: 0,
            nextAction: AccountingWorkspaceWorkQueueResolutionNextAction(
              queueId: 'ready-evidence-pack',
              title: 'Ready evidence pack',
              statusLabel: 'Ready to clear',
              actionLabel: 'Mark queue cleared',
              ownerLabel: 'Controller',
              dueLabel: 'Due today',
            ),
          ),
          evidenceSummary:
              AccountingWorkspaceWorkQueueClosePacketEvidenceSummary(
                queueCount: 4,
                readyQueueCount: 2,
                reviewNeededQueueCount: 1,
                reworkQueueCount: 1,
                partialQueueCount: 0,
                missingQueueCount: 0,
                requestedEvidenceCount: 8,
                linkedEvidenceCount: 7,
                acceptedEvidenceCount: 5,
                pendingReviewCount: 1,
                reworkEvidenceCount: 1,
              ),
        ),
      ),
    ),
  );
}

/// Active filter notice with a direct path back to the full queue list.
class _ResolutionActiveFilterRow extends StatelessWidget {
  const _ResolutionActiveFilterRow({
    required this.filter,
    required this.onClear,
  });

  final AccountingWorkspaceWorkQueueResolutionFilter filter;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-resolution-active-filter'),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_rounded,
              color: colorScheme.primary,
              size: 15,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                '${filter.label} filter active',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              key: const ValueKey(
                'accounting-work-queue-resolution-clear-filter',
              ),
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 15),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                visualDensity: VisualDensity.compact,
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact evidence posture signal for the active resolution packet.
class _ResolutionEvidencePostureRow extends StatelessWidget {
  const _ResolutionEvidencePostureRow({required this.summary});

  final AccountingWorkspaceWorkQueueClosePacketEvidenceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _evidenceAccentColor(colorScheme, summary);

    return DecoratedBox(
      key: const ValueKey('accounting-work-queue-resolution-evidence-posture'),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Row(
          children: [
            Icon(Icons.fact_check_rounded, color: accentColor, size: 15),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${summary.coverageLabel} · ${summary.linkReviewLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _actionNeededLabel(summary.actionNeededQueueCount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable count pill used for resolution filter shortcuts.
class _ResolutionMetricPill extends StatelessWidget {
  const _ResolutionMetricPill({
    super.key,
    required this.icon,
    required this.valueLabel,
    required this.label,
    required this.containerColor,
    required this.contentColor,
    required this.isSelected,
    required this.isEnabled,
    this.onSelected,
  });

  final IconData icon;
  final String valueLabel;
  final String label;
  final Color containerColor;
  final Color contentColor;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveContainerColor =
        isEnabled
            ? containerColor
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.62);
    final effectiveContentColor =
        isEnabled
            ? contentColor
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.48);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveContainerColor,
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected
                ? Border.all(
                  color: effectiveContentColor.withValues(alpha: 0.72),
                )
                : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isEnabled ? onSelected : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: effectiveContentColor, size: 15),
              const SizedBox(width: 6),
              Text(
                valueLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: effectiveContentColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: effectiveContentColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline review handoff for the next queue requiring user attention.
class _ResolutionNextActionRow extends StatelessWidget {
  const _ResolutionNextActionRow({
    required this.action,
    required this.onSelected,
  });

  final AccountingWorkspaceWorkQueueResolutionNextAction action;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      key: const ValueKey('accounting-work-queue-resolution-next-action'),
      children: [
        Icon(
          Icons.manage_search_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 16,
        ),
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
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                action.previewLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          key: const ValueKey('accounting-work-queue-resolution-review-next'),
          onPressed: onSelected,
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: const Text('Review'),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }
}

String _actionNeededLabel(int count) =>
    count == 1 ? '1 action' : '$count actions';

Color _summaryAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueResolutionSummary summary,
) {
  if (summary.isFullyCleared || summary.hasReadyToClearQueues) {
    return colorScheme.tertiary;
  }
  if (summary.hasBlockedQueues) return colorScheme.error;

  return colorScheme.primary;
}

Color _evidenceAccentColor(
  ColorScheme colorScheme,
  AccountingWorkspaceWorkQueueClosePacketEvidenceSummary summary,
) {
  if (summary.isFullyReady) return colorScheme.tertiary;
  if (summary.reworkQueueCount > 0 || summary.missingQueueCount > 0) {
    return colorScheme.error;
  }

  return colorScheme.secondary;
}
