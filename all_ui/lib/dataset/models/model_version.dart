import 'job_status.dart';

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
