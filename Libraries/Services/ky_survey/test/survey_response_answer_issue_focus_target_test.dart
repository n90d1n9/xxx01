import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/logic/survey_response_answer_issue_focus_target.dart';
import 'package:ky_survey/logic/survey_response_focus_state.dart';
import 'package:ky_survey/logic/survey_response_section_flow.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/models/survey_section.dart';
import 'package:ky_survey/validation/survey_response_validator.dart';

void main() {
  group('SurveyResponseAnswerIssueFocusTarget', () {
    test('focuses the first answer issue on its response section', () {
      final fixture = _answerIssueFixture(validAnswers: false);
      final target = SurveyResponseAnswerIssueFocusTarget.resolveFirst(
        sectionFlow: fixture.sectionFlow,
        validation: fixture.validation,
      );
      final focused = target?.applyTo(const SurveyResponseFocusState());

      expect(target, isNotNull);
      expect(target?.questionId, 'visitors');
      expect(target?.pageIndex, 0);
      expect(target?.pageTitle, 'Visit');
      expect(target?.locationSuffix, ' - check Visit');
      expect(focused?.selectedPageIndex, 0);
      expect(focused?.focusedQuestionId, 'visitors');
      expect(focused?.questionFocusRequestId, 1);
      expect(focused?.focusedRequirementId, isNull);
    });

    test('returns null when answers are valid', () {
      final fixture = _answerIssueFixture(validAnswers: true);
      final target = SurveyResponseAnswerIssueFocusTarget.resolveFirst(
        sectionFlow: fixture.sectionFlow,
        validation: fixture.validation,
      );

      expect(target, isNull);
    });

    test('keeps current focus when the issue question is not visible', () {
      final fixture = _answerIssueFixture(validAnswers: true);
      final hiddenIssue = SurveyResponseValidationIssue(
        question: Question(
          id: 'removed-question',
          text: 'Removed question',
          type: QuestionType.singleLineText,
          required: true,
          sectionId: 'missing-section',
        ),
        type: SurveyResponseValidationIssueType.required,
        message: 'Removed question is required',
      );
      final target = SurveyResponseAnswerIssueFocusTarget.forIssue(
        sectionFlow: fixture.sectionFlow,
        issue: hiddenIssue,
      );
      const initial = SurveyResponseFocusState(
        selectedPageIndex: 1,
        focusedQuestionId: 'stock-note',
        questionFocusRequestId: 3,
      );

      final focused = target.applyTo(initial);

      expect(target.pageIndex, isNull);
      expect(target.locationSuffix, isEmpty);
      expect(focused.selectedPageIndex, 1);
      expect(focused.focusedQuestionId, 'stock-note');
      expect(focused.questionFocusRequestId, 3);
    });
  });
}

_AnswerIssueFixture _answerIssueFixture({required bool validAnswers}) {
  final survey = Survey(
    id: 'answer-focus-target-survey',
    title: 'Answer Focus Target Survey',
    description: 'Answer issue focus behavior',
    createdAt: DateTime(2026),
    sections: const [
      SurveySection(id: 'visit', title: 'Visit', order: 0),
      SurveySection(id: 'stock', title: 'Stock', order: 1),
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
  var response = SurveyResponse(
    id: 'answer-focus-target-response',
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

  return _AnswerIssueFixture(
    sectionFlow: SurveyResponseSectionFlow(survey: survey, response: response),
    validation: SurveyResponseValidator.validate(
      questions: survey.questions,
      response: response,
    ),
  );
}

/// Holds flow and validation objects for answer issue focus target tests.
class _AnswerIssueFixture {
  final SurveyResponseSectionFlow sectionFlow;
  final SurveyResponseValidationResult validation;

  const _AnswerIssueFixture({
    required this.sectionFlow,
    required this.validation,
  });
}
