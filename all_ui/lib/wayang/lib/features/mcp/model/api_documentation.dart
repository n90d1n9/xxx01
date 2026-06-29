import 'api_example.dart';

class MCPAPIDocumentation {
  final String id;
  final String title;
  final String description;
  final String version;
  final String? openApiSpec;
  final String? swaggerUrl;
  final List<String> endpoints;
  final List<MCPAPIExample> examples;
  final DateTime lastUpdated;

  MCPAPIDocumentation({
    required this.id,
    required this.title,
    required this.description,
    required this.version,
    required this.endpoints,
    required this.examples,
    required this.lastUpdated,
    this.openApiSpec,
    this.swaggerUrl,
  });
}
