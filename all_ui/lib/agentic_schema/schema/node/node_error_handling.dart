import '../exception/exception_handler.dart';

class NodeErrorHandling {
  final String? strategy;
  final int? maxRetries;
  final int? retryDelay;
  final String? fallbackNode;
  final String? deadLetterChannel;
  final List<ExceptionHandler>? onException;

  NodeErrorHandling({
    this.strategy = 'retry',
    this.maxRetries = 3,
    this.retryDelay = 1000,
    this.fallbackNode,
    this.deadLetterChannel,
    this.onException,
  });

  factory NodeErrorHandling.fromJson(Map<String, dynamic> json) {
    return NodeErrorHandling(
      strategy: json['strategy'] as String?,
      maxRetries: json['maxRetries'] as int?,
      retryDelay: json['retryDelay'] as int?,
      fallbackNode: json['fallbackNode'] as String?,
      deadLetterChannel: json['deadLetterChannel'] as String?,
      onException: json['onException'] != null
          ? (json['onException'] as List)
                .map(
                  (e) => ExceptionHandler.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (strategy != null) 'strategy': strategy,
      if (maxRetries != null) 'maxRetries': maxRetries,
      if (retryDelay != null) 'retryDelay': retryDelay,
      if (fallbackNode != null) 'fallbackNode': fallbackNode,
      if (deadLetterChannel != null) 'deadLetterChannel': deadLetterChannel,
      if (onException != null)
        'onException': onException!.map((e) => e.toJson()).toList(),
    };
  }
}
