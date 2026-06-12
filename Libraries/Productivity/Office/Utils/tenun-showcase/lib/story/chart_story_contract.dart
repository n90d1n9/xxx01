import 'package:storybook_flutter/storybook_flutter.dart';

enum ChartStoryKnobType {
  boolean,
  options,
  sliderInt,
  nullableSliderInt,
  sliderDouble,
  text,
}

class ChartStoryKnobSpec {
  const ChartStoryKnobSpec({
    required this.key,
    required this.label,
    required this.type,
    this.group = 'General',
    this.description,
    this.defaultValue,
    this.min,
    this.max,
    this.divisions,
    this.options = const [],
  });

  const ChartStoryKnobSpec.boolean({
    required String key,
    required String label,
    String group = 'General',
    String? description,
    bool defaultValue = false,
  }) : this(
         key: key,
         label: label,
         type: ChartStoryKnobType.boolean,
         group: group,
         description: description,
         defaultValue: defaultValue,
       );

  const ChartStoryKnobSpec.options({
    required String key,
    required String label,
    required List<String> options,
    String group = 'General',
    String? description,
    Object? defaultValue,
  }) : this(
         key: key,
         label: label,
         type: ChartStoryKnobType.options,
         group: group,
         description: description,
         defaultValue: defaultValue,
         options: options,
       );

  const ChartStoryKnobSpec.sliderInt({
    required String key,
    required String label,
    required int min,
    required int max,
    String group = 'General',
    String? description,
    int? defaultValue,
    int? divisions,
  }) : this(
         key: key,
         label: label,
         type: ChartStoryKnobType.sliderInt,
         group: group,
         description: description,
         defaultValue: defaultValue,
         min: min,
         max: max,
         divisions: divisions,
       );

  final String key;
  final String label;
  final ChartStoryKnobType type;
  final String group;
  final String? description;
  final Object? defaultValue;
  final num? min;
  final num? max;
  final int? divisions;
  final List<String> options;

  Iterable<Object?> get searchValues sync* {
    yield key;
    yield label;
    yield group;
    yield description;
    yield defaultValue;
    yield type.name;
    yield* options;
  }
}

class ChartStoryContract {
  ChartStoryContract({
    this.section,
    this.dataShape,
    this.family,
    this.variant,
    this.summary,
    Iterable<String> tags = const [],
    Iterable<String> useCases = const [],
    Iterable<ChartStoryKnobSpec> knobs = const [],
    Map<String, Object?>? sampleJson,
    this.sampleCode,
  }) : tags = List.unmodifiable(tags),
       useCases = List.unmodifiable(useCases),
       knobs = List.unmodifiable(knobs),
       sampleJson = sampleJson == null ? null : Map.unmodifiable(sampleJson);

  final String? section;
  final String? dataShape;
  final String? family;
  final String? variant;
  final String? summary;
  final List<String> tags;
  final List<String> useCases;
  final List<ChartStoryKnobSpec> knobs;
  final Map<String, Object?>? sampleJson;
  final String? sampleCode;

  bool get hasSampleJson => sampleJson != null;

  bool get hasSampleCode => sampleCode != null && sampleCode!.trim().isNotEmpty;

  Iterable<Object?> get searchValues sync* {
    yield section;
    yield dataShape;
    yield family;
    yield variant;
    yield summary;
    yield* tags;
    yield* useCases;

    for (final knob in knobs) {
      yield* knob.searchValues;
    }

    yield sampleJson;
    yield sampleCode;
  }
}

class ChartStoryContractRegistry {
  final _contractsByStoryName = <String, ChartStoryContract>{};

  Map<String, ChartStoryContract> get contractsByStoryName {
    return Map.unmodifiable(_contractsByStoryName);
  }

  void register({
    required String storyName,
    required ChartStoryContract contract,
  }) {
    _contractsByStoryName[storyName] = contract;
  }

  void registerStory(Story story, ChartStoryContract? contract) {
    if (contract == null) {
      return;
    }

    register(storyName: story.name, contract: contract);
  }

  ChartStoryContract? contractForStoryName(String storyName) {
    return _contractsByStoryName[storyName];
  }
}

final chartStoryContractRegistry = ChartStoryContractRegistry();
