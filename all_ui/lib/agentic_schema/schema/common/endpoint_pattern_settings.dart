class EndpointPatternSettings {
  final int? pollingInterval;
  final int? maxMessagesPerPoll;
  final String? transactionManager;
  final String? errorHandler;

  EndpointPatternSettings({
    this.pollingInterval = 5000,
    this.maxMessagesPerPoll = 10,
    this.transactionManager,
    this.errorHandler,
  });

  factory EndpointPatternSettings.fromJson(Map<String, dynamic> json) {
    return EndpointPatternSettings(
      pollingInterval: json['pollingInterval'] as int?,
      maxMessagesPerPoll: json['maxMessagesPerPoll'] as int?,
      transactionManager: json['transactionManager'] as String?,
      errorHandler: json['errorHandler'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pollingInterval != null) 'pollingInterval': pollingInterval,
      if (maxMessagesPerPoll != null) 'maxMessagesPerPoll': maxMessagesPerPoll,
      if (transactionManager != null) 'transactionManager': transactionManager,
      if (errorHandler != null) 'errorHandler': errorHandler,
    };
  }
}
