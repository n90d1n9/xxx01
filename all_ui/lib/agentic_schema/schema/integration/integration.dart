class Integration {
  final String type;
  final String name;
  final Map<String, dynamic>? config;
  final bool? enabled;

  Integration({
    required this.type,
    required this.name,
    this.config,
    this.enabled = true,
  });

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      type: json['type'] as String,
      name: json['name'] as String,
      config: json['config'] != null
          ? Map<String, dynamic>.from(json['config'] as Map)
          : null,
      enabled: json['enabled'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      if (config != null) 'config': config,
      if (enabled != null) 'enabled': enabled,
    };
  }
}
