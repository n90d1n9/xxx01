class MCPServerInfo {
  final String name;
  final String version;
  final List<Map<String, dynamic>> tools;

  MCPServerInfo({
    required this.name,
    required this.version,
    required this.tools,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'version': version,
    'tools': tools,
  };
}
