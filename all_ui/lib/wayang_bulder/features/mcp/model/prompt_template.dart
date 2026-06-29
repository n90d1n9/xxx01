import 'prompt_category.dart';

class MCPPromptTemplate {
  final String id;
  final String name;
  final String description;
  final String template;
  final List<String> requiredVariables;
  final MCPPromptCategory category;
  final int usageCount;
  final String author;
  final DateTime createdAt;
  final bool isPublic;
  final List<String> tags;

  MCPPromptTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.template,
    required this.requiredVariables,
    required this.category,
    required this.author,
    required this.createdAt,
    this.usageCount = 0,
    this.isPublic = true,
    this.tags = const [],
  });
}

/* 
class MCPPromptTemplate {
  final String id;
  final String name;
  final String description;
  final String template;
  final List<String> requiredVariables;
  final MCPPromptCategory category;
  final int usageCount;

  MCPPromptTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.template,
    required this.requiredVariables,
    required this.category,
    this.usageCount = 0,
  });
} */
