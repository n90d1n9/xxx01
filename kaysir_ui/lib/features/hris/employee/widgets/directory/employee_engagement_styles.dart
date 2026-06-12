import 'package:flutter/material.dart';

import '../../models/employee_engagement_models.dart';

Color employeeEngagementStatusColor(EmployeeEngagementStatus status) {
  return switch (status) {
    EmployeeEngagementStatus.thriving => const Color(0xFF15803D),
    EmployeeEngagementStatus.steady => const Color(0xFF2563EB),
    EmployeeEngagementStatus.watch => const Color(0xFFB45309),
    EmployeeEngagementStatus.critical => const Color(0xFFB91C1C),
  };
}

Color employeeEngagementSentimentColor(EmployeeEngagementSentiment sentiment) {
  return switch (sentiment) {
    EmployeeEngagementSentiment.energized => const Color(0xFF15803D),
    EmployeeEngagementSentiment.steady => const Color(0xFF2563EB),
    EmployeeEngagementSentiment.strained => const Color(0xFFB45309),
    EmployeeEngagementSentiment.disengaged => const Color(0xFFB91C1C),
  };
}

Color employeeRetentionSignalStatusColor(EmployeeRetentionSignalStatus status) {
  return switch (status) {
    EmployeeRetentionSignalStatus.open => const Color(0xFFB91C1C),
    EmployeeRetentionSignalStatus.inProgress => const Color(0xFFB45309),
    EmployeeRetentionSignalStatus.resolved => const Color(0xFF15803D),
  };
}

IconData employeeRecognitionImpactIcon(EmployeeRecognitionImpact impact) {
  return switch (impact) {
    EmployeeRecognitionImpact.customer => Icons.handshake_outlined,
    EmployeeRecognitionImpact.craft => Icons.auto_awesome_outlined,
    EmployeeRecognitionImpact.teamwork => Icons.groups_2_outlined,
    EmployeeRecognitionImpact.leadership => Icons.emoji_events_outlined,
  };
}
