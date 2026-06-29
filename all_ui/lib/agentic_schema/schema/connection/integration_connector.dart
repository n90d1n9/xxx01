import '../data/data_format.dart';
import '../exception/error_handling.dart';
import '../config/message_patter_config.dart';
import '../integration/integration_type.dart';
import '../monitoring/monitoring_config.dart';
import 'connection_config.dart';

enum IntegrationDirection { inbound, outbound, bidirectional }

class IntegrationConnector {
  final String id;
  final String name;
  final IntegrationType type;
  final IntegrationDirection direction;
  final ConnectionConfig? connectionConfig;
  final DataFormat? dataFormat;
  final MessagePatternConfig? messagePattern;
  final ErrorHandling? errorHandling;
  final MonitoringConfig? monitoring;

  IntegrationConnector({
    required this.id,
    required this.name,
    required this.type,
    required this.direction,
    this.connectionConfig,
    this.dataFormat,
    this.messagePattern,
    this.errorHandling,
    this.monitoring,
  });

  factory IntegrationConnector.fromJson(Map<String, dynamic> json) {
    return IntegrationConnector(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseIntegrationType(json['type']),
      direction: _parseIntegrationDirection(json['direction']),
      connectionConfig: json['connectionConfig'] != null
          ? ConnectionConfig.fromJson(
              json['connectionConfig'] as Map<String, dynamic>,
            )
          : null,
      dataFormat: json['dataFormat'] != null
          ? DataFormat.fromJson(json['dataFormat'] as Map<String, dynamic>)
          : null,
      messagePattern: json['messagePattern'] != null
          ? MessagePatternConfig.fromJson(
              json['messagePattern'] as Map<String, dynamic>,
            )
          : null,
      errorHandling: json['errorHandling'] != null
          ? ErrorHandling.fromJson(
              json['errorHandling'] as Map<String, dynamic>,
            )
          : null,
      monitoring: json['monitoring'] != null
          ? MonitoringConfig.fromJson(
              json['monitoring'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'direction': direction.name,
      if (connectionConfig != null)
        'connectionConfig': connectionConfig!.toJson(),
      if (dataFormat != null) 'dataFormat': dataFormat!.toJson(),
      if (messagePattern != null) 'messagePattern': messagePattern!.toJson(),
      if (errorHandling != null) 'errorHandling': errorHandling!.toJson(),
      if (monitoring != null) 'monitoring': monitoring!.toJson(),
    };
  }

  static IntegrationType _parseIntegrationType(dynamic value) {
    if (value is IntegrationType) return value;
    final stringValue = value.toString();
    return IntegrationType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => IntegrationType.custom,
    );
  }

  static IntegrationDirection _parseIntegrationDirection(dynamic value) {
    if (value is IntegrationDirection) return value;
    final stringValue = value.toString();
    return IntegrationDirection.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => IntegrationDirection.inbound,
    );
  }
}
