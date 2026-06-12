import 'package:flutter/material.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

/// Displays structured kitchen-facing service alerts in priority order.
class KitchenServiceAlertList extends StatelessWidget {
  const KitchenServiceAlertList({
    super.key,
    required this.alerts,
    this.emptyMessage = 'No service alerts.',
  });

  final List<FnbServiceAlert> alerts;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final orderedAlerts = [...alerts]
      ..sort(
        (first, second) => second.priorityScore.compareTo(first.priorityScore),
      );

    if (orderedAlerts.isEmpty) {
      final colors = Theme.of(context).colorScheme;
      return Text(
        emptyMessage,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in orderedAlerts.asMap().entries) ...[
          _KitchenServiceAlertRow(alert: entry.value),
          if (entry.key != orderedAlerts.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// One compact service alert row with severity and optional guidance.
class _KitchenServiceAlertRow extends StatelessWidget {
  const _KitchenServiceAlertRow({required this.alert});

  final FnbServiceAlert alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final alertColor = _serviceAlertColor(colors, alert);
    final description = alert.descriptionLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: alert.critical ? .12 : .08),
        border: Border.all(color: alertColor.withValues(alpha: .22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_serviceAlertIcon(alert.type), size: 18, color: alertColor),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.compactLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: alertColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (alert.critical) ...[
                        const SizedBox(width: 8),
                        _CriticalAlertChip(color: alertColor),
                      ],
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
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

/// Visual severity marker for critical service alerts.
class _CriticalAlertChip extends StatelessWidget {
  const _CriticalAlertChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          'Critical',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

IconData _serviceAlertIcon(FnbServiceAlertType type) {
  return switch (type) {
    FnbServiceAlertType.allergy => Icons.warning_amber_rounded,
    FnbServiceAlertType.dietary => Icons.restaurant_menu_outlined,
    FnbServiceAlertType.preference => Icons.tune_outlined,
    FnbServiceAlertType.accessibility => Icons.accessible_forward_outlined,
    FnbServiceAlertType.timing => Icons.schedule_outlined,
    FnbServiceAlertType.service => Icons.support_agent_outlined,
  };
}

Color _serviceAlertColor(ColorScheme colors, FnbServiceAlert alert) {
  if (alert.critical) return colors.error;
  return switch (alert.type) {
    FnbServiceAlertType.allergy => colors.error,
    FnbServiceAlertType.dietary => colors.tertiary,
    FnbServiceAlertType.preference => colors.secondary,
    FnbServiceAlertType.accessibility => colors.secondary,
    FnbServiceAlertType.timing => colors.primary,
    FnbServiceAlertType.service => colors.primary,
  };
}
