// ============================================================================
// MLOPS PAGE - Advanced MLOps Features
// ============================================================================

// ============================================================================
// HELPER WIDGETS
// ============================================================================

// ============================================================================
// EXPERIMENTS PAGE - A/B Testing & Hyperparameter Optimization
// ============================================================================

// ============================================================================
// CHAIN OF THOUGHT PAGE - Reasoning & Prompting Strategies
// ============================================================================

// ============================================================================
// DATA PREPARATION PAGE
// ============================================================================

// ============================================================================
// TRAINING CONFIG PAGE - Enhanced with Step Indicator
// ============================================================================

// ============================================================================
// EVALUATION PAGE
// ============================================================================

// ============================================================================
// DEPLOYMENT PAGE
// ============================================================================

// ============================================================================
// MODEL REGISTRY PAGE
// ============================================================================

// ============================================================================
// HELPER WIDGETS
// ============================================================================
// pubspec.yaml dependencies needed:
// flutter_riverpod: ^2.4.0
// riverpod_annotation: ^2.3.0
// freezed_annotation: ^2.4.1
// json_annotation: ^4.8.1
// file_picker: ^6.0.0
// uuid: ^4.0.0
// http: ^1.1.0
// shared_preferences: ^2.2.2
// sqflite: ^2.3.0
// path_provider: ^2.1.1
// fl_chart: ^0.66.0

// ============================================================================
// ENUMS & CONSTANTS
// ============================================================================

enum PipelineStage {
  dataPreparation,
  training,
  evaluation,
  deployment,
  monitoring,
}

enum TrainingMethod {
  fullFineTuning,
  lora,
  qlora,
  prefixTuning,
  pTuning,
  adaptiveLora,
  dpo,
  rlhf,
  continualLearning,
  knowledgeDistillation,
  mixtureOfExperts,
  sparseFineTuning,
  chainOfThought,
  selfConsistency,
  treeOfThoughts,
  reflexion,
}

enum BaseModel {
  llama2_7b,
  llama2_13b,
  llama3_8b,
  mistral_7b,
  phi3_mini,
  gemma_7b,
  gpt2,
  custom,
}

enum DatasetFormat { jsonl, csv, parquet, hf_dataset, sql, mongodb }

enum DatasetSource {
  localFile,
  manualEntry,
  huggingFace,
  cloudStorage,
  database,
  api,
  hybrid,
}

enum JobStatus {
  draft,
  dataPreparation,
  queued,
  training,
  evaluating,
  completed,
  failed,
  cancelled,
  deployed,
}

enum DeploymentTarget { local, cloud, edge, api, huggingface, custom }

enum EvaluationMetric {
  perplexity,
  bleu,
  rouge,
  accuracy,
  f1Score,
  bertscore,
  customMetric,
}

// ============================================================================
// DATA MODELS
// ============================================================================

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

class EvaluationConfig {
  final List<EvaluationMetric> metrics;
  final bool enableHumanEval;
  final int? humanEvalSamples;
  final bool generateReport;
  final bool compareWithBaseline;
  final String? baselineModelPath;
  final List<String> testDatasets;
  final bool enableBiasDetection;
  final bool enableToxicityCheck;

  EvaluationConfig({
    this.metrics = const [
      EvaluationMetric.perplexity,
      EvaluationMetric.accuracy,
    ],
    this.enableHumanEval = false,
    this.humanEvalSamples,
    this.generateReport = true,
    this.compareWithBaseline = false,
    this.baselineModelPath,
    this.testDatasets = const [],
    this.enableBiasDetection = true,
    this.enableToxicityCheck = true,
  });

  Map<String, dynamic> toJson() => {
    'metrics': metrics.map((m) => m.name).toList(),
    'enableHumanEval': enableHumanEval,
    'humanEvalSamples': humanEvalSamples,
    'generateReport': generateReport,
    'compareWithBaseline': compareWithBaseline,
    'baselineModelPath': baselineModelPath,
    'testDatasets': testDatasets,
    'enableBiasDetection': enableBiasDetection,
    'enableToxicityCheck': enableToxicityCheck,
  };
}

