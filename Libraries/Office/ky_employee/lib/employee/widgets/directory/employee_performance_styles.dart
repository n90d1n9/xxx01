import 'package:flutter/material.dart';

import '../../models/employee_performance_models.dart';

Color employeePerformanceCycleStatusColor(
  EmployeePerformanceCycleStatus status,
) {
  return switch (status) {
    EmployeePerformanceCycleStatus.onTrack => const Color(0xFF2563EB),
    EmployeePerformanceCycleStatus.attention => const Color(0xFFB45309),
    EmployeePerformanceCycleStatus.readyForReview => const Color(0xFF15803D),
    EmployeePerformanceCycleStatus.overdue => const Color(0xFFB91C1C),
  };
}

Color employeePerformanceGoalStatusColor(EmployeePerformanceGoalStatus status) {
  return switch (status) {
    EmployeePerformanceGoalStatus.active => const Color(0xFF2563EB),
    EmployeePerformanceGoalStatus.atRisk => const Color(0xFFB91C1C),
    EmployeePerformanceGoalStatus.complete => const Color(0xFF15803D),
    EmployeePerformanceGoalStatus.paused => const Color(0xFF6B7280),
  };
}

Color employeePerformanceSentimentColor(
  EmployeePerformanceCheckInSentiment sentiment,
) {
  return switch (sentiment) {
    EmployeePerformanceCheckInSentiment.positive => const Color(0xFF15803D),
    EmployeePerformanceCheckInSentiment.neutral => const Color(0xFF2563EB),
    EmployeePerformanceCheckInSentiment.concern => const Color(0xFFB91C1C),
  };
}

IconData employeePerformanceSentimentIcon(
  EmployeePerformanceCheckInSentiment sentiment,
) {
  return switch (sentiment) {
    EmployeePerformanceCheckInSentiment.positive => Icons.thumb_up_outlined,
    EmployeePerformanceCheckInSentiment.neutral => Icons.chat_bubble_outline,
    EmployeePerformanceCheckInSentiment.concern => Icons.warning_amber_outlined,
  };
}
