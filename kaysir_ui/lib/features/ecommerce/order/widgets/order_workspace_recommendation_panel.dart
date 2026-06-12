import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_workspace_recommendation.dart';
import '../models/order_workspace_view.dart';

class OrderWorkspaceRecommendationPanel extends StatelessWidget {
  final OrderWorkspaceContext activeWorkspace;
  final List<OrderWorkspaceView> workspaceViews;
  final Map<String, int> workspaceViewCounts;
  final List<OrderWorkspaceRecommendation>? recommendations;
  final ValueChanged<OrderWorkspaceView> onWorkspaceViewSelected;

  const OrderWorkspaceRecommendationPanel({
    super.key,
    required this.activeWorkspace,
    required this.workspaceViews,
    required this.workspaceViewCounts,
    this.recommendations,
    required this.onWorkspaceViewSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRecommendations =
        recommendations ??
        ecommerceOrderWorkspaceRecommendations(
          activeWorkspace: activeWorkspace,
          workspaceViewCounts: workspaceViewCounts,
        );
    if (visibleRecommendations.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_motion_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: POSUiTokens.gap),
            Expanded(
              child: Text(
                'Recommended next moves',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              'Live queue signals',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: POSUiTokens.gap),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 980
                    ? 3
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
            final spacing = columns == 1 ? 0.0 : POSUiTokens.gapLarge;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: POSUiTokens.gapLarge,
              runSpacing: POSUiTokens.gapLarge,
              children: visibleRecommendations
                  .map(
                    (recommendation) => _RecommendationTile(
                      width: width,
                      recommendation: recommendation,
                      onPressed: () {
                        final view = _workspaceViewById(
                          workspaceViews,
                          recommendation.targetWorkspaceViewId,
                        );
                        if (view != null) onWorkspaceViewSelected(view);
                      },
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final double width;
  final OrderWorkspaceRecommendation recommendation;
  final VoidCallback onPressed;

  const _RecommendationTile({
    required this.width,
    required this.recommendation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _recommendationColors(
      theme.colorScheme,
      recommendation.tone,
    );

    return SizedBox(
      key: ValueKey('order_recommendation_${recommendation.id}'),
      width: width,
      child: Material(
        color: colors.background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(POSUiTokens.radius),
              border: Border.all(
                color: colors.foreground.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                POSIconBadge(
                  icon: _recommendationIcon(recommendation.id),
                  backgroundColor: colors.foreground.withValues(alpha: 0.12),
                  foregroundColor: colors.foreground,
                  size: 32,
                  iconSize: 18,
                ),
                const SizedBox(width: POSUiTokens.gapLarge),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recommendation.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: POSUiTokens.gap),
                          _RecommendationBadge(
                            label: recommendation.badgeLabel,
                            foreground: colors.foreground,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation.description,
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
                const SizedBox(width: POSUiTokens.gap),
                Icon(
                  Icons.arrow_forward_outlined,
                  size: 18,
                  color: colors.foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendationBadge extends StatelessWidget {
  final String label;
  final Color foreground;

  const _RecommendationBadge({required this.label, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

OrderWorkspaceView? _workspaceViewById(
  List<OrderWorkspaceView> views,
  String id,
) {
  for (final view in views) {
    if (view.id == id) return view;
  }
  return null;
}

({Color background, Color foreground}) _recommendationColors(
  ColorScheme scheme,
  OrderWorkspaceRecommendationTone tone,
) {
  return switch (tone) {
    OrderWorkspaceRecommendationTone.info => (
      background: scheme.primaryContainer.withValues(alpha: 0.2),
      foreground: scheme.primary,
    ),
    OrderWorkspaceRecommendationTone.success => (
      background: scheme.tertiaryContainer.withValues(alpha: 0.26),
      foreground: scheme.tertiary,
    ),
    OrderWorkspaceRecommendationTone.warning => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.64),
      foreground: scheme.outline,
    ),
    OrderWorkspaceRecommendationTone.danger => (
      background: scheme.errorContainer.withValues(alpha: 0.3),
      foreground: scheme.error,
    ),
  };
}

IconData _recommendationIcon(String recommendationId) {
  return switch (recommendationId) {
    'priority_queue' => Icons.report_outlined,
    'action_queue' => Icons.assignment_late_outlined,
    'ready_handoff' => Icons.local_shipping_outlined,
    'settlement_review' => Icons.hub_outlined,
    'today_queue' => Icons.today_outlined,
    _ => Icons.auto_awesome_motion_outlined,
  };
}
