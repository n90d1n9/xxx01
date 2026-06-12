class CodeTemplate {
  final String id;
  final String name;
  final String framework;
  final String language;
  final String category;
  final String filePath;
  final String template;
  final Map<String, String>? dependencies;
  const CodeTemplate({
    required this.id,
    required this.name,
    required this.framework,
    required this.language,
    required this.category,
    required this.filePath,
    required this.template,
    this.dependencies,
  });
}
