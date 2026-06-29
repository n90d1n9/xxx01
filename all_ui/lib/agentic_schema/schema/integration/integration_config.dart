import '../config/backend_config.dart';
import '../camel/camel_context.dart';
import '../config/component_config.dart';
import '../data/data_format_config.dart';
import '../common/rest_configuration.dart';

class IntegrationConfig {
  final BackendConfig? backend;
  final CamelContext? camelContext;
  final List<ComponentConfig>? components;
  final List<DataFormatConfig>? dataFormats;
  final RestConfiguration? restConfiguration;

  IntegrationConfig({
    this.backend,
    this.camelContext,
    this.components,
    this.dataFormats,
    this.restConfiguration,
  });

  factory IntegrationConfig.fromJson(Map<String, dynamic> json) {
    return IntegrationConfig(
      backend: json['backend'] != null
          ? BackendConfig.fromJson(json['backend'] as Map<String, dynamic>)
          : null,
      camelContext: json['camelContext'] != null
          ? CamelContext.fromJson(json['camelContext'] as Map<String, dynamic>)
          : null,
      components: json['components'] != null
          ? (json['components'] as List)
                .map((e) => ComponentConfig.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      dataFormats: json['dataFormats'] != null
          ? (json['dataFormats'] as List)
                .map(
                  (e) => DataFormatConfig.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      restConfiguration: json['restConfiguration'] != null
          ? RestConfiguration.fromJson(
              json['restConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (backend != null) 'backend': backend!.toJson(),
      if (camelContext != null) 'camelContext': camelContext!.toJson(),
      if (components != null)
        'components': components!.map((e) => e.toJson()).toList(),
      if (dataFormats != null)
        'dataFormats': dataFormats!.map((e) => e.toJson()).toList(),
      if (restConfiguration != null)
        'restConfiguration': restConfiguration!.toJson(),
    };
  }
}
