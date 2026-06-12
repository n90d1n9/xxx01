import 'package:storybook_flutter/storybook_flutter.dart' show Story;

import '../example/chart_story_catalog_explorer_example.dart';
import 'chart_catalog_story_knobs.dart';
import 'chart_story_builders.dart';
import 'chart_story_catalog_presets.dart';
import 'chart_story_groups.dart';
import 'chart_story_tier.dart';

final chartCatalogUtilityStories = [
  _chartCatalogExplorerStory(),
  ...chartCatalogPresetExplorerStories,
  ...chartCatalogTierExplorerStories,
  ...chartCatalogCategoryExplorerStories,
  ...chartCatalogGroupExplorerStories,
];

final chartCatalogPresetExplorerStories = [
  for (final preset in chartStoryCatalogPresets.where(
    (preset) => preset.hasFilters,
  ))
    fixedHeightChartStory(
      name: 'Charts/Catalog/Quick Views/${preset.label}',
      description: preset.description,
      height: 760,
      builder: (context) {
        final knobs = chartCatalogExplorerKnobs(
          context,
          chartStoryCatalog,
          initialQuery: preset.query,
          initialTier: preset.tier,
          initialCategory: preset.categoryLabel,
          initialGroupId: preset.groupId,
          initialSection: preset.section,
          initialDataShape: preset.dataShape,
          initialFamily: preset.family,
          initialContractStatus: preset.contractStatus,
        );

        return _catalogExplorerFromKnobs(
          knobs,
          title: preset.label,
          subtitle: preset.description,
        );
      },
    ),
];

final chartCatalogTierExplorerStories = [
  for (final tierKey in chartStoryCatalog.tierKeys)
    fixedHeightChartStory(
      name: 'Charts/Catalog/By Tier/${chartStoryTierLabelForKey(tierKey)}',
      description:
          chartStoryTierFromKey(tierKey)?.description ??
          'Stories assigned to the $tierKey tier.',
      height: 760,
      builder: (context) {
        final knobs = chartCatalogExplorerKnobs(
          context,
          chartStoryCatalog,
          initialTier: tierKey,
        );

        return _catalogExplorerFromKnobs(
          knobs,
          title: '${chartStoryTierLabelForKey(tierKey)} Tier Stories',
          subtitle:
              chartStoryTierFromKey(tierKey)?.description ??
              'Stories assigned to the $tierKey tier.',
        );
      },
    ),
];

final chartCatalogCategoryExplorerStories = [
  for (final category in chartStoryCatalog.categories)
    fixedHeightChartStory(
      name: 'Charts/Catalog/By Category/${category.label}',
      description: category.description,
      height: 760,
      builder: (context) {
        final knobs = chartCatalogExplorerKnobs(
          context,
          chartStoryCatalog,
          initialCategory: category.label,
        );

        return _catalogExplorerFromKnobs(
          knobs,
          title: '${category.label} Stories',
          subtitle: category.description,
        );
      },
    ),
];

final chartCatalogGroupExplorerStories = [
  for (final group in chartStoryCatalog.groups)
    fixedHeightChartStory(
      name: 'Charts/Catalog/By Group/${group.label}',
      description: group.description,
      height: 760,
      builder: (context) {
        final knobs = chartCatalogExplorerKnobs(
          context,
          chartStoryCatalog,
          initialGroupId: group.id,
        );

        return _catalogExplorerFromKnobs(
          knobs,
          title: '${group.label} Stories',
          subtitle: group.description,
        );
      },
    ),
];

Story _chartCatalogExplorerStory() {
  return fixedHeightChartStory(
    name: 'Charts/Catalog/All Stories',
    description:
        'Searchable story catalog with category, group, section, data-shape, and family facets.',
    height: 760,
    builder: (context) {
      final knobs = chartCatalogExplorerKnobs(context, chartStoryCatalog);

      return _catalogExplorerFromKnobs(knobs);
    },
  );
}

ChartStoryCatalogExplorerExample _catalogExplorerFromKnobs(
  ChartCatalogExplorerKnobs knobs, {
  String title = 'Story Catalog Explorer',
  String? subtitle,
}) {
  return ChartStoryCatalogExplorerExample(
    catalog: chartStoryCatalog,
    title: title,
    subtitle: subtitle,
    initialQuery: knobs.initialQuery,
    initialTier: knobs.initialTier,
    initialCategory: knobs.initialCategory,
    initialGroupId: knobs.initialGroupId,
    initialSection: knobs.initialSection,
    initialDataShape: knobs.initialDataShape,
    initialFamily: knobs.initialFamily,
    initialContractStatus: knobs.initialContractStatus,
    maxVisibleEntries: knobs.maxVisibleEntries,
  );
}
