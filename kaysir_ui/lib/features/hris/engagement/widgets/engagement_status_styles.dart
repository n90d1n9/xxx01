import 'package:flutter/material.dart';

import '../models/engagement_models.dart';

Color surveyStatusColor(SurveyStatus status) {
  switch (status) {
    case SurveyStatus.live:
      return const Color(0xFF2563EB);
    case SurveyStatus.actionRequired:
      return const Color(0xFFDC2626);
    case SurveyStatus.closed:
      return const Color(0xFF059669);
    case SurveyStatus.draft:
      return const Color(0xFF7C3AED);
  }
}

String surveyStatusLabel(SurveyStatus status) {
  switch (status) {
    case SurveyStatus.draft:
      return 'Draft';
    case SurveyStatus.live:
      return 'Live';
    case SurveyStatus.closed:
      return 'Closed';
    case SurveyStatus.actionRequired:
      return 'Action';
  }
}

Color engagementPriorityColor(EngagementPriority priority) {
  switch (priority) {
    case EngagementPriority.high:
      return const Color(0xFFDC2626);
    case EngagementPriority.medium:
      return const Color(0xFFD97706);
    case EngagementPriority.low:
      return const Color(0xFF059669);
  }
}

Color recognitionTypeColor(RecognitionType type) {
  switch (type) {
    case RecognitionType.peer:
      return const Color(0xFF7C3AED);
    case RecognitionType.manager:
      return const Color(0xFF2563EB);
    case RecognitionType.milestone:
      return const Color(0xFFD97706);
  }
}

String recognitionTypeLabel(RecognitionType type) {
  switch (type) {
    case RecognitionType.peer:
      return 'Peer';
    case RecognitionType.manager:
      return 'Manager';
    case RecognitionType.milestone:
      return 'Milestone';
  }
}

Color wellbeingRiskColor(WellbeingRiskLevel level) {
  switch (level) {
    case WellbeingRiskLevel.high:
      return const Color(0xFFDC2626);
    case WellbeingRiskLevel.medium:
      return const Color(0xFFD97706);
    case WellbeingRiskLevel.low:
      return const Color(0xFF059669);
  }
}

String wellbeingRiskLabel(WellbeingRiskLevel level) {
  switch (level) {
    case WellbeingRiskLevel.low:
      return 'Low';
    case WellbeingRiskLevel.medium:
      return 'Medium';
    case WellbeingRiskLevel.high:
      return 'High';
  }
}

Color actionPlanStatusColor(ActionPlanStatus status) {
  switch (status) {
    case ActionPlanStatus.done:
      return const Color(0xFF059669);
    case ActionPlanStatus.inProgress:
      return const Color(0xFF2563EB);
    case ActionPlanStatus.planned:
      return const Color(0xFF7C3AED);
    case ActionPlanStatus.blocked:
      return const Color(0xFFDC2626);
  }
}

String actionPlanStatusLabel(ActionPlanStatus status) {
  switch (status) {
    case ActionPlanStatus.planned:
      return 'Planned';
    case ActionPlanStatus.inProgress:
      return 'In progress';
    case ActionPlanStatus.blocked:
      return 'Blocked';
    case ActionPlanStatus.done:
      return 'Done';
  }
}
