import 'action_definition.dart';

class TemplateAction extends ActionDefinition {
  final String template;
  final String templateEngine;
  final Map<String, dynamic>? context;

  TemplateAction({
    required this.template,
    this.templateEngine = 'mustache',
    this.context,
  }) : super('template');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'template': template,
    'templateEngine': templateEngine,
    'context': context,
  };

  factory TemplateAction.fromJson(Map<String, dynamic> json) => TemplateAction(
    template: json['template'],
    templateEngine: json['templateEngine'] ?? 'mustache',
    context: json['context'],
  );
}
