import 'tool_config.dart';
import '../connection/integration_connector.dart';
import 'tool_parameter.dart';

class Tool {
  final String id;
  final String name;
  final String type;
  final String? description;
  final bool? enabled;
  final IntegrationConnector? connector;
  final ToolConfig? config;
  final List<ToolParameter>? parameters;

  Tool({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.enabled = true,
    this.connector,
    this.config,
    this.parameters,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      enabled: json['enabled'] as bool?,
      connector: json['connector'] != null
          ? IntegrationConnector.fromJson(
              json['connector'] as Map<String, dynamic>,
            )
          : null,
      config: json['config'] != null
          ? ToolConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      parameters: json['parameters'] != null
          ? (json['parameters'] as List)
                .map((e) => ToolParameter.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      if (description != null) 'description': description,
      if (enabled != null) 'enabled': enabled,
      if (connector != null) 'connector': connector!.toJson(),
      if (config != null) 'config': config!.toJson(),
      if (parameters != null)
        'parameters': parameters!.map((e) => e.toJson()).toList(),
    };
  }
}
