class AriaConfig {
  final Map<String, String>? roles;
  final Map<String, String>? labels;
  final Map<String, String>? descriptions;
  final Map<String, bool>? states;

  AriaConfig({this.roles, this.labels, this.descriptions, this.states});

  factory AriaConfig.fromJson(Map<String, dynamic> json) {
    return AriaConfig(
      roles:
          json['roles'] != null
              ? Map<String, String>.from(json['roles'] as Map)
              : null,
      labels:
          json['labels'] != null
              ? Map<String, String>.from(json['labels'] as Map)
              : null,
      descriptions:
          json['descriptions'] != null
              ? Map<String, String>.from(json['descriptions'] as Map)
              : null,
      states:
          json['states'] != null
              ? Map<String, bool>.from(json['states'] as Map)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (roles != null) 'roles': roles,
    if (labels != null) 'labels': labels,
    if (descriptions != null) 'descriptions': descriptions,
    if (states != null) 'states': states,
  };
}
