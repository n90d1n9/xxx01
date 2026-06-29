class KafkaBroker {
  final String id;
  final String host;
  final int port;
  final bool isController;
  final Map<String, dynamic> metrics;

  KafkaBroker({
    required this.id,
    required this.host,
    required this.port,
    required this.isController,
    required this.metrics,
  });

  factory KafkaBroker.fromJson(Map<String, dynamic> json) {
    return KafkaBroker(
      id: json['id'],
      host: json['host'],
      port: json['port'],
      isController: json['is_controller'] ?? false,
      metrics: json['metrics'] ?? {},
    );
  }
}
