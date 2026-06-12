import 'package:flutter/material.dart';

import '../models/people_ops_models.dart';

Color peopleOpsPriorityColor(PeopleOpsPriority priority) {
  switch (priority) {
    case PeopleOpsPriority.high:
      return const Color(0xFFDC2626);
    case PeopleOpsPriority.medium:
      return const Color(0xFFD97706);
    case PeopleOpsPriority.low:
      return const Color(0xFF059669);
  }
}

Color onboardingStatusColor(OnboardingStatus status) {
  switch (status) {
    case OnboardingStatus.blocked:
      return const Color(0xFFDC2626);
    case OnboardingStatus.inProgress:
      return const Color(0xFF2563EB);
    case OnboardingStatus.notStarted:
      return const Color(0xFFD97706);
    case OnboardingStatus.done:
      return const Color(0xFF059669);
  }
}

Color complianceStatusColor(ComplianceStatus status) {
  switch (status) {
    case ComplianceStatus.overdue:
      return const Color(0xFFDC2626);
    case ComplianceStatus.dueSoon:
      return const Color(0xFFD97706);
    case ComplianceStatus.valid:
      return const Color(0xFF059669);
  }
}

IconData complianceStatusIcon(ComplianceStatus status) {
  switch (status) {
    case ComplianceStatus.overdue:
      return Icons.error_outline;
    case ComplianceStatus.dueSoon:
      return Icons.schedule_outlined;
    case ComplianceStatus.valid:
      return Icons.check_circle_outline;
  }
}

String workforceStatusLabel(WorkforcePlanStatus status) {
  switch (status) {
    case WorkforcePlanStatus.open:
      return 'Open';
    case WorkforcePlanStatus.interviewing:
      return 'Interviewing';
    case WorkforcePlanStatus.offer:
      return 'Offer';
    case WorkforcePlanStatus.fulfilled:
      return 'Fulfilled';
  }
}

String onboardingStatusLabel(OnboardingStatus status) {
  switch (status) {
    case OnboardingStatus.notStarted:
      return 'Not started';
    case OnboardingStatus.inProgress:
      return 'In progress';
    case OnboardingStatus.blocked:
      return 'Blocked';
    case OnboardingStatus.done:
      return 'Done';
  }
}

String complianceStatusLabel(ComplianceStatus status) {
  switch (status) {
    case ComplianceStatus.valid:
      return 'Valid';
    case ComplianceStatus.dueSoon:
      return 'Due soon';
    case ComplianceStatus.overdue:
      return 'Overdue';
  }
}

String peopleOpsInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
