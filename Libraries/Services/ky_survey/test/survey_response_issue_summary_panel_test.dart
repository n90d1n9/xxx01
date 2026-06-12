import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_issue_summary.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:ky_survey/widgets/survey_response_issue_summary_panel.dart';

void main() {
  group('SurveyResponseIssueSummary', () {
    test('groups response issues by section page', () {
      final summary = _issueSummary();

      expect(summary.hasIssues, isTrue);
      expect(summary.issueCount, 2);
      expect(summary.requiredIssueCount, 1);
      expect(summary.invalidIssueCount, 1);
      expect(summary.titleLabel, '2 answers need attention');
      expect(summary.detailLabel, '1 required missing • 1 invalid answer');
      expect(summary.firstIssueLabel, 'Q2: Visitor count must be a number');
      expect(summary.items.map((item) => item.pageIndex), [1, 2]);
      expect(summary.items.map((item) => item.pageLabel), [
        'Metrics',
        'General',
      ]);
      expect(summary.items.map((item) => item.firstQuestionNumber), [2, 3]);
    });
  });

  group('SurveyResponseIssueSummaryPanel', () {
    testWidgets('renders issue shortcuts and forwards section selection', (
      tester,
    ) async {
      var selectedPageIndex = -1;
      SurveyResponseIssueSummaryItem? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SurveyResponseIssueSummaryPanel(
                summary: _issueSummary(),
                selectedPageIndex: 1,
                onIssueSelected: (index) => selectedPageIndex = index,
                onIssueItemSelected: (item) => selectedItem = item,
              ),
            ),
          ),
        ),
      );

      expect(find.text('2 answers need attention'), findsOneWidget);
      expect(
        find.text('1 required missing • 1 invalid answer'),
        findsOneWidget,
      );
      expect(find.text('Q2: Visitor count must be a number'), findsOneWidget);
      expect(find.text('Metrics'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);

      await tester.tap(find.text('General'));
      await tester.pump();

      expect(selectedPageIndex, 2);
      expect(selectedItem?.pageIndex, 2);
      expect(selectedItem?.firstQuestionId, 'note');
    });
  });
}

SurveyResponseIssueSummary _issueSummary() {
  final survey = Survey(
    id: 'issue-summary-survey',
    title: 'Issue Summary Survey',
    description: 'Routes issues to response sections',
    createdAt: DateTime(2026),
    sections: const [
      SurveySection(id: 'identity', title: 'Identity', order: 0),
      SurveySection(id: 'metrics', title: 'Metrics', order: 1),
    ],
    questions: [
      Question(
        id: 'name',
        text: 'Store name',
        type: QuestionType.singleLineText,
        required: true,
        sectionId: 'identity',
      ),
      Question(
        id: 'visitors',
        text: 'Visitor count',
        type: QuestionType.number,
        required: true,
        sectionId: 'metrics',
      ),
      Question(
        id: 'note',
        text: 'General note',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
  );
  final response =
      SurveyResponse(
            id: 'issue-summary-response',
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

  return SurveyResponseIssueSummary.fromPageStatuses(
    flow.pageStatuses(validation),
  );
}
