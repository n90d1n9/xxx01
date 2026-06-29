class RateLimit {
  final int requests;
  final int period;
  final String unit;

  RateLimit({required this.requests, required this.period, required this.unit});

  factory RateLimit.fromJson(Map<String, dynamic> json) {
    return RateLimit(
      requests: json['requests'] as int,
      period: json['period'] as int,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'requests': requests, 'period': period, 'unit': unit};
  }
}
