import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';
import 'package:ky_survey/widgets/survey_response_question_card.dart';
import 'package:ky_survey/widgets/survey_response_question_frame.dart';

void main() {
  group('SurveyResponseQuestionFrame', () {
    testWidgets('renders helper text, issues, and read-only state', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        _frameHarness(
          SurveyResponseQuestionFrame(
            questionNumber: 2,
            title: 'Store visit notes',
            isRequired: false,
            helperText: 'Add fieldwork context when available.',
            enabled: false,
            issueMessages: const ['Store visit notes must be text'],
            child: FilledButton(
              onPressed: () => tapped = true,
              child: const Text('Edit'),
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Store visit notes'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Read-only'), findsOneWidget);
      expect(
        find.text('Add fieldwork context when available.'),
        findsOneWidget,
      );
      expect(find.text('Store visit notes must be text'), findsOneWidget);

      await tester.tap(find.text('Edit'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renders focused state when highlighted', (tester) async {
      await tester.pumpWidget(
        _frameHarness(
          const SurveyResponseQuestionFrame(
            questionNumber: 3,
            title: 'Field note',
            isRequired: true,
            highlighted: true,
            child: Text('Answer field'),
          ),
        ),
      );

      expect(find.text('Field note'), findsOneWidget);
      expect(find.text('Focused'), findsOneWidget);
      expect(find.text('Answer field'), findsOneWidget);
    });
  });

  group('SurveyResponseQuestionCard', () {
    testWidgets('shows validation issues beside the response field', (
      tester,
    ) async {
      String? latestValue;
      final question = Question(
        id: 'visitor_count',
        text: 'Visitor count',
        type: QuestionType.singleLineText,
        required: true,
        answer: 'many',
      );

      await tester.pumpWidget(
        _frameHarness(
          SurveyResponseQuestionCard(
            questionNumber: 1,
            question: question,
            highlighted: true,
            issues: [
              SurveyResponseValidationIssue(
                question: question,
                type: SurveyResponseValidationIssueType.invalidType,
                message: 'Visitor count must be a number',
              ),
            ],
            onAnswerChanged: (value) => latestValue = value as String,
          ),
        ),
      );

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Focused'), findsOneWidget);
      expect(find.text('Visitor count must be a number'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '42');
      await tester.pump();

      expect(latestValue, '42');
    });
  });
}

Widget _frameHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}
