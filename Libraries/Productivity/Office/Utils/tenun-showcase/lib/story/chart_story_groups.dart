import 'package:storybook_flutter/storybook_flutter.dart';

import 'chart_cartesian_stories.dart';
import 'chart_data_shape_gallery_stories.dart';
import 'chart_financial_stories.dart';
import 'chart_matrix_stories.dart';
import 'chart_story_category.dart';
import 'chart_story_contract.dart';
import 'chart_story_tier.dart';
import 'chart_tool_stories.dart';

class ChartStoryGroup {
  ChartStoryGroup({
    required this.id,
    required this.label,
    required this.description,
    required Iterable<Story> stories,
    this.category = chartStoryCategoryUncategorized,
    this.tier = ChartStoryTier.core,
  }) : stories = List.unmodifiable(stories);

  final String id;
  final String label;
  final String description;
  final ChartStoryCategory category;
  final ChartStoryTier tier;
  final List<Story> stories;

  int get storyCount => stories.length;

  List<String> get storyNames {
    return List.unmodifiable(stories.map((story) => story.name));
  }
}

class ChartStoryEntry {
  ChartStoryEntry({required this.group, required this.story})
    : contract = chartStoryContractRegistry.contractForStoryName(story.name),
      pathSegments = List.unmodifiable(_storyPathSegments(story.name)),
      searchableText = _normalizedSearchText([
        group.id,
        group.label,
        group.description,
        ...group.category.searchValues,
        group.tier.key,
        group.tier.label,
        group.tier.description,
        story.name,
        story.description,
        ...?chartStoryContractRegistry
            .contractForStoryName(story.name)
            ?.searchValues,
      ]);

  final ChartStoryGroup group;
  final Story story;
  final ChartStoryContract? contract;
  final List<String> pathSegments;
  final String searchableText;

  String get name => story.name;

  String get groupId => group.id;

  String get groupLabel => group.label;

  ChartStoryCategory get category => group.category;

  String get categoryId => category.id;

  String get categoryLabel => category.label;

  ChartStoryTier get tier => group.tier;

  String get tierKey => tier.key;

  String get tierLabel => tier.label;

  String? get root => pathSegment(0);

  String? get section => contract?.section ?? pathSegment(1);

  String? get dataShape {
    final contractedDataShape = contract?.dataShape;
    if (contractedDataShape != null) {
      return contractedDataShape;
    }

    if (section != 'By Data Shape') {
      return null;
    }

    return pathSegment(2);
  }

  String? get family {
    final contractedFamily = contract?.family;
    if (contractedFamily != null) {
      return contractedFamily;
    }

    if (section == 'By Data Shape') {
      return pathSegment(3);
    }

    return pathSegment(2);
  }

  String? get variant {
    final contractedVariant = contract?.variant;
    if (contractedVariant != null) {
      return contractedVariant;
    }

    if (section == 'By Data Shape') {
      return pathSegment(4);
    }

    return pathSegment(3);
  }

  List<String> get tags => contract?.tags ?? const [];

  List<String> get useCases => contract?.useCases ?? const [];

  List<ChartStoryKnobSpec> get knobs => contract?.knobs ?? const [];

  Map<String, Object?>? get sampleJson => contract?.sampleJson;

  String? get sampleCode => contract?.sampleCode;

  bool get hasSampleJson => contract?.hasSampleJson ?? false;

  bool get hasSampleCode => contract?.hasSampleCode ?? false;

  bool get isContractReady {
    return contract != null &&
        knobs.isNotEmpty &&
        hasSampleJson &&
        hasSampleCode;
  }

  String? get leaf {
    if (pathSegments.isEmpty) {
      return null;
    }

    return pathSegments.last;
  }

  String get breadcrumb {
    return pathSegments.skip(1).join(' / ');
  }

  String? pathSegment(int index) {
    if (index < 0 || index >= pathSegments.length) {
      return null;
    }

    return pathSegments[index];
  }

  bool matchesQuery(String query) {
    final tokens = _searchTokens(query);

    if (tokens.isEmpty) {
      return true;
    }

    return tokens.every(searchableText.contains);
  }
}

class ChartStoryCatalog {
  ChartStoryCatalog(Iterable<ChartStoryGroup> groups)
    : this._(List.unmodifiable(groups));

