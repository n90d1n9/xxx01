import 'package:flutter/material.dart';

import '../../models/employee_accommodation_models.dart';

Color employeeAccommodationStatusColor(EmployeeAccommodationStatus status) {
  return switch (status) {
    EmployeeAccommodationStatus.requested => const Color(0xFF2563EB),
    EmployeeAccommodationStatus.approved => const Color(0xFFB45309),
    EmployeeAccommodationStatus.active => const Color(0xFF15803D),
    EmployeeAccommodationStatus.reviewDue => const Color(0xFFB45309),
    EmployeeAccommodationStatus.expired => const Color(0xFFB91C1C),
    EmployeeAccommodationStatus.declined => const Color(0xFF64748B),
  };
}

Color employeeAccommodationSensitivityColor(
  EmployeeAccommodationSensitivity sensitivity,
) {
  return switch (sensitivity) {
    EmployeeAccommodationSensitivity.standard => const Color(0xFF15803D),
    EmployeeAccommodationSensitivity.confidential => const Color(0xFFB45309),
    EmployeeAccommodationSensitivity.restricted => const Color(0xFFB91C1C),
  };
}

IconData employeeAccommodationTypeIcon(EmployeeAccommodationType type) {
  return switch (type) {
    EmployeeAccommodationType.ergonomic => Icons.chair_outlined,
    EmployeeAccommodationType.medical => Icons.medical_services_outlined,
    EmployeeAccommodationType.schedule => Icons.schedule_outlined,
    EmployeeAccommodationType.assistiveTechnology => Icons.devices_outlined,
    EmployeeAccommodationType.workplaceAccess => Icons.meeting_room_outlined,
    EmployeeAccommodationType.leaveSupport => Icons.event_available_outlined,
  };
}

IconData employeeAccommodationSensitivityIcon(
  EmployeeAccommodationSensitivity sensitivity,
) {
  return switch (sensitivity) {
    EmployeeAccommodationSensitivity.standard => Icons.visibility_outlined,
    EmployeeAccommodationSensitivity.confidential => Icons.lock_outline,
    EmployeeAccommodationSensitivity.restricted =>
      Icons.admin_panel_settings_outlined,
  };
}
