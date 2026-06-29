import '../../schema/validation_result.dart';
import '../mcp/mcp_tool.dart';
import 'agent_context.dart';
import 'agent_response.dart';
import 'agent_type.dart';

abstract class AIAgent {
  final String id;
  final String name;
  final String description;
  final AgentType type;
  final Map<String, dynamic> config;
  final List<AgentCapability> capabilities;
  final List<MCPTool> tools;

  const AIAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.config,
    required this.capabilities,
    required this.tools,
  });

  /// Execute agent with given context
  Future<AgentResponse> execute(AgentContext context);

  /// Validate agent configuration
  ValidationResult validate();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'config': config,
    'capabilities': capabilities.map((c) => c.name).toList(),
    'tools': tools.map((t) => t.toJson()).toList(),
  };
}
