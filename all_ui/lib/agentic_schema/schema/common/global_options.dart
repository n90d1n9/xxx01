class GlobalOptions {
  final bool? tracing;
  final bool? messageHistory;
  final bool? logMask;
  final bool? streamCaching;
  final bool? autoStartup;

  GlobalOptions({
    this.tracing = false,
    this.messageHistory = true,
    this.logMask = true,
    this.streamCaching = true,
    this.autoStartup = true,
  });

  factory GlobalOptions.fromJson(Map<String, dynamic> json) {
    return GlobalOptions(
      tracing: json['tracing'] as bool?,
      messageHistory: json['messageHistory'] as bool?,
      logMask: json['logMask'] as bool?,
      streamCaching: json['streamCaching'] as bool?,
      autoStartup: json['autoStartup'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tracing != null) 'tracing': tracing,
      if (messageHistory != null) 'messageHistory': messageHistory,
      if (logMask != null) 'logMask': logMask,
      if (streamCaching != null) 'streamCaching': streamCaching,
      if (autoStartup != null) 'autoStartup': autoStartup,
    };
  }
}
