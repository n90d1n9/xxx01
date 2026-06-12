import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_dashboard_insights_bundle.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_assignment.dart';
import 'package:ky_survey/models/survey_response.dart';

void main() {
  test('SurveyDashboardInsightsBundle composes dashboard analytics', () {
    final now = DateTime(2026, 1, 15, 9);
    final survey = Survey(
      id: 'survey-1',
      title: 'Household Survey',
      description: 'Dashboard bundle test',
      questions: const [],
      createdAt: now.subtract(const Duration(days: 7)),
      responseCount: 1,
      targetResponses: 5,
    );
    final response = SurveyResponse(
      id: 'response-1',
      surveyId: survey.id,
      respondentId: 'participant-1',
      respondentName: 'Participant One',
      status: SurveyResponseStatus.submitted,
      startedAt: now.subtract(const Duration(hours: 1)),
      submittedAt: now,
    );
    final assignment = SurveyAssignment(
      id: 'assignment-1',
      surveyId: survey.id,
      assigneeId: 'surveyor-1',
      assigneeName: 'Surveyor One',
      territory: 'North',
      status: SurveyAssignmentStatus.inProgress,
      targetResponses: 5,
      completedResponses: 2,
      dueAt: now.add(const Duration(days: 2)),
      assignedAt: now.subtract(const Duration(days: 1)),
    );

    final bundle = SurveyDashboardInsightsBundle.evaluate(
      surveys: [survey],
      responses: [response],
      assignments: [assignment],
      now: now,
    );

    expect(bundle.insights.totalSurveys, 1);
    expect(bundle.insights.totalResponses, 1);
    expect(bundle.fieldworkInsights.totalAssignments, 1);
    expect(bundle.fieldworkInsights.activeAssignments, 1);
    expect(bundle.responseInsights.submittedResponseCount, 1);
    expect(bundle.responseQualityInsights.submittedResponseCount, 1);
    expect(bundle.responseReviewInsights.pendingReviewCount, 1);
    expect(bundle.responseSyncReadiness.now, now);
    expect(bundle.responseSyncReadiness.submittedCount, 1);
    expect(
      identical(
        bundle.responseReviewInsights.qualityInsights,
        bundle.responseQualityInsights,
      ),
      isTrue,
    );
  });
}
