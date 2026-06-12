import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_focus_state.dart';

void main() {
  group('SurveyResponseFocusState', () {
    test('selectPage clears focus without issuing focus requests', () {
      final focused = const SurveyResponseFocusState().focusEvidence(
        requirementId: 'photo',
        pageIndex: 2,
        questionId: 'display',
      );

      final selected = focused.selectPage(1);

      expect(selected.selectedPageIndex, 1);
      expect(selected.focusedQuestionId, isNull);
      expect(selected.focusedRequirementId, isNull);
      expect(selected.questionFocusRequestId, focused.questionFocusRequestId);
      expect(selected.evidenceFocusRequestId, focused.evidenceFocusRequestId);
    });

    test('focusQuestion selects a page and clears evidence focus', () {
      final focused = const SurveyResponseFocusState()
          .focusEvidence(requirementId: 'photo')
          .focusQuestion(pageIndex: 3, questionId: 'store-name');

      expect(focused.selectedPageIndex, 3);
      expect(focused.focusedQuestionId, 'store-name');
      expect(focused.focusedRequirementId, isNull);
      expect(focused.questionFocusRequestId, 1);
      expect(focused.evidenceFocusRequestId, 1);
    });

    test('focusEvidence can focus both a requirement and a question', () {
      final focused = const SurveyResponseFocusState().focusEvidence(
        requirementId: 'location',
        pageIndex: 4,
        questionId: 'store-location',
      );

      expect(focused.selectedPageIndex, 4);
      expect(focused.focusedQuestionId, 'store-location');
      expect(focused.focusedRequirementId, 'location');
      expect(focused.questionFocusRequestId, 1);
      expect(focused.evidenceFocusRequestId, 1);
    });

    test('focusEvidence can target response-level evidence only', () {
      final focused = const SurveyResponseFocusState(
        selectedPageIndex: 2,
      ).focusEvidence(requirementId: 'interview-audio');

      expect(focused.selectedPageIndex, 2);
      expect(focused.focusedQuestionId, isNull);
      expect(focused.focusedRequirementId, 'interview-audio');
      expect(focused.questionFocusRequestId, 0);
      expect(focused.evidenceFocusRequestId, 1);
    });
  });
}
