import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../devportal/models/alert.dart';

// Alert Types and Severity
enum AlertType {
  CLUSTER_HEALTH,
  TOPIC_PERFORMANCE,
  SECURITY_VIOLATION,
  CONSUMPTION_LAG,
}

class Alert {
  final AlertType type;
  final String message;
  final DateTime timestamp;
  final dynamic details;
  final int severity; // 1-5, 5 being most critical

  Alert({
    required this.type,
    required this.message,
    required this.severity,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class MonitoringService {
  final _alertsController = BehaviorSubject<List<Alert>>.seeded([]);
  Stream<List<Alert>> get alertsStream => _alertsController.stream;

  // Sophisticated Alerting Logic
  void createAlert({
    required AlertType type,
    required String message,
    required int severity,
    dynamic details,
  }) {
    final alert = Alert(
      type: type,
      message: message,
      severity: severity,
      details: details,
    );

    final currentAlerts = _alertsController.value;
    currentAlerts.add(alert);
    _alertsController.add(currentAlerts);

    // Optional: Send to external monitoring system
    _sendAlertToExternalSystem(alert);
  }

  Future<void> _sendAlertToExternalSystem(Alert alert) async {
    try {
      await http.post(
        Uri.parse('https://monitoring.yourcompany.com/alerts'),
        body: json.encode({
          'type': alert.type.toString(),
          'message': alert.message,
          'severity': alert.severity,
          'details': alert.details,
          'timestamp': alert.timestamp.toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Failed to send alert to external system: $e');
    }
  }
}
