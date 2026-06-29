class IfElseCondition {
  final String id;
  final String expression;
  final String label;
  final String? description;

  IfElseCondition({
    required this.id,
    required this.expression,
    required this.label,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'expression': expression,
    'label': label,
    'description': description,
  };

  factory IfElseCondition.fromJson(Map<String, dynamic> json) =>
      IfElseCondition(
        id: json['id'],
        expression: json['expression'],
        label: json['label'],
        description: json['description'],
      );
}
