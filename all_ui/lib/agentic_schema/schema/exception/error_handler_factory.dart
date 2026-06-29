class ErrorHandlerFactory {
  final String? type;
  final String? deadLetterUri;
  final bool? useOriginalMessage;

  ErrorHandlerFactory({
    this.type = 'DefaultErrorHandler',
    this.deadLetterUri,
    this.useOriginalMessage = false,
  });

  factory ErrorHandlerFactory.fromJson(Map<String, dynamic> json) {
    return ErrorHandlerFactory(
      type: json['type'] as String?,
      deadLetterUri: json['deadLetterUri'] as String?,
      useOriginalMessage: json['useOriginalMessage'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (deadLetterUri != null) 'deadLetterUri': deadLetterUri,
      if (useOriginalMessage != null) 'useOriginalMessage': useOriginalMessage,
    };
  }
}
