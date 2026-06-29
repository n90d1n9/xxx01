import 'exception_handler.dart';

class ErrorHandling {
  final String? deadLetterQueue;
  final String? errorChannel;
  final int? maxRedeliveries;
  final int? redeliveryDelay;
  final List<ExceptionHandler>? onException;

  ErrorHandling({
    this.deadLetterQueue,
    this.errorChannel,
    this.maxRedeliveries,
    this.redeliveryDelay,
    this.onException,
  });

  factory ErrorHandling.fromJson(Map<String, dynamic> json) {
    return ErrorHandling(
      deadLetterQueue: json['deadLetterQueue'] as String?,
      errorChannel: json['errorChannel'] as String?,
      maxRedeliveries: json['maxRedeliveries'] as int?,
      redeliveryDelay: json['redeliveryDelay'] as int?,
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
      if (deadLetterQueue != null) 'deadLetterQueue': deadLetterQueue,
      if (errorChannel != null) 'errorChannel': errorChannel,
      if (maxRedeliveries != null) 'maxRedeliveries': maxRedeliveries,
      if (redeliveryDelay != null) 'redeliveryDelay': redeliveryDelay,
      if (onException != null)
        'onException': onException!.map((e) => e.toJson()).toList(),
    };
  }
}
