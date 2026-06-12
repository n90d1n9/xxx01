import 'package:ky_survey/analytics/survey_fieldwork_insights.dart';
import 'package:ky_survey/analytics/survey_response_insights.dart';
import 'package:ky_survey/analytics/survey_response_quality_insights.dart';
import 'package:ky_survey/analytics/survey_response_review_insights.dart';
import 'package:ky_survey/analytics/survey_structure_insights.dart';
import 'package:ky_survey/data/sample.dart';
import 'package:ky_survey/data/sample_assignments.dart';
import 'package:ky_survey/data/sample_responses.dart';
import 'package:test/test.dart';

void main() {
  group('sample response data', () {
    test('keeps survey response counts aligned with submitted samples', () {
      for (final survey in sampleSurveys) {
        expect(survey.responseCount, submittedSampleResponseCount(survey.id));
      }
    });

    test('feeds dashboard response insights immediately', () {
      final insights = SurveyResponseInsights(
        surveys: sampleSurveys,
        responses: sampleResponses,
      );

      expect(insights.submittedResponseCount, greaterThan(0));
      expect(insights.draftResponseCount, greaterThan(0));
      expect(insights.reportReadySurveyCount, sampleSurveys.length);
      expect(insights.notableBreakdowns(), isNotEmpty);
    });

    test('feeds response quality review immediately', () {
      final insights = SurveyResponseQualityInsights(
        surveys: sampleSurveys,
        responses: sampleResponses,
      );

      expect(insights.submittedResponseCount, greaterThan(0));
      expect(insights.flaggedResponseCount(), greaterThan(0));
      expect(insights.reviewQueue(), isNotEmpty);
    });

    test('feeds response review workflow immediately', () {
      final qualityInsights = SurveyResponseQualityInsights(
        surveys: sampleSurveys,
        responses: sampleResponses,
      );
      final reviewInsights = SurveyResponseReviewInsights(
        surveys: sampleSurveys,
        responses: sampleResponses,
        qualityInsights: qualityInsights,
      );

      expect(reviewInsights.reviewableResponses, isNotEmpty);
      expect(reviewInsights.pendingReviewCount, greaterThan(0));
      expect(reviewInsights.reviewQueue(), isNotEmpty);
      expect(reviewInsights.summaries, hasLength(sampleSurveys.length));
    });

    test('feeds structure insights immediately', () {
      final insights = SurveyStructureInsights(sampleSurveys);

      expect(insights.totalSections, greaterThan(0));
      expect(insights.sectionedSurveyCount, sampleSurveys.length);
      expect(insights.unsectionedQuestionCount, 0);
      expect(insights.summariesForSurvey(sampleSurveys.first), isNotEmpty);
    });
  });

  group('sample assignment data', () {
    test('feeds fieldwork operations insights immediately', () {
      final insights = SurveyFieldworkInsights(
        surveys: sampleSurveys,
        assignments: sampleAssignments,
      );

      expect(insights.totalAssignments, greaterThan(0));
      expect(insights.overdueAssignments(), greaterThan(0));
      expect(insights.assignmentsForSurvey('1'), isNotEmpty);
      expect(insights.completionRate, greaterThan(0));
    });
  });
}
