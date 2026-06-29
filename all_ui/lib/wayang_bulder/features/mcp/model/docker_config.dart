class MCPDockerConfig {
  final String dockerImageUrl;
  final String? registryUrl;
  final String? registryUsername;
  final String? registryPassword;
  final Map<String, String> environmentVariables;
  final List<String> exposedPorts;
  final String? dockerfilePath;
  final String? dockerComposeTemplate;
  final DateTime? lastBuilt;
  final String? lastBuildHash;

  MCPDockerConfig({
    required this.dockerImageUrl,
    this.registryUrl,
    this.registryUsername,
    this.registryPassword,
    this.environmentVariables = const {},
    this.exposedPorts = const [],
    this.dockerfilePath,
    this.dockerComposeTemplate,
    this.lastBuilt,
    this.lastBuildHash,
  });
}
