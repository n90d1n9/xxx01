class ApiGatewayConfig {
  final String version;
  final bool enableLogging;
  final bool enableRateLimit;
  final bool enableCaching;
  final bool enableCors;
  final int defaultTimeout;
  final Map<String, dynamic> authentication;
  final List<String> allowedOrigins;
  final Map<String, dynamic> throttling;

  ApiGatewayConfig({
    required this.version,
    required this.enableLogging,
    required this.enableRateLimit,
    required this.enableCaching,
    required this.enableCors,
    required this.defaultTimeout,
    required this.authentication,
    required this.allowedOrigins,
    required this.throttling,
  });
}
