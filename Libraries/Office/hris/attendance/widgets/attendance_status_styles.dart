import 'package:flutter/material.dart';

Color attendanceStatusColor(String status) {
  switch (status) {
    case 'present':
      return const Color(0xFF059669);
    case 'late':
      return const Color(0xFFD97706);
    case 'absent':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF6B7280);
  }
}

IconData attendanceStatusIcon(String status) {
  switch (status) {
    case 'present':
      return Icons.check_circle_outline;
    case 'late':
      return Icons.access_time;
    case 'absent':
      return Icons.cancel_outlined;
    default:
      return Icons.event_note_outlined;
  }
}

String attendanceStatusLabel(String status) {
  switch (status) {
    case 'present':
      return 'Present';
    case 'late':
      return 'Late';
    case 'absent':
      return 'Absent';
    default:
      return status;
  }
}

String attendanceDurationLabel(int minutes) {
  if (minutes <= 0) return '--';
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  return '${hours}h ${remainingMinutes}m';
}
