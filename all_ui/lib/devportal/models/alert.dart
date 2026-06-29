import 'package:flutter/material.dart';

import 'enums.dart';

class Alert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity; // 'info', 'warning', 'error', 'critical'
  final DateTime timestamp;
  final bool isRead;
  final String? projectId;
  final String? category;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isDismissible;
  final VoidCallback? onDismiss;

  Alert({
    this.description,
    this.actionLabel,
    this.onAction,
    this.isDismissible = false,
    this.onDismiss,
    required this.id,
    this.title = '',
    this.message = '',
    this.severity = AlertSeverity.info,
    DateTime? timestamp,
    this.isRead = false,
    this.projectId,
    this.category,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert from JSON
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: AlertSeverity.info, //json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      projectId: json['projectId'] as String?,
      category: json['category'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'projectId': projectId,
      'category': category,
    };
  }

  // Get color based on severity
  Color get severityColor {
    switch (severity) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Get icon based on severity
  IconData get severityIcon {
    switch (severity) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'critical':
        return Icons.notification_important;
      default:
        return Icons.notifications_none;
    }
  }
}
