import 'package:flutter/material.dart';

import '../story/chart_story_tier.dart';

@immutable
class ChartStoryTierPalette {
  const ChartStoryTierPalette({
    required this.container,
    required this.foreground,
  });

  final Color container;
  final Color foreground;
}

IconData chartStoryTierIcon(ChartStoryTier tier) {
  return switch (tier) {
    ChartStoryTier.core => Icons.layers_outlined,
    ChartStoryTier.pro => Icons.workspace_premium_outlined,
    ChartStoryTier.custom => Icons.extension_outlined,
  };
}

IconData? chartStoryTierIconForKey(String tierKey) {
  final tier = chartStoryTierFromKey(tierKey);
  if (tier == null) {
    return null;
  }

  return chartStoryTierIcon(tier);
}

String? chartStoryTierDescriptionForKey(String tierKey) {
  return chartStoryTierFromKey(tierKey)?.description;
}

ChartStoryTierPalette chartStoryTierPalette(
  ChartStoryTier tier,
  ColorScheme colorScheme,
) {
  return switch (tier) {
    ChartStoryTier.core => ChartStoryTierPalette(
      container: colorScheme.primaryContainer,
      foreground: colorScheme.onPrimaryContainer,
    ),
    ChartStoryTier.pro => ChartStoryTierPalette(
      container: colorScheme.tertiaryContainer,
      foreground: colorScheme.onTertiaryContainer,
    ),
    ChartStoryTier.custom => ChartStoryTierPalette(
      container: colorScheme.secondaryContainer,
      foreground: colorScheme.onSecondaryContainer,
    ),
  };
}
