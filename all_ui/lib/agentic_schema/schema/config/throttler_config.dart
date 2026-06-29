class ThrottlerConfig {
  final int maximumRequests;
  final int timePeriod;
  final bool? rejectExecution;

  ThrottlerConfig({
    required this.maximumRequests,
    required this.timePeriod,
    this.rejectExecution = false,
  });

  factory ThrottlerConfig.fromJson(Map<String, dynamic> json) {
    return ThrottlerConfig(
      maximumRequests: json['maximumRequests'] as int,
      timePeriod: json['timePeriod'] as int,
      rejectExecution: json['rejectExecution'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maximumRequests': maximumRequests,
      'timePeriod': timePeriod,
      if (rejectExecution != null) 'rejectExecution': rejectExecution,
    };
  }
}
