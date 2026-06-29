class RestConfiguration {
  final String? component;
  final String? host;
  final int? port;
  final String? contextPath;
  final String? apiContextPath;
  final bool? enableCORS;

  RestConfiguration({
    this.component = 'jetty',
    this.host = '0.0.0.0',
    this.port = 8080,
    this.contextPath = '/api',
    this.apiContextPath = '/api-doc',
    this.enableCORS = true,
  });

  factory RestConfiguration.fromJson(Map<String, dynamic> json) {
    return RestConfiguration(
      component: json['component'] as String?,
      host: json['host'] as String?,
      port: json['port'] as int?,
      contextPath: json['contextPath'] as String?,
      apiContextPath: json['apiContextPath'] as String?,
      enableCORS: json['enableCORS'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (component != null) 'component': component,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (contextPath != null) 'contextPath': contextPath,
      if (apiContextPath != null) 'apiContextPath': apiContextPath,
      if (enableCORS != null) 'enableCORS': enableCORS,
    };
  }
}
