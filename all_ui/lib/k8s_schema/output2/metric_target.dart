class MetricTarget {
  final String type;
  final String? value;
  final String? averageValue;
  final int? averageUtilization;
  MetricTarget({
    required this.type,
    this.value,
    this.averageValue,
    this.averageUtilization,
  });
  factory MetricTarget.fromJson(Map<String, dynamic> json) {
    return MetricTarget(
      type: json['type'],
      value: json['value'],
      averageValue: json['averageValue'],
      averageUtilization: json['averageUtilization'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (value != null) 'value': value,
      if (averageValue != null) 'averageValue': averageValue,
      if (averageUtilization != null) 'averageUtilization': averageUtilization,
    };
  }
}
