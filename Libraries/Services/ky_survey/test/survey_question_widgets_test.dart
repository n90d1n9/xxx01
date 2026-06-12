import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_date_answer_formatter.dart';
import 'package:ky_survey/models/option.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/widgets/date_question.dart';
import 'package:ky_survey/widgets/multiple_question.dart';
import 'package:ky_survey/widgets/number_question.dart';
import 'package:ky_survey/widgets/single_choice.dart';
import 'package:ky_survey/widgets/survey_number_input_formatter.dart';

void main() {
  group('Survey question widgets', () {
    testWidgets('single choice forwards selected option from RadioGroup', (
      tester,
    ) async {
      String? selectedOptionId;

      await tester.pumpWidget(
        _questionHarness(
          SingleChoiceQuestion(
            question: _choiceQuestion(answer: 'yes'),
            onChanged: (value) => selectedOptionId = value,
          ),
        ),
      );

      await tester.tap(find.text('No'));
      await tester.pump();

      expect(selectedOptionId, 'no');
    });

    testWidgets('multiple choice forwards toggled selections', (tester) async {
      List<String>? selectedOptionIds;

      await tester.pumpWidget(
        _questionHarness(
          MultipleChoiceQuestion(
            question: _choiceQuestion(answer: ['yes']),
            onChanged: (value) => selectedOptionIds = value,
          ),
        ),
      );

      await tester.tap(find.text('No'));
      await tester.pump();

      expect(selectedOptionIds, ['yes', 'no']);
    });

    testWidgets('multiple choice normalizes decoded selections before toggle', (
      tester,
    ) async {
      List<String>? selectedOptionIds;

      await tester.pumpWidget(
        _questionHarness(
          MultipleChoiceQuestion(
            question: _choiceQuestion(answer: <dynamic>['yes', 'ghost', 'yes']),
            onChanged: (value) => selectedOptionIds = value,
          ),
        ),
      );

      await tester.tap(find.text('No'));
      await tester.pump();

      expect(selectedOptionIds, ['yes', 'no']);
    });

    testWidgets('number question renders numeric answers and signed decimals', (
      tester,
    ) async {
      String? latestValue;

      await tester.pumpWidget(
        _questionHarness(
          NumberQuestion(
            question: _numberQuestion(answer: -3.5),
            onChanged: (value) => latestValue = value,
          ),
        ),
      );

      expect(_editableText(tester).controller.text, '-3.5');

      await tester.enterText(find.byType(TextField), '-12.75');
      await tester.pump();

      expect(latestValue, '-12.75');
      expect(_editableText(tester).controller.text, '-12.75');
    });

    test('number input formatter allows editable signed decimal states', () {
      const formatter = SurveyNumberInputFormatter();

      expect(_formatNumber(formatter, '', '-'), '-');
      expect(_formatNumber(formatter, '-', '-.'), '-.');
      expect(_formatNumber(formatter, '-.', '-.5'), '-.5');
      expect(_formatNumber(formatter, '-.5', '-12.75'), '-12.75');
      expect(_formatNumber(formatter, '-12.75', '-12.7.5'), '-12.75');
      expect(_formatNumber(formatter, '-12.75', 'abc'), '-12.75');
    });

    testWidgets('date question displays answers and forwards picker results', (
      tester,
    ) async {
      String? selectedDate;

      await tester.pumpWidget(
        _questionHarness(
          DateQuestion(
            question: _dateQuestion(answer: '2026-06-11T14:30:00Z'),
            fallbackDate: DateTime(2026, 1, 1),
            datePicker:
                ({
                  required BuildContext context,
                  required DateTime initialDate,
                  required DateTime firstDate,
                  required DateTime lastDate,
                }) async {
                  expect(initialDate, DateTime(2026, 6, 11));
                  expect(firstDate, DateTime(1900));
                  expect(lastDate, DateTime(2100));
                  return DateTime(2026, 7, 4, 16);
                },
            onChanged: (value) => selectedDate = value,
          ),
        ),
      );

      expect(find.text('2026-06-11'), findsOneWidget);

      await tester.tap(find.text('2026-06-11'));
      await tester.pump();

      expect(selectedDate, '2026-07-04');
    });

    test(
      'date answer formatter normalizes answers and clamps picker dates',
      () {
        const formatter = SurveyDateAnswerFormatter();

        expect(formatter.formatAnswer(DateTime(2026, 1, 2, 13)), '2026-01-02');
        expect(formatter.formatAnswer('not-a-date'), '');
        expect(
          formatter.resolveInitialDate(
            answer: '1800-01-01',
            fallbackDate: DateTime(2026),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          ),
          DateTime(1900),
        );
        expect(
          formatter.resolveInitialDate(
            answer: null,
            fallbackDate: DateTime(2200),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          ),
          DateTime(2100),
        );
      },
    );
  });
}

Widget _questionHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

Question _choiceQuestion({required dynamic answer}) {
  return Question(
    id: 'consent',
    text: 'Do you agree?',
    type: QuestionType.singleChoice,
    required: true,
    answer: answer,
    options: [
      Option(id: 'yes', text: 'Yes'),
      Option(id: 'no', text: 'No'),
    ],
  );
}

Question _numberQuestion({required dynamic answer}) {
  return Question(
    id: 'income',
    text: 'Monthly income',
    type: QuestionType.number,
    required: true,
    answer: answer,
  );
}

Question _dateQuestion({required dynamic answer}) {
  return Question(
    id: 'visit_date',
    text: 'Visit date',
    type: QuestionType.date,
    required: true,
    answer: answer,
  );
}

EditableText _editableText(WidgetTester tester) {
  return tester.widget<EditableText>(find.byType(EditableText));
}

String _formatNumber(
  SurveyNumberInputFormatter formatter,
  String oldText,
  String newText,
) {
  return formatter
      .formatEditUpdate(
        TextEditingValue(text: oldText),
        TextEditingValue(text: newText),
      )
      .text;
}
