import '../camel/camel_route.dart';
import '../model/llm_config.dart';
import '../connection/integration_connector.dart';
import '../integration/integration_pattern_template.dart';
import '../tool/tool.dart';
import '../variable/variable.dart';

class SharedResources {
  final List<Variable>? variables;
  final List<Tool>? tools;
  final List<LLMConfig>? llmConfigs;
  final List<IntegrationConnector>? connectors;
  final List<IntegrationPatternTemplate>? integrationPatterns;
  final List<CamelRoute>? camelRoutes;

  SharedResources({
    this.variables,
    this.tools,
    this.llmConfigs,
    this.connectors,
    this.integrationPatterns,
    this.camelRoutes,
  });

  factory SharedResources.fromJson(Map<String, dynamic> json) {
    return SharedResources(
      variables: json['variables'] != null
          ? (json['variables'] as List)
                .map((e) => Variable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      tools: json['tools'] != null
          ? (json['tools'] as List)
                .map((e) => Tool.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      llmConfigs: json['llmConfigs'] != null
          ? (json['llmConfigs'] as List)
                .map((e) => LLMConfig.fromJson(e as Map<String, dynamic>))
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
      integrationPatterns: json['integrationPatterns'] != null
          ? (json['integrationPatterns'] as List)
                .map(
                  (e) => IntegrationPatternTemplate.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      camelRoutes: json['camelRoutes'] != null
          ? (json['camelRoutes'] as List)
                .map((e) => CamelRoute.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (variables != null)
        'variables': variables!.map((e) => e.toJson()).toList(),
      if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
      if (llmConfigs != null)
        'llmConfigs': llmConfigs!.map((e) => e.toJson()).toList(),
      if (connectors != null)
        'connectors': connectors!.map((e) => e.toJson()).toList(),
      if (integrationPatterns != null)
        'integrationPatterns': integrationPatterns!
            .map((e) => e.toJson())
            .toList(),
      if (camelRoutes != null)
        'camelRoutes': camelRoutes!.map((e) => e.toJson()).toList(),
    };
  }
}
