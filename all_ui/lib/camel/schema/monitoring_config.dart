/// Monitoring and metrics configuration
class MonitoringConfig {
  final bool enabled;
  final bool collectMetrics;
  final bool enableTracing;
  final List<String> logLevels;
  final Map<String, dynamic> customConfig;

  const MonitoringConfig({
    this.enabled = true,
    this.collectMetrics = true,
    this.enableTracing = false,
    this.logLevels = const ['INFO', 'WARN', 'ERROR'],
    this.customConfig = const {},
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'collectMetrics': collectMetrics,
    'enableTracing': enableTracing,
    'logLevels': logLevels,
    'customConfig': customConfig,
  };
}
