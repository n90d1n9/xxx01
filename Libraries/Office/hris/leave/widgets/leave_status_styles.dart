import 'package:flutter/material.dart';

import '../models/leave_request.dart';

const leaveTypes = [
  'Vacation',
  'Sick Leave',
  'Personal Leave',
  'Work From Home',
];

Color leaveStatusColor(LeaveStatus status) {
  switch (status) {
    case LeaveStatus.pending:
      return const Color(0xFFD97706);
    case LeaveStatus.approved:
      return const Color(0xFF059669);
    case LeaveStatus.rejected:
      return const Color(0xFFDC2626);
  }
}

IconData leaveStatusIcon(LeaveStatus status) {
  switch (status) {
    case LeaveStatus.pending:
      return Icons.pending_outlined;
    case LeaveStatus.approved:
      return Icons.check_circle_outline;
    case LeaveStatus.rejected:
      return Icons.cancel_outlined;
  }
}

String leaveStatusLabel(LeaveStatus status) {
  switch (status) {
    case LeaveStatus.pending:
      return 'Pending';
    case LeaveStatus.approved:
      return 'Approved';
    case LeaveStatus.rejected:
      return 'Rejected';
  }
}

Color leaveTypeColor(String leaveType) {
  switch (leaveType) {
    case 'Vacation':
      return const Color(0xFF2563EB);
    case 'Sick Leave':
      return const Color(0xFF7C3AED);
    case 'Personal Leave':
      return const Color(0xFFD97706);
    case 'Work From Home':
      return const Color(0xFF0F766E);
    default:
      return const Color(0xFF6B7280);
  }
}

IconData leaveTypeIcon(String leaveType) {
  switch (leaveType) {
    case 'Vacation':
      return Icons.beach_access_outlined;
    case 'Sick Leave':
      return Icons.healing_outlined;
    case 'Personal Leave':
      return Icons.person_outline;
    case 'Work From Home':
      return Icons.home_work_outlined;
    default:
      return Icons.event_note_outlined;
  }
}
