import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_workspace_recommendation.dart';
import 'workspace_preview_fixtures.dart';

/// Prioritized action list for the next product workspace decisions.
class ProductWorkspaceRecommendationPanel extends StatelessWidget {
  const ProductWorkspaceRecommendationPanel({
    super.key,
    required this.recommendations,
    required this.onRecommendationSelected,
  });

  final List<ProductWorkspaceRecommendation> recommendations;
  final ValueChanged<ProductWorkspaceRecommendation> onRecommendationSelected;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Recommended next steps',
      subtitle:
          'Prioritized from catalog setup, channel readiness, and stock attention',
      leadingIcon: Icons.auto_awesome_rounded,
      child:
          recommendations.isEmpty
              ? const Text('No product recommendations are available yet.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (
                    var index = 0;
                    index < recommendations.length;
                    index += 1
                  ) ...[
                    _RecommendationRow(
                      recommendation: recommendations[index],
                      onSelected: onRecommendationSelected,
                    ),
                    if (index != recommendations.length - 1)
                      const Divider(height: 20),
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Product workspace recommendations')
Widget workspaceRecommendationPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceRecommendationPanel(
          recommendations: previewProductWorkspaceRecommendations,
          onRecommendationSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Responsive recommendation row with status context and a guarded action.
class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.recommendation,
    required this.onSelected,
  });

  final ProductWorkspaceRecommendation recommendation;
  final ValueChanged<ProductWorkspaceRecommendation> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _priorityColor(colorScheme, recommendation.priority);

    return LayoutBuilder(
      builder: (context, constraints) {
        final action = AppActionButton(
          label: recommendation.actionLabel,
          icon: Icons.arrow_forward_rounded,
          variant: AppActionButtonVariant.secondary,
          onPressed:
              recommendation.canNavigate
                  ? () => onSelected(recommendation)
                  : null,
        );

        final content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _priorityIcon(recommendation.priority),
                  color: accent,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        recommendation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      AppStatusPill(
                        label: recommendation.statusLabel,
                        color: accent,
                        showDot: true,
                        maxWidth: 120,
                      ),
                      AppStatusPill(
                        label: recommendation.sourceLabel,
                        color: colorScheme.primary,
                        icon: Icons.extension_rounded,
                        maxWidth: 150,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            const SizedBox(width: 12),
            action,
          ],
        );
      },
    );
  }
}

Color _priorityColor(
  ColorScheme colorScheme,
  ProductWorkspaceRecommendationPriority priority,
) {
  return switch (priority) {
    ProductWorkspaceRecommendationPriority.critical => colorScheme.error,
    ProductWorkspaceRecommendationPriority.high => colorScheme.tertiary,
    ProductWorkspaceRecommendationPriority.medium => colorScheme.primary,
    ProductWorkspaceRecommendationPriority.ready => colorScheme.secondary,
  };
}

IconData _priorityIcon(ProductWorkspaceRecommendationPriority priority) {
  return switch (priority) {
    ProductWorkspaceRecommendationPriority.critical =>
      Icons.priority_high_rounded,
    ProductWorkspaceRecommendationPriority.high => Icons.trending_up_rounded,
    ProductWorkspaceRecommendationPriority.medium =>
      Icons.manage_search_rounded,
    ProductWorkspaceRecommendationPriority.ready => Icons.task_alt_rounded,
  };
}
