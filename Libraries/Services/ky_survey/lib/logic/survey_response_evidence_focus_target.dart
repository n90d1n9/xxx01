import 'survey_response_evidence_summary.dart';
import 'survey_response_focus_state.dart';
import 'survey_response_section_flow.dart';

/// Describes where evidence-related response work should focus in the viewer.
class SurveyResponseEvidenceFocusTarget {
  final SurveyEvidenceRequirementStatus status;
  final int? pageIndex;
  final String? questionId;
  final String? pageTitle;

  const SurveyResponseEvidenceFocusTarget({
    required this.status,
    required this.pageIndex,
    required this.questionId,
    required this.pageTitle,
  });

  factory SurveyResponseEvidenceFocusTarget.resolve({
    required SurveyResponseSectionFlow sectionFlow,
    required SurveyEvidenceRequirementStatus status,
  }) {
    final questionId = status.requirement.questionId;
    final pageIndex = _validPageIndex(
      sectionFlow: sectionFlow,
      pageIndex: questionId == null
          ? null
          : sectionFlow.pageIndexForQuestion(questionId),
    );

    return SurveyResponseEvidenceFocusTarget(
      status: status,
      pageIndex: pageIndex,
      questionId: questionId,
      pageTitle: pageIndex == null ? null : sectionFlow.pages[pageIndex].title,
    );
  }

  String get locationSuffix {
    final title = pageTitle;
    return title == null ? ' - check evidence checklist' : ' - check $title';
  }

  SurveyResponseFocusState applyTo(SurveyResponseFocusState focusState) {
    return focusState.focusEvidence(
      requirementId: status.requirement.id,
      pageIndex: pageIndex,
      questionId: questionId,
    );
  }

  static int? _validPageIndex({
    required SurveyResponseSectionFlow sectionFlow,
    required int? pageIndex,
  }) {
    if (pageIndex == null) {
      return null;
    }

    final pages = sectionFlow.pages;
    if (pageIndex < 0 || pageIndex >= pages.length) {
      return null;
    }

    return pageIndex;
  }
}
