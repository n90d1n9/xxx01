import 'survey_response_answer_issue_focus_target.dart';
import 'survey_response_evidence_focus_target.dart';
import 'survey_response_focus_state.dart';
import 'survey_response_view_intent.dart';
import 'survey_response_viewer_snapshot.dart';

/// Resolves response viewer intents into concrete section and field focus.
class SurveyResponseViewerFocusResolver {
  const SurveyResponseViewerFocusResolver._();

  static SurveyResponseFocusState resolveInitialFocus({
    required SurveyResponseViewerIntent? intent,
    required SurveyResponseViewerSnapshot snapshot,
    SurveyResponseFocusState initialState = const SurveyResponseFocusState(),
  }) {
    if (intent == null) {
      return initialState;
    }

    final focusQuestionId = intent.focusQuestionId;
    if (focusQuestionId != null) {
      final pageIndex = snapshot.sectionFlow.pageIndexForQuestion(
        focusQuestionId,
      );
      if (pageIndex != null) {
        return initialState.focusQuestion(
          pageIndex: pageIndex,
          questionId: focusQuestionId,
        );
      }
    }

    if (intent.shouldFocusFirstAnswerIssue) {
      final target = SurveyResponseAnswerIssueFocusTarget.resolveFirst(
        sectionFlow: snapshot.sectionFlow,
        validation: snapshot.sessionSummary.validation,
      );
      if (target != null) {
        return target.applyTo(initialState);
      }
    }

    if (intent.shouldOpenEvidenceCapture) {
      final status = snapshot.evidenceSummary.firstIncompleteRequirement;
      if (status != null) {
        final target = SurveyResponseEvidenceFocusTarget.resolve(
          sectionFlow: snapshot.sectionFlow,
          status: status,
        );
        return target.applyTo(initialState);
      }
    }

    if (intent.shouldPromptSubmit) {
      return initialState.selectPage(
        snapshot.pageCount <= 1 ? 0 : snapshot.pageCount - 1,
      );
    }

    return initialState;
  }
}
