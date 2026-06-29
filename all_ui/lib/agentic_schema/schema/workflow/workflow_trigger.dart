import '../connection/integration_connector.dart';

class WorkflowTrigger {
  final String type;
  final Map<String, dynamic>? config;
  final IntegrationConnector? connector;

  WorkflowTrigger({required this.type, this.config, this.connector});

  factory WorkflowTrigger.fromJson(Map<String, dynamic> json) {
    return WorkflowTrigger(
      type: json['type'] as String,
      config: json['config'] != null
          ? Map<String, dynamic>.from(json['config'] as Map)
          : null,
      connector: json['connector'] != null
          ? IntegrationConnector.fromJson(
              json['connector'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (config != null) 'config': config,
      if (connector != null) 'connector': connector!.toJson(),
    };
  }
}
