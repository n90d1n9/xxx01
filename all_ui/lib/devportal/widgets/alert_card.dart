import 'package:flutter/material.dart';

import '../models/alert.dart';
import '../models/alert_model.dart';
import '../models/enums.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final bool isDarkMode;

  const AlertCard({super.key, required this.alert, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;

    switch (alert.severity) {
      case AlertSeverity.info:
        backgroundColor =
            isDarkMode ? const Color(0xFF2D3A4F) : const Color(0xFFE8F4FF);
        borderColor =
            isDarkMode ? const Color(0xFF3A5F8A) : const Color(0xFFBFDFFF);
        iconColor = const Color(0xFF0D6EFD);
        iconData = Icons.info;
        break;
      case AlertSeverity.warning:
        backgroundColor =
            isDarkMode ? const Color(0xFF3F3A2D) : const Color(0xFFFFF8EC);
        borderColor =
            isDarkMode ? const Color(0xFF8A7A3A) : const Color(0xFFFFECBF);
        iconColor = const Color(0xFFFFC107);
        iconData = Icons.warning;
        break;
      case AlertSeverity.error:
        backgroundColor =
            isDarkMode ? const Color(0xFF3F2D2D) : const Color(0xFFF8ECEC);
        borderColor =
            isDarkMode ? const Color(0xFF8A3A3A) : const Color(0xFFFFBFBF);
        iconColor = const Color(0xFFDC3545);
        iconData = Icons.error;
        break;
      case AlertSeverity.success:
        backgroundColor =
            isDarkMode ? const Color(0xFF203F2D) : const Color(0xFFECF8F0);
        borderColor =
            isDarkMode ? const Color(0xFF3A8A3A) : const Color(0xFFBFFFBF);
        iconColor = const Color(0xFF28A745);
        iconData = Icons.check_circle;
        break;
      case AlertSeverity.critical:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, size: 24, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                if (alert.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    alert.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
                if (alert.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: alert.onAction,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: iconColor.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      alert.actionLabel!,
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (alert.isDismissible)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: isDarkMode ? Colors.white54 : Colors.black45,
              ),
              onPressed: alert.onDismiss,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
