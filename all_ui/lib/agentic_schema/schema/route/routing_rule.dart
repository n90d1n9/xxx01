class RoutingRule {
  final String condition;
  final String destination;
  final int? priority;

  RoutingRule({
    required this.condition,
    required this.destination,
    this.priority,
  });

  factory RoutingRule.fromJson(Map<String, dynamic> json) {
    return RoutingRule(
      condition: json['condition'] as String,
      destination: json['destination'] as String,
      priority: json['priority'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'destination': destination,
      if (priority != null) 'priority': priority,
    };
  }
}
