import 'logic_condition.dart';

class SectionLogic {
  final String id;
  final String sectionId;
  final List<LogicCondition> conditions;
  final List<LogicAction> actions;
  final bool isEnabled;

  SectionLogic({
    required this.id,
    required this.sectionId,
    required this.conditions,
    required this.actions,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionId': sectionId,
        'conditions': conditions.map((c) => c.toJson()).toList(),
        'actions': actions.map((a) => a.toJson()).toList(),
        'isEnabled': isEnabled,
      };

  factory SectionLogic.fromJson(Map<String, dynamic> json) => SectionLogic(
        id: json['id'],
        sectionId: json['sectionId'],
        conditions: (json['conditions'] as List)
            .map((c) => LogicCondition.fromJson(c))
            .toList(),
        actions: (json['actions'] as List)
            .map((a) => LogicAction.fromJson(a))
            .toList(),
        isEnabled: json['isEnabled'],
      );
}
