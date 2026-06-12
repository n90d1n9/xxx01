import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_submission_plan.dart';
import 'package:ky_survey/logic/survey_response_viewer_snapshot.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';

void main() {
  group('SurveyResponseSubmissionPlan', () {
    test('blocks submission on the first answer issue', () {
      final plan = _submissionPlan(validAnswers: false);

      expect(plan.canSubmit, isFalse);
      expect(plan.blocker, SurveyResponseSubmissionBlocker.answerIssue);
      expect(plan.pageIndex, 0);
      expect(plan.questionId, 'visitors');
      expect(plan.answerTarget?.locationSuffix, ' - check Visit');
      expect(plan.evidenceStatus, isNull);
      expect(
        plan.feedbackMessage,
        'Visitor count must be a number (2 issues) - check Visit',
      );
    });

    test('blocks submission on question-scoped evidence', () {
      final plan = _submissionPlan(questionScopedEvidence: true);

      expect(plan.canSubmit, isFalse);
      expect(plan.blocker, SurveyResponseSubmissionBlocker.evidenceIssue);
      expect(plan.pageIndex, 0);
      expect(plan.questionId, 'store-name');
      expect(plan.evidenceStatus?.requirement.id, 'gps-check-in');
      expect(plan.evidenceTarget?.locationSuffix, ' - check Visit');
      expect(plan.feedbackMessage, contains('GPS check-in'));
      expect(plan.feedbackMessage, contains('check Visit'));
    });

    test('blocks response-level evidence at the evidence checklist', () {
      final plan = _submissionPlan(responseLevelEvidence: true);

      expect(plan.canSubmit, isFalse);
      expect(plan.blocker, SurveyResponseSubmissionBlocker.evidenceIssue);
      expect(plan.pageIndex, isNull);
      expect(plan.questionId, isNull);
      expect(plan.evidenceStatus?.requirement.id, 'interview-audio');
      expect(
        plan.evidenceTarget?.locationSuffix,
        ' - check evidence checklist',
      );
      expect(plan.feedbackMessage, contains('Interview audio'));
      expect(plan.feedbackMessage, contains('check evidence checklist'));
    });

    test('allows complete answer and evidence state to submit', () {
      final plan = _submissionPlan();

      expect(plan.canSubmit, isTrue);
      expect(plan.blocker, SurveyResponseSubmissionBlocker.none);
      expect(plan.feedbackMessage, isEmpty);
      expect(plan.pageIndex, isNull);
      expect(plan.answerTarget, isNull);
      expect(plan.evidenceStatus, isNull);
      expect(plan.evidenceTarget, isNull);
    });
  });
}

SurveyResponseSubmissionPlan _submissionPlan({
  bool validAnswers = true,
  bool questionScopedEvidence = false,
  bool responseLevelEvidence = false,
}) {
  final survey = _survey(
    questionScopedEvidence: questionScopedEvidence,
    responseLevelEvidence: responseLevelEvidence,
  );
  final response = _responseFor(survey, validAnswers: validAnswers);
  final snapshot = SurveyResponseViewerSnapshot.evaluate(
    survey: survey,
    response: response,
    requestedPageIndex: 0,
  );

  return SurveyResponseSubmissionPlan.evaluate(
    summary: snapshot.sessionSummary,
    evidenceSummary: snapshot.evidenceSummary,
    sectionFlow: snapshot.sectionFlow,
  );
}

Survey _survey({
  required bool questionScopedEvidence,
  required bool responseLevelEvidence,
}) {
  return Survey(
    id: 'submission-plan-survey',
    title: 'Submission Plan Survey',
    description: 'Submit blockers',
    createdAt: DateTime(2026),
    sections: const [
      SurveySection(id: 'visit', title: 'Visit', order: 0),
      SurveySection(id: 'stock', title: 'Stock', order: 1),
    ],
    evidenceRequirements: [
      if (questionScopedEvidence)
        const SurveyEvidenceRequirement(
          id: 'gps-check-in',
          kind: SurveyEvidenceKind.location,
          scope: SurveyEvidenceScope.question,
          questionId: 'store-name',
          label: 'GPS check-in',
        ),
      if (responseLevelEvidence)
        const SurveyEvidenceRequirement(
          id: 'interview-audio',
          kind: SurveyEvidenceKind.audio,
          scope: SurveyEvidenceScope.response,
          label: 'Interview audio',
        ),
    ],
    questions: [
      Question(
        id: 'store-name',
        text: 'Store name',
        type: QuestionType.singleLineText,
        required: true,
        sectionId: 'visit',
      ),
      Question(
        id: 'visitors',
        text: 'Visitor count',
        type: QuestionType.number,
        required: true,
        sectionId: 'visit',
      ),
      Question(
        id: 'stock-note',
        text: 'Stock note',
        type: QuestionType.singleLineText,
        required: true,
        sectionId: 'stock',
      ),
    ],
  );
}

SurveyResponse _responseFor(Survey survey, {required bool validAnswers}) {
  var response = SurveyResponse(
    id: 'submission-plan-response',
    surveyId: survey.id,
    respondentId: 'participant',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  ).upsertAnswer(questionId: 'store-name', value: 'Kaysir Mart');

  if (validAnswers) {
    response = response
        .upsertAnswer(questionId: 'visitors', value: 12)
        .upsertAnswer(questionId: 'stock-note', value: 'Shelf looks full');
  } else {
    response = response.upsertAnswer(questionId: 'visitors', value: 'many');
  }

  return response;
}
