import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_catalog_utility_stories.dart';
import 'package:tenun_showcase/story/chart_story_catalog_presets.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/chart_story_tier.dart';
import 'package:tenun_showcase/story/charts.dart';

void main() {
  test('chart catalog utility stories stay grouped in navigation order', () {
    final presetStoryNames = [
      for (final preset in chartStoryCatalogPresets.where(
        (preset) => preset.hasFilters,
      ))
        'Charts/Catalog/Quick Views/${preset.label}',
    ];
    final categoryStoryNames = [
      for (final category in chartStoryCatalog.categories)
        'Charts/Catalog/By Category/${category.label}',
    ];
    final tierStoryNames = [
      for (final tierKey in chartStoryCatalog.tierKeys)
        'Charts/Catalog/By Tier/${chartStoryTierLabelForKey(tierKey)}',
    ];
    final groupStoryNames = [
      for (final group in chartStoryCatalog.groups)
        'Charts/Catalog/By Group/${group.label}',
    ];

    expect(chartCatalogUtilityStories.map((story) => story.name), [
      'Charts/Catalog/All Stories',
      ...presetStoryNames,
      ...tierStoryNames,
      ...categoryStoryNames,
      ...groupStoryNames,
    ]);
  });

  test('chart catalog preset utility stories mirror quick view presets', () {
    expect(chartCatalogPresetExplorerStories.map((story) => story.name), [
      for (final preset in chartStoryCatalogPresets.where(
        (preset) => preset.hasFilters,
      ))
        'Charts/Catalog/Quick Views/${preset.label}',
    ]);
  });

  test('chart catalog category utility stories mirror catalog categories', () {
    expect(chartCatalogCategoryExplorerStories.map((story) => story.name), [
      for (final category in chartStoryCatalog.categories)
        'Charts/Catalog/By Category/${category.label}',
    ]);
  });

  test('chart catalog tier utility stories mirror catalog tiers', () {
    expect(chartCatalogTierExplorerStories.map((story) => story.name), [
      for (final tierKey in chartStoryCatalog.tierKeys)
        'Charts/Catalog/By Tier/${chartStoryTierLabelForKey(tierKey)}',
    ]);
  });

  test('chart catalog group utility stories mirror catalog groups', () {
    expect(chartCatalogGroupExplorerStories.map((story) => story.name), [
      for (final group in chartStoryCatalog.groups)
        'Charts/Catalog/By Group/${group.label}',
    ]);
  });

  test(
    'top-level chart stories append utility stories after catalog stories',
    () {
      final names = charts.map((story) => story.name).toList();
      final catalogNames = chartStoryCatalog.stories
          .map((story) => story.name)
          .toList(growable: false);
      final utilityNames = chartCatalogUtilityStories
          .map((story) => story.name)
          .toList(growable: false);

      expect(names.take(catalogNames.length), catalogNames);
      expect(names.skip(catalogNames.length), utilityNames);
    },
  );
}
