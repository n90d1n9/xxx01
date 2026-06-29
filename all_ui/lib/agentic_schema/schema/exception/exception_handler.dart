class ExceptionHandler {
  final String exceptionType;
  final String? handler;
  final bool? retryable;

  ExceptionHandler({required this.exceptionType, this.handler, this.retryable});

  factory ExceptionHandler.fromJson(Map<String, dynamic> json) {
    return ExceptionHandler(
      exceptionType: json['exceptionType'] as String,
      handler: json['handler'] as String?,
      retryable: json['retryable'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exceptionType': exceptionType,
      if (handler != null) 'handler': handler,
      if (retryable != null) 'retryable': retryable,
    };
  }
}
