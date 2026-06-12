import 'package:flutter/material.dart';

import '../models/restaurant_operational_insight.dart';
import 'operational_insight_card.dart';
import 'restaurant_adaptive_grid.dart';

export 'operational_insight_card.dart';

/// Lays out prioritized operational insights in a responsive card grid.
class RestaurantOperationalInsightGrid extends StatelessWidget {
  const RestaurantOperationalInsightGrid({
    super.key,
    required this.insights,
    this.selectedInsight,
    this.onInsightSelected,
  });

  final List<RestaurantOperationalInsight> insights;
  final RestaurantOperationalInsight? selectedInsight;
  final ValueChanged<RestaurantOperationalInsight>? onInsightSelected;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.insights_rounded, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              'Shift insights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        RestaurantAdaptiveGrid(
          itemCount: insights.length,
          itemExtent: 136,
          itemBuilder: (context, index) {
            final insight = insights[index];
            return RestaurantOperationalInsightCard(
              insight: insight,
              selected: selectedInsight?.id == insight.id,
              onPressed: onInsightSelected == null
                  ? null
                  : () => onInsightSelected!(insight),
            );
          },
        ),
      ],
    );
  }
}
