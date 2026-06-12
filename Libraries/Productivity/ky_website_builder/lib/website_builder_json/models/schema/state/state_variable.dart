class StateVariable {
  final String name;
  final String type; // string, number, boolean, array, object
  final dynamic defaultValue;
  final bool persistent; // Save to localStorage

  StateVariable({
    required this.name,
    required this.type,
    this.defaultValue,
    this.persistent = false,
  });

  factory StateVariable.fromJson(Map<String, dynamic> json) {
    return StateVariable(
      name: json['name'] as String,
      type: json['type'] as String,
      defaultValue: json['defaultValue'],
      persistent: json['persistent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    if (defaultValue != null) 'defaultValue': defaultValue,
    'persistent': persistent,
  };
}
