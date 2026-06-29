class PersistentVolumeClaimCondition {
  final String type;
  final String status;
  final DateTime? lastProbeTime;
  final DateTime? lastTransitionTime;
  final String? reason;
  final String? message;
  PersistentVolumeClaimCondition({
    required this.type,
    required this.status,
    this.lastProbeTime,
    this.lastTransitionTime,
    this.reason,
    this.message,
  });
  factory PersistentVolumeClaimCondition.fromJson(Map<String, dynamic> json) {
    return PersistentVolumeClaimCondition(
      type: json['type'],
      status: json['status'],
      lastProbeTime:
          json['lastProbeTime'] != null
              ? DateTime.parse(json['lastProbeTime'])
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
      if (lastProbeTime != null)
        'lastProbeTime': lastProbeTime!.toIso8601String(),
      if (lastTransitionTime != null)
        'lastTransitionTime': lastTransitionTime!.toIso8601String(),
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
    };
  }
}
