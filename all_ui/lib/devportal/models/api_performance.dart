class ApiPerformance {
  final String name;
  final String responseTime;
  final String errorRate;
  final String uptime;

  ApiPerformance({
    required this.name,
    required this.responseTime,
    required this.errorRate,
    required this.uptime,
  });
}
