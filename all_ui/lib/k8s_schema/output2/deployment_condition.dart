class DeploymentCondition {
  final String type;
  final String status;
  final DateTime? lastUpdateTime;
  final DateTime? lastTransitionTime;
  final String? reason;
  final String? message;
  DeploymentCondition({
    required this.type,
    required this.status,
    this.lastUpdateTime,
    this.lastTransitionTime,
    this.reason,
    this.message,
  });
  factory DeploymentCondition.fromJson(Map<String, dynamic> json) {
    return DeploymentCondition(
      type: json['type'],
      status: json['status'],
      lastUpdateTime:
          json['lastUpdateTime'] != null
              ? DateTime.parse(json['lastUpdateTime'])
              : null,
      lastTransitionTime:
          json['lastTransitionTime'] != null
              ? DateTime.parse(json['lastTransitionTime'])
              : null,
      reason: json['reason'],
      message: json['message'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'status': status,
      if (lastUpdateTime != null)
        'lastUpdateTime': lastUpdateTime!.toIso8601String(),
      if (lastTransitionTime != null)
        'lastTransitionTime': lastTransitionTime!.toIso8601String(),
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
    };
  }
}
