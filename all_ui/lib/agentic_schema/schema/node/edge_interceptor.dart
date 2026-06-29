class EdgeInterceptor {
  final String type;
  final Map<String, dynamic>? config;

  EdgeInterceptor({required this.type, this.config});

  factory EdgeInterceptor.fromJson(Map<String, dynamic> json) {
    return EdgeInterceptor(
      type: json['type'] as String,
      config: json['config'] != null
          ? Map<String, dynamic>.from(json['config'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, if (config != null) 'config': config};
  }
}
