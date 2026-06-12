import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_choice_answer_selection.dart';

void main() {
  group('SurveyChoiceAnswerSelection', () {
    test('normalizes single choice answers against known options', () {
      final selection = SurveyChoiceAnswerSelection.single(
        optionIds: ['yes', 'no'],
        answer: 'missing',
      );

      expect(selection.selectedId, isNull);
      expect(selection.selectedIds, isEmpty);

      final numericSelection = SurveyChoiceAnswerSelection.single(
        optionIds: ['1', '2'],
        answer: 2,
      );

      expect(numericSelection.selectedId, '2');
    });

    test('deduplicates and orders multiple choice answers by option order', () {
      final selection = SurveyChoiceAnswerSelection.multiple(
        optionIds: ['a', 'b', 'c'],
        answer: <dynamic>['c', 'unknown', 'a', 'a'],
      );

      expect(selection.selectedIds, ['a', 'c']);
      expect(selection.isSelected('b'), isFalse);
      expect(selection.isSelected('c'), isTrue);
    });

    test('toggles multiple choice selections without keeping stale ids', () {
      final selection = SurveyChoiceAnswerSelection.multiple(
        optionIds: ['first', 'second', 'third'],
        answer: <dynamic>['stale', 'third'],
      );

      expect(selection.toggle('second', selected: true), ['second', 'third']);
      expect(selection.toggle('third', selected: false), isEmpty);
      expect(selection.toggle('stale', selected: true), ['third']);
    });
  });
}
