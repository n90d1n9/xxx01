import 'package:flutter/material.dart';

import '../models/performance_models.dart';

Color goalStatusColor(GoalStatus status) {
  switch (status) {
    case GoalStatus.onTrack:
      return const Color(0xFF2563EB);
    case GoalStatus.atRisk:
      return const Color(0xFFDC2626);
    case GoalStatus.completed:
      return const Color(0xFF059669);
  }
}

String goalStatusLabel(GoalStatus status) {
  switch (status) {
    case GoalStatus.onTrack:
      return 'On track';
    case GoalStatus.atRisk:
      return 'At risk';
    case GoalStatus.completed:
      return 'Completed';
  }
}

Color reviewStatusColor(ReviewStatus status) {
  switch (status) {
    case ReviewStatus.notStarted:
      return const Color(0xFF7C3AED);
    case ReviewStatus.inProgress:
      return const Color(0xFF2563EB);
    case ReviewStatus.submitted:
      return const Color(0xFF059669);
    case ReviewStatus.overdue:
      return const Color(0xFFDC2626);
  }
}

String reviewStatusLabel(ReviewStatus status) {
  switch (status) {
    case ReviewStatus.notStarted:
      return 'Not started';
    case ReviewStatus.inProgress:
      return 'In progress';
    case ReviewStatus.submitted:
      return 'Submitted';
    case ReviewStatus.overdue:
      return 'Overdue';
  }
}

Color calibrationStatusColor(CalibrationStatus status) {
  switch (status) {
    case CalibrationStatus.aligned:
      return const Color(0xFF059669);
    case CalibrationStatus.needsReview:
      return const Color(0xFFD97706);
    case CalibrationStatus.disputed:
      return const Color(0xFFDC2626);
  }
}

String calibrationStatusLabel(CalibrationStatus status) {
  switch (status) {
    case CalibrationStatus.aligned:
      return 'Aligned';
    case CalibrationStatus.needsReview:
      return 'Review';
    case CalibrationStatus.disputed:
      return 'Disputed';
  }
}

Color readinessColor(SuccessionReadiness readiness) {
  switch (readiness) {
    case SuccessionReadiness.readyNow:
      return const Color(0xFF059669);
    case SuccessionReadiness.readySoon:
      return const Color(0xFF2563EB);
    case SuccessionReadiness.developing:
      return const Color(0xFFD97706);
  }
}

String readinessLabel(SuccessionReadiness readiness) {
  switch (readiness) {
    case SuccessionReadiness.readyNow:
      return 'Ready now';
    case SuccessionReadiness.readySoon:
      return 'Ready soon';
    case SuccessionReadiness.developing:
      return 'Developing';
  }
}

Color retentionRiskColor(RetentionRiskLevel level) {
  switch (level) {
    case RetentionRiskLevel.low:
      return const Color(0xFF059669);
    case RetentionRiskLevel.medium:
      return const Color(0xFFD97706);
    case RetentionRiskLevel.high:
      return const Color(0xFFDC2626);
  }
}

String retentionRiskLabel(RetentionRiskLevel level) {
  switch (level) {
    case RetentionRiskLevel.low:
      return 'Low';
    case RetentionRiskLevel.medium:
      return 'Medium';
    case RetentionRiskLevel.high:
      return 'High';
  }
}
