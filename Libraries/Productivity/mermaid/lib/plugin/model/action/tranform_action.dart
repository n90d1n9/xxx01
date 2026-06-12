import 'action_definition.dart';
import 'tranform_rule.dart';

class TransformAction extends ActionDefinition {
  final List<TransformRule> rules;
  final String outputFormat;

  TransformAction({required this.rules, this.outputFormat = 'json'})
    : super('transform');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'rules': rules.map((r) => r.toJson()).toList(),
    'outputFormat': outputFormat,
  };

  factory TransformAction.fromJson(Map<String, dynamic> json) =>
      TransformAction(
        rules: (json['rules'] as List)
            .map((r) => TransformRule.fromJson(r))
            .toList(),
        outputFormat: json['outputFormat'] ?? 'json',
      );
}
