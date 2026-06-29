class ComponentConfig {
  final String name;
  final String? version;
  final Map<String, dynamic>? config;

  ComponentConfig({required this.name, this.version, this.config});

  factory ComponentConfig.fromJson(Map<String, dynamic> json) {
    return ComponentConfig(
      name: json['name'] as String,
      version: json['version'] as String?,
      config: json['config'] != null
          ? Map<String, dynamic>.from(json['config'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (version != null) 'version': version,
      if (config != null) 'config': config,
    };
  }
}
