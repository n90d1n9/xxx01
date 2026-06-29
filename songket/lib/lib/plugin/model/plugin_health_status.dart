class PluginHealthStatus {
  final bool isHealthy;
  final String? message;
  final Map<String, dynamic>? details;

  PluginHealthStatus({required this.isHealthy, this.message, this.details});

  factory PluginHealthStatus.healthy() =>
      PluginHealthStatus(isHealthy: true, message: 'Plugin is healthy');

  factory PluginHealthStatus.unhealthy(
    String message, [
    Map<String, dynamic>? details,
  ]) =>
      PluginHealthStatus(isHealthy: false, message: message, details: details);
}