  ChartStoryCatalog._(this.groups)
    : stories = List.unmodifiable(flattenChartStoryGroups(groups)),
      categories = List.unmodifiable(_categories(groups)),
      entries = List.unmodifiable(_storyEntries(groups)),
      categoriesById = _categoriesById(groups),
      groupsById = _groupsById(groups),
      storiesByName = _storiesByName(groups),
      groupsByStoryName = _groupsByStoryName(groups),
      entriesByName = _entriesByName(groups),
      duplicateGroupIds = _duplicateValues(groups.map((group) => group.id)),
      duplicateStoryNames = _duplicateValues(
        groups.expand((group) => group.storyNames),
      );

  final List<ChartStoryGroup> groups;
  final List<Story> stories;
  final List<ChartStoryCategory> categories;
  final List<ChartStoryEntry> entries;
  final Map<String, ChartStoryCategory> categoriesById;
  final Map<String, ChartStoryGroup> groupsById;
  final Map<String, Story> storiesByName;
  final Map<String, ChartStoryGroup> groupsByStoryName;
  final Map<String, ChartStoryEntry> entriesByName;
  final List<String> duplicateGroupIds;
  final List<String> duplicateStoryNames;

  int get groupCount => groups.length;

  int get storyCount => stories.length;

  int get categoryCount => categories.length;

  bool get hasDuplicateGroupIds => duplicateGroupIds.isNotEmpty;

  bool get hasDuplicateStoryNames => duplicateStoryNames.isNotEmpty;

  ChartStoryGroup? groupById(String id) {
    return groupsById[id];
  }

  ChartStoryCategory? categoryById(String id) {
    return categoriesById[id];
  }

  Story? storyByName(String name) {
    return storiesByName[name];
  }

  ChartStoryEntry? entryByName(String name) {
    return entriesByName[name];
  }

  ChartStoryGroup? groupForStoryName(String storyName) {
    return groupsByStoryName[storyName];
  }

  List<String> get sections {
    return _uniqueEntryValues(entries.map((entry) => entry.section));
  }

  List<String> get dataShapes {
    return _uniqueEntryValues(entries.map((entry) => entry.dataShape));
  }

  List<String> get families {
    return _uniqueEntryValues(entries.map((entry) => entry.family));
  }

  List<String> get tierKeys {
    return _uniqueEntryValues(entries.map((entry) => entry.tierKey));
  }

  List<ChartStoryEntry> entriesForSection(String section) {
    return List.unmodifiable(
      entries.where((entry) => entry.section == section),
    );
  }

  List<ChartStoryEntry> entriesForCategory(String categoryLabel) {
    return List.unmodifiable(
      entries.where((entry) => entry.categoryLabel == categoryLabel),
    );
  }

  List<ChartStoryEntry> entriesForTier(String tierKey) {
    return List.unmodifiable(
      entries.where((entry) => entry.tierKey == tierKey),
    );
  }

  List<ChartStoryEntry> entriesForDataShape(String dataShape) {
    return List.unmodifiable(
      entries.where((entry) => entry.dataShape == dataShape),
    );
  }

  List<ChartStoryEntry> entriesForFamily(String family) {
    return List.unmodifiable(entries.where((entry) => entry.family == family));
  }

  List<ChartStoryEntry> entriesForGroupId(String groupId) {
    return List.unmodifiable(
      entries.where((entry) => entry.groupId == groupId),
    );
  }

  List<ChartStoryEntry> entriesMatchingQuery(String query) {
    return List.unmodifiable(
      entries.where((entry) => entry.matchesQuery(query)),
    );
  }
}

final chartStoryGroups = [
  ChartStoryGroup(
    id: 'data-shape-gallery',
    label: 'Data Shape Galleries',
    description:
        'Overview and broad family galleries for discovering available chart families.',
    category: chartStoryCategoryDiscover,
    stories: chartDataShapeGalleryStories,
  ),
  ChartStoryGroup(
    id: 'tools',
    label: 'Tools',
    description:
        'Diagnostics, safety, export, performance, and authoring utilities.',
    category: chartStoryCategoryTooling,
    stories: chartToolStories,
  ),
  ChartStoryGroup(
    id: 'cartesian-exploration',
    label: 'Cartesian Exploration',
    description: 'Interactive line, area, and smart type-switching stories.',
    category: chartStoryCategoryCoreShapes,
    stories: chartCartesianExplorationStories,
  ),
  ChartStoryGroup(
    id: 'cartesian-variants',
    label: 'Cartesian Variants',
    description: 'Bar, scatter, and other Cartesian chart variants.',
    category: chartStoryCategoryCoreShapes,
    stories: chartCartesianVariantStories,
  ),
  ChartStoryGroup(
    id: 'matrix',
    label: 'Matrix',
    description: 'Matrix and heatmap-oriented chart examples.',
    category: chartStoryCategoryCoreShapes,
    tier: ChartStoryTier.pro,
    stories: chartMatrixStories,
  ),
  ChartStoryGroup(
    id: 'financial',
    label: 'Financial',
    description: 'Finance-oriented analytical chart examples.',
    category: chartStoryCategoryDomainSpecialized,
    tier: ChartStoryTier.pro,
    stories: chartFinancialStories,
  ),
];