class DeploymentConfig {
  final DeploymentTarget target;
  final String? endpointUrl;
  final Map<String, String> environment;
  final int? replicas;
  final String? hardwareAccelerator;
  final bool enableAutoScaling;
  final int? minReplicas;
  final int? maxReplicas;
  final bool enableMonitoring;
  final bool enableLogging;
  final String? containerImage;
  final Map<String, dynamic> customConfig;

  DeploymentConfig({
    required this.target,
    this.endpointUrl,
    this.environment = const {},
    this.replicas = 1,
    this.hardwareAccelerator,
    this.enableAutoScaling = false,
    this.minReplicas,
    this.maxReplicas,
    this.enableMonitoring = true,
    this.enableLogging = true,
    this.containerImage,
    this.customConfig = const {},
  });

  Map<String, dynamic> toJson() => {
    'target': target.name,
    'endpointUrl': endpointUrl,
    'environment': environment,
    'replicas': replicas,
    'hardwareAccelerator': hardwareAccelerator,
    'enableAutoScaling': enableAutoScaling,
    'minReplicas': minReplicas,
    'maxReplicas': maxReplicas,
    'enableMonitoring': enableMonitoring,
    'enableLogging': enableLogging,
    'containerImage': containerImage,
    'customConfig': customConfig,
  };
}

class ModelVersion {
  final String id;
  final String name;
  final String version;
  final DateTime createdAt;
  final String trainingJobId;
  final Map<String, dynamic> metrics;
  final String modelPath;
  final int modelSizeMB;
  final JobStatus status;
  final bool isDeployed;
  final String? deploymentEndpoint;

  ModelVersion({
    required this.id,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.trainingJobId,
    required this.metrics,
    required this.modelPath,
    required this.modelSizeMB,
    required this.status,
    this.isDeployed = false,
    this.deploymentEndpoint,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'trainingJobId': trainingJobId,
    'metrics': metrics,
    'modelPath': modelPath,
    'modelSizeMB': modelSizeMB,
    'status': status.name,
    'isDeployed': isDeployed,
    'deploymentEndpoint': deploymentEndpoint,
  };
}

class CompletePipeline {
  final String id;
  final String name;
  final PipelineStage currentStage;
  final DataPreparationConfig dataPrep;
  final TrainingConfig training;
  final EvaluationConfig evaluation;
  final DeploymentConfig? deployment;
  final List<ModelVersion> modelVersions;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> logs;

  CompletePipeline({
    required this.id,
    required this.name,
    required this.currentStage,
    required this.dataPrep,
    required this.training,
    required this.evaluation,
    this.deployment,
    this.modelVersions = const [],
    required this.createdAt,
    this.updatedAt,
    this.logs = const {},
  });
}

class TrainingConfig {
  final String id;
  final String name;
  final String? description;
  final BaseModel baseModel;
  final String? customModelPath;
  final TrainingMethod method;
  final Map<String, dynamic> methodConfig;
  final Map<String, dynamic> hyperParams;
  final DateTime createdAt;
  final JobStatus status;

  TrainingConfig({
    required this.id,
    required this.name,
    this.description,
    required this.baseModel,
    this.customModelPath,
    required this.method,
    this.methodConfig = const {},
    this.hyperParams = const {},
    required this.createdAt,
    this.status = JobStatus.draft,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'baseModel': baseModel.name,
    'customModelPath': customModelPath,
    'method': method.name,
    'methodConfig': methodConfig,
    'hyperParams': hyperParams,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };
}

// ============================================================================
// STATE MANAGEMENT
// ============================================================================


// ============================================================================
// MAIN NAVIGATION
// ============================================================================

// ============================================================================
// DASHBOARD PAGE
// ============================================================================


// ============================================================================
// PIPELINES PAGE
// ============================================================================

