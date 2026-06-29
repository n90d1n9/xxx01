class GatewayStatus {
  final bool isOnline;
  final double averageResponseTime;
  final double successRate;
  final int totalEndpoints;
  final int totalRequests;
  final DateTime lastUpdated;
  final int activeEndpoints;
  final double requestsPerSecond;
  final double cpuUsage;
  final double memoryUsage;
  final String uptime;
  final String certificateExpiry;
  final String logsStorageUsage;

  GatewayStatus({
    this.isOnline = false,
    this.averageResponseTime = 0.0,
    this.successRate = 0.0,
    this.totalEndpoints = 0,
    this.totalRequests = 0,
    DateTime? lastUpdated,
    this.activeEndpoints = 0,
    this.requestsPerSecond = 0.0,
    this.cpuUsage = 0.0,
    this.memoryUsage = 0.0,
    String? uptime,
    String? certificateExpiry,
    String? logsStorageUsage,
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       uptime = uptime ?? 'Unknown',
       certificateExpiry = certificateExpiry ?? 'Unknown',
       logsStorageUsage = logsStorageUsage ?? '0%';

  // Create from API response
  factory GatewayStatus.fromJson(Map<String, dynamic> json) {
    return GatewayStatus(
      isOnline: json['isOnline'] ?? false,
      averageResponseTime:
          (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      totalEndpoints: json['totalEndpoints'] ?? 0,
      totalRequests: json['totalRequests'] ?? 0,
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'])
              : DateTime.now(),
      activeEndpoints: json['activeEndpoints'] ?? 0,
      requestsPerSecond: (json['requestsPerSecond'] as num?)?.toDouble() ?? 0.0,
      cpuUsage: (json['cpuUsage'] as num?)?.toDouble() ?? 0.0,
      memoryUsage: (json['memoryUsage'] as num?)?.toDouble() ?? 0.0,
      uptime: json['uptime'] ?? 'Unknown',
      certificateExpiry: json['certificateExpiry'] ?? 'Unknown',
      logsStorageUsage: json['logsStorageUsage'] ?? '0%',
    );
  }

  // Create from map (from API response)
  factory GatewayStatus.fromMap(Map<String, dynamic> map) {
    return GatewayStatus(
      isOnline: map['status'] == 'operational',
      totalEndpoints: map['totalEndpoints'] ?? 0,
      activeEndpoints: map['activeEndpoints'] ?? 0,
      averageResponseTime: map['averageLatency']?.toDouble() ?? 0.0,
      successRate:
          map['successRate']?.toDouble() ?? 0.95, // Default 95% if not provided
      requestsPerSecond: map['requestsPerSecond']?.toDouble() ?? 0.0,
      cpuUsage: map['cpuUsage']?.toDouble() ?? 0.0,
      memoryUsage: map['memoryUsage']?.toDouble() ?? 0.0,
      lastUpdated:
          map['lastUpdated'] is DateTime
              ? map['lastUpdated']
              : DateTime.now().subtract(const Duration(minutes: 5)),
      uptime: map['uptime'] ?? 'Unknown',
      certificateExpiry: map['certificateExpiry'] ?? 'Unknown',
      logsStorageUsage: map['logsStorageUsage'] ?? '0%',
    );
  }

  // Convert to map (for API requests)
  Map<String, dynamic> toMap() {
    return {
      'status': isOnline ? 'operational' : 'offline',
      'totalEndpoints': totalEndpoints,
      'activeEndpoints': activeEndpoints,
      'averageLatency': averageResponseTime,
      'successRate': successRate,
      'requestsPerSecond': requestsPerSecond,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'lastUpdated': lastUpdated,
      'uptime': uptime,
      'certificateExpiry': certificateExpiry,
      'logsStorageUsage': logsStorageUsage,
    };
  }

  // Create a copy with updated values
  GatewayStatus copyWith({
    bool? isOnline,
    int? totalEndpoints,
    int? activeEndpoints,
    double? averageResponseTime,
    double? successRate,
    double? requestsPerSecond,
    double? cpuUsage,
    double? memoryUsage,
    DateTime? lastUpdated,
    String? uptime,
    String? certificateExpiry,
    String? logsStorageUsage,
  }) {
    return GatewayStatus(
      isOnline: isOnline ?? this.isOnline,
      totalEndpoints: totalEndpoints ?? this.totalEndpoints,
      activeEndpoints: activeEndpoints ?? this.activeEndpoints,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      successRate: successRate ?? this.successRate,
      requestsPerSecond: requestsPerSecond ?? this.requestsPerSecond,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      uptime: uptime ?? this.uptime,
      certificateExpiry: certificateExpiry ?? this.certificateExpiry,
      logsStorageUsage: logsStorageUsage ?? this.logsStorageUsage,
      totalRequests: totalRequests,
    );
  }
}
