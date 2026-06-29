import 'routing_choice.dart';

/// Routing logic for content-based routing
class RoutingRule {
  final String id;
  final String name;
  final RoutingType type;
  final String? condition;
  final List<RoutingChoice> choices;
  final String? otherwiseNodeId;

  const RoutingRule({
    required this.id,
    required this.name,
    required this.type,
    this.condition,
    required this.choices,
    this.otherwiseNodeId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'condition': condition,
    'choices': choices.map((c) => c.toJson()).toList(),
    'otherwiseNodeId': otherwiseNodeId,
  };
}
