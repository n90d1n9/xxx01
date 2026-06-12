import 'package:flutter/material.dart';

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  const AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });

  AdminNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'isRead': isRead,
    };
  }

  static AdminNotification fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      isRead: json['isRead'],
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_cart_outlined;
      case NotificationType.payment:
        return Icons.payments_outlined;
      case NotificationType.inventory:
        return Icons.inventory_2_outlined;
      case NotificationType.user:
        return Icons.person_outline;
      case NotificationType.general:
      default:
        return Icons.notifications_outlined;
    }
  }

  Color getColor(BuildContext context) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.inventory:
        return Colors.orange;
      case NotificationType.user:
        return Colors.purple;
      case NotificationType.general:
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

enum NotificationType {
  order,
  payment,
  inventory,
  user,
  general,
  success,
  warning,
  error,
  info,
}
