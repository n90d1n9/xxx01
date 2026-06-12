import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_fulfillment_promise.dart';

class OrderFulfillmentPromisePanel extends StatelessWidget {
  final List<pos_order.Order> orders;
  final DateTime now;
  final OrderFulfillmentPromisePolicy policy;

  const OrderFulfillmentPromisePanel({
    super.key,
    required this.orders,
    required this.now,
    this.policy = const OrderFulfillmentPromisePolicy(),
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    final summary = OrderFulfillmentPromiseSummary.fromOrders(
      orders: orders,
      now: now,
      policy: policy,
    );
    final theme = Theme.of(context);
    final colors = _promiseColors(theme.colorScheme, summary.tone);

    return POSSurface(
      padding: const EdgeInsets.all(12),
      color: colors.background,
      border: Border.all(color: colors.foreground.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PromiseHeader(summary: summary, foreground: colors.foreground),
          const SizedBox(height: POSUiTokens.gapLarge),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth >= 1120
                      ? 5
                      : constraints.maxWidth >= 820
                      ? 3
                      : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              final spacing = columns == 1 ? 0.0 : POSUiTokens.gapLarge;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: POSUiTokens.gapLarge,
                runSpacing: POSUiTokens.gapLarge,
                children: summary.bands
                    .map((band) => _PromiseBandTile(width: width, band: band))
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PromiseHeader extends StatelessWidget {
  final OrderFulfillmentPromiseSummary summary;
  final Color foreground;

  const _PromiseHeader({required this.summary, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSIconBadge(
          icon: _promiseIcon(summary.tone),
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
                  _PromiseBadge(
                    label: summary.badgeLabel,
                    foreground: foreground,
                  ),
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
        _NextPromisePill(
          label: summary.nextPromiseDueLabel,
          foreground: foreground,
        ),
      ],
    );
  }
}

class _PromiseBandTile extends StatelessWidget {
  final double width;
  final OrderFulfillmentPromiseBand band;

  const _PromiseBandTile({required this.width, required this.band});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _promiseColors(theme.colorScheme, band.tone);

    return SizedBox(
      key: ValueKey('order_fulfillment_promise_band_${band.id}'),
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
                  const SizedBox(height: 3),
                  Text(
                    band.detail,
                    maxLines: 2,
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

class _NextPromisePill extends StatelessWidget {
  final String label;
  final Color foreground;

  const _NextPromisePill({required this.label, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 124),
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
            'Next target',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
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

class _PromiseBadge extends StatelessWidget {
  final String label;
  final Color foreground;

  const _PromiseBadge({required this.label, required this.foreground});

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

({Color background, Color foreground}) _promiseColors(
  ColorScheme scheme,
  OrderFulfillmentPromiseTone tone,
) {
  return switch (tone) {
    OrderFulfillmentPromiseTone.neutral => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.24),
      foreground: scheme.outline,
    ),
    OrderFulfillmentPromiseTone.info => (
      background: scheme.primaryContainer.withValues(alpha: 0.18),
      foreground: scheme.primary,
    ),
    OrderFulfillmentPromiseTone.success => (
      background: scheme.tertiaryContainer.withValues(alpha: 0.24),
      foreground: scheme.tertiary,
    ),
    OrderFulfillmentPromiseTone.warning => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
      foreground: scheme.outline,
    ),
    OrderFulfillmentPromiseTone.danger => (
      background: scheme.errorContainer.withValues(alpha: 0.28),
      foreground: scheme.error,
    ),
  };
}

IconData _promiseIcon(OrderFulfillmentPromiseTone tone) {
  return switch (tone) {
    OrderFulfillmentPromiseTone.neutral => Icons.fact_check_outlined,
    OrderFulfillmentPromiseTone.info => Icons.outbound_outlined,
    OrderFulfillmentPromiseTone.success => Icons.task_alt_outlined,
    OrderFulfillmentPromiseTone.warning => Icons.running_with_errors_outlined,
    OrderFulfillmentPromiseTone.danger => Icons.assignment_late_outlined,
  };
}

IconData _bandIcon(String bandId) {
  return switch (bandId) {
    'blocked' => Icons.lock_clock_outlined,
    'over_target' => Icons.warning_amber_outlined,
    'due_soon' => Icons.av_timer_outlined,
    'ready_handoff' => Icons.local_shipping_outlined,
    'on_track' => Icons.check_circle_outline,
    _ => Icons.fact_check_outlined,
  };
}
