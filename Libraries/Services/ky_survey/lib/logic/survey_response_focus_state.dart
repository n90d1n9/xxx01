/// Coordinates selected section, question focus, and evidence focus requests.
class SurveyResponseFocusState {
  final int selectedPageIndex;
  final String? focusedQuestionId;
  final String? focusedRequirementId;
  final int questionFocusRequestId;
  final int evidenceFocusRequestId;

  const SurveyResponseFocusState({
    this.selectedPageIndex = 0,
    this.focusedQuestionId,
    this.focusedRequirementId,
    this.questionFocusRequestId = 0,
    this.evidenceFocusRequestId = 0,
  });

  SurveyResponseFocusState selectPage(int pageIndex) {
    return SurveyResponseFocusState(
      selectedPageIndex: pageIndex,
      questionFocusRequestId: questionFocusRequestId,
      evidenceFocusRequestId: evidenceFocusRequestId,
    );
  }

  SurveyResponseFocusState focusQuestion({
    required int pageIndex,
    required String? questionId,
  }) {
    return SurveyResponseFocusState(
      selectedPageIndex: pageIndex,
      focusedQuestionId: questionId,
      questionFocusRequestId: questionFocusRequestId + _requestStep(questionId),
      evidenceFocusRequestId: evidenceFocusRequestId,
    );
  }

  SurveyResponseFocusState focusEvidence({
    required String requirementId,
    int? pageIndex,
    String? questionId,
  }) {
    return SurveyResponseFocusState(
      selectedPageIndex: pageIndex ?? selectedPageIndex,
      focusedQuestionId: pageIndex == null ? null : questionId,
      focusedRequirementId: requirementId,
      questionFocusRequestId:
          questionFocusRequestId +
          _requestStep(pageIndex == null ? null : questionId),
      evidenceFocusRequestId: evidenceFocusRequestId + 1,
    );
  }

  int _requestStep(String? targetId) => targetId == null ? 0 : 1;
}
