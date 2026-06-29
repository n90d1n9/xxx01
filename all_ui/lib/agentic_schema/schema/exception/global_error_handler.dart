class GlobalErrorHandler {
  final String? deadLetterQueue;
  final String? errorWorkflow;
  final bool? logErrors;

  GlobalErrorHandler({
    this.deadLetterQueue,
    this.errorWorkflow,
    this.logErrors = true,
  });

  factory GlobalErrorHandler.fromJson(Map<String, dynamic> json) {
    return GlobalErrorHandler(
      deadLetterQueue: json['deadLetterQueue'] as String?,
      errorWorkflow: json['errorWorkflow'] as String?,
      logErrors: json['logErrors'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (deadLetterQueue != null) 'deadLetterQueue': deadLetterQueue,
      if (errorWorkflow != null) 'errorWorkflow': errorWorkflow,
      if (logErrors != null) 'logErrors': logErrors,
    };
  }
}
