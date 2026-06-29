class NodeCondition {
  final String type;
  final String status;
  final DateTime? lastHeartbeatTime;
  final DateTime? lastTransitionTime;
  final String? reason;
  final String? message;
  NodeCondition({
    required this.type,
    required this.status,
    this.lastHeartbeatTime,
    this.lastTransitionTime,
    this.reason,
    this.message,
  });
  factory NodeCondition.fromJson(Map<String, dynamic> json) {
    return NodeCondition(
      type: json['type'],
      status: json['status'],
      lastHeartbeatTime:
          json['lastHeartbeatTime'] != null
              ? DateTime.parse(json['lastHeartbeatTime'])
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
      if (lastHeartbeatTime != null)
        'lastHeartbeatTime': lastHeartbeatTime!.toIso8601String(),
      if (lastTransitionTime != null)
        'lastTransitionTime': lastTransitionTime!.toIso8601String(),
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
    };
  }
}
