class DataFormatConfig {
  final String name;
  final String type;
  final Map<String, dynamic>? config;

  DataFormatConfig({required this.name, required this.type, this.config});

  factory DataFormatConfig.fromJson(Map<String, dynamic> json) {
    return DataFormatConfig(
      name: json['name'] as String,
      type: json['type'] as String,
      config: json['config'] != null
          ? Map<String, dynamic>.from(json['config'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'type': type, if (config != null) 'config': config};
  }
}
