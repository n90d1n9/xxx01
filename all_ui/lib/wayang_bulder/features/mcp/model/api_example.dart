class MCPAPIExample {
  final String description;
  final String endpoint;
  final String method;
  final String? requestBody;
  final String responseBody;

  MCPAPIExample({
    required this.description,
    required this.endpoint,
    required this.method,
    required this.responseBody,
    this.requestBody,
  });
}
