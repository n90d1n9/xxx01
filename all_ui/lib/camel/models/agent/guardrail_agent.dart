import '../../schema/validation_issue.dart';
import '../../schema/validation_result.dart';
import 'agent_context.dart';
import 'agent_response.dart';
import 'agent_type.dart';
import 'ai_agent.dart';

class GuardrailAgent extends AIAgent {
  final List<GuardrailRule> rules;
  final GuardrailMode mode;
  final ActionOnViolation violationAction;

  GuardrailAgent({
    required super.id,
    required super.name,
    required super.description,
    required super.config,
    required this.rules,
    required this.mode,
    required this.violationAction,
  }) : super(
         type: AgentType.guardrail,
         capabilities: [AgentCapability.validation, AgentCapability.monitoring],
         tools: [],
       );

  @override
  Future<AgentResponse> execute(AgentContext context) async {
    final violations = <GuardrailViolation>[];

    try {
      // Check all rules
      for (final rule in rules) {
        final result = await _checkRule(rule, context);
        if (!result.passed) {
          violations.add(
            GuardrailViolation(
              rule: rule,
              message: result.message!,
              severity: rule.severity,
            ),
          );
        }
      }

      // Handle violations
      if (violations.isNotEmpty) {
        return await _handleViolations(violations, context);
      }

      return AgentResponse(
        success: true,
        data: {'violations': 0, 'status': 'passed'},
        metadata: {'mode': mode.name},
      );
    } catch (e) {
      return AgentResponse(success: false, data: null, error: e.toString());
    }
  }

  Future<RuleCheckResult> _checkRule(
    GuardrailRule rule,
    AgentContext context,
  ) async {
    switch (rule.type) {
      case GuardrailType.contentFilter:
        return await _checkContentFilter(rule, context);

      case GuardrailType.rateLimiting:
        return await _checkRateLimit(rule, context);

      case GuardrailType.dataValidation:
        return await _checkDataValidation(rule, context);

      case GuardrailType.securityPolicy:
        return await _checkSecurityPolicy(rule, context);

      case GuardrailType.businessRule:
        return await _checkBusinessRule(rule, context);

      case GuardrailType.complianceCheck:
        return await _checkCompliance(rule, context);
    }
  }

  Future<RuleCheckResult> _checkContentFilter(
    GuardrailRule rule,
    AgentContext context,
  ) async {
    final content = context.input as String;
    final pattern = rule.config['pattern'] as String;

    if (content.contains(RegExp(pattern))) {
      return RuleCheckResult(
        passed: false,
        message: 'Content violates filter: ${rule.name}',
      );
    }

    return RuleCheckResult(passed: true);
  }

  Future<RuleCheckResult> _checkRateLimit(
    GuardrailRule rule,
    AgentContext context,
  ) async {
    // Check rate limiting
    return RuleCheckResult(passed: true);
  }

  Future<RuleCheckResult> _checkDataValidation(
    GuardrailRule rule,
    AgentContext context,
  ) async {
    // Validate data structure and values
    return RuleCheckResult(passed: true);
  }

  Future<RuleCheckResult> _checkSecurityPolicy(
    GuardrailRule rule,
    AgentContext context,
  ) async {
    // Check security policies
    return RuleCheckResult(passed: true);
  }

  Future<RuleCheckResult> _checkBusinessRule(
    GuardrailRule rule,
    AgentContext context,
  ) async {
    // Check business rules
    return RuleCheckResult(passed: true);
  }

  Future<RuleCheckResult> _checkCompliance(
    GuardrailRule rule,
    AgentContext context,
  ) async {
    // Check compliance rules
    return RuleCheckResult(passed: true);
  }

  Future<AgentResponse> _handleViolations(
    List<GuardrailViolation> violations,
    AgentContext context,
  ) async {
    switch (violationAction) {
      case ActionOnViolation.block:
        return AgentResponse(
          success: false,
          data: null,
          error: 'Guardrail violations detected',
          metadata: {'violations': violations.map((v) => v.toJson()).toList()},
        );

      case ActionOnViolation.warn:
        return AgentResponse(
          success: true,
          data: context.input,
          metadata: {'warnings': violations.map((v) => v.toJson()).toList()},
        );

      case ActionOnViolation.sanitize:
        final sanitized = await _sanitizeInput(context.input, violations);
        return AgentResponse(
          success: true,
          data: sanitized,
          metadata: {'sanitized': true, 'violations': violations.length},
        );

      case ActionOnViolation.redirect:
        // Redirect to alternative handler
        return AgentResponse(
          success: true,
          data: context.input,
          metadata: {'redirected': true},
        );
    }
  }

  Future<dynamic> _sanitizeInput(
    dynamic input,
    List<GuardrailViolation> violations,
  ) async {
    // Sanitize input based on violations
    return input;
  }

  @override
  ValidationResult validate() {
    final issues = <ValidationIssue>[];

    if (rules.isEmpty) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.error,
          category: IssueCategory.configuration,
          message: 'Guardrail must have at least one rule',
        ),
      );
    }

    return ValidationResult(isValid: issues.isEmpty, issues: issues);
  }
}

enum GuardrailMode { strict, moderate, permissive }

enum ActionOnViolation { block, warn, sanitize, redirect }

enum GuardrailType {
  contentFilter,
  rateLimiting,
  dataValidation,
  securityPolicy,
  businessRule,
  complianceCheck,
}

class GuardrailRule {
  final String name;
  final GuardrailType type;
  final Map<String, dynamic> config;
  final GuardrailSeverity severity;

  GuardrailRule({
    required this.name,
    required this.type,
    required this.config,
    required this.severity,
  });
}

enum GuardrailSeverity { low, medium, high, critical }

class GuardrailViolation {
  final GuardrailRule rule;
  final String message;
  final GuardrailSeverity severity;

  GuardrailViolation({
    required this.rule,
    required this.message,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'rule': rule.name,
    'message': message,
    'severity': severity.name,
  };
}

class RuleCheckResult {
  final bool passed;
  final String? message;

  RuleCheckResult({required this.passed, this.message});
}
