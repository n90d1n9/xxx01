import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_action_queue.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseActionQueuePanel extends StatelessWidget {
  const FinancialReportReleaseActionQueuePanel({
    required this.summary,
    this.onOpenAction,
    super.key,
  });

  final FinancialReportReleaseActionQueueSummary summary;
  final ValueChanged<FinancialReportReleaseActionItem>? onOpenAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        summary.criticalCount > 0 || summary.overdueCount > 0
            ? colorScheme.error
            : summary.highCount > 0
            ? colorScheme.tertiary
            : Colors.teal.shade700;

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 740;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon:
                        summary.isClear
                            ? Icons.task_alt_rounded
                            : Icons.playlist_add_check_circle_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Release Action Queue',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.nextAction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final badge = FinancialReportReleaseSignOffBadge(
                label:
                    summary.isClear
                        ? 'Queue clear'
                        : '${summary.totalCount} open action(s)',
                color: accent,
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), badge],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: '${summary.criticalCount} critical',
                color:
                    summary.criticalCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.overdueCount} overdue',
                color:
                    summary.overdueCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.blockedCount} blocked',
                color:
                    summary.blockedCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.highCount} high',
                color:
                    summary.highCount == 0
                        ? colorScheme.secondary
                        : colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (summary.items.isEmpty)
            FinancialReportTintedSurface(
              color: Colors.teal.shade700,
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.teal.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No open release actions.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            FinancialReportResponsiveWrapGrid<FinancialReportReleaseActionItem>(
              items: summary.items,
              breakpoints: const [
                FinancialReportResponsiveGridBreakpoint(
                  minWidth: 760,
                  columns: 2,
                ),
              ],
              itemBuilder:
                  (_, item) => FinancialReportReleaseActionTile(
                    item: item,
                    onOpen:
                        item.destination == null || onOpenAction == null
                            ? null
                            : () => onOpenAction!(item),
                  ),
            ),
        ],
      ),
    );
  }
}

class FinancialReportReleaseActionTile extends StatelessWidget {
  const FinancialReportReleaseActionTile({
    required this.item,
    this.onOpen,
    super.key,
  });

  final FinancialReportReleaseActionItem item;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _priorityColor(item.priority, colorScheme);
    final canOpen = item.destination != null && onOpen != null;

    return FinancialReportTintedSurface(
      color: color,
      minHeight: canOpen ? 176 : 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_areaIcon(item.area), color: color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: item.priority.label,
                color: color,
              ),
              FinancialReportReleaseSignOffBadge(
                label: item.area.label,
                color: colorScheme.primary,
              ),
              if (item.dueDate != null)
                FinancialReportReleaseSignOffBadge(
                  label: 'Due ${_date(item.dueDate!)}',
                  color: colorScheme.secondary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.owner} / ${item.reference}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          if (canOpen) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(item.destination!.label),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _priorityColor(
  FinancialReportReleaseActionPriority priority,
  ColorScheme colorScheme,
) {
  switch (priority) {
    case FinancialReportReleaseActionPriority.critical:
      return colorScheme.error;
    case FinancialReportReleaseActionPriority.high:
      return colorScheme.tertiary;
    case FinancialReportReleaseActionPriority.normal:
      return colorScheme.primary;
  }
}

IconData _areaIcon(FinancialReportReleaseActionArea area) {
  switch (area) {
    case FinancialReportReleaseActionArea.packageIntegrity:
      return Icons.fingerprint_rounded;
    case FinancialReportReleaseActionArea.managementMeasures:
      return Icons.speed_rounded;
    case FinancialReportReleaseActionArea.signOff:
      return Icons.draw_rounded;
    case FinancialReportReleaseActionArea.evidenceManifest:
      return Icons.fact_check_rounded;
    case FinancialReportReleaseActionArea.distribution:
      return Icons.send_rounded;
    case FinancialReportReleaseActionArea.archive:
      return Icons.inventory_2_rounded;
    case FinancialReportReleaseActionArea.retention:
      return Icons.manage_history_rounded;
    case FinancialReportReleaseActionArea.statutoryFiling:
      return Icons.account_balance_rounded;
  }
}

String _date(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
