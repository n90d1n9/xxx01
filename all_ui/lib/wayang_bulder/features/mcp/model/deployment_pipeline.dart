import 'deployment_status.dart';
import 'pipeline_stage.dart';

class MCPDeploymentPipeline {
  final String id;
  final String name;
  final List<MCPPipelineStage> stages;
  final DateTime createdAt;
  final MCPDeploymentStatus status;
  final String? gitRepository;
  final String? cicdProvider; // github-actions, gitlab-ci, jenkins, etc
  final String? lastDeployedVersion;

  MCPDeploymentPipeline({
    required this.id,
    required this.name,
    required this.stages,
    required this.createdAt,
    required this.status,
    this.gitRepository,
    this.cicdProvider,
    this.lastDeployedVersion,
  });
}
