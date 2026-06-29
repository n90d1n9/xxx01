class PriorityLevelConfigurationReference {
  final String name;
  PriorityLevelConfigurationReference({required this.name});
  factory PriorityLevelConfigurationReference.fromJson(
    Map<String, dynamic> json,
  ) {
    return PriorityLevelConfigurationReference(name: json['name']);
  }
  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
