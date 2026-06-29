import 'guardrail_violation.dart';

class GuardrailResult {
  final bool passed;
  final List<GuardrailViolation> violations;
  final String? sanitizedInput;
  final Map<String, dynamic> metadata;

  GuardrailResult({
    required this.passed,
    this.violations = const [],
    this.sanitizedInput,
    this.metadata = const {},
  });

  factory GuardrailResult.pass() => GuardrailResult(passed: true);

  factory GuardrailResult.fail(List<GuardrailViolation> violations) =>
      GuardrailResult(passed: false, violations: violations);
}
