class PluginCapabilities {
  final bool supportsAsync;
  final bool supportsStreaming;
  final bool supportsBatch;
  final bool requiresAuth;
  final bool isStateful;
  final int maxConcurrency;
  final Duration? timeout;

  PluginCapabilities({
    this.supportsAsync = true,
    this.supportsStreaming = false,
    this.supportsBatch = false,
    this.requiresAuth = false,
    this.isStateful = false,
    this.maxConcurrency = 10,
    this.timeout,
  });

  Map<String, dynamic> toJson() => {
    'supportsAsync': supportsAsync,
    'supportsStreaming': supportsStreaming,
    'supportsBatch': supportsBatch,
    'requiresAuth': requiresAuth,
    'isStateful': isStateful,
    'maxConcurrency': maxConcurrency,
    'timeout': timeout?.inMilliseconds,
  };

  factory PluginCapabilities.fromJson(Map<String, dynamic> json) =>
      PluginCapabilities(
        supportsAsync: json['supportsAsync'] ?? true,
        supportsStreaming: json['supportsStreaming'] ?? false,
        supportsBatch: json['supportsBatch'] ?? false,
        requiresAuth: json['requiresAuth'] ?? false,
        isStateful: json['isStateful'] ?? false,
        maxConcurrency: json['maxConcurrency'] ?? 10,
        timeout: json['timeout'] != null
            ? Duration(milliseconds: json['timeout'])
            : null,
      );
}
