import '../models/survey.dart';
import '../models/survey_assignment.dart';
import '../models/survey_response.dart';
import 'survey_evidence_sync_insights.dart';
import 'survey_fieldwork_insights.dart';
import 'survey_insights.dart';
import 'survey_response_insights.dart';
import 'survey_response_quality_insights.dart';
import 'survey_response_review_insights.dart';
import 'survey_response_sync_readiness.dart';

/// Groups the analytics required to render the survey dashboard workspace.
class SurveyDashboardInsightsBundle {
  final SurveyInsights insights;
  final SurveyFieldworkInsights fieldworkInsights;
  final SurveyResponseInsights responseInsights;
  final SurveyEvidenceSyncInsights evidenceSyncInsights;
  final SurveyResponseQualityInsights responseQualityInsights;
  final SurveyResponseReviewInsights responseReviewInsights;
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;

  const SurveyDashboardInsightsBundle({
    required this.insights,
    required this.fieldworkInsights,
    required this.responseInsights,
    required this.evidenceSyncInsights,
    required this.responseQualityInsights,
    required this.responseReviewInsights,
    required this.responseSyncReadiness,
  });

  factory SurveyDashboardInsightsBundle.evaluate({
    required List<Survey> surveys,
    required List<SurveyResponse> responses,
    required List<SurveyAssignment> assignments,
    DateTime? now,
  }) {
    final responseQualityInsights = SurveyResponseQualityInsights(
      surveys: surveys,
      responses: responses,
    );

    return SurveyDashboardInsightsBundle(
      insights: SurveyInsights(surveys),
      fieldworkInsights: SurveyFieldworkInsights(
        surveys: surveys,
        assignments: assignments,
      ),
      responseInsights: SurveyResponseInsights(
        surveys: surveys,
        responses: responses,
      ),
      evidenceSyncInsights: SurveyEvidenceSyncInsights(
        surveys: surveys,
        responses: responses,
      ),
      responseQualityInsights: responseQualityInsights,
      responseReviewInsights: SurveyResponseReviewInsights(
        surveys: surveys,
        responses: responses,
        qualityInsights: responseQualityInsights,
      ),
      responseSyncReadiness: SurveyResponseSyncReadinessInsights.evaluate(
        surveys: surveys,
        responses: responses,
        now: now,
      ),
    );
  }
}
