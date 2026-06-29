class CodeTemplate {
  final String name;
  final String template;
  final String outputFile;

  CodeTemplate({
    required this.name,
    required this.template,
    required this.outputFile,
  });

  factory CodeTemplate.fromJson(Map<String, dynamic> json) {
    return CodeTemplate(
      name: json['name'] as String,
      template: json['template'] as String,
      outputFile: json['outputFile'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'template': template, 'outputFile': outputFile};
  }
}
