class MCPResourceIndicator {
  final String uri;
  final String scope;
  final DateTime? expiresAt;
  final List<String> allowedOperations;

  MCPResourceIndicator({
    required this.uri,
    required this.scope,
    this.expiresAt,
    this.allowedOperations = const ['read'],
  });
}
