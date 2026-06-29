import 'retention.dart';
import 'memory_config_settings.dart';

class MemoryConfig {
  final String type;
  final String? storageBackend;
  final MemoryConfigSettings? config;
  final Retention? retention;

  MemoryConfig({
    required this.type,
    this.storageBackend,
    this.config,
    this.retention,
  });

  factory MemoryConfig.fromJson(Map<String, dynamic> json) {
    return MemoryConfig(
      type: json['type'] as String,
      storageBackend: json['storageBackend'] as String?,
      config: json['config'] != null
          ? MemoryConfigSettings.fromJson(
              json['config'] as Map<String, dynamic>,
            )
          : null,
      retention: json['retention'] != null
          ? Retention.fromJson(json['retention'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (storageBackend != null) 'storageBackend': storageBackend,
      if (config != null) 'config': config!.toJson(),
      if (retention != null) 'retention': retention!.toJson(),
    };
  }
}
