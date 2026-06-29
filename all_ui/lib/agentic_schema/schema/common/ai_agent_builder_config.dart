class AIAgentBuilderConfig {
  final String? version;
  final String? schemaVersion;
  final String? exportFormat;
  final Map<String, dynamic>? customSettings;

  AIAgentBuilderConfig({
    this.version = '1.0.0',
    this.schemaVersion = '1.0',
    this.exportFormat = 'json',
    this.customSettings,
  });

  factory AIAgentBuilderConfig.fromJson(Map<String, dynamic> json) {
    return AIAgentBuilderConfig(
      version: json['version'] as String?,
      schemaVersion: json['schemaVersion'] as String?,
      exportFormat: json['exportFormat'] as String?,
      customSettings: json['customSettings'] != null
          ? Map<String, dynamic>.from(json['customSettings'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (version != null) 'version': version,
      if (schemaVersion != null) 'schemaVersion': schemaVersion,
      if (exportFormat != null) 'exportFormat': exportFormat,
      if (customSettings != null) 'customSettings': customSettings,
    };
  }
}
