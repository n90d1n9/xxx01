import 'deployment_target.dart';

class DeploymentConfig {
  final DeploymentTarget target;
  final String? endpointUrl;
  final Map<String, String> environment;
  final int? replicas;
  final String? hardwareAccelerator;
  final bool enableAutoScaling;
  final int? minReplicas;
  final int? maxReplicas;
  final bool enableMonitoring;
  final bool enableLogging;
  final String? containerImage;
  final Map<String, dynamic> customConfig;
  DeploymentConfig({
    required this.target,
    this.endpointUrl,
    this.environment = const {},
    this.replicas = 1,
    this.hardwareAccelerator,
    this.enableAutoScaling = false,
    this.minReplicas,
    this.maxReplicas,
    this.enableMonitoring = true,
    this.enableLogging = true,
    this.containerImage,
    this.customConfig = const {},
  });
  Map<String, dynamic> toJson() => {
    'target': target.name,
    'endpointUrl': endpointUrl,
    'environment': environment,
    'replicas': replicas,
    'hardwareAccelerator': hardwareAccelerator,
    'enableAutoScaling': enableAutoScaling,
    'minReplicas': minReplicas,
    'maxReplicas': maxReplicas,
    'enableMonitoring': enableMonitoring,
    'enableLogging': enableLogging,
    'containerImage': containerImage,
    'customConfig': customConfig,
  };
}
