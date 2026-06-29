class NodeSelectorRequirement {
  final String key;
  final String operator;
  final List<String>? values;
  NodeSelectorRequirement({
    required this.key,
    required this.operator,
    this.values,
  });
  factory NodeSelectorRequirement.fromJson(Map<String, dynamic> json) {
    return NodeSelectorRequirement(
      key: json['key'],
      operator: json['operator'],
      values: json['values'] != null ? List<String>.from(json['values']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'operator': operator,
      if (values != null) 'values': values,
    };
  }
}
