import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_workspace_sla.dart';

class OrderWorkspaceSlaPanel extends StatelessWidget {
  final List<pos_order.Order> orders;
  final DateTime now;

  const OrderWorkspaceSlaPanel({
    super.key,
    required this.orders,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    final summary = OrderWorkspaceSlaSummary.fromOrders(
      orders: orders,
      now: now,
    );
    final theme = Theme.of(context);
    final colors = _slaColors(theme.colorScheme, summary.tone);

    return POSSurface(
      padding: const EdgeInsets.all(12),
      color: colors.background,
      border: Border.all(color: colors.foreground.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SlaHeader(summary: summary, foreground: colors.foreground),
          const SizedBox(height: POSUiTokens.gapLarge),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth >= 980
                      ? 4
                      : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              final spacing = columns == 1 ? 0.0 : POSUiTokens.gapLarge;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: POSUiTokens.gapLarge,
                runSpacing: POSUiTokens.gapLarge,
                children: summary.bands
                    .map((band) => _SlaBandTile(width: width, band: band))
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SlaHeader extends StatelessWidget {
  final OrderWorkspaceSlaSummary summary;
  final Color foreground;

  const _SlaHeader({required this.summary, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSIconBadge(
          icon: _slaIcon(summary.tone),
          backgroundColor: foreground.withValues(alpha: 0.12),
          foregroundColor: foreground,
        ),
        const SizedBox(width: POSUiTokens.gapLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: POSUiTokens.gap,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    summary.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _SlaBadge(label: summary.badgeLabel, foreground: foreground),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                summary.summary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: POSUiTokens.gap),
        _OldestAgePill(
          ageLabel: summary.oldestActiveAgeLabel,
          foreground: foreground,
        ),
      ],
    );
  }
}

class _SlaBandTile extends StatelessWidget {
  final double width;
  final OrderWorkspaceSlaBand band;

  const _SlaBandTile({required this.width, required this.band});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _slaColors(theme.colorScheme, band.tone);

    return SizedBox(
      key: ValueKey('order_workspace_sla_band_${band.id}'),
      width: width,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: colors.foreground.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            POSIconBadge(
              icon: _bandIcon(band.id),
              backgroundColor: colors.foreground.withValues(alpha: 0.1),
              foregroundColor: colors.foreground,
              size: 30,
              iconSize: 16,
            ),
            const SizedBox(width: POSUiTokens.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          band.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${band.count}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    band.rangeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    band.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OldestAgePill extends StatelessWidget {
  final String ageLabel;
  final Color foreground;

  const _OldestAgePill({required this.ageLabel, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Oldest active',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            ageLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlaBadge extends StatelessWidget {
  final String label;
  final Color foreground;

  const _SlaBadge({required this.label, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

({Color background, Color foreground}) _slaColors(
  ColorScheme scheme,
  OrderWorkspaceSlaTone tone,
) {
  return switch (tone) {
    OrderWorkspaceSlaTone.neutral => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.24),
      foreground: scheme.outline,
    ),
    OrderWorkspaceSlaTone.info => (
      background: scheme.primaryContainer.withValues(alpha: 0.18),
      foreground: scheme.primary,
    ),
    OrderWorkspaceSlaTone.success => (
      background: scheme.tertiaryContainer.withValues(alpha: 0.24),
      foreground: scheme.tertiary,
    ),
    OrderWorkspaceSlaTone.warning => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
      foreground: scheme.outline,
    ),
    OrderWorkspaceSlaTone.danger => (
      background: scheme.errorContainer.withValues(alpha: 0.28),
      foreground: scheme.error,
    ),
  };
}

IconData _slaIcon(OrderWorkspaceSlaTone tone) {
  return switch (tone) {
    OrderWorkspaceSlaTone.neutral => Icons.hourglass_empty_outlined,
    OrderWorkspaceSlaTone.info => Icons.schedule_outlined,
    OrderWorkspaceSlaTone.success => Icons.timer_outlined,
    OrderWorkspaceSlaTone.warning => Icons.pending_actions_outlined,
    OrderWorkspaceSlaTone.danger => Icons.notification_important,
  };
}

IconData _bandIcon(String bandId) {
  return switch (bandId) {
    'fresh' => Icons.bolt_outlined,
    'watch' => Icons.schedule_outlined,
    'stale' => Icons.pending_actions_outlined,
    'escalate' => Icons.notification_important_outlined,
    _ => Icons.timer_outlined,
  };
}
