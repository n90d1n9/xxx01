import 'package:flutter/material.dart';

import '../models/enums.dart';

class ApiKeyStatusBadge extends StatelessWidget {
  final ApiKeyStatus status;
  final bool isDarkMode;

  const ApiKeyStatusBadge({
    Key? key,
    required this.status,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (status) {
      case ApiKeyStatus.active:
        backgroundColor =
            isDarkMode ? const Color(0xFF203F2D) : const Color(0xFFECF8F0);
        textColor = const Color(0xFF28A745);
        iconData = Icons.vpn_key;
        break;
      case ApiKeyStatus.revoked:
        backgroundColor =
            isDarkMode ? const Color(0xFF3F2D2D) : const Color(0xFFF8ECEC);
        textColor = const Color(0xFFDC3545);
        iconData = Icons.no_encryption;
        break;
      case ApiKeyStatus.expired:
        backgroundColor =
            isDarkMode ? const Color(0xFF3F3A2D) : const Color(0xFFFFF8EC);
        textColor = const Color(0xFFFFC107);
        iconData = Icons.timer_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ApiKeyStatus status) {
    switch (status) {
      case ApiKeyStatus.active:
        return 'Active';
      case ApiKeyStatus.revoked:
        return 'Revoked';
      case ApiKeyStatus.expired:
        return 'Expired';
    }
  }
}
