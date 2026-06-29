import 'package:flutter/material.dart';

import '../models/enums.dart';

class StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final bool isDarkMode;

  const StatusBadge({
    super.key,
    required this.status,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (status) {
      case ProjectStatus.active:
        backgroundColor =
            isDarkMode ? const Color(0xFF203F2D) : const Color(0xFFECF8F0);
        textColor = const Color(0xFF28A745);
        iconData = Icons.check_circle;
        break;
      case ProjectStatus.pending:
        backgroundColor =
            isDarkMode ? const Color(0xFF3F3A2D) : const Color(0xFFFFF8EC);
        textColor = const Color(0xFFFFC107);
        iconData = Icons.hourglass_empty;
        break;
      case ProjectStatus.archived:
        backgroundColor =
            isDarkMode ? const Color(0xFF2D2D3F) : const Color(0xFFF0F0F7);
        textColor = const Color(0xFF6C757D);
        iconData = Icons.archive;
        break;
      case ProjectStatus.error:
        backgroundColor =
            isDarkMode ? const Color(0xFF3F2D2D) : const Color(0xFFF8ECEC);
        textColor = const Color(0xFFDC3545);
        iconData = Icons.error;
        break;
      case ProjectStatus.warning:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ProjectStatus.inactive:
        // TODO: Handle this case.
        throw UnimplementedError();
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

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.archived:
        return 'Archived';
      case ProjectStatus.error:
        return 'Error';
      case ProjectStatus.warning:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ProjectStatus.inactive:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
