import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_evidence_summary.dart';
import 'package:ky_survey/logic/survey_response_issue_summary.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/logic/survey_response_view_intent.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:ky_survey/widgets/survey_response_viewer_body.dart';

void main() {
  group('SurveyResponseViewerBody', () {
    testWidgets('renders composed response modules and forwards actions', (
      tester,
    ) async {
      final fixture = _viewerBodyFixture();
      var intentActionCount = 0;
      String? selectedRequirementId;
      int? selectedIssuePage;
      String? selectedIssueQuestionId;
      String? changedQuestionId;
      dynamic changedValue;

      await tester.pumpWidget(
        _bodyHarness(
          SurveyResponseViewerBody(
            intent: const SurveyResponseViewerIntent(
              focus: SurveyResponseViewerFocus.answerIssue,
              title: 'Resume answers',
              detail: 'Two answers need attention',
            ),
            onIntentAction: () => intentActionCount += 1,
            evidenceSummary: fixture.evidenceSummary,
            issueSummary: fixture.issueSummary,
            selectedPageIndex: 0,
            selectedPage: fixture.status.page,
            selectedPageStatus: fixture.status,
            focusedRequirementId: 'gps-check-in',
            onRequirementStatusSelected: (status) {
              selectedRequirementId = status.requirement.id;
            },
            onIssueSelected: (pageIndex) {
              selectedIssuePage = pageIndex;
            },
            onIssueItemSelected: (item) {
              selectedIssueQuestionId = item.firstQuestionId;
            },
            valueForQuestion: fixture.response.valueFor,
            issuesForQuestion: fixture.validation.issuesForQuestion,
            onAnswerChanged: (question, value) {
              changedQuestionId = question.id;
              changedValue = value;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resume answers'), findsOneWidget);
      expect(find.text('Review issue'), findsOneWidget);
      expect(find.text('Evidence checklist'), findsOneWidget);
      expect(find.text('GPS check-in'), findsOneWidget);
      expect(find.text('2 answers need attention'), findsWidgets);

      await tester.tap(find.text('Review issue'));
      await tester.pump();
      expect(intentActionCount, 1);

      await tester.tap(find.text('GPS check-in'));
      await tester.pump();
      expect(selectedRequirementId, 'gps-check-in');

      await tester.ensureVisible(find.text('Visit (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visit (2)'));
      await tester.pump();
      expect(selectedIssuePage, 0);
      expect(selectedIssueQuestionId, 'visitors');

      await tester.scrollUntilVisible(
        find.text('Visit'),
        700,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Visit'), findsOneWidget);
      expect(find.text('Q2 Invalid'), findsOneWidget);
      expect(find.text('Q3 Missing'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Updated store');
      await tester.pump();
      expect(changedQuestionId, 'name');
      expect(changedValue, 'Updated store');
    });

    testWidgets('renders the empty question state', (tester) async {
      final survey = Survey(
        id: 'empty-response-body-survey',
        title: 'Empty Survey',
        description: 'No questions yet',
        createdAt: DateTime(2026),
        questions: const [],
      );
      final response = SurveyResponse(
        id: 'empty-response',
        surveyId: survey.id,
        respondentId: 'participant',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      );

      await tester.pumpWidget(
        _bodyHarness(
          SurveyResponseViewerBody(
            evidenceSummary: SurveyResponseEvidenceSummary.evaluate(
              survey: survey,
              response: response,
            ),
            issueSummary: const SurveyResponseIssueSummary(items: []),
            selectedPageIndex: 0,
            selectedPage: null,
            selectedPageStatus: null,
            onRequirementStatusSelected: (_) {},
            onIssueSelected: (_) {},
            onIssueItemSelected: (_) {},
            valueForQuestion: response.valueFor,
            issuesForQuestion: (_) => const [],
            onAnswerChanged: (_, _) {},
          ),
        ),
      );

      expect(find.text('No questions in this survey.'), findsOneWidget);
      expect(find.text('Evidence checklist'), findsNothing);
    });
  });
}

Widget _bodyHarness(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

_ViewerBodyFixture _viewerBodyFixture() {
  final survey = Survey(
    id: 'viewer-body-survey',
    title: 'Viewer Body Survey',
    description: 'Composable response body',
    createdAt: DateTime(2026),
    sections: const [SurveySection(id: 'visit', title: 'Visit', order: 0)],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'gps-check-in',
        kind: SurveyEvidenceKind.location,
        scope: SurveyEvidenceScope.question,
        questionId: 'name',
        label: 'GPS check-in',
      ),
    ],
    questions: [
      Question(
        id: 'name',
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
        id: 'note',
        text: 'Field note',
        type: QuestionType.singleLineText,
        required: true,
        sectionId: 'visit',
      ),
    ],
  );
  final response =
      SurveyResponse(
            id: 'viewer-body-response',
            surveyId: survey.id,
            respondentId: 'participant',
            respondentName: 'Participant',
            startedAt: DateTime(2026),
          )
          .upsertAnswer(questionId: 'name', value: 'Kaysir Mart')
          .upsertAnswer(questionId: 'visitors', value: 'many');
  final flow = SurveyResponseSectionFlow(survey: survey, response: response);
  final validation = SurveyResponseValidator.validate(
    questions: survey.questions,
    response: response,
  );
  final statuses = flow.pageStatuses(validation);

  return _ViewerBodyFixture(
    response: response,
    validation: validation,
    evidenceSummary: SurveyResponseEvidenceSummary.evaluate(
      survey: survey,
      response: response,
    ),
    issueSummary: SurveyResponseIssueSummary.fromPageStatuses(statuses),
    status: statuses.single,
  );
}

/// Holds production summary objects for response viewer body tests.
class _ViewerBodyFixture {
  final SurveyResponse response;
  final SurveyResponseValidationResult validation;
  final SurveyResponseEvidenceSummary evidenceSummary;
  final SurveyResponseIssueSummary issueSummary;
  final SurveyResponseSectionPageStatus status;

  const _ViewerBodyFixture({
    required this.response,
    required this.validation,
    required this.evidenceSummary,
    required this.issueSummary,
    required this.status,
  });
}
