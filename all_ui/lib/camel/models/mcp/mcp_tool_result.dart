class MCPToolResult {
  final bool success;
  final dynamic data;
  final String? error;
  final Map<String, dynamic>? metadata;

  const MCPToolResult({
    required this.success,
    this.data,
    this.error,
    this.metadata,
  });
}
