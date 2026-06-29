class ContainerStateTerminated {
  final int exitCode;
  final String? reason;
  final String? message;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? signal;
  final String? containerID;
  ContainerStateTerminated({
    required this.exitCode,
    this.reason,
    this.message,
    this.startedAt,
    this.finishedAt,
    this.signal,
    this.containerID,
  });
  factory ContainerStateTerminated.fromJson(Map<String, dynamic> json) {
    return ContainerStateTerminated(
      exitCode: json['exitCode'],
      reason: json['reason'],
      message: json['message'],
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      finishedAt:
          json['finishedAt'] != null
              ? DateTime.parse(json['finishedAt'])
              : null,
      signal: json['signal'],
      containerID: json['containerID'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'exitCode': exitCode,
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
      if (signal != null) 'signal': signal,
      if (containerID != null) 'containerID': containerID,
    };
  }
}
