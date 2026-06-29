class PromptTemplate {
  final String template;
  final List<String>? variables;

  PromptTemplate({required this.template, this.variables});

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      template: json['template'] as String,
      variables: json['variables'] != null
          ? List<String>.from(json['variables'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template': template,
      if (variables != null) 'variables': variables,
    };
  }
}
