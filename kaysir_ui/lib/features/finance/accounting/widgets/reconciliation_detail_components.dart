import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/ui/app_empty_state.dart';
import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../../../../widgets/ui/app_text_cluster.dart';

class ReconciliationDetailHeader extends StatelessWidget {
  const ReconciliationDetailHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.statusLabel,
    required this.statusColor,
    this.statusIcon,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String statusLabel;
  final Color statusColor;
  final IconData? statusIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: icon,
          size: 44,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: AppTextCluster(
            title: title,
            subtitle: subtitle,
            titleStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            subtitleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            subtitleMaxLines: 2,
          ),
        ),
        const SizedBox(width: 12),
        AppStatusPill(
          label: statusLabel,
          color: statusColor,
          icon: statusIcon,
          maxWidth: 140,
        ),
      ],
    );
  }
}

class ReconciliationMetricData {
  const ReconciliationMetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.helper,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? helper;
}

class ReconciliationMetricStrip extends StatelessWidget {
  const ReconciliationMetricStrip({
    required this.metrics,
    this.maxColumns = 4,
    super.key,
  });

  final List<ReconciliationMetricData> metrics;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 960.0;
        final columns = _columnCountFor(
          availableWidth,
          metrics.length,
          maxColumns,
        );
        final itemWidth =
            ((availableWidth - (spacing * (columns - 1))) / columns)
                .clamp(0.0, availableWidth)
                .toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: _ReconciliationMetricTile(metric: metric),
              ),
          ],
        );
      },
    );
  }

  int _columnCountFor(double width, int itemCount, int maxColumns) {
    final targetColumns =
        width < 460
            ? 1
            : width < 760
            ? 2
            : width < 980
            ? 3
            : maxColumns;
    final boundedTarget = targetColumns.clamp(1, maxColumns);
    return itemCount < boundedTarget ? itemCount : boundedTarget;
  }
}

class ReconciliationSectionHeader extends StatelessWidget {
  const ReconciliationSectionHeader({
    required this.title,
    required this.amount,
    required this.currency,
    this.amountLabel,
    this.icon,
    super.key,
  });

  final String title;
  final double amount;
  final NumberFormat currency;
  final String? amountLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedAmount = currency.format(amount);
    final trailingText =
        amountLabel == null
            ? formattedAmount
            : '$amountLabel: $formattedAmount';

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              trailingText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReconciliationTableShell extends StatelessWidget {
  const ReconciliationTableShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }
}

class ReconciliationEmptyState extends StatelessWidget {
  const ReconciliationEmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppEmptyState(title: title, message: message, icon: icon),
    );
  }
}

class _ReconciliationMetricTile extends StatelessWidget {
  const _ReconciliationMetricTile({required this.metric});

  final ReconciliationMetricData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconBadge(
              icon: metric.icon,
              size: 36,
              iconSize: 18,
              backgroundColor: metric.accentColor.withValues(alpha: 0.12),
              foregroundColor: metric.accentColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    metric.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      metric.value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: metric.accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (metric.helper != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      metric.helper!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
