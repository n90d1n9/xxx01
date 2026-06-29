import '../../survey/models/logic_condition.dart';

class QuestionLogic {
  final List<LogicCondition> conditions;
  final List<LogicAction> actions;
  final LogicOperator logicOperator;

  QuestionLogic({
    required this.conditions,
    required this.actions,
    this.logicOperator = LogicOperator.between,
  });

  factory QuestionLogic.fromJson(Map<String, dynamic> json) {
    return QuestionLogic(
      conditions: (json['conditions'] as List<dynamic>)
          .map((c) => LogicCondition.fromJson(c as Map<String, dynamic>))
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map((a) => LogicAction.fromJson(a as Map<String, dynamic>))
          .toList(),
      logicOperator: LogicOperator.fromJson(json['logicOperator']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'actions': actions.map((a) => a.toJson()).toList(),
      'logicOperator': logicOperator.toJson(),
    };
  }
}
