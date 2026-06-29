import 'guardrail_rule.dart';
import 'guardrail_type.dart';

class GuardrailViolation {
  final String ruleId;
  final String ruleName;
  final GuardrailType type;
  final RuleAction action;
  final GuardrailSeverity severity;
  final String message;
  final double confidence;
  final Map<String, dynamic> details;

  GuardrailViolation({
    required this.ruleId,
    required this.ruleName,
    required this.type,
    required this.action,
    required this.severity,
    required this.message,
    required this.confidence,
    this.details = const {},
  });
}
