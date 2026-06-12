import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../services/restaurant_briefing_builder.dart';
import 'restaurant_adaptive_grid.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'shift_focus_tile.dart';

/// Shows the top ranked operational focus items for fast shift triage.
class RestaurantShiftFocusStrip extends StatelessWidget {
  const RestaurantShiftFocusStrip({
    super.key,
    required this.snapshot,
    this.builder = const RestaurantBriefingBuilder(),
    this.maxItems = 4,
    this.onItemSelected,
  });

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantBriefingBuilder builder;
  final int maxItems;
  final ValueChanged<RestaurantBriefingItem>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final items = builder.build(snapshot).take(maxItems).toList();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RestaurantSectionSurface(
      backgroundColor: Color.alphaBlend(
        colors.tertiary.withValues(alpha: .04),
        colors.surface,
      ),
      borderColor: colors.outlineVariant.withValues(alpha: .7),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantSectionHeader(
            icon: Icons.radar_outlined,
            iconColor: colors.primary,
            title: 'Priority watch',
            subtitle: 'Fast triage from the current service snapshot.',
            titleStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          RestaurantAdaptiveGrid(
            itemCount: items.length,
            itemExtent: 118,
            wideBreakpoint: 980,
            mediumBreakpoint: 620,
            spacing: 10,
            itemBuilder: (context, index) {
              final item = items[index];
              return RestaurantShiftFocusTile(
                item: item,
                onSelected: onItemSelected == null
                    ? null
                    : () => onItemSelected!(item),
              );
            },
          ),
        ],
      ),
    );
  }
}
