import 'chart_story_groups.dart';

class ChartStoryContractStarter {
  const ChartStoryContractStarter({
    required this.variableName,
    required this.code,
  });

  final String variableName;
  final String code;
}

class ChartStoryContractStarterBundle {
  ChartStoryContractStarterBundle({
    required Iterable<ChartStoryContractStarter> starters,
    required this.hiddenCount,
  }) : starters = List.unmodifiable(starters);

  final List<ChartStoryContractStarter> starters;
  final int hiddenCount;

  int get count => starters.length;

  bool get isEmpty => starters.isEmpty;

  String get code => starters.map((starter) => starter.code).join('\n\n');
}

ChartStoryContractStarter chartStoryContractStarterForEntry(
  ChartStoryEntry entry,
) {
  final variableName =
      '${_lowerCamelIdentifier(entry.pathSegments.skip(1))}'
      'StoryContract';
  final section = entry.section;
  final dataShape = entry.dataShape;
  final family = entry.family;
  final variant = entry.variant;
  final title = entry.leaf ?? entry.family ?? entry.name;
  final tags = _starterTags(entry);
  final chartType = _slug(entry.family ?? entry.leaf ?? 'chart');
  final summary = entry.story.description ?? entry.name;

  return ChartStoryContractStarter(
    variableName: variableName,
    code:
        '''final $variableName = ChartStoryContract(
${_contractField('section', section)}${_contractField('dataShape', dataShape)}${_contractField('family', family)}${_contractField('variant', variant)}  summary: '${_escapeDartString(summary)}',
  tags: const [${tags.map((tag) => "'${_escapeDartString(tag)}'").join(', ')}],
  useCases: const [
    'Replace with a concrete business, education, or operations use case.',
  ],
  knobs: const [],
  sampleJson: const {
    'type': '$chartType',
    'title': '${_escapeDartString(title)}',
    'series': [
      {'name': 'Example', 'data': [12, 18, 24]},
    ],
  },
  sampleCode: \'\'\'
TenunChartFromJson(
  jsonConfig: const {
    'type': '$chartType',
    'series': [
      {'name': 'Example', 'data': [12, 18, 24]},
    ],
  },
)
\'\'\',
);''',
  );
}

ChartStoryContractStarterBundle chartStoryContractStarterBundleForEntries(
  Iterable<ChartStoryEntry> entries, {
  int limit = 6,
}) {
  final safeLimit = limit < 0 ? 0 : limit;
  final entryList = entries.toList(growable: false);
  final selectedEntries = entryList.take(safeLimit);

  return ChartStoryContractStarterBundle(
    starters: [
      for (final entry in selectedEntries)
        chartStoryContractStarterForEntry(entry),
    ],
    hiddenCount: entryList.length > safeLimit
        ? entryList.length - safeLimit
        : 0,
  );
}

String _contractField(String name, String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }

  return "  $name: '${_escapeDartString(value)}',\n";
}

List<String> _starterTags(ChartStoryEntry entry) {
  final tags = <String>{};

  for (final value in [
    entry.section,
    entry.dataShape,
    entry.family,
    entry.variant,
  ]) {
    final slug = _slug(value);
    if (slug.isNotEmpty && slug != 'by-data-shape') {
      tags.add(slug);
    }
  }

  return tags.isEmpty ? const ['chart'] : List.unmodifiable(tags);
}

String _lowerCamelIdentifier(Iterable<String> values) {
  final words = values.expand(_identifierWords).toList(growable: false);
  if (words.isEmpty) {
    return 'chart';
  }

  final buffer = StringBuffer(words.first);
  for (final word in words.skip(1)) {
    buffer
      ..write(word[0].toUpperCase())
      ..write(word.substring(1));
  }

  return buffer.toString();
}

Iterable<String> _identifierWords(String value) {
  return value
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.isNotEmpty);
}

String _slug(String? value) {
  if (value == null) {
    return '';
  }

  return value
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .join('-');
}

String _escapeDartString(String value) {
  return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}
