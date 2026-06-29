class AuditLogger {
  /// Logs security-relevant events with detailed metadata
  Future<void> logSecurityEvent({
    required SecurityEvent event,
    required String userId,
    required Map<String, dynamic> metadata,
  }) async {
    final logEntry = SecurityLogEntry(
      timestamp: DateTime.now().toUtc(),
      eventType: event,
      userId: userId,
      metadata: metadata,
      systemInfo: await SystemInfo.gather(),
    );
    
    await _persistLogEntry(logEntry);
    await _checkSecurityThresholds(logEntry);
  }

  /// Generates security audit report
  Future<SecurityAuditReport> generateAuditReport({
    required DateTimeRange timeRange,
    required AuditConfig config,
  }) async {
    final logs = await _fetchLogs(timeRange);
    final analysis = await SecurityAnalyzer.analyze(logs, config);
    
    return SecurityAuditReport(
      timeRange: timeRange,
      events: analysis.events,
      anomalies: analysis.anomalies,
      recommendations: analysis.recommendations,
    );
  }
}
