import 'survey_response_answer_issue_focus_target.dart';
import 'survey_response_evidence_summary.dart';
import 'survey_response_evidence_focus_target.dart';
import 'survey_response_section_flow.dart';
import 'survey_response_session_summary.dart';

/// Identifies the submit outcome for a response viewer.
enum SurveyResponseSubmissionBlocker { none, answerIssue, evidenceIssue }

/// Describes whether a response can submit and where blocked work should focus.
class SurveyResponseSubmissionPlan {
  final SurveyResponseSubmissionBlocker blocker;
  final String feedbackMessage;
  final int? pageIndex;
  final String? questionId;
  final SurveyResponseAnswerIssueFocusTarget? answerTarget;
  final SurveyEvidenceRequirementStatus? evidenceStatus;
  final SurveyResponseEvidenceFocusTarget? evidenceTarget;

  const SurveyResponseSubmissionPlan({
    required this.blocker,
    required this.feedbackMessage,
    this.pageIndex,
    this.questionId,
    this.answerTarget,
    this.evidenceStatus,
    this.evidenceTarget,
  });

  factory SurveyResponseSubmissionPlan.evaluate({
    required SurveyResponseSessionSummary summary,
    required SurveyResponseEvidenceSummary evidenceSummary,
    required SurveyResponseSectionFlow sectionFlow,
  }) {
    final validation = summary.validation;
    if (!validation.isValid) {
      final firstIssue = validation.firstIssue!;
      final answerTarget = SurveyResponseAnswerIssueFocusTarget.resolveFirst(
        sectionFlow: sectionFlow,
        validation: validation,
      );
      return SurveyResponseSubmissionPlan(
        blocker: SurveyResponseSubmissionBlocker.answerIssue,
        feedbackMessage:
            '${firstIssue.message}${_issueCountSuffix(validation.issues.length)}'
            '${answerTarget?.locationSuffix ?? ''}',
        pageIndex: answerTarget?.pageIndex,
        questionId: firstIssue.question.id,
        answerTarget: answerTarget,
      );
    }

    if (!evidenceSummary.isComplete) {
      final status = evidenceSummary.firstIncompleteRequirement;
      final evidenceTarget = status == null
          ? null
          : SurveyResponseEvidenceFocusTarget.resolve(
              sectionFlow: sectionFlow,
              status: status,
            );
      final issueMessage =
          evidenceSummary.firstIssueMessage ??
          'Required evidence is incomplete';

      return SurveyResponseSubmissionPlan(
        blocker: SurveyResponseSubmissionBlocker.evidenceIssue,
        feedbackMessage:
            '$issueMessage${_issueCountSuffix(evidenceSummary.issueCount)}'
            '${evidenceTarget?.locationSuffix ?? ''}',
        pageIndex: evidenceTarget?.pageIndex,
        questionId: evidenceTarget?.questionId,
        evidenceStatus: status,
        evidenceTarget: evidenceTarget,
      );
    }

    return const SurveyResponseSubmissionPlan(
      blocker: SurveyResponseSubmissionBlocker.none,
      feedbackMessage: '',
    );
  }

  bool get canSubmit => blocker == SurveyResponseSubmissionBlocker.none;

  static String _issueCountSuffix(int issueCount) {
    return issueCount == 1 ? '' : ' ($issueCount issues)';
  }
}
