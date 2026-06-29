import 'package:flutter/material.dart';

import '../../models/employee_compensation_models.dart';

Color employeeCompensationReviewStatusColor(
  EmployeeCompensationReviewStatus status,
) {
  return switch (status) {
    EmployeeCompensationReviewStatus.submitted => const Color(0xFF2563EB),
    EmployeeCompensationReviewStatus.approved => const Color(0xFFB45309),
    EmployeeCompensationReviewStatus.applied => const Color(0xFF15803D),
  };
}

IconData employeeCompensationReviewTypeIcon(
  EmployeeCompensationReviewType type,
) {
  return switch (type) {
    EmployeeCompensationReviewType.meritIncrease => Icons.trending_up_outlined,
    EmployeeCompensationReviewType.marketAdjustment =>
      Icons.query_stats_outlined,
    EmployeeCompensationReviewType.retention => Icons.handshake_outlined,
    EmployeeCompensationReviewType.correction => Icons.tune_outlined,
  };
}
