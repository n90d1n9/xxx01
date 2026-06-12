class NetworkConfig {
  final String hostDev;
  final String hostProd;
  final String hostDevSchema;
  final String hostProdSchema;
  final String webSocketUrlDev;
  final String webSocketUrlProd;
  final bool isDev;
  final int timeoutReceive;
  final int timeoutConnection;
  final bool isWebSocketDev;
  final int maxRetries;
  final int retryBaseDelayMs;
  final int retryMaxDelayMs;
  final double retryJitterPct;
  final bool failFastOffline;
  final bool circuitBreakerEnabled;
  final int circuitBreakerFailureThreshold;
  final int circuitBreakerSuccessThreshold;
  final int circuitBreakerCooldownMs;
  final bool requestDeduplicationEnabled;

  const NetworkConfig({
    this.hostDev = 'localhost:7100',
    this.hostProd = 'api.mydomain.com',
    this.hostDevSchema = 'http',
    this.hostProdSchema = 'https',
    this.webSocketUrlDev = 'ws://localhost:7100',
    this.webSocketUrlProd = 'wss://api.mydomain.com',
    this.timeoutReceive = 12000,
    this.timeoutConnection = 5000,
    this.isWebSocketDev = true,
    this.isDev = true,
    this.maxRetries = 0,
    this.retryBaseDelayMs = 250,
    this.retryMaxDelayMs = 2000,
    this.retryJitterPct = 0.2,
    this.failFastOffline = false,
    this.circuitBreakerEnabled = false,
    this.circuitBreakerFailureThreshold = 5,
    this.circuitBreakerSuccessThreshold = 2,
    this.circuitBreakerCooldownMs = 15000,
    this.requestDeduplicationEnabled = false,
  });

  String get hostUrl {
    return isDev ? hostDev : hostProd;
  }

  String get hostSchema {
    return isDev ? hostDevSchema : hostProdSchema;
  }

  String get baseUrl {
    return '$hostSchema://$hostUrl';
  }

  String get webSocketUrl {
    return isWebSocketDev ? webSocketUrlDev : webSocketUrlProd;
  }

  NetworkConfig copyWith({
    String? hostDev,
    String? hostProd,
    String? hostDevSchema,
    String? hostProdSchema,
    String? webSocketUrlDev,
    String? webSocketUrlProd,
    int? timeoutReceive,
    int? timeoutConnection,
    bool? isDev,
    int? maxRetries,
    int? retryBaseDelayMs,
    int? retryMaxDelayMs,
    double? retryJitterPct,
    bool? failFastOffline,
    bool? circuitBreakerEnabled,
    int? circuitBreakerFailureThreshold,
    int? circuitBreakerSuccessThreshold,
    int? circuitBreakerCooldownMs,
    bool? requestDeduplicationEnabled,
  }) {
    return NetworkConfig(
      hostDev: hostDev ?? this.hostDev,
      hostProd: hostProd ?? this.hostProd,
      hostDevSchema: hostDevSchema ?? this.hostDevSchema,
      hostProdSchema: hostProdSchema ?? this.hostProdSchema,
      webSocketUrlDev: webSocketUrlDev ?? this.webSocketUrlDev,
      webSocketUrlProd: webSocketUrlProd ?? this.webSocketUrlProd,
      timeoutReceive: timeoutReceive ?? this.timeoutReceive,
      timeoutConnection: timeoutConnection ?? this.timeoutConnection,
      isDev: isDev ?? this.isDev,
      maxRetries: maxRetries ?? this.maxRetries,
      retryBaseDelayMs: retryBaseDelayMs ?? this.retryBaseDelayMs,
      retryMaxDelayMs: retryMaxDelayMs ?? this.retryMaxDelayMs,
      retryJitterPct: retryJitterPct ?? this.retryJitterPct,
      failFastOffline: failFastOffline ?? this.failFastOffline,
      circuitBreakerEnabled:
          circuitBreakerEnabled ?? this.circuitBreakerEnabled,
      circuitBreakerFailureThreshold:
          circuitBreakerFailureThreshold ?? this.circuitBreakerFailureThreshold,
      circuitBreakerSuccessThreshold:
          circuitBreakerSuccessThreshold ?? this.circuitBreakerSuccessThreshold,
      circuitBreakerCooldownMs:
          circuitBreakerCooldownMs ?? this.circuitBreakerCooldownMs,
      requestDeduplicationEnabled:
          requestDeduplicationEnabled ?? this.requestDeduplicationEnabled,
    );
  }

  @override
  String toString() {
    return '''
hostDev: $hostDev \n
hostDevSchema: $hostDevSchema \n
hostProd: $hostProd \n
hostProdSchema: $hostProdSchema \n
webSocketUrlDev: $webSocketUrlDev \n
webSocketUrlProd: $webSocketUrlProd \n
timeoutReceive: $timeoutReceive \n
timeoutConnection: $timeoutConnection \n
isDev: $isDev \n
maxRetries: $maxRetries \n
retryBaseDelayMs: $retryBaseDelayMs \n
retryMaxDelayMs: $retryMaxDelayMs \n
retryJitterPct: $retryJitterPct \n
failFastOffline: $failFastOffline \n
circuitBreakerEnabled: $circuitBreakerEnabled \n
circuitBreakerFailureThreshold: $circuitBreakerFailureThreshold \n
circuitBreakerSuccessThreshold: $circuitBreakerSuccessThreshold \n
circuitBreakerCooldownMs: $circuitBreakerCooldownMs \n
requestDeduplicationEnabled: $requestDeduplicationEnabled''';
  }
}
