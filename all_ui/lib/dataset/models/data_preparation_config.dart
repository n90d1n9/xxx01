class DataPreparationConfig {
  final bool enableCleaning;
  final bool removeEmptyLines;
  final bool deduplication;
  final int? maxSamples;
  final double trainTestSplit;
  final double? validationSplit;
  final bool shuffle;
  final int? randomSeed;
  final bool enableTokenization;
  final int? maxTokenLength;
  final bool enableAugmentation;
  final List<String> augmentationTypes;
  final Map<String, dynamic> customPreprocessing;
  DataPreparationConfig({
    this.enableCleaning = true,
    this.removeEmptyLines = true,
    this.deduplication = true,
    this.maxSamples,
    this.trainTestSplit = 0.9,
    this.validationSplit,
    this.shuffle = true,
    this.randomSeed,
    this.enableTokenization = true,
    this.maxTokenLength,
    this.enableAugmentation = false,
    this.augmentationTypes = const [],
    this.customPreprocessing = const {},
  });
  Map<String, dynamic> toJson() => {
    'enableCleaning': enableCleaning,
    'removeEmptyLines': removeEmptyLines,
    'deduplication': deduplication,
    'maxSamples': maxSamples,
    'trainTestSplit': trainTestSplit,
    'validationSplit': validationSplit,
    'shuffle': shuffle,
    'randomSeed': randomSeed,
    'enableTokenization': enableTokenization,
    'maxTokenLength': maxTokenLength,
    'enableAugmentation': enableAugmentation,
    'augmentationTypes': augmentationTypes,
    'customPreprocessing': customPreprocessing,
  };
}
