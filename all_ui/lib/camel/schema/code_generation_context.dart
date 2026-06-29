import 'generation_target.dart';
import 'integration_route.dart';

/// Context for code generation from visual design
class CodeGenerationContext {
  final IntegrationRoute route;
  final GenerationTarget target;
  final String templateEngine;
  final Map<String, dynamic> variables;

  const CodeGenerationContext({
    required this.route,
    required this.target,
    this.templateEngine = 'mustache',
    this.variables = const {},
  });

  Map<String, dynamic> toTemplateContext() => {
    'route': route.toJson(),
    'target': target.name,
    'timestamp': DateTime.now().toIso8601String(),
    'variables': variables,
  };
}
