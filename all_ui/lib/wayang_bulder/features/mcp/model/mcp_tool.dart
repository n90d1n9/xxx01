import 'mcp.dart';
import 'mcp_tool_category.dart';
import 'mcp_tool_parameter.dart';

class MCPTool {
  final String id;
  final String name;
  final String version;
  final String description;
  final MCPToolCategory category;
  final List<MCPToolParameter> parameters;
  final String? inputSchema;
  final String? outputSchema;
  final MCPToolStatus status;
  final int usageCount;
  final double rating;
  final String author;
  final String? gitHubUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublic;
  final Map<String, dynamic>? metadata;

  MCPTool({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.category,
    required this.parameters,
    required this.status,
    required this.author,
    required this.createdAt,
    this.inputSchema,
    this.outputSchema,
    this.usageCount = 0,
    this.rating = 0.0,
    this.gitHubUrl,
    this.tags = const [],
    this.updatedAt,
    this.isPublic = true,
    this.metadata,
  });

  MCPTool copyWith({
    String? id,
    String? name,
    String? version,
    String? description,
    MCPToolCategory? category,
    List<MCPToolParameter>? parameters,
    String? inputSchema,
    String? outputSchema,
    MCPToolStatus? status,
    int? usageCount,
    double? rating,
    String? author,
    String? gitHubUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    Map<String, dynamic>? metadata,
  }) {
    return MCPTool(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      category: category ?? this.category,
      parameters: parameters ?? this.parameters,
      inputSchema: inputSchema ?? this.inputSchema,
      outputSchema: outputSchema ?? this.outputSchema,
      status: status ?? this.status,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      author: author ?? this.author,
      gitHubUrl: gitHubUrl ?? this.gitHubUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      metadata: metadata ?? this.metadata,
    );
  }
}
