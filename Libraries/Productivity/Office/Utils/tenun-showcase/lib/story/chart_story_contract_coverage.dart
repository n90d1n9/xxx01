import 'chart_story_groups.dart';

enum ChartStoryContractStatusFilter {
  all,
  ready,
  needsWork,
  contracted,
  needsContract,
  needsKnobs,
  needsSampleJson,
  needsSampleCode,
}

const chartStoryContractStatusFilters = [
  ChartStoryContractStatusFilter.all,
  ChartStoryContractStatusFilter.ready,
  ChartStoryContractStatusFilter.needsWork,
  ChartStoryContractStatusFilter.contracted,
  ChartStoryContractStatusFilter.needsContract,
  ChartStoryContractStatusFilter.needsKnobs,
  ChartStoryContractStatusFilter.needsSampleJson,
  ChartStoryContractStatusFilter.needsSampleCode,
];

const _missingContractLabel = 'contract';
const _missingKnobsLabel = 'knobs';
const _missingSampleJsonLabel = 'sample JSON';
const _missingSampleCodeLabel = 'sample code';

extension ChartStoryContractStatusFilterLabel
    on ChartStoryContractStatusFilter {
  String get label {
    return switch (this) {
      ChartStoryContractStatusFilter.all => 'All',
      ChartStoryContractStatusFilter.ready => 'Ready',
      ChartStoryContractStatusFilter.needsWork => 'Needs work',
      ChartStoryContractStatusFilter.contracted => 'Contracted',
      ChartStoryContractStatusFilter.needsContract => 'Needs contract',
      ChartStoryContractStatusFilter.needsKnobs => 'Needs knobs',
      ChartStoryContractStatusFilter.needsSampleJson => 'Needs JSON',
      ChartStoryContractStatusFilter.needsSampleCode => 'Needs code',
    };
  }
}

bool chartStoryMatchesContractStatus(
  ChartStoryEntry entry,
  ChartStoryContractStatusFilter status,
) {
  return switch (status) {
    ChartStoryContractStatusFilter.all => true,
    ChartStoryContractStatusFilter.ready => entry.isContractReady,
    ChartStoryContractStatusFilter.needsWork => !entry.isContractReady,
    ChartStoryContractStatusFilter.contracted => entry.contract != null,
    ChartStoryContractStatusFilter.needsContract => entry.contract == null,
    ChartStoryContractStatusFilter.needsKnobs => entry.knobs.isEmpty,
    ChartStoryContractStatusFilter.needsSampleJson => !entry.hasSampleJson,
    ChartStoryContractStatusFilter.needsSampleCode => !entry.hasSampleCode,
  };
}

List<String> chartStoryContractMissingParts(ChartStoryEntry entry) {
  final missingParts = <String>[];

  if (entry.contract == null) {
    missingParts.addAll(const [
      _missingContractLabel,
      _missingKnobsLabel,
      _missingSampleJsonLabel,
      _missingSampleCodeLabel,
    ]);
  } else {
    if (entry.knobs.isEmpty) {
      missingParts.add(_missingKnobsLabel);
    }

    if (!entry.hasSampleJson) {
      missingParts.add(_missingSampleJsonLabel);
    }

    if (!entry.hasSampleCode) {
      missingParts.add(_missingSampleCodeLabel);
    }
  }

  return List.unmodifiable(missingParts);
}

String chartStoryContractReadinessLabel(ChartStoryEntry entry) {
  if (entry.isContractReady) {
    return 'Ready';
  }

  if (entry.contract == null) {
    return 'Needs contract';
  }

  return 'Needs work';
}

