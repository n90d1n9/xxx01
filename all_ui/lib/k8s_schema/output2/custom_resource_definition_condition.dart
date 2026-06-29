class CustomResourceDefinitionCondition {
  final String type;
  final String status;
  final DateTime? lastTransitionTime;
  final String? reason;
  final String? message;
  CustomResourceDefinitionCondition({
    required this.type,
    required this.status,
    this.lastTransitionTime,
    this.reason,
    this.message,
  });
  factory CustomResourceDefinitionCondition.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomResourceDefinitionCondition(
      type: json['type'],
      status: json['status'],
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
      if (lastTransitionTime != null)
        'lastTransitionTime': lastTransitionTime!.toIso8601String(),
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
    };
  }
}
