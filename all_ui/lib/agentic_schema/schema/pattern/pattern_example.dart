class PatternExample {
  final String name;
  final String? description;
  final Map<String, dynamic>? config;

  PatternExample({required this.name, this.description, this.config});

  factory PatternExample.fromJson(Map<String, dynamic> json) {
    return PatternExample(
      name: json['name'] as String,
      description: json['description'] as String?,
      config: json['config'] != null
          ? Map<String, dynamic>.from(json['config'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (config != null) 'config': config,
    };
  }
}
