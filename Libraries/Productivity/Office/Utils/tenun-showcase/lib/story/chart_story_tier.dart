enum ChartStoryTier { core, pro, custom }

extension ChartStoryTierLabel on ChartStoryTier {
  String get key => name;

  String get label => switch (this) {
    ChartStoryTier.core => 'Core',
    ChartStoryTier.pro => 'Pro',
    ChartStoryTier.custom => 'Custom',
  };

  String get description => switch (this) {
    ChartStoryTier.core => 'Open-source core chart stories.',
    ChartStoryTier.pro => 'Commercial and enterprise-focused chart stories.',
    ChartStoryTier.custom => 'Custom or partner-specific chart stories.',
  };
}

ChartStoryTier? chartStoryTierFromKey(String? key) {
  if (key == null || key.isEmpty) {
    return null;
  }

  for (final tier in ChartStoryTier.values) {
    if (tier.key == key) {
      return tier;
    }
  }

  return null;
}

String chartStoryTierLabelForKey(String key) {
  return chartStoryTierFromKey(key)?.label ?? key;
}
