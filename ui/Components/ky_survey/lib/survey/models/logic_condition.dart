class LogicCondition {
  final String id;
  final String questionId;
  final LogicOperator logicOperator;
  final dynamic value;
  final bool isNegated;
  final String conjunction;

  LogicCondition({
    required this.id,
    required this.questionId,
    required this.logicOperator,
    required this.value,
    required this.isNegated,
    required this.conjunction,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionId': questionId,
        'operator': logicOperator.toJson(),
        'value': value,
        'isNegated': isNegated,
        'conjunction': conjunction,
      };

  factory LogicCondition.fromJson(Map<String, dynamic> json) => LogicCondition(
        id: json['id'],
        questionId: json['questionId'],
        logicOperator: LogicOperator.fromJson(json['operator']),
        value: json['value'],
        isNegated: json['isNegated'],
        conjunction: json['conjunction'],
      );
}

class LogicAction {
  final String id;
  final String type;
  final String targetId;
  final dynamic value;
  final String? message;

  LogicAction({
    required this.id,
    required this.type,
    required this.targetId,
    this.value,
    this.message,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'targetId': targetId,
        'value': value,
        'message': message,
      };

  factory LogicAction.fromJson(Map<String, dynamic> json) => LogicAction(
        id: json['id'],
        type: json['type'],
        targetId: json['targetId'],
        value: json['value'],
        message: json['message'],
      );
}

enum LogicOperator {
  equals,
  notEquals,
  contains,
  notContains,
  greaterThan,
  lessThan,
  between,
  notBetween;

  String toJson() => name;
  static LogicOperator fromJson(String json) => values.byName(json);
}