final chartStoryCatalog = ChartStoryCatalog(chartStoryGroups);

List<Story> flattenChartStoryGroups(Iterable<ChartStoryGroup> groups) {
  return [for (final group in groups) ...group.stories];
}

ChartStoryGroup? findChartStoryGroupById(
  String id, {
  Iterable<ChartStoryGroup>? groups,
}) {
  if (groups == null) {
    return chartStoryCatalog.groupById(id);
  }

  return ChartStoryCatalog(groups).groupById(id);
}

Story? findChartStoryByName(String name, {Iterable<ChartStoryGroup>? groups}) {
  if (groups == null) {
    return chartStoryCatalog.storyByName(name);
  }

  return ChartStoryCatalog(groups).storyByName(name);
}

ChartStoryGroup? findChartStoryGroupForStoryName(
  String storyName, {
  Iterable<ChartStoryGroup>? groups,
}) {
  if (groups == null) {
    return chartStoryCatalog.groupForStoryName(storyName);
  }

  return ChartStoryCatalog(groups).groupForStoryName(storyName);
}

List<ChartStoryCategory> _categories(Iterable<ChartStoryGroup> groups) {
  final categoriesById = <String, ChartStoryCategory>{};

  for (final group in groups) {
    categoriesById.putIfAbsent(group.category.id, () => group.category);
  }

  return List.unmodifiable(categoriesById.values);
}

Map<String, ChartStoryCategory> _categoriesById(
  Iterable<ChartStoryGroup> groups,
) {
  final categoriesById = <String, ChartStoryCategory>{};

  for (final group in groups) {
    categoriesById.putIfAbsent(group.category.id, () => group.category);
  }

  return Map.unmodifiable(categoriesById);
}

Map<String, ChartStoryGroup> _groupsById(Iterable<ChartStoryGroup> groups) {
  final groupsById = <String, ChartStoryGroup>{};

  for (final group in groups) {
    groupsById.putIfAbsent(group.id, () => group);
  }

  return Map.unmodifiable(groupsById);
}

Map<String, Story> _storiesByName(Iterable<ChartStoryGroup> groups) {
  final storiesByName = <String, Story>{};

  for (final group in groups) {
    for (final story in group.stories) {
      storiesByName.putIfAbsent(story.name, () => story);
    }
  }

  return Map.unmodifiable(storiesByName);
}

Map<String, ChartStoryGroup> _groupsByStoryName(
  Iterable<ChartStoryGroup> groups,
) {
  final groupsByStoryName = <String, ChartStoryGroup>{};

  for (final group in groups) {
    for (final story in group.stories) {
      groupsByStoryName.putIfAbsent(story.name, () => group);
    }
  }

  return Map.unmodifiable(groupsByStoryName);
}

List<ChartStoryEntry> _storyEntries(Iterable<ChartStoryGroup> groups) {
  return [
    for (final group in groups)
      for (final story in group.stories)
        ChartStoryEntry(group: group, story: story),
  ];
}

Map<String, ChartStoryEntry> _entriesByName(Iterable<ChartStoryGroup> groups) {
  final entriesByName = <String, ChartStoryEntry>{};

  for (final entry in _storyEntries(groups)) {
    entriesByName.putIfAbsent(entry.name, () => entry);
  }

  return Map.unmodifiable(entriesByName);
}

List<String> _duplicateValues(Iterable<String> values) {
  final seen = <String>{};
  final duplicates = <String>{};

  for (final value in values) {
    if (!seen.add(value)) {
      duplicates.add(value);
    }
  }

  return List.unmodifiable(duplicates);
}

List<String> _uniqueEntryValues(Iterable<String?> values) {
  final uniqueValues = <String>{};

  for (final value in values) {
    if (value != null && value.isNotEmpty) {
      uniqueValues.add(value);
    }
  }

  return List.unmodifiable(uniqueValues);
}

List<String> _storyPathSegments(String name) {
  return name
      .split('/')
      .map((segment) => segment.trim())
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
}

String _normalizedSearchText(Iterable<Object?> values) {
  return values
      .where((value) => value != null)
      .map((value) => value.toString().toLowerCase())
      .join(' ');
}

List<String> _searchTokens(String query) {
  return query
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
}
