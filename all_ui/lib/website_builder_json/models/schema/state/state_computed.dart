class StateComputed {
  final String name;
  final List<String> dependencies; // Variable names this depends on
  final String expression; // Expression to compute value

  StateComputed({
    required this.name,
    required this.dependencies,
    required this.expression,
  });

  factory StateComputed.fromJson(Map<String, dynamic> json) {
    return StateComputed(
      name: json['name'] as String,
      dependencies: List<String>.from(json['dependencies'] as List),
      expression: json['expression'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'dependencies': dependencies,
    'expression': expression,
  };
}
