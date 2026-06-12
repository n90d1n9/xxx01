import 'package:flutter/material.dart';

import '../models/accounting_workspace_work_queue_sla_summary.dart';

class AccountingNavigationWorkQueueSlaStrip extends StatelessWidget {
  const AccountingNavigationWorkQueueSlaStrip({
    required this.summary,
    super.key,
  });

  final AccountingWorkspaceWorkQueueSlaSummary summary;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasQueues) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer_rounded, color: colorScheme.primary, size: 17),
            const SizedBox(width: 7),
            Text(
              'SLA pressure',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            if (summary.hasTimeSensitiveItems)
              Text(
                '${summary.timeSensitiveItems} time-sensitive',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SlaPressureMetric(
              key: const ValueKey('accounting-work-queue-sla-overdue'),
              icon: Icons.warning_amber_rounded,
              value: summary.overdueItems,
              label: 'Overdue',
              queueCount: summary.overdueQueueCount,
              containerColor: colorScheme.errorContainer,
              contentColor: colorScheme.onErrorContainer,
            ),
            _SlaPressureMetric(
              key: const ValueKey('accounting-work-queue-sla-due-today'),
              icon: Icons.today_rounded,
              value: summary.dueTodayItems,
              label: 'Due today',
              queueCount: summary.dueTodayQueueCount,
              containerColor: colorScheme.secondaryContainer,
              contentColor: colorScheme.onSecondaryContainer,
            ),
            _SlaPressureMetric(
              key: const ValueKey('accounting-work-queue-sla-on-track'),
              icon: Icons.check_circle_rounded,
              value: summary.onTrackItems,
              label: 'On track',
              queueCount: summary.onTrackQueueCount,
              containerColor: colorScheme.tertiaryContainer,
              contentColor: colorScheme.onTertiaryContainer,
            ),
            if (summary.hasOverdueItems)
              _SlaPressureMetric(
                key: const ValueKey('accounting-work-queue-sla-worst-overdue'),
                icon: Icons.history_rounded,
                value: summary.worstOverdueDays,
                label: summary.worstOverdueDays == 1 ? 'Day max' : 'Days max',
                containerColor: colorScheme.surfaceContainerLow,
                contentColor: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ],
    );
  }
}

class _SlaPressureMetric extends StatelessWidget {
  const _SlaPressureMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.containerColor,
    required this.contentColor,
    this.queueCount,
  });

  final IconData icon;
  final int value;
  final String label;
  final int? queueCount;
  final Color containerColor;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = queueCount == null ? null : '$queueCount queues';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: contentColor, size: 16),
            const SizedBox(width: 7),
            Text(
              '$value',
              style: theme.textTheme.titleSmall?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(width: 6),
              Text(
                detail,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: contentColor.withValues(alpha: 0.74),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
