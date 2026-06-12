import 'package:flutter/material.dart';

import '../../models/employee_leave_models.dart';

Color employeeLeaveRequestStatusColor(EmployeeLeaveRequestStatus status) {
  return switch (status) {
    EmployeeLeaveRequestStatus.pending => const Color(0xFFB45309),
    EmployeeLeaveRequestStatus.approved => const Color(0xFF15803D),
    EmployeeLeaveRequestStatus.rejected => const Color(0xFFB91C1C),
    EmployeeLeaveRequestStatus.cancelled => const Color(0xFF6B7280),
  };
}

Color employeeLeaveRiskColor(EmployeeLeaveRiskType type) {
  return switch (type) {
    EmployeeLeaveRiskType.blackoutConflict => const Color(0xFFB91C1C),
    EmployeeLeaveRiskType.lowBalance => const Color(0xFFB45309),
    EmployeeLeaveRiskType.pendingApproval => const Color(0xFF2563EB),
  };
}

IconData employeeLeaveTypeIcon(EmployeeLeaveType type) {
  return switch (type) {
    EmployeeLeaveType.vacation => Icons.beach_access_outlined,
    EmployeeLeaveType.sick => Icons.medical_services_outlined,
    EmployeeLeaveType.personal => Icons.person_pin_circle_outlined,
    EmployeeLeaveType.unpaid => Icons.money_off_csred_outlined,
    EmployeeLeaveType.bereavement => Icons.volunteer_activism_outlined,
  };
}

IconData employeeLeaveRiskIcon(EmployeeLeaveRiskType type) {
  return switch (type) {
    EmployeeLeaveRiskType.blackoutConflict => Icons.event_busy_outlined,
    EmployeeLeaveRiskType.lowBalance => Icons.warning_amber_outlined,
    EmployeeLeaveRiskType.pendingApproval => Icons.rate_review_outlined,
  };
}
