import '../validation/survey_response_validator.dart';
import 'survey_response_focus_state.dart';
import 'survey_response_section_flow.dart';

/// Describes where answer-related response work should focus in the viewer.
class SurveyResponseAnswerIssueFocusTarget {
  final SurveyResponseValidationIssue issue;
  final int? pageIndex;
  final String? pageTitle;

  const SurveyResponseAnswerIssueFocusTarget({
    required this.issue,
    required this.pageIndex,
    required this.pageTitle,
  });

  factory SurveyResponseAnswerIssueFocusTarget.forIssue({
    required SurveyResponseSectionFlow sectionFlow,
    required SurveyResponseValidationIssue issue,
  }) {
    final pageIndex = sectionFlow.pageIndexForQuestion(issue.question.id);
    return SurveyResponseAnswerIssueFocusTarget(
      issue: issue,
      pageIndex: pageIndex,
      pageTitle: pageIndex == null ? null : sectionFlow.pages[pageIndex].title,
    );
  }

  static SurveyResponseAnswerIssueFocusTarget? resolveFirst({
    required SurveyResponseSectionFlow sectionFlow,
    required SurveyResponseValidationResult validation,
  }) {
    final issue = validation.firstIssue;
    if (issue == null) {
      return null;
    }

    return SurveyResponseAnswerIssueFocusTarget.forIssue(
      sectionFlow: sectionFlow,
      issue: issue,
    );
  }

  String get questionId => issue.question.id;

  String get locationSuffix {
    final title = pageTitle;
    return title == null ? '' : ' - check $title';
  }

  SurveyResponseFocusState applyTo(SurveyResponseFocusState focusState) {
    final pageIndex = this.pageIndex;
    if (pageIndex == null) {
      return focusState;
    }

    return focusState.focusQuestion(
      pageIndex: pageIndex,
      questionId: questionId,
    );
  }
}
