import 'package:flutter/material.dart';

import '../logic/survey_response_evidence_summary.dart';
import '../logic/survey_response_issue_summary.dart';
import '../logic/survey_response_section_flow.dart';
import '../logic/survey_response_view_intent.dart';
import 'dashboard/survey_requested_section_focus.dart';
import 'survey_response_evidence_checklist.dart';
import 'survey_response_intent_banner.dart';
import 'survey_response_issue_summary_panel.dart';
import 'survey_response_section_question_list.dart';

/// Composes the scrollable response viewer body from reusable response modules.
class SurveyResponseViewerBody extends StatelessWidget {
  final SurveyResponseViewerIntent? intent;
  final VoidCallback? onIntentAction;
  final SurveyResponseEvidenceSummary evidenceSummary;
  final SurveyResponseIssueSummary issueSummary;
  final int selectedPageIndex;
  final SurveyResponseSectionPage? selectedPage;
  final SurveyResponseSectionPageStatus? selectedPageStatus;
  final String? focusedRequirementId;
  final int? evidenceFocusRequestKey;
  final String? focusedQuestionId;
  final Object? questionFocusRequestKey;
  final ValueChanged<SurveyEvidenceRequirementStatus>
  onRequirementStatusSelected;
  final ValueChanged<int> onIssueSelected;
  final ValueChanged<SurveyResponseIssueSummaryItem> onIssueItemSelected;
  final SurveyResponseQuestionValueResolver valueForQuestion;
  final SurveyResponseQuestionIssuesResolver issuesForQuestion;
  final SurveyResponseQuestionAnswerChanged onAnswerChanged;

  const SurveyResponseViewerBody({
    super.key,
    required this.evidenceSummary,
    required this.issueSummary,
    required this.selectedPageIndex,
    required this.selectedPage,
    required this.selectedPageStatus,
    required this.onRequirementStatusSelected,
    required this.onIssueSelected,
    required this.onIssueItemSelected,
    required this.valueForQuestion,
    required this.issuesForQuestion,
    required this.onAnswerChanged,
    this.intent,
    this.onIntentAction,
    this.focusedRequirementId,
    this.evidenceFocusRequestKey,
    this.focusedQuestionId,
    this.questionFocusRequestKey,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (intent != null) ...[
          SurveyResponseIntentBanner(
            intent: intent!,
            actionLabel: intent!.primaryActionLabel,
            onAction: intent!.primaryActionLabel == null
                ? null
                : onIntentAction,
          ),
          const SizedBox(height: 16),
        ],
        if (evidenceSummary.hasRequirements) ...[
          SurveyRequestedSectionFocus(
            requestId: evidenceFocusRequestKey ?? 0,
            semanticsLabel: 'Focused evidence checklist',
            padding: EdgeInsets.zero,
            alignment: 0.02,
            child: SurveyResponseEvidenceChecklist(
              summary: evidenceSummary,
              focusedRequirementId: focusedRequirementId,
              highlighted: intent?.shouldHighlightEvidence ?? false,
              onRequirementStatusSelected: onRequirementStatusSelected,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (issueSummary.hasIssues) ...[
          SurveyResponseIssueSummaryPanel(
            summary: issueSummary,
            selectedPageIndex: selectedPageIndex,
            onIssueSelected: onIssueSelected,
            onIssueItemSelected: onIssueItemSelected,
          ),
          const SizedBox(height: 16),
        ],
        if (selectedPage == null)
          const Center(child: Text('No questions in this survey.'))
        else
          SurveyResponseSectionQuestionList(
            page: selectedPage!,
            status: selectedPageStatus,
            focusedQuestionId: focusedQuestionId,
            focusRequestKey: questionFocusRequestKey,
            valueForQuestion: valueForQuestion,
            issuesForQuestion: issuesForQuestion,
            onAnswerChanged: onAnswerChanged,
          ),
      ],
    );
  }
}
