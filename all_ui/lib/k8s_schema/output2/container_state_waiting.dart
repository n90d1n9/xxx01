class ContainerStateWaiting {
  final String? reason;
  final String? message;
  ContainerStateWaiting({this.reason, this.message});
  factory ContainerStateWaiting.fromJson(Map<String, dynamic> json) {
    return ContainerStateWaiting(
      reason: json['reason'],
      message: json['message'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
    };
  }
}
