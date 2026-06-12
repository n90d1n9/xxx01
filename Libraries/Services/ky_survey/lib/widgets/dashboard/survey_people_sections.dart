import 'package:flutter/material.dart';

import '../../analytics/survey_fieldwork_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../models/survey.dart';
import '../../models/survey_status.dart';
import 'survey_dashboard_shared.dart';
import 'survey_fieldwork_board.dart';
import 'survey_progress_list.dart';

/// Hosts fieldwork queues while allowing read-only embedded dashboards.
class SurveyFieldworkSection extends StatelessWidget {
  final SurveyFieldworkInsights fieldworkInsights;
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;
  final ValueChanged<Survey>? onOpenSurvey;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;
  final SurveyAssignmentStatusChanged? onAssignmentStatusChanged;

  const SurveyFieldworkSection({
    super.key,
    required this.fieldworkInsights,
    required this.responseSyncReadiness,
    this.onOpenSurvey,
    this.onOpenResponse,
    this.onAssignmentStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyFieldworkBoard(
      insights: fieldworkInsights,
      responseSyncReadiness: responseSyncReadiness,
      onOpenSurvey: onOpenSurvey,
      onOpenResponse: onOpenResponse,
      onStatusChanged: onAssignmentStatusChanged,
    );
  }
}

/// Shows live surveys that participants can open when intake is available.
class SurveyParticipantSection extends StatelessWidget {
  final List<Survey> surveys;
  final ValueChanged<Survey>? onOpenSurvey;

  const SurveyParticipantSection({
    super.key,
    required this.surveys,
    this.onOpenSurvey,
  });

  @override
  Widget build(BuildContext context) {
    final availableSurveys = surveys
        .where((survey) => survey.status.isLive)
        .toList();

    return SurveySectionStack(
      children: [
        const SurveySectionHeader(title: 'Available Surveys'),
        SurveyProgressList(
          surveys: availableSurveys,
          onSurveySelected: onOpenSurvey,
        ),
      ],
    );
  }
}
