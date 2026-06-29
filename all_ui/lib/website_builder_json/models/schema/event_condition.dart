class EventCondition {
  final String operator; // equals, notEquals, contains, greaterThan, etc.
  final String field;
  final dynamic value;

  EventCondition({
    required this.operator,
    required this.field,
    required this.value,
  });

  factory EventCondition.fromJson(Map<String, dynamic> json) {
    return EventCondition(
      operator: json['operator'] as String,
      field: json['field'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
    'operator': operator,
    'field': field,
    'value': value,
  };
}
