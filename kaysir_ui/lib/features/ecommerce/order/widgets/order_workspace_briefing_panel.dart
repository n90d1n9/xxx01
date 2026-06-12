import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_workspace_briefing.dart';
import '../models/order_workspace_view.dart';

class OrderWorkspaceBriefingPanel extends StatelessWidget {
  final OrderWorkspaceContext workspace;
  final List<pos_order.Order> orders;
  final int totalOrderCount;

  const OrderWorkspaceBriefingPanel({
    super.key,
    required this.workspace,
    required this.orders,
    required this.totalOrderCount,
  });

  @override
  Widget build(BuildContext context) {
    final briefing = OrderWorkspaceBriefing.fromOrders(
      workspace: workspace,
      orders: orders,
      totalOrderCount: totalOrderCount,
    );
    final theme = Theme.of(context);
    final colors = _briefingColors(theme.colorScheme, briefing.tone);

    return POSSurface(
      padding: const EdgeInsets.all(14),
      color: colors.background,
      border: Border.all(color: colors.foreground.withValues(alpha: 0.22)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          final heading = _BriefingHeading(
            briefing: briefing,
            foreground: colors.foreground,
          );
          final cues = _BriefingCueWrap(cues: briefing.cues);

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                const SizedBox(height: POSUiTokens.gapLarge),
                cues,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: heading),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(flex: 4, child: cues),
            ],
          );
        },
      ),
    );
  }
}

class _BriefingHeading extends StatelessWidget {
  final OrderWorkspaceBriefing briefing;
  final Color foreground;

  const _BriefingHeading({required this.briefing, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSIconBadge(
          icon: _briefingIcon(briefing.tone),
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
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: POSUiTokens.gap,
                runSpacing: 4,
                children: [
                  Text(
                    briefing.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _BriefingBadge(
                    label: briefing.badgeLabel,
                    foreground: foreground,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                briefing.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                briefing.detail,
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
    );
  }
}

class _BriefingCueWrap extends StatelessWidget {
  final List<OrderWorkspaceBriefingCue> cues;

  const _BriefingCueWrap({required this.cues});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: cues
          .map((cue) => _BriefingCuePill(key: ValueKey(cue.id), cue: cue))
          .toList(growable: false),
    );
  }
}

class _BriefingCuePill extends StatelessWidget {
  final OrderWorkspaceBriefingCue cue;

  const _BriefingCuePill({super.key, required this.cue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _briefingColors(theme.colorScheme, cue.tone);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.foreground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: colors.foreground.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_cueIcon(cue.id), size: 16, color: colors.foreground),
            const SizedBox(width: POSUiTokens.gap),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cue.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cue.detail,
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

class _BriefingBadge extends StatelessWidget {
  final String label;
  final Color foreground;

  const _BriefingBadge({required this.label, required this.foreground});

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

({Color background, Color foreground}) _briefingColors(
  ColorScheme scheme,
  OrderWorkspaceBriefingTone tone,
) {
  return switch (tone) {
    OrderWorkspaceBriefingTone.neutral => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.24),
      foreground: scheme.outline,
    ),
    OrderWorkspaceBriefingTone.info => (
      background: scheme.primaryContainer.withValues(alpha: 0.2),
      foreground: scheme.primary,
    ),
    OrderWorkspaceBriefingTone.success => (
      background: scheme.tertiaryContainer.withValues(alpha: 0.26),
      foreground: scheme.tertiary,
    ),
    OrderWorkspaceBriefingTone.warning => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
      foreground: scheme.outline,
    ),
    OrderWorkspaceBriefingTone.danger => (
      background: scheme.errorContainer.withValues(alpha: 0.3),
      foreground: scheme.error,
    ),
  };
}

IconData _briefingIcon(OrderWorkspaceBriefingTone tone) {
  return switch (tone) {
    OrderWorkspaceBriefingTone.neutral => Icons.inbox_outlined,
    OrderWorkspaceBriefingTone.info => Icons.route_outlined,
    OrderWorkspaceBriefingTone.success => Icons.check_circle_outline,
    OrderWorkspaceBriefingTone.warning => Icons.assignment_late_outlined,
    OrderWorkspaceBriefingTone.danger => Icons.report_outlined,
  };
}

IconData _cueIcon(String cueId) {
  return switch (cueId) {
    'fix_blockers' => Icons.priority_high_outlined,
    'confirm_payment' => Icons.payments_outlined,
    'handoff_ready' => Icons.local_shipping_outlined,
    'reconcile_settlement' => Icons.hub_outlined,
    'clear_workspace' => Icons.check_circle_outline,
    'watch_intake' => Icons.inbox_outlined,
    _ => Icons.bolt_outlined,
  };
}
