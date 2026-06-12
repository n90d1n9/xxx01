import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/widgets/multiline_question.dart';
import 'package:ky_survey/widgets/survey_text_answer_field.dart';
import 'package:ky_survey/widgets/text_question.dart';

void main() {
  group('SurveyTextAnswerField', () {
    testWidgets('syncs host answer updates and forwards edits', (tester) async {
      String? latestValue;

      await tester.pumpWidget(
        _textHarness(
          SurveyTextAnswerField(
            answer: 'Original',
            hintText: 'Write response',
            maxLength: 80,
            onChanged: (value) => latestValue = value,
          ),
        ),
      );

      expect(_editableText(tester).controller.text, 'Original');

      await tester.enterText(find.byType(TextField), 'Typed response');
      await tester.pump();

      expect(latestValue, 'Typed response');

      await tester.pumpWidget(
        _textHarness(
          SurveyTextAnswerField(
            answer: 'Synced response',
            hintText: 'Write response',
            maxLength: 80,
            onChanged: (value) => latestValue = value,
          ),
        ),
      );

      expect(_editableText(tester).controller.text, 'Synced response');
    });

    testWidgets('single-line question maps survey metadata into the field', (
      tester,
    ) async {
      String? latestValue;

      await tester.pumpWidget(
        _textHarness(
          TextQuestion(
            question: _textQuestion(
              type: QuestionType.singleLineText,
              answer: 'Rina',
              hint: 'Participant name',
              maxLength: 40,
            ),
            onChanged: (value) => latestValue = value,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(_editableText(tester).controller.text, 'Rina');
      expect(textField.maxLength, 40);
      expect(textField.maxLines, 1);
      expect(textField.textInputAction, TextInputAction.next);

      await tester.enterText(find.byType(TextField), 'Siti');
      await tester.pump();

      expect(latestValue, 'Siti');
    });

    testWidgets('multiline question keeps a larger writing surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        _textHarness(
          MultilineTextQuestion(
            question: _textQuestion(
              type: QuestionType.multiLineText,
              answer: 'Detailed notes',
              hint: 'Interview notes',
              maxLength: 280,
            ),
            onChanged: (_) {},
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(_editableText(tester).controller.text, 'Detailed notes');
      expect(textField.minLines, 5);
      expect(textField.maxLines, 5);
      expect(textField.maxLength, 280);
      expect(textField.keyboardType, TextInputType.multiline);
      expect(textField.textInputAction, TextInputAction.newline);
    });
  });
}

Widget _textHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

Question _textQuestion({
  required QuestionType type,
  required dynamic answer,
  required String hint,
  required int maxLength,
}) {
  return Question(
    id: 'text_question',
    text: 'Text question',
    type: type,
    required: true,
    answer: answer,
    hint: hint,
    maxLength: maxLength,
  );
}

EditableText _editableText(WidgetTester tester) {
  return tester.widget<EditableText>(find.byType(EditableText));
}
