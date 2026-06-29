import 'guardrail_type.dart';

enum RuleAction {
  block,
  warn,
  log,
  redact,
  notify,
  sanitize;

  String get displayName => name.toUpperCase();
}

class GuardrailRule {
  final String id;
  final String name;
  final String description;
  final GuardrailType type;
  final GuardrailSeverity severity;
  final RuleAction action;
  final bool enabled;
  final Map<String, dynamic> config;
  final double threshold;

  GuardrailRule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.severity = GuardrailSeverity.medium,
    this.action = RuleAction.block, // ← default updated
    this.enabled = true,
    this.config = const {},
    this.threshold = 0.7,
  });

  GuardrailRule copyWith({
    String? name,
    String? description,
    GuardrailType? type,
    GuardrailSeverity? severity,
    RuleAction? action,
    bool? enabled,
    Map<String, dynamic>? config,
    double? threshold,
  }) {
    return GuardrailRule(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      action: action ?? this.action,
      enabled: enabled ?? this.enabled,
      config: config ?? this.config,
      threshold: threshold ?? this.threshold,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name, // ✅ use .name
    'severity': severity.name, // ✅
    'action': action.name, // ✅
    'enabled': enabled,
    'config': config,
    'threshold': threshold,
  };

  factory GuardrailRule.fromJson(Map<String, dynamic> json) {
    // Safe helpers to avoid crashes on invalid enum strings
    GuardrailType parseType(String? value) {
      if (value == null) return GuardrailType.piiDetection; // or throw
      try {
        return GuardrailType.values.firstWhere((e) => e.name == value);
      } catch (e) {
        throw Exception('Invalid GuardrailType: $value');
      }
    }

    GuardrailSeverity parseSeverity(String? value) {
      if (value == null) return GuardrailSeverity.medium;
      try {
        return GuardrailSeverity.values.firstWhere((e) => e.name == value);
      } catch (e) {
        throw Exception('Invalid GuardrailSeverity: $value');
      }
    }

    RuleAction parseAction(String? value) {
      if (value == null) return RuleAction.block;
      try {
        return RuleAction.values.firstWhere((e) => e.name == value);
      } catch (e) {
        throw Exception('Invalid RuleAction: $value');
      }
    }

    return GuardrailRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: parseType(json['type'] as String?),
      severity: parseSeverity(json['severity'] as String?),
      action: parseAction(json['action'] as String?),
      enabled: json['enabled'] as bool? ?? true,
      config: (json['config'] as Map<String, dynamic>?) ?? const {},
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.7,
    );
  }
}
