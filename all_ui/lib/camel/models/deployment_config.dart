// CI/CD Integration
class DeploymentConfig {
  final String environment; // 'dev', 'staging', 'prod'
  final String platform; // 'kubernetes', 'docker', 'cloud-run'
  final Map<String, String> envVars;
  final Map<String, dynamic> resources;

  DeploymentConfig({
    required this.environment,
    required this.platform,
    this.envVars = const {},
    this.resources = const {},
  });
}
