class CamelStep {
  final String type;
  final Map<String, dynamic>? config;
  final List<CamelStep>? nested;

  CamelStep({required this.type, this.config, this.nested});

  factory CamelStep.fromJson(Map<String, dynamic> json) {
    return CamelStep(
      type: json['type'] as String,
      config: json['config'] != null
          ? Map<String, dynamic>.from(json['config'] as Map)
          : null,
      nested: json['nested'] != null
          ? (json['nested'] as List)
                .map((e) => CamelStep.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (config != null) 'config': config,
      if (nested != null) 'nested': nested!.map((e) => e.toJson()).toList(),
    };
  }
}
