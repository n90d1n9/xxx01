import 'package:flutter/material.dart';

import '../../models/employee_work_authorization_models.dart';

Color employeeWorkAuthorizationStatusColor(
  EmployeeWorkAuthorizationStatus status,
) {
  return switch (status) {
    EmployeeWorkAuthorizationStatus.valid => const Color(0xFF15803D),
    EmployeeWorkAuthorizationStatus.renewalDue => const Color(0xFFB45309),
    EmployeeWorkAuthorizationStatus.pendingReview => const Color(0xFF2563EB),
    EmployeeWorkAuthorizationStatus.missing => const Color(0xFFB91C1C),
    EmployeeWorkAuthorizationStatus.expired => const Color(0xFFB91C1C),
    EmployeeWorkAuthorizationStatus.suspended => const Color(0xFF64748B),
  };
}

Color employeeWorkAuthorizationEvidenceColor(
  EmployeeWorkAuthorizationEvidenceStatus status,
) {
  return switch (status) {
    EmployeeWorkAuthorizationEvidenceStatus.verified => const Color(0xFF15803D),
    EmployeeWorkAuthorizationEvidenceStatus.pendingUpload => const Color(
      0xFFB45309,
    ),
    EmployeeWorkAuthorizationEvidenceStatus.rejected => const Color(0xFFB91C1C),
    EmployeeWorkAuthorizationEvidenceStatus.expiring => const Color(0xFFB45309),
    EmployeeWorkAuthorizationEvidenceStatus.missing => const Color(0xFFB91C1C),
  };
}

Color employeeWorkAuthorizationSponsorshipColor(
  EmployeeWorkAuthorizationSponsorship sponsorship,
) {
  return switch (sponsorship) {
    EmployeeWorkAuthorizationSponsorship.notRequired => const Color(0xFF64748B),
    EmployeeWorkAuthorizationSponsorship.companySponsored => const Color(
      0xFF2563EB,
    ),
    EmployeeWorkAuthorizationSponsorship.employeeManaged => const Color(
      0xFF15803D,
    ),
    EmployeeWorkAuthorizationSponsorship.vendorManaged => const Color(
      0xFF7C3AED,
    ),
  };
}

IconData employeeWorkAuthorizationTypeIcon(EmployeeWorkAuthorizationType type) {
  return switch (type) {
    EmployeeWorkAuthorizationType.citizen => Icons.verified_user_outlined,
    EmployeeWorkAuthorizationType.permanentResident => Icons.badge_outlined,
    EmployeeWorkAuthorizationType.workVisa => Icons.assignment_ind_outlined,
    EmployeeWorkAuthorizationType.dependentVisa => Icons.groups_2_outlined,
    EmployeeWorkAuthorizationType.studentPermit => Icons.school_outlined,
    EmployeeWorkAuthorizationType.contractorPermit =>
      Icons.engineering_outlined,
  };
}

IconData employeeWorkAuthorizationEvidenceIcon(
  EmployeeWorkAuthorizationEvidenceStatus status,
) {
  return switch (status) {
    EmployeeWorkAuthorizationEvidenceStatus.verified => Icons.verified_outlined,
    EmployeeWorkAuthorizationEvidenceStatus.pendingUpload =>
      Icons.upload_file_outlined,
    EmployeeWorkAuthorizationEvidenceStatus.rejected =>
      Icons.report_problem_outlined,
    EmployeeWorkAuthorizationEvidenceStatus.expiring =>
      Icons.event_busy_outlined,
    EmployeeWorkAuthorizationEvidenceStatus.missing => Icons.help_outline,
  };
}

IconData employeeWorkAuthorizationSponsorshipIcon(
  EmployeeWorkAuthorizationSponsorship sponsorship,
) {
  return switch (sponsorship) {
    EmployeeWorkAuthorizationSponsorship.notRequired => Icons.block_outlined,
    EmployeeWorkAuthorizationSponsorship.companySponsored =>
      Icons.business_center_outlined,
    EmployeeWorkAuthorizationSponsorship.employeeManaged =>
      Icons.person_pin_circle_outlined,
    EmployeeWorkAuthorizationSponsorship.vendorManaged =>
      Icons.handshake_outlined,
  };
}
