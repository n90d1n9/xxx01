class EtcdMetric {
  final String key;
  final int value;

  EtcdMetric({required this.key, required this.value});

  factory EtcdMetric.fromJson(Map<String, dynamic> json) {
    return EtcdMetric(key: json['key'], value: json['value']);
  }
}
