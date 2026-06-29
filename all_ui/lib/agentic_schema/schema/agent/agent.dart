import '../common/analytics.dart';
import '../model/llm_config.dart';
import '../connection/integration_connector.dart';
import '../common/deployment.dart';
import '../integration/integration.dart';
import '../memory/memory_config.dart';
import '../common/metadata.dart';
import '../security/permission.dart';
import '../profile/personality.dart';
import '../security/safety.dart';
import '../tool/tool.dart';
import '../workflow/workflow.dart';
import 'capabilities.dart';

enum AgentType {
  conversational,
  task,
  autonomous,
  reactive,
  multiAgent,
  integration,
}

enum AgentStatus { draft, active, paused, archived }

class Agent {
  final String id;
  final String name;
  final String? description;
  final AgentType type;
  final AgentStatus? status;
  final LLMConfig llmConfig;
  final MemoryConfig? memoryConfig;
  final List<Tool>? tools;
  final List<Workflow>? workflows;
  final List<IntegrationConnector>? connectors;
  final Personality? personality;
  final Capabilities? capabilities;
  final Safety? safety;
  final Analytics? analytics;
  final Deployment? deployment;
  final List<Integration>? integrations;
  final Permissions? permissions;
  final Metadata? metadata;

  Agent({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.status,
    required this.llmConfig,
    this.memoryConfig,
    this.tools,
    this.workflows,
    this.connectors,
    this.personality,
    this.capabilities,
    this.safety,
    this.analytics,
    this.deployment,
    this.integrations,
    this.permissions,
    this.metadata,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: _parseAgentType(json['type']),
      status: json['status'] != null ? _parseAgentStatus(json['status']) : null,
      llmConfig: LLMConfig.fromJson(json['llmConfig'] as Map<String, dynamic>),
      memoryConfig: json['memoryConfig'] != null
          ? MemoryConfig.fromJson(json['memoryConfig'] as Map<String, dynamic>)
          : null,
      tools: json['tools'] != null
          ? (json['tools'] as List)
                .map((e) => Tool.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      workflows: json['workflows'] != null
          ? (json['workflows'] as List)
                .map((e) => Workflow.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      connectors: json['connectors'] != null
          ? (json['connectors'] as List)
                .map(
                  (e) =>
                      IntegrationConnector.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      personality: json['personality'] != null
          ? Personality.fromJson(json['personality'] as Map<String, dynamic>)
          : null,
      capabilities: json['capabilities'] != null
          ? Capabilities.fromJson(json['capabilities'] as Map<String, dynamic>)
          : null,
      safety: json['safety'] != null
          ? Safety.fromJson(json['safety'] as Map<String, dynamic>)
          : null,
      analytics: json['analytics'] != null
          ? Analytics.fromJson(json['analytics'] as Map<String, dynamic>)
          : null,
      deployment: json['deployment'] != null
          ? Deployment.fromJson(json['deployment'] as Map<String, dynamic>)
          : null,
      integrations: json['integrations'] != null
          ? (json['integrations'] as List)
                .map((e) => Integration.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      permissions: json['permissions'] != null
          ? Permissions.fromJson(json['permissions'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'type': type.name,
      if (status != null) 'status': status!.name,
      'llmConfig': llmConfig.toJson(),
      if (memoryConfig != null) 'memoryConfig': memoryConfig!.toJson(),
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (workflows != null)
        'workflows': workflows!.map((e) => e.toJson()).toList(),
      if (connectors != null)
        'connectors': connectors!.map((e) => e.toJson()).toList(),
      if (personality != null) 'personality': personality!.toJson(),
      if (capabilities != null) 'capabilities': capabilities!.toJson(),
      if (safety != null) 'safety': safety!.toJson(),
      if (analytics != null) 'analytics': analytics!.toJson(),
      if (deployment != null) 'deployment': deployment!.toJson(),
      if (integrations != null)
        'integrations': integrations!.map((e) => e.toJson()).toList(),
      if (permissions != null) 'permissions': permissions!.toJson(),
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  static AgentType _parseAgentType(dynamic value) {
    if (value is AgentType) return value;
    final stringValue = value.toString();
    return AgentType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => AgentType.task,
    );
  }

  static AgentStatus _parseAgentStatus(dynamic value) {
    if (value is AgentStatus) return value;
    final stringValue = value.toString();
    return AgentStatus.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => AgentStatus.draft,
    );
  }

  Agent copyWith({
    String? id,
    String? name,
    String? description,
    AgentType? type,
    AgentStatus? status,
    LLMConfig? llmConfig,
    MemoryConfig? memoryConfig,
    List<Tool>? tools,
    List<Workflow>? workflows,
    List<IntegrationConnector>? connectors,
    Personality? personality,
    Capabilities? capabilities,
    Safety? safety,
    Analytics? analytics,
    Deployment? deployment,
    List<Integration>? integrations,
    Permissions? permissions,
    Metadata? metadata,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      llmConfig: llmConfig ?? this.llmConfig,
      memoryConfig: memoryConfig ?? this.memoryConfig,
      tools: tools ?? this.tools,
      workflows: workflows ?? this.workflows,
      connectors: connectors ?? this.connectors,
      personality: personality ?? this.personality,
      capabilities: capabilities ?? this.capabilities,
      safety: safety ?? this.safety,
      analytics: analytics ?? this.analytics,
      deployment: deployment ?? this.deployment,
      integrations: integrations ?? this.integrations,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
    );
  }
}
