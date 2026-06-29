class StatusCause {
  final String? reason;
  final String? message;
  final String? field;
  StatusCause({this.reason, this.message, this.field});
  factory StatusCause.fromJson(Map<String, dynamic> json) {
    return StatusCause(
      reason: json['reason'],
      message: json['message'],
      field: json['field'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
      if (field != null) 'field': field,
    };
  }
}
