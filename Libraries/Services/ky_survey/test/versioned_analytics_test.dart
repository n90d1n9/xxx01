import 'package:ky_survey/analytics/survey_response_insights.dart';
import 'package:ky_survey/analytics/survey_response_quality_insights.dart';
import 'package:ky_survey/logic/survey_versioning.dart';
import 'package:ky_survey/models/option.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('Versioned response analytics', () {
    test('uses published snapshots for edited survey response reports', () {
      final originalSurvey = Survey(
        id: 'versioned-report',
        title: 'Versioned Report',
        description: 'Published analytics',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Original availability',
            type: QuestionType.singleChoice,
            required: true,
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Original follow up',
            type: QuestionType.multiLineText,
            required: true,
          ),
        ],
      );
      final published = SurveyVersioning.publishSnapshot(
        survey: originalSurvey,
        publishedAt: DateTime(2026, 1, 1),
      );
      final editedSurvey = published.copyWith(
        questions: [
          Question(
            id: 'q3',
            text: 'New required question',
            type: QuestionType.singleLineText,
            required: true,
          ),
        ],
      );
      final response =
          SurveyResponse(
                id: 'r1',
                surveyId: editedSurvey.id,
                surveyVersionId: published.activeVersionId,
                respondentId: 'u1',
                respondentName: 'Published Participant',
                startedAt: DateTime(2026),
              )
              .upsertAnswer(questionId: 'q1', value: 'yes')
              .submit(surveyVersionId: published.activeVersionId);

      final insights = SurveyResponseInsights(
        surveys: [editedSurvey],
        responses: [response],
      );
      final summary = insights.summaryForSurvey(editedSurvey);
      final breakdowns = insights.questionBreakdowns(editedSurvey);
      final answeredBreakdown = breakdowns.firstWhere(
        (breakdown) => breakdown.question.id == 'q1',
      );
      final missingBreakdown = breakdowns.firstWhere(
        (breakdown) => breakdown.question.id == 'q2',
      );

      expect(summary.averageCompletion, 0.5);
      expect(answeredBreakdown.question.text, 'Original availability');
      expect(answeredBreakdown.optionCounts, {'Yes': 1});
      expect(missingBreakdown.question.text, 'Original follow up');
      expect(missingBreakdown.missingRequiredCount, 1);
      expect(
        insights.notableBreakdowns().map((breakdown) => breakdown.question.id),
        containsAll(['q1', 'q2']),
      );
    });

    test('validates versioned responses against published snapshots', () {
      final originalSurvey = Survey(
        id: 'versioned-quality',
        title: 'Quality Snapshot',
        description: 'Published structure',
        createdAt: DateTime(2026),
        questions: [
          Question(
            id: 'q1',
            text: 'Original choice',
            type: QuestionType.singleChoice,
            required: true,
            options: [
              Option(id: 'yes', text: 'Yes'),
              Option(id: 'no', text: 'No'),
            ],
          ),
        ],
      );
      final published = SurveyVersioning.publishSnapshot(
        survey: originalSurvey,
        publishedAt: DateTime(2026, 1, 1),
      );
      final editedSurvey = published.copyWith(
        questions: [
          Question(
            id: 'q1',
            text: 'Edited choice',
            type: QuestionType.singleChoice,
            required: true,
            options: [Option(id: 'maybe', text: 'Maybe')],
          ),
        ],
      );
      final response =
          SurveyResponse(
                id: 'snapshot-response',
                surveyId: editedSurvey.id,
                surveyVersionId: published.activeVersionId,
                respondentId: 'u1',
                respondentName: 'Snapshot Participant',
                startedAt: DateTime(2026, 1, 1, 10),
              )
              .upsertAnswer(questionId: 'q1', value: 'yes')
              .submit(
                submittedAt: DateTime(2026, 1, 1, 10, 2),
                surveyVersionId: published.activeVersionId,
              );

      final insights = SurveyResponseQualityInsights(
        surveys: [editedSurvey],
        responses: [response],
      );
      final resolvedSurvey = insights.surveyForResponse(response);

      expect(insights.signals(), isEmpty);
      expect(resolvedSurvey?.questions.single.text, 'Original choice');
      expect(resolvedSurvey?.questions.single.options?.first.id, 'yes');
    });
  });
}
