class HPAScalingPolicy {
  final String type;
  final int value;
  final int periodSeconds;
  HPAScalingPolicy({
    required this.type,
    required this.value,
    required this.periodSeconds,
  });
  factory HPAScalingPolicy.fromJson(Map<String, dynamic> json) {
    return HPAScalingPolicy(
      type: json['type'],
      value: json['value'],
      periodSeconds: json['periodSeconds'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'type': type, 'value': value, 'periodSeconds': periodSeconds};
  }
}
