class ExecutionStep {
  final String agentId;
  final String agentName;
  final bool success;
  final dynamic output;
  final Duration? duration;
  final String? error;

  ExecutionStep({
    required this.agentId,
    required this.agentName,
    required this.success,
    this.output,
    this.duration,
    this.error,
  });

  factory ExecutionStep.fromJson(Map<String, dynamic> json) {
    final durationMs = json['duration'] as int?;
    return ExecutionStep(
      agentId: json['agentId'] as String,
      agentName: json['agentName'] as String,
      success: json['success'] as bool,
      output: json['output'],
      duration: durationMs != null ? Duration(milliseconds: durationMs) : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'agentName': agentName,
      'success': success,
      'output': output,
      'duration': duration?.inMilliseconds,
      'error': error,
    };
  }

  ExecutionStep copyWith({
    String? agentId,
    String? agentName,
    bool? success,
    dynamic output,
    Duration? duration,
    String? error,
  }) {
    return ExecutionStep(
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      success: success ?? this.success,
      output: output ?? this.output,
      duration: duration ?? this.duration,
      error: error ?? this.error,
    );
  }
}
