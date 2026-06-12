import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_viewer_snapshot.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';

void main() {
  group('SurveyResponseViewerSnapshot', () {
    test('composes visible pages, response issues, and evidence summary', () {
      final fixture = _snapshotFixture();

      final snapshot = SurveyResponseViewerSnapshot.evaluate(
        survey: fixture.survey,
        response: fixture.response,
        requestedPageIndex: 99,
      );

      expect(snapshot.pageCount, 2);
      expect(snapshot.selectedPageIndex, 1);
      expect(snapshot.selectedPage?.title, 'Stock');
      expect(snapshot.selectedPageStatus?.hasIssues, isTrue);
      expect(snapshot.selectedPageStatus?.requiredIssueCount, 1);
      expect(snapshot.sessionSummary.visibleQuestionCount, 3);
      expect(snapshot.sessionSummary.answeredQuestionCount, 2);
      expect(snapshot.sessionSummary.invalidIssueCount, 1);
      expect(snapshot.issueSummary.issueCount, 2);
      expect(snapshot.evidenceSummary.hasRequirements, isTrue);
      expect(snapshot.evidenceSummary.missingRequiredCount, 1);
      expect(snapshot.sectionFlow.pageIndexForQuestion('visitors'), 0);
    });

    test('keeps empty surveys on a stable empty page selection', () {
      final survey = Survey(
        id: 'empty-viewer-snapshot-survey',
        title: 'Empty Survey',
        description: 'No questions yet',
        questions: const [],
        createdAt: DateTime(2026),
      );
      final response = SurveyResponse(
        id: 'empty-viewer-snapshot-response',
        surveyId: survey.id,
        respondentId: 'participant',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      );

      final snapshot = SurveyResponseViewerSnapshot.evaluate(
        survey: survey,
        response: response,
        requestedPageIndex: 4,
      );

      expect(snapshot.pageCount, 0);
      expect(snapshot.selectedPageIndex, 0);
      expect(snapshot.selectedPage, isNull);
      expect(snapshot.selectedPageStatus, isNull);
      expect(snapshot.issueSummary.hasIssues, isFalse);
      expect(snapshot.sessionSummary.primaryStatusLabel, 'No questions');
    });

    test('clamps negative and overflow page requests', () {
      expect(
        SurveyResponseViewerSnapshot.clampSelectedPageIndex(
          requestedIndex: -2,
          pageCount: 3,
        ),
        0,
      );
      expect(
        SurveyResponseViewerSnapshot.clampSelectedPageIndex(
          requestedIndex: 6,
          pageCount: 3,
        ),
        2,
      );
      expect(
        SurveyResponseViewerSnapshot.clampSelectedPageIndex(
          requestedIndex: 1,
          pageCount: 0,
        ),
        0,
      );
    });
  });
}

_SnapshotFixture _snapshotFixture() {
  final survey = Survey(
    id: 'viewer-snapshot-survey',
    title: 'Viewer Snapshot Survey',
    description: 'Derived response state',
    createdAt: DateTime(2026),
    sections: const [
      SurveySection(id: 'visit', title: 'Visit', order: 0),
      SurveySection(id: 'stock', title: 'Stock', order: 1),
    ],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'gps-check-in',
        kind: SurveyEvidenceKind.location,
        scope: SurveyEvidenceScope.question,
        questionId: 'store-name',
        label: 'GPS check-in',
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
  final response =
      SurveyResponse(
            id: 'viewer-snapshot-response',
            surveyId: survey.id,
            respondentId: 'participant',
            respondentName: 'Participant',
            startedAt: DateTime(2026),
          )
          .upsertAnswer(questionId: 'store-name', value: 'Kaysir Mart')
          .upsertAnswer(questionId: 'visitors', value: 'many');

  return _SnapshotFixture(survey: survey, response: response);
}

/// Stores the survey and response used to verify viewer snapshot composition.
class _SnapshotFixture {
  final Survey survey;
  final SurveyResponse response;

  const _SnapshotFixture({required this.survey, required this.response});
}
