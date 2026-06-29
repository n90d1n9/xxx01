import 'deployment_config.dart';
import 'pipeline_stage.dart';
import 'data_preparation_config.dart';
import 'evaluation_config.dart';
import 'model_version.dart';
import 'training_config.dart';

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