class ChartStoryContractCoverage {
  ChartStoryContractCoverage._({
    required Iterable<ChartStoryEntry> entries,
    required Iterable<ChartStoryEntry> contractedEntries,
    required Iterable<ChartStoryEntry> readyEntries,
    required Iterable<ChartStoryEntry> knobEntries,
    required Iterable<ChartStoryEntry> sampleJsonEntries,
    required Iterable<ChartStoryEntry> sampleCodeEntries,
    required Iterable<ChartStoryContractGap> gaps,
  }) : entries = List.unmodifiable(entries),
       contractedEntries = List.unmodifiable(contractedEntries),
       readyEntries = List.unmodifiable(readyEntries),
       knobEntries = List.unmodifiable(knobEntries),
       sampleJsonEntries = List.unmodifiable(sampleJsonEntries),
       sampleCodeEntries = List.unmodifiable(sampleCodeEntries),
       gaps = List.unmodifiable(gaps);

  factory ChartStoryContractCoverage.fromCatalog(ChartStoryCatalog catalog) {
    return ChartStoryContractCoverage.fromEntries(catalog.entries);
  }

  factory ChartStoryContractCoverage.fromEntries(
    Iterable<ChartStoryEntry> entries,
  ) {
    final entryList = entries.toList(growable: false);
    final contractedEntries = <ChartStoryEntry>[];
    final readyEntries = <ChartStoryEntry>[];
    final knobEntries = <ChartStoryEntry>[];
    final sampleJsonEntries = <ChartStoryEntry>[];
    final sampleCodeEntries = <ChartStoryEntry>[];
    final gaps = <ChartStoryContractGap>[];

    for (final entry in entryList) {
      final missingParts = chartStoryContractMissingParts(entry);

      if (entry.contract != null) {
        contractedEntries.add(entry);

        if (entry.knobs.isNotEmpty) {
          knobEntries.add(entry);
        }

        if (entry.hasSampleJson) {
          sampleJsonEntries.add(entry);
        }

        if (entry.hasSampleCode) {
          sampleCodeEntries.add(entry);
        }
      }

      if (missingParts.isEmpty) {
        readyEntries.add(entry);
      } else {
        gaps.add(
          ChartStoryContractGap(entry: entry, missingParts: missingParts),
        );
      }
    }

    return ChartStoryContractCoverage._(
      entries: entryList,
      contractedEntries: contractedEntries,
      readyEntries: readyEntries,
      knobEntries: knobEntries,
      sampleJsonEntries: sampleJsonEntries,
      sampleCodeEntries: sampleCodeEntries,
      gaps: gaps,
    );
  }

  final List<ChartStoryEntry> entries;
  final List<ChartStoryEntry> contractedEntries;
  final List<ChartStoryEntry> readyEntries;
  final List<ChartStoryEntry> knobEntries;
  final List<ChartStoryEntry> sampleJsonEntries;
  final List<ChartStoryEntry> sampleCodeEntries;
  final List<ChartStoryContractGap> gaps;

  int get totalCount => entries.length;

  int get contractedCount => contractedEntries.length;

  int get readyCount => readyEntries.length;

  int get knobCount => knobEntries.length;

  int get sampleJsonCount => sampleJsonEntries.length;

  int get sampleCodeCount => sampleCodeEntries.length;

  int get missingContractCount => totalCount - contractedCount;

  int get gapCount => gaps.length;

  double get contractRatio => _ratio(contractedCount, totalCount);

  double get readyRatio => _ratio(readyCount, totalCount);

  bool get isComplete => totalCount > 0 && readyCount == totalCount;

  static double _ratio(int count, int total) {
    if (total <= 0) {
      return 0;
    }

    return count / total;
  }
}

class ChartStoryContractGap {
  ChartStoryContractGap({
    required this.entry,
    required Iterable<String> missingParts,
  }) : missingParts = List.unmodifiable(missingParts);

  final ChartStoryEntry entry;
  final List<String> missingParts;

  String get label => entry.leaf ?? entry.name;

  String get missingLabel => missingParts.join(', ');
}

String chartStoryContractCoverageRatioLabel(double ratio) {
  if (!ratio.isFinite) {
    return '0%';
  }

  return '${(ratio.clamp(0, 1) * 100).round()}%';
}
