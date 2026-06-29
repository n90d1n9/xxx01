class MCPCapability {
  final String name;
  final String version;
  final bool enabled;
  final Map<String, dynamic> parameters;

  MCPCapability({
    required this.name,
    required this.version,
    required this.enabled,
    this.parameters = const {},
  });
}
