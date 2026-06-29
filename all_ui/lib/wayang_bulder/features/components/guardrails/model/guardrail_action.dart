import '../../../plugin/model/action/action_definition.dart';
import 'guardrail_rule.dart';

class GuardrailAction extends ActionDefinition {
  final List<GuardrailRule> rules;
  final bool stopOnFirstViolation;
  final bool returnViolations;

  static const String actionType = 'guardrail';

  GuardrailAction({
    required this.rules,
    this.stopOnFirstViolation = false,
    this.returnViolations = true,
  }) : super(actionType);

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'rules': rules.map((r) => r.toJson()).toList(),
    'stopOnFirstViolation': stopOnFirstViolation,
    'returnViolations': returnViolations,
  };

  factory GuardrailAction.fromJson(Map<String, dynamic> json) {
    return GuardrailAction(
      rules:
          (json['rules'] as List?)
              ?.map((r) => GuardrailRule.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      stopOnFirstViolation: json['stopOnFirstViolation'] as bool? ?? false,
      returnViolations: json['returnViolations'] as bool? ?? true,
    );
  }
}
