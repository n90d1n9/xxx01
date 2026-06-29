import 'package:flutter/material.dart';

import '../../models/employee_personal_records_models.dart';

Color employeePersonalRecordStatusColor(EmployeePersonalRecordStatus status) {
  return switch (status) {
    EmployeePersonalRecordStatus.verified => const Color(0xFF15803D),
    EmployeePersonalRecordStatus.pending => const Color(0xFF2563EB),
    EmployeePersonalRecordStatus.reviewDue => const Color(0xFFB45309),
    EmployeePersonalRecordStatus.missing => const Color(0xFFB91C1C),
  };
}

IconData employeeAddressTypeIcon(EmployeeAddressType type) {
  return switch (type) {
    EmployeeAddressType.home => Icons.home_outlined,
    EmployeeAddressType.mailing => Icons.markunread_mailbox_outlined,
    EmployeeAddressType.work => Icons.apartment_outlined,
  };
}

IconData employeeEmergencyRelationshipIcon(
  EmployeeEmergencyContactRelationship relationship,
) {
  return switch (relationship) {
    EmployeeEmergencyContactRelationship.spouse =>
      Icons.favorite_border_outlined,
    EmployeeEmergencyContactRelationship.partner => Icons.handshake_outlined,
    EmployeeEmergencyContactRelationship.parent => Icons.elderly_outlined,
    EmployeeEmergencyContactRelationship.sibling => Icons.groups_2_outlined,
    EmployeeEmergencyContactRelationship.friend => Icons.person_outline,
    EmployeeEmergencyContactRelationship.guardian => Icons.shield_outlined,
  };
}
