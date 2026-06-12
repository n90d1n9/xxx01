import 'package:ky_survey/logic/survey_versioning.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/question_visibility_rule.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_response_review.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/models/survey_status.dart';
import 'package:ky_survey/models/survey_version.dart';
import 'package:test/test.dart';

void main() {
  group('Survey model', () {
    test('keeps older JSON payloads compatible', () {
      final survey = Survey.fromJson({
        'id': 'survey-1',
        'title': 'Legacy Survey',
        'description': 'Imported from an older payload',
        'questions': [],
        'createdAt': DateTime(2026).toIso8601String(),
      });

      expect(survey.status, SurveyStatus.draft);
      expect(survey.responseCount, 0);
      expect(survey.targetResponses, 0);
      expect(survey.ownerName, 'Admin');
      expect(survey.assigneeNames, isEmpty);
      expect(survey.sections, isEmpty);
      expect(survey.questions, isEmpty);
      expect(survey.evidenceRequirements, isEmpty);
      expect(survey.currentVersion, 0);
      expect(survey.activeVersionId, isNull);
      expect(survey.versions, isEmpty);
    });

    test('serializes lifecycle metadata', () {
      final survey = Survey(
        id: 'survey-2',
        title: 'Market Visit',
        description: 'Outlet visit checklist',
        questions: const [],
        createdAt: DateTime(2026),
        status: SurveyStatus.collecting,
        responseCount: 14,
        targetResponses: 20,
        ownerName: 'Ops',
        assigneeNames: const ['Ari', 'Nadia'],
      );

      final json = survey.toJson();

      expect(json['status'], 'collecting');
      expect(json['responseCount'], 14);
      expect(json['targetResponses'], 20);
      expect(json['ownerName'], 'Ops');
      expect(json['assigneeNames'], ['Ari', 'Nadia']);
    });

    test('serializes conditional visibility rules on questions', () {
      final question = Question(
        id: 'follow-up',
        text: 'What went wrong?',
        type: QuestionType.multiLineText,
        required: true,
        visibilityRules: const [
          QuestionVisibilityRule(
            sourceQuestionId: 'rating',
            operator: QuestionVisibilityOperator.lessThanOrEqual,
            value: 3,
          ),
        ],
      );

      final restored = Question.fromJson(question.toJson());

      expect(restored.visibilityRules, hasLength(1));
      expect(
        restored.visibilityRules.single.operator,
        QuestionVisibilityOperator.lessThanOrEqual,
      );
      expect(restored.visibilityRules.single.value, 3);
    });

    test('serializes section metadata and question assignments', () {
      final survey = Survey(
        id: 'sectioned',
        title: 'Sectioned Survey',
        description: 'Grouped questions',
        createdAt: DateTime(2026),
        sections: const [
          SurveySection(id: 'intro', title: 'Intro', order: 1),
          SurveySection(id: 'profile', title: 'Profile', order: 0),
        ],
        questions: [
          Question(
            id: 'q1',
            text: 'Name',
            type: QuestionType.singleLineText,
            required: true,
            sectionId: 'profile',
          ),
        ],
      );

      final restored = Survey.fromJson(survey.toJson());

      expect(restored.sections, hasLength(2));
      expect(restored.orderedSections.first.id, 'profile');
      expect(restored.questions.single.sectionId, 'profile');
      expect(restored.questionsForSection('profile').single.id, 'q1');
    });

    test('serializes version metadata and active snapshots', () {
      final version = SurveyVersion(
        id: 'survey-3-v1',
        surveyId: 'survey-3',
        versionNumber: 1,
        title: 'Published Title',
        description: 'Published description',
        sections: const [SurveySection(id: 's1', title: 'Intro')],
        questions: [
          Question(
            id: 'q1',
            text: 'Name',
            type: QuestionType.singleLineText,
            required: true,
          ),
        ],
        createdAt: DateTime(2026, 1, 1),
        publishedAt: DateTime(2026, 1, 2),
      );
      final survey = Survey(
        id: 'survey-3',
        title: 'Editable Title',
        description: 'Editable description',
        questions: const [],
        createdAt: DateTime(2026),
        currentVersion: 1,
        activeVersionId: version.id,
        versions: [version],
      );

      final restored = Survey.fromJson(survey.toJson());

      expect(restored.currentVersion, 1);
      expect(restored.activeVersionId, 'survey-3-v1');
      expect(restored.activeVersion?.title, 'Published Title');
      expect(restored.versions.single.questions.single.id, 'q1');
    });
  });

  group('SurveyVersioning', () {
    test('publishes immutable snapshots and resolves response structure', () {
      final survey = Survey(
        id: 'versioned',
        title: 'Original Survey',
        description: 'Original copy',
        createdAt: DateTime(2026),
        sections: const [SurveySection(id: 's1', title: 'Original Section')],
        questions: [
          Question(
            id: 'q1',
            text: 'Original question',
            type: QuestionType.singleLineText,
            required: true,
            sectionId: 's1',
          ),
        ],
      );

      final published = SurveyVersioning.publishSnapshot(
        survey: survey,
        publishedAt: DateTime(2026, 1, 1, 10),
      );
      final edited = published.copyWith(
        title: 'Edited Survey',
        questions: [
          published.questions.single.copyWith(text: 'Edited question'),
        ],
      );
      final response = SurveyResponse(
        id: 'r1',
        surveyId: edited.id,
        surveyVersionId: published.activeVersionId,
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      );

      final resolved = SurveyVersioning.surveyForResponse(
        survey: edited,
        response: response,
      );

      expect(published.currentVersion, 1);
      expect(published.activeVersionId, 'versioned-v1');
      expect(published.versions.single.publishedAt, DateTime(2026, 1, 1, 10));
      expect(edited.questions.single.text, 'Edited question');
      expect(resolved.title, 'Original Survey');
      expect(resolved.questions.single.text, 'Original question');
      expect(SurveyVersioning.nextVersionNumber(published), 2);
    });
  });

  group('SurveyResponse', () {
    test('tracks answers without mutating question definitions', () {
      final question = Question(
        id: 'q1',
        text: 'Store name',
        type: QuestionType.singleLineText,
        required: true,
      );
      final response =
          SurveyResponse(
            id: 'r1',
            surveyId: 's1',
            respondentId: 'u1',
            respondentName: 'Participant',
            startedAt: DateTime(2026),
          ).upsertAnswer(
            questionId: question.id,
            value: 'Kaysir Mart',
            answeredAt: DateTime(2026, 1, 1, 10),
          );

      expect(question.answer, isNull);
      expect(response.valueFor(question.id), 'Kaysir Mart');
      expect(response.unansweredRequiredQuestions([question]), isEmpty);
      expect(response.completionRate([question]), 1);
    });

    test('serializes submitted response sessions', () {
      final submitted =
          SurveyResponse(
                id: 'r2',
                surveyId: 's1',
                surveyVersionId: 's1-v1',
                respondentId: 'u2',
                respondentName: 'Analyst Sample',
                startedAt: DateTime(2026),
              )
              .upsertAnswer(
                questionId: 'q1',
                value: ['a', 'b'],
                answeredAt: DateTime(2026, 1, 1, 10),
              )
              .submit(
                submittedAt: DateTime(2026, 1, 1, 11),
                surveyVersionId: 's1-v2',
              );

      final restored = SurveyResponse.fromJson(submitted.toJson());

      expect(restored.status, SurveyResponseStatus.submitted);
      expect(restored.surveyVersionId, 's1-v2');
      expect(restored.submittedAt, DateTime(2026, 1, 1, 11));
      expect(restored.valueFor('q1'), ['a', 'b']);
    });

    test('serializes response review metadata', () {
      final reviewed =
          SurveyResponse(
                id: 'r3',
                surveyId: 's1',
                respondentId: 'u3',
                respondentName: 'Review Sample',
                startedAt: DateTime(2026),
              )
              .submit(submittedAt: DateTime(2026, 1, 1, 10))
              .review(
                status: SurveyResponseReviewStatus.rejected,
                reviewerId: 'lead-1',
                reviewerName: 'Lead Reviewer',
                note: 'Duplicate respondent',
                reviewedAt: DateTime(2026, 1, 1, 12),
              );

      final restored = SurveyResponse.fromJson(reviewed.toJson());

      expect(restored.reviewStatus, SurveyResponseReviewStatus.rejected);
      expect(restored.reviewerId, 'lead-1');
      expect(restored.reviewerName, 'Lead Reviewer');
      expect(restored.reviewNote, 'Duplicate respondent');
      expect(restored.reviewedAt, DateTime(2026, 1, 1, 12));
    });
  });
}
