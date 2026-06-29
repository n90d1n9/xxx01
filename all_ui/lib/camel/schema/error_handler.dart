class ErrorHandler {
  final String id;
  final ErrorHandlerType type;
  final int maxRetries;
  final Duration retryDelay;
  final bool useExponentialBackoff;
  final String? deadLetterChannel;
  final Map<String, dynamic> config;

  const ErrorHandler({
    required this.id,
    required this.type,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 5),
    this.useExponentialBackoff = false,
    this.deadLetterChannel,
    required this.config,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'maxRetries': maxRetries,
    'retryDelay': retryDelay.inMilliseconds,
    'useExponentialBackoff': useExponentialBackoff,
    'deadLetterChannel': deadLetterChannel,
    'config': config,
  };
}

enum ErrorHandlerType {
  defaultErrorHandler,
  deadLetterChannel,
  noErrorHandler,
  loggingErrorHandler,
  custom,
}
