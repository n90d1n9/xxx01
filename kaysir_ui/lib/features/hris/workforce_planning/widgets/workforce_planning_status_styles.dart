import 'package:flutter/material.dart';

import '../models/workforce_planning_models.dart';

String planStatusLabel(WorkforcePlanStatus status) {
  switch (status) {
    case WorkforcePlanStatus.onTrack:
      return 'On track';
    case WorkforcePlanStatus.watch:
      return 'Watch';
    case WorkforcePlanStatus.gap:
      return 'Gap';
    case WorkforcePlanStatus.overPlan:
      return 'Over plan';
  }
}

Color planStatusColor(WorkforcePlanStatus status) {
  switch (status) {
    case WorkforcePlanStatus.onTrack:
      return const Color(0xFF15803D);
    case WorkforcePlanStatus.watch:
      return const Color(0xFFB45309);
    case WorkforcePlanStatus.gap:
      return const Color(0xFFDC2626);
    case WorkforcePlanStatus.overPlan:
      return const Color(0xFF7C3AED);
  }
}

String positionStatusLabel(PositionRequestStatus status) {
  switch (status) {
    case PositionRequestStatus.draft:
      return 'Draft';
    case PositionRequestStatus.awaitingApproval:
      return 'Approval';
    case PositionRequestStatus.approved:
      return 'Approved';
    case PositionRequestStatus.blocked:
      return 'Blocked';
  }
}

Color positionStatusColor(PositionRequestStatus status) {
  switch (status) {
    case PositionRequestStatus.draft:
      return const Color(0xFF64748B);
    case PositionRequestStatus.awaitingApproval:
      return const Color(0xFFB45309);
    case PositionRequestStatus.approved:
      return const Color(0xFF15803D);
    case PositionRequestStatus.blocked:
      return const Color(0xFFDC2626);
  }
}

String capacityRiskLabel(CapacityRiskLevel level) {
  switch (level) {
    case CapacityRiskLevel.low:
      return 'Low';
    case CapacityRiskLevel.medium:
      return 'Medium';
    case CapacityRiskLevel.high:
      return 'High';
  }
}

Color capacityRiskColor(CapacityRiskLevel level) {
  switch (level) {
    case CapacityRiskLevel.low:
      return const Color(0xFF15803D);
    case CapacityRiskLevel.medium:
      return const Color(0xFFB45309);
    case CapacityRiskLevel.high:
      return const Color(0xFFDC2626);
  }
}

String scenarioConfidenceLabel(ScenarioConfidence confidence) {
  switch (confidence) {
    case ScenarioConfidence.low:
      return 'Low confidence';
    case ScenarioConfidence.medium:
      return 'Medium';
    case ScenarioConfidence.high:
      return 'High';
  }
}

Color scenarioConfidenceColor(ScenarioConfidence confidence) {
  switch (confidence) {
    case ScenarioConfidence.low:
      return const Color(0xFFDC2626);
    case ScenarioConfidence.medium:
      return const Color(0xFFB45309);
    case ScenarioConfidence.high:
      return const Color(0xFF15803D);
  }
}
