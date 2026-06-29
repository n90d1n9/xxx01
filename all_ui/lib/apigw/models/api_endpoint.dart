class ApiEndpoint {
  final String id;
  final String name;
  final String path;
  final String method;
  final int requestCount;
  final double averageResponseTime;
  final double successRate;
  final String lastAccessed;
  final bool isActive;
  final bool isAuthenticated;
  final int rateLimit;
  final String timeout;
  final List<String> allowedIPs;
  final Map<String, dynamic> customHeaders;
  final Map<String, dynamic> cachingPolicy;

  final String targetUrl;

  final int avgResponseTime;

  ApiEndpoint({
    required this.id,
    required this.name,
    required this.path,
    required this.method,
    this.requestCount = 0,
    this.averageResponseTime = 0.0,
    this.successRate = 0.0,
    required this.lastAccessed,
    this.isActive = false,
    this.isAuthenticated = false,
    this.rateLimit = 100,
    required this.timeout,
    this.allowedIPs = const ['*'],
    required this.customHeaders,
    required this.cachingPolicy,
    this.targetUrl = '',
    this.avgResponseTime = 0,
  });

  ApiEndpoint copyWith({
    String? id,
    String? name,
    String? path,
    String? method,
    int? requestCount,
    double? averageResponseTime,
    double? successRate,
    String? lastAccessed,
    bool? isActive,
    bool? isAuthenticated,
    int? rateLimit,
    String? timeout,
    List<String>? allowedIPs,
    Map<String, dynamic>? customHeaders,
    Map<String, dynamic>? cachingPolicy,
  }) {
    return ApiEndpoint(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      method: method ?? this.method,
      requestCount: requestCount ?? this.requestCount,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      successRate: successRate ?? this.successRate,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isActive: isActive ?? this.isActive,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      rateLimit: rateLimit ?? this.rateLimit,
      timeout: timeout ?? this.timeout,
      allowedIPs: allowedIPs ?? this.allowedIPs,
      customHeaders: customHeaders ?? this.customHeaders,
      cachingPolicy: cachingPolicy ?? this.cachingPolicy,
    );
  }
}
