class TopologySelectorLabelRequirement {
  final String key;
  final List<String> values;
  TopologySelectorLabelRequirement({required this.key, required this.values});
  factory TopologySelectorLabelRequirement.fromJson(Map<String, dynamic> json) {
    return TopologySelectorLabelRequirement(
      key: json['key'],
      values: List<String>.from(json['values']),
    );
  }
  Map<String, dynamic> toJson() {
    return {'key': key, 'values': values};
  }
}
