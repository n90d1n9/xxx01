class BackendConfig {
  final String type;
  final String? version;
  final String? runtime;
  final String? baseUrl;

  BackendConfig({required this.type, this.version, this.runtime, this.baseUrl});

  factory BackendConfig.fromJson(Map<String, dynamic> json) {
    return BackendConfig(
      type: json['type'] as String,
      version: json['version'] as String?,
      runtime: json['runtime'] as String?,
      baseUrl: json['baseUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (version != null) 'version': version,
      if (runtime != null) 'runtime': runtime,
      if (baseUrl != null) 'baseUrl': baseUrl,
    };
  }
}
