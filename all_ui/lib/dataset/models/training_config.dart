import 'training_method.dart';
import 'base_model.dart';
import 'job_status.dart';

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
