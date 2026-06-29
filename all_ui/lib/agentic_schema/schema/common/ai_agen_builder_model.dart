import '../agent/agent.dart';
import 'ai_agent_builder_config.dart';
import '../code/code_generation.dart';
import '../integration/integration_config.dart';
import 'project.dart';
import 'shared_resources.dart';
import '../config/visual_config.dart';

class AIAgentBuilderModel {
  final Project project;
  final List<Agent> agents;
  final SharedResources? sharedResources;
  final IntegrationConfig? integrationConfig;
  final VisualConfig? visualConfig;
  final CodeGeneration? codeGeneration;
  final AIAgentBuilderConfig? config;

  AIAgentBuilderModel({
    required this.project,
    required this.agents,
    this.sharedResources,
    this.integrationConfig,
    this.visualConfig,
    this.codeGeneration,
    this.config,
  });

  factory AIAgentBuilderModel.fromJson(Map<String, dynamic> json) {
    return AIAgentBuilderModel(
      project: Project.fromJson(json['project'] as Map<String, dynamic>),
      agents: (json['agents'] as List)
          .map((e) => Agent.fromJson(e as Map<String, dynamic>))
          .toList(),
      sharedResources: json['sharedResources'] != null
          ? SharedResources.fromJson(
              json['sharedResources'] as Map<String, dynamic>,
            )
          : null,
      integrationConfig: json['integrationConfig'] != null
          ? IntegrationConfig.fromJson(
              json['integrationConfig'] as Map<String, dynamic>,
            )
          : null,
      visualConfig: json['visualConfig'] != null
          ? VisualConfig.fromJson(json['visualConfig'] as Map<String, dynamic>)
          : null,
      codeGeneration: json['codeGeneration'] != null
          ? CodeGeneration.fromJson(
              json['codeGeneration'] as Map<String, dynamic>,
            )
          : null,
      config: json['config'] != null
          ? AIAgentBuilderConfig.fromJson(
              json['config'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project': project.toJson(),
      'agents': agents.map((e) => e.toJson()).toList(),
      if (sharedResources != null) 'sharedResources': sharedResources!.toJson(),
      if (integrationConfig != null)
        'integrationConfig': integrationConfig!.toJson(),
      if (visualConfig != null) 'visualConfig': visualConfig!.toJson(),
      if (codeGeneration != null) 'codeGeneration': codeGeneration!.toJson(),
      if (config != null) 'config': config!.toJson(),
    };
  }

  AIAgentBuilderModel copyWith({
    Project? project,
    List<Agent>? agents,
    SharedResources? sharedResources,
    IntegrationConfig? integrationConfig,
    VisualConfig? visualConfig,
    CodeGeneration? codeGeneration,
    AIAgentBuilderConfig? config,
  }) {
    return AIAgentBuilderModel(
      project: project ?? this.project,
      agents: agents ?? this.agents,
      sharedResources: sharedResources ?? this.sharedResources,
      integrationConfig: integrationConfig ?? this.integrationConfig,
      visualConfig: visualConfig ?? this.visualConfig,
      codeGeneration: codeGeneration ?? this.codeGeneration,
      config: config ?? this.config,
    );
  }
}
