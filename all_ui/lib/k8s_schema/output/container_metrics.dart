class ContainerMetrics {
  final String name;
  final Map<String, String> usage;
  ContainerMetrics({required this.name, required this.usage});
  factory ContainerMetrics.fromJson(Map<String, dynamic> json) {
    return ContainerMetrics(
      name: json['name'],
      usage: Map<String, String>.from(json['usage']),
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'usage': usage};
  }
}
