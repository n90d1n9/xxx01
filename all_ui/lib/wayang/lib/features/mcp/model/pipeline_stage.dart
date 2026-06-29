import 'mcp_environment.dart';

class MCPPipelineStage {
  final String name;
  final MCPEnvironment environment; // dev, staging, prod
  final List<String> steps;
  final bool requiresApproval;
  final bool autoExecute;

  MCPPipelineStage({
    required this.name,
    required this.environment,
    required this.steps,
    this.requiresApproval = false,
    this.autoExecute = false,
  });
}
