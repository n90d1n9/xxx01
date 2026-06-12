import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_catalog_utility_stories.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/charts.dart';

void main() {
  test('chart story groups stay in navigation order', () {
    expect(chartStoryGroups.map((group) => group.id), const [
      'data-shape-gallery',
      'tools',
      'cartesian-exploration',
      'cartesian-variants',
      'matrix',
      'financial',
    ]);
  });

  test('chart story groups are all populated', () {
    expect(
      chartStoryGroups,
      everyElement(
        isA<ChartStoryGroup>().having(
          (group) => group.stories,
          'stories',
          isNotEmpty,
        ),
      ),
    );
  });

  test('chart story group ids stay unique', () {
    final ids = chartStoryGroups.map((group) => group.id).toList();

    expect(ids.toSet(), hasLength(ids.length));
    expect(chartStoryCatalog.hasDuplicateGroupIds, isFalse);
  });

  test('flattened chart story groups match catalog-backed exported charts', () {
    final flattenedNames = flattenChartStoryGroups(
      chartStoryGroups,
    ).map((story) => story.name);
    final catalogBackedChartNames = charts
        .take(chartStoryCatalog.storyCount)
        .map((story) => story.name);

    expect(catalogBackedChartNames, flattenedNames);
    expect(
      chartStoryCatalog.stories.map((story) => story.name),
      flattenedNames,
    );
    expect(
      charts.skip(chartStoryCatalog.storyCount).map((story) => story.name),
      chartCatalogUtilityStories.map((story) => story.name),
    );
  });

  test('chart story names stay unique across groups', () {
    final names = charts.map((story) => story.name).toList();

    expect(names.toSet(), hasLength(names.length));
    expect(chartStoryCatalog.hasDuplicateStoryNames, isFalse);
  });

  test('chart story catalog exposes immutable lookup indexes', () {
    expect(chartStoryCatalog.groupCount, chartStoryGroups.length);
    expect(chartStoryCatalog.storyCount, chartStoryCatalog.stories.length);
    expect(chartStoryCatalog.entries, hasLength(chartStoryCatalog.storyCount));
    expect(
      chartStoryCatalog.groupsById.keys,
      chartStoryGroups.map((group) => group.id),
    );
    expect(
      chartStoryCatalog.storiesByName.keys,
      chartStoryCatalog.stories.map((story) => story.name),
    );
    expect(
      chartStoryCatalog.entriesByName.keys,
      chartStoryCatalog.stories.map((story) => story.name),
    );
    expect(chartStoryCatalog.categoryCount, 4);
    expect(
      chartStoryCatalog.categories.map((category) => category.label),
      const ['Discover', 'Tooling', 'Core Shapes', 'Domain & Specialized'],
    );
    expect(chartStoryCatalog.categoriesById.keys, const [
      'discover',
      'tooling',
      'core-shapes',
      'domain-specialized',
    ]);

    expect(
      () => chartStoryCatalog.groups.add(chartStoryGroups.first),
      throwsUnsupportedError,
    );
    expect(
      () => chartStoryCatalog.stories.add(charts.first),
      throwsUnsupportedError,
    );
    expect(
      () => chartStoryCatalog.entries.add(chartStoryCatalog.entries.first),
      throwsUnsupportedError,
    );
    expect(() => chartStoryCatalog.groupsById.clear(), throwsUnsupportedError);
    expect(
      () => chartStoryCatalog.storiesByName.clear(),
      throwsUnsupportedError,
    );
    expect(
      () => chartStoryCatalog.entriesByName.clear(),
      throwsUnsupportedError,
    );
    expect(
      () => chartStoryCatalog.categories.add(chartStoryGroups.first.category),
      throwsUnsupportedError,
    );
    expect(
      () => chartStoryCatalog.categoriesById.clear(),
      throwsUnsupportedError,
    );
  });

  test('chart story group exposes immutable story metadata', () {
    final tools = findChartStoryGroupById('tools')!;

    expect(tools.storyCount, tools.stories.length);
    expect(
      tools.description,
      'Diagnostics, safety, export, performance, and authoring utilities.',
    );
    expect(tools.storyNames, [
      'Charts/Tools/Chart Export Lab',
      'Charts/Tools/TenunChartJson ForceType Guardrails',
      'Charts/Tools/JSON Render Safety',
      'Charts/Tools/Zoom Legacy Charts',
      'Charts/Tools/Drilldown Bar',
      'Charts/Tools/Large Data Sampling Lab',
      'Charts/Tools/Interaction Reliability Lab',
      'Charts/Tools/Performance Diagnostics Lab',
      'Charts/Tools/Payload Doctor',
      'Charts/Tools/Payload Normalize Playground',
      'Charts/Tools/Registry Health Matrix',
      'Charts/Tools/Registry Health Split Review',
    ]);
    expect(() => tools.stories.add(charts.first), throwsUnsupportedError);
    expect(
      () => tools.storyNames.add('Charts/Tools/Extra'),
      throwsUnsupportedError,
    );
  });

  test('chart story lookup helpers find groups and stories', () {
    final storyName = 'Charts/By Data Shape/Cartesian/Bar/Simple';
    final story = findChartStoryByName(storyName);
    final group = findChartStoryGroupForStoryName(storyName);

    expect(
      findChartStoryGroupById('cartesian-variants')?.label,
      'Cartesian Variants',
    );
    expect(story?.name, storyName);
    expect(group?.id, 'cartesian-variants');
    expect(chartStoryCatalog.storyByName(storyName)?.name, storyName);
    expect(chartStoryCatalog.entryByName(storyName)?.name, storyName);
    expect(
      chartStoryCatalog.groupForStoryName(storyName)?.id,
      'cartesian-variants',
    );
  });

  test('chart story lookup helpers return null for unknown input', () {
    expect(findChartStoryGroupById('unknown'), isNull);
    expect(findChartStoryByName('Charts/Unknown'), isNull);
    expect(findChartStoryGroupForStoryName('Charts/Unknown'), isNull);
    expect(chartStoryCatalog.groupById('unknown'), isNull);
    expect(chartStoryCatalog.storyByName('Charts/Unknown'), isNull);
    expect(chartStoryCatalog.entryByName('Charts/Unknown'), isNull);
    expect(chartStoryCatalog.groupForStoryName('Charts/Unknown'), isNull);
  });

  test('chart story entries expose group and path metadata', () {
    final entry = chartStoryCatalog.entryByName(
      'Charts/By Data Shape/Cartesian/Bar/Simple',
    )!;

    expect(entry.groupId, 'cartesian-variants');
    expect(entry.groupLabel, 'Cartesian Variants');
    expect(entry.categoryId, 'core-shapes');
    expect(entry.categoryLabel, 'Core Shapes');
    expect(entry.pathSegments, [
      'Charts',
      'By Data Shape',
      'Cartesian',
      'Bar',
      'Simple',
    ]);
    expect(entry.pathSegment(0), 'Charts');
    expect(entry.pathSegment(3), 'Bar');
    expect(entry.pathSegment(-1), isNull);
    expect(entry.pathSegment(99), isNull);
    expect(entry.root, 'Charts');
    expect(entry.section, 'By Data Shape');
    expect(entry.dataShape, 'Cartesian');
    expect(entry.family, 'Bar');
    expect(entry.variant, 'Simple');
    expect(entry.leaf, 'Simple');
    expect(entry.breadcrumb, 'By Data Shape / Cartesian / Bar / Simple');
    expect(() => entry.pathSegments.add('Extra'), throwsUnsupportedError);
  });

  test('chart story entries expose optional structured contracts', () {
    final entry = chartStoryCatalog.entryByName(
      'Charts/By Data Shape/Cartesian/Bar/Simple',
    )!;

    expect(entry.contract, isNotNull);
    expect(entry.tags, containsAll(['bar', 'comparison', 'json']));
    expect(entry.useCases, contains('Survey category comparison'));
    expect(entry.knobs.map((knob) => knob.key), contains('dataMode'));
    expect(entry.knobs.map((knob) => knob.label), contains('Show Tooltip'));
    expect(entry.sampleJson?['type'], 'bar');
    expect(entry.sampleCode, contains('TenunChartFromJson'));
    expect(entry.hasSampleJson, isTrue);
    expect(entry.hasSampleCode, isTrue);
    expect(entry.matchesQuery('survey category'), isTrue);
    expect(entry.matchesQuery('sampling strategy'), isTrue);
  });

  test('registry health tool entries expose release planning contracts', () {
    final matrixEntry = chartStoryCatalog.entryByName(
      'Charts/Tools/Registry Health Matrix',
    )!;
    final splitEntry = chartStoryCatalog.entryByName(
      'Charts/Tools/Registry Health Split Review',
    )!;

    expect(matrixEntry.contract, isNotNull);
    expect(matrixEntry.isContractReady, isTrue);
    expect(matrixEntry.family, 'Registry Health');
    expect(matrixEntry.variant, 'Matrix');
    expect(matrixEntry.tags, containsAll(['registry', 'audit', 'release']));
    expect(
      matrixEntry.knobs.map((knob) => knob.label),
      containsAll(['Health Sections', 'Matrix View', 'Export Preset']),
    );
    expect(matrixEntry.sampleJson?['tool'], 'registryHealth');
    expect(matrixEntry.sampleCode, contains('registryHealthStoryKnobs'));
    expect(matrixEntry.matchesQuery('package split handoff'), isTrue);

    expect(splitEntry.contract, isNotNull);
    expect(splitEntry.isContractReady, isTrue);
    expect(splitEntry.family, 'Registry Health');
    expect(splitEntry.variant, 'Split Review');
    expect(
      splitEntry.tags,
      containsAll(['package-split', 'pro', 'enterprise']),
    );
    expect(
      splitEntry.knobs.map((knob) => knob.key),
      containsAll(['showPackageBoundary', 'showProReadiness', 'splitIssues']),
    );
    expect(splitEntry.sampleJson?['preset'], 'release');
    expect(splitEntry.sampleCode, contains("initialSectionSet: 'split'"));
    expect(
      splitEntry.matchesQuery('commercial pro financial planning'),
      isTrue,
    );
  });

  test(
    'chart story entries expose neutral facets for non data-shape stories',
    () {
      final galleryEntry = chartStoryCatalog.entryByName(
        'Charts/Galleries/Advanced Business & AI-ML',
      )!;
      final toolEntry = chartStoryCatalog.entryByName(
        'Charts/Tools/Payload Normalize Playground',
      )!;

      expect(galleryEntry.section, 'Galleries');
      expect(galleryEntry.categoryLabel, 'Discover');
      expect(galleryEntry.dataShape, isNull);
      expect(galleryEntry.family, 'Advanced Business & AI-ML');
      expect(galleryEntry.variant, isNull);
      expect(galleryEntry.breadcrumb, 'Galleries / Advanced Business & AI-ML');

      expect(toolEntry.section, 'Tools');
      expect(toolEntry.categoryLabel, 'Tooling');
      expect(toolEntry.dataShape, isNull);
      expect(toolEntry.family, 'Payload Normalize Playground');
      expect(toolEntry.variant, isNull);
      expect(toolEntry.breadcrumb, 'Tools / Payload Normalize Playground');
    },
  );

  test('chart story catalog filters entries by group id', () {
    final toolEntries = chartStoryCatalog.entriesForGroupId('tools');
    final unknownEntries = chartStoryCatalog.entriesForGroupId('unknown');

    expect(
      toolEntries,
      hasLength(findChartStoryGroupById('tools')!.storyCount),
    );
    expect(toolEntries.every((entry) => entry.groupId == 'tools'), isTrue);
    expect(unknownEntries, isEmpty);
    expect(
      () => toolEntries.add(chartStoryCatalog.entries.first),
      throwsUnsupportedError,
    );
  });

  test('chart story catalog filters entries by category', () {
    final coreEntries = chartStoryCatalog.entriesForCategory('Core Shapes');
    final unknownEntries = chartStoryCatalog.entriesForCategory('Unknown');

    expect(coreEntries, isNotEmpty);
    expect(
      coreEntries.every((entry) => entry.categoryLabel == 'Core Shapes'),
      isTrue,
    );
    expect(
      coreEntries.map((entry) => entry.name),
      contains('Charts/By Data Shape/Cartesian/Bar/Simple'),
    );
    expect(unknownEntries, isEmpty);
    expect(
      () => coreEntries.add(chartStoryCatalog.entries.first),
      throwsUnsupportedError,
    );
  });

  test(
    'chart story catalog exposes section, data-shape, and family facets',
    () {
      expect(chartStoryCatalog.sections, [
        'Galleries',
        'By Data Shape',
        'Tools',
      ]);
      expect(chartStoryCatalog.dataShapes, [
        'Catalog Overview',
        'AI & Machine Learning',
        'Business & Project Management',
        'Hierarchy',
        'Flow',
        'Radial',
        'Geo',
        'Text-Timeline',
        'Mixed',
        'Cartesian',
        'Smart Type Switch',
        'Matrix',
        'Financial',
      ]);
      expect(
        chartStoryCatalog.families,
        containsAll(['Bar', 'Payload Doctor']),
      );
    },
  );

  test('chart story catalog filters entries by path facets', () {
    final toolEntries = chartStoryCatalog.entriesForSection('Tools');
    final cartesianEntries = chartStoryCatalog.entriesForDataShape('Cartesian');
    final barEntries = chartStoryCatalog.entriesForFamily('Bar');

    expect(
      toolEntries,
      hasLength(findChartStoryGroupById('tools')!.storyCount),
    );
    expect(toolEntries.every((entry) => entry.section == 'Tools'), isTrue);
    expect(
      cartesianEntries.every((entry) => entry.dataShape == 'Cartesian'),
      isTrue,
    );
    expect(barEntries.every((entry) => entry.family == 'Bar'), isTrue);
    expect(
      barEntries.map((entry) => entry.name),
      contains('Charts/By Data Shape/Cartesian/Bar/Simple'),
    );
    expect(chartStoryCatalog.entriesForSection('Unknown'), isEmpty);
    expect(chartStoryCatalog.entriesForDataShape('Unknown'), isEmpty);
    expect(chartStoryCatalog.entriesForFamily('Unknown'), isEmpty);
    expect(
      () => barEntries.add(chartStoryCatalog.entries.first),
      throwsUnsupportedError,
    );
  });

  test('chart story catalog searches entries with multi-token queries', () {
    final payloadMatches = chartStoryCatalog.entriesMatchingQuery(
      'payload normalize',
    );
    final heatmapMatches = chartStoryCatalog.entriesMatchingQuery(
      'temperature heatmap',
    );
    final emptyQueryMatches = chartStoryCatalog.entriesMatchingQuery('  ');

    expect(payloadMatches.map((entry) => entry.name), [
      'Charts/Tools/JSON Render Safety',
      'Charts/Tools/Payload Normalize Playground',
    ]);
    expect(heatmapMatches.map((entry) => entry.name), [
      'Charts/By Data Shape/Matrix/Heatmap/Basic',
    ]);
    expect(emptyQueryMatches, hasLength(chartStoryCatalog.storyCount));
    expect(chartStoryCatalog.entriesMatchingQuery('no-such-chart'), isEmpty);
    expect(
      () => payloadMatches.add(chartStoryCatalog.entries.first),
      throwsUnsupportedError,
    );
  });

  test('chart story catalog reports duplicate group ids and story names', () {
    final duplicateCatalog = ChartStoryCatalog([
      chartStoryGroups.first,
      ChartStoryGroup(
        id: chartStoryGroups.first.id,
        label: 'Duplicate Group',
        description: 'Duplicate group fixture.',
        stories: chartStoryGroups.first.stories.take(1),
      ),
    ]);

    expect(duplicateCatalog.duplicateGroupIds, [chartStoryGroups.first.id]);
    expect(duplicateCatalog.duplicateStoryNames, [
      chartStoryGroups.first.stories.first.name,
    ]);
    expect(duplicateCatalog.hasDuplicateGroupIds, isTrue);
    expect(duplicateCatalog.hasDuplicateStoryNames, isTrue);
  });
}
