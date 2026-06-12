import '../models/survey.dart';
import '../models/survey_response.dart';
import 'survey_response_evidence_summary.dart';
import 'survey_response_issue_summary.dart';
import 'survey_response_section_flow.dart';
import 'survey_response_session_summary.dart';

/// Captures the derived state needed to render a response viewer screen.
class SurveyResponseViewerSnapshot {
  final Survey survey;
  final SurveyResponse response;
  final SurveyResponseSectionFlow sectionFlow;
  final List<SurveyResponseSectionPage> pages;
  final int selectedPageIndex;
  final SurveyResponseSectionPage? selectedPage;
  final SurveyResponseSessionSummary sessionSummary;
  final SurveyResponseEvidenceSummary evidenceSummary;
  final List<SurveyResponseSectionPageStatus> pageStatuses;
  final SurveyResponseIssueSummary issueSummary;
  final SurveyResponseSectionPageStatus? selectedPageStatus;

  const SurveyResponseViewerSnapshot({
    required this.survey,
    required this.response,
    required this.sectionFlow,
    required this.pages,
    required this.selectedPageIndex,
    required this.selectedPage,
    required this.sessionSummary,
    required this.evidenceSummary,
    required this.pageStatuses,
    required this.issueSummary,
    required this.selectedPageStatus,
  });

  factory SurveyResponseViewerSnapshot.evaluate({
    required Survey survey,
    required SurveyResponse response,
    required int requestedPageIndex,
  }) {
    final sectionFlow = SurveyResponseSectionFlow(
      survey: survey,
      response: response,
    );
    final pages = sectionFlow.pages;
    final selectedPageIndex = clampSelectedPageIndex(
      requestedIndex: requestedPageIndex,
      pageCount: pages.length,
    );
    final selectedPage = pages.isEmpty ? null : pages[selectedPageIndex];
    final sessionSummary = SurveyResponseSessionSummary.evaluate(
      survey: survey,
      response: response,
    );
    final evidenceSummary = SurveyResponseEvidenceSummary.evaluate(
      survey: survey,
      response: response,
    );
    final pageStatuses = sectionFlow.pageStatuses(sessionSummary.validation);
    final issueSummary = SurveyResponseIssueSummary.fromPageStatuses(
      pageStatuses,
    );

    return SurveyResponseViewerSnapshot(
      survey: survey,
      response: response,
      sectionFlow: sectionFlow,
      pages: pages,
      selectedPageIndex: selectedPageIndex,
      selectedPage: selectedPage,
      sessionSummary: sessionSummary,
      evidenceSummary: evidenceSummary,
      pageStatuses: pageStatuses,
      issueSummary: issueSummary,
      selectedPageStatus:
          selectedPage == null || selectedPageIndex >= pageStatuses.length
          ? null
          : pageStatuses[selectedPageIndex],
    );
  }

  int get pageCount => pages.length;

  static int clampSelectedPageIndex({
    required int requestedIndex,
    required int pageCount,
  }) {
    if (pageCount <= 0 || requestedIndex <= 0) {
      return 0;
    }

    if (requestedIndex >= pageCount) {
      return pageCount - 1;
    }

    return requestedIndex;
  }
}
