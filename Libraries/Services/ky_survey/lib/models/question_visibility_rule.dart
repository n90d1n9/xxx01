enum QuestionVisibilityOperator {
  answered,
  unanswered,
  equals,
  notEquals,
  contains,
  notContains,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
}

QuestionVisibilityOperator questionVisibilityOperatorFromJson(Object? value) {
  if (value is QuestionVisibilityOperator) {
    return value;
  }

  if (value is String) {
    for (final operator in QuestionVisibilityOperator.values) {
      if (operator.name == value) {
        return operator;
      }
    }
  }

  return QuestionVisibilityOperator.answered;
}

class QuestionVisibilityRule {
  final String sourceQuestionId;
  final QuestionVisibilityOperator operator;
  final dynamic value;

  const QuestionVisibilityRule({
    required this.sourceQuestionId,
    this.operator = QuestionVisibilityOperator.answered,
    this.value,
  });

  QuestionVisibilityRule copyWith({
    String? sourceQuestionId,
    QuestionVisibilityOperator? operator,
    dynamic value,
  }) {
    return QuestionVisibilityRule(
      sourceQuestionId: sourceQuestionId ?? this.sourceQuestionId,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  factory QuestionVisibilityRule.fromJson(Map<String, dynamic> json) {
    return QuestionVisibilityRule(
      sourceQuestionId: json['sourceQuestionId'] as String? ?? '',
      operator: questionVisibilityOperatorFromJson(json['operator']),
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceQuestionId': sourceQuestionId,
      'operator': operator.name,
      'value': value,
    };
  }
}

extension QuestionVisibilityOperatorDetails on QuestionVisibilityOperator {
  String get label {
    switch (this) {
      case QuestionVisibilityOperator.answered:
        return 'Answered';
      case QuestionVisibilityOperator.unanswered:
        return 'Unanswered';
      case QuestionVisibilityOperator.equals:
        return 'Equals';
      case QuestionVisibilityOperator.notEquals:
        return 'Does Not Equal';
      case QuestionVisibilityOperator.contains:
        return 'Contains';
      case QuestionVisibilityOperator.notContains:
        return 'Does Not Contain';
      case QuestionVisibilityOperator.greaterThan:
        return 'Greater Than';
      case QuestionVisibilityOperator.greaterThanOrEqual:
        return 'Greater Or Equal';
      case QuestionVisibilityOperator.lessThan:
        return 'Less Than';
      case QuestionVisibilityOperator.lessThanOrEqual:
        return 'Less Or Equal';
    }
  }

  bool get needsValue {
    switch (this) {
      case QuestionVisibilityOperator.answered:
      case QuestionVisibilityOperator.unanswered:
        return false;
      case QuestionVisibilityOperator.equals:
      case QuestionVisibilityOperator.notEquals:
      case QuestionVisibilityOperator.contains:
      case QuestionVisibilityOperator.notContains:
      case QuestionVisibilityOperator.greaterThan:
      case QuestionVisibilityOperator.greaterThanOrEqual:
      case QuestionVisibilityOperator.lessThan:
      case QuestionVisibilityOperator.lessThanOrEqual:
        return true;
    }
  }

  bool get usesNumericValue {
    switch (this) {
      case QuestionVisibilityOperator.greaterThan:
      case QuestionVisibilityOperator.greaterThanOrEqual:
      case QuestionVisibilityOperator.lessThan:
      case QuestionVisibilityOperator.lessThanOrEqual:
        return true;
      case QuestionVisibilityOperator.answered:
      case QuestionVisibilityOperator.unanswered:
      case QuestionVisibilityOperator.equals:
      case QuestionVisibilityOperator.notEquals:
      case QuestionVisibilityOperator.contains:
      case QuestionVisibilityOperator.notContains:
        return false;
    }
  }
}
