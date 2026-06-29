import '../event_condition.dart';
import 'action.dart';

class Event {
  final String type; // click, hover, scroll, submit, change, etc.
  final List<Action> actions;
  final EventCondition? condition;
  final bool preventDefault;
  final bool stopPropagation;

  Event({
    required this.type,
    required this.actions,
    this.condition,
    this.preventDefault = false,
    this.stopPropagation = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      type: json['type'] as String,
      actions:
          (json['actions'] as List)
              .map((a) => Action.fromJson(a as Map<String, dynamic>))
              .toList(),
      condition:
          json['condition'] != null
              ? EventCondition.fromJson(
                json['condition'] as Map<String, dynamic>,
              )
              : null,
      preventDefault: json['preventDefault'] as bool? ?? false,
      stopPropagation: json['stopPropagation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'actions': actions.map((a) => a.toJson()).toList(),
    if (condition != null) 'condition': condition!.toJson(),
    'preventDefault': preventDefault,
    'stopPropagation': stopPropagation,
  };
}
