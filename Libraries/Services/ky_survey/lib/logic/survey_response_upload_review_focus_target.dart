import '../analytics/survey_evidence_sync_insights.dart';
import 'survey_response_focus_state.dart';
import 'survey_response_section_flow.dart';

/// Describes where an upload review item should focus in the response viewer.
class SurveyResponseUploadReviewFocusTarget {
  final SurveyEvidenceSyncItem item;
  final String? questionId;
  final int? pageIndex;

  const SurveyResponseUploadReviewFocusTarget({
    required this.item,
    required this.questionId,
    required this.pageIndex,
  });

  factory SurveyResponseUploadReviewFocusTarget.resolve({
    required SurveyResponseSectionFlow sectionFlow,
    required SurveyEvidenceSyncItem item,
  }) {
    final questionId = item.evidence.questionId ?? item.requirement?.questionId;
    return SurveyResponseUploadReviewFocusTarget(
      item: item,
      questionId: questionId,
      pageIndex: questionId == null
          ? null
          : sectionFlow.pageIndexForQuestion(questionId),
    );
  }

  bool get canFocus => questionId != null && pageIndex != null;

  String get fallbackMessage => item.detail;

  SurveyResponseFocusState applyTo(SurveyResponseFocusState focusState) {
    final pageIndex = this.pageIndex;
    final questionId = this.questionId;
    if (pageIndex == null || questionId == null) {
      return focusState;
    }

    final requirement = item.requirement;
    if (requirement == null) {
      return focusState.focusQuestion(
        pageIndex: pageIndex,
        questionId: questionId,
      );
    }

    return focusState.focusEvidence(
      requirementId: requirement.id,
      pageIndex: pageIndex,
      questionId: questionId,
    );
  }
}
