enum ConditionOperator {
  equals,
  notEquals,
  contains,
  notContains,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  isEmpty,
  isNotEmpty,
  startsWith,
  endsWith,
  matches, // regex
}

class Condition {
  final String fieldId;
  final ConditionOperator operator;
  final dynamic value;

  const Condition({required this.fieldId, required this.operator, this.value});

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'operator': operator.toString(),
      'value': value,
    };
  }
}

enum LogicOperator { and, or }

class ConditionalRule {
  final List<Condition> conditions;
  final LogicOperator logicOperator;
  final ConditionalAction action;

  const ConditionalRule({
    required this.conditions,
    required this.logicOperator,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'logic': logicOperator.toString(),
      'action': action.toJson(),
    };
  }
}

enum ActionType {
  show,
  hide,
  enable,
  disable,
  setValue,
  calculate,
  validate,
  trigger,
}

class ConditionalAction {
  final ActionType type;
  final List<String> targetFieldIds;
  final dynamic value;
  final String? expression;

  const ConditionalAction({
    required this.type,
    required this.targetFieldIds,
    this.value,
    this.expression,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'targets': targetFieldIds,
      if (value != null) 'value': value,
      if (expression != null) 'expression': expression,
    };
  }
}
