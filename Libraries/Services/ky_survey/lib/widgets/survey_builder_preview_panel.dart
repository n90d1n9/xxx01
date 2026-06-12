import 'package:flutter/material.dart';

import '../logic/survey_preview_session.dart';
import '../logic/survey_response_focus_state.dart';
import '../logic/survey_response_issue_summary.dart';
import '../models/survey.dart';
import 'survey_response_issue_summary_panel.dart';
import 'survey_response_section_question_list.dart';
import 'survey_response_section_progress.dart';

/// Provides an interactive response preview for the survey builder.
class SurveyBuilderPreviewPanel extends StatefulWidget {
  final Survey survey;

  const SurveyBuilderPreviewPanel({super.key, required this.survey});

  @override
  State<SurveyBuilderPreviewPanel> createState() =>
      _SurveyBuilderPreviewPanelState();
}

/// Owns the preview response session, selected section, and focused issue.
class _SurveyBuilderPreviewPanelState extends State<SurveyBuilderPreviewPanel> {
  late SurveyPreviewSession _session;
  SurveyResponseFocusState _focusState = const SurveyResponseFocusState();

  int get _selectedPageIndex => _focusState.selectedPageIndex;

  String? get _focusedQuestionId => _focusState.focusedQuestionId;

  int get _focusRequestCount => _focusState.questionFocusRequestId;

  @override
  void initState() {
    super.initState();
    _session = SurveyPreviewSession.initial(widget.survey);
  }

  @override
  void didUpdateWidget(covariant SurveyBuilderPreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.survey, widget.survey)) {
      _session = _session.forSurvey(widget.survey);
      _focusState = _focusState.selectPage(
        _clampedPageIndex(_session.sectionFlow.pages.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sectionFlow = _session.sectionFlow;
    final pages = sectionFlow.pages;
    final selectedPageIndex = _clampedPageIndex(pages.length);
    final selectedPage = pages.isEmpty ? null : pages[selectedPageIndex];
    final summary = _session.summary();
    final pageStatuses = sectionFlow.pageStatuses(summary.validation);
    final issueSummary = SurveyResponseIssueSummary.fromPageStatuses(
      pageStatuses,
    );
    final selectedPageStatus =
        selectedPage == null || selectedPageIndex >= pageStatuses.length
        ? null
        : pageStatuses[selectedPageIndex];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.preview_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Builder Preview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Reset preview',
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetPreview,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.primaryStatusLabel} - ${summary.visibleQuestionCount} visible questions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (pages.isEmpty) ...[
              const SizedBox(height: 16),
              _PreviewEmptyState(colorScheme: colorScheme),
            ] else ...[
              const SizedBox(height: 12),
              SurveyResponseSectionProgress(
                pages: pages,
                pageStatuses: pageStatuses,
                selectedIndex: selectedPageIndex,
                onPageSelected: _selectPage,
              ),
              if (issueSummary.hasIssues) ...[
                const SizedBox(height: 12),
                SurveyResponseIssueSummaryPanel(
                  summary: issueSummary,
                  selectedPageIndex: selectedPageIndex,
                  onIssueSelected: _selectPage,
                  onIssueItemSelected: _focusIssueItem,
                ),
              ],
              const SizedBox(height: 16),
              SurveyResponseSectionQuestionList(
                page: selectedPage!,
                status: selectedPageStatus,
                focusedQuestionId: _focusedQuestionId,
                focusRequestKey: _focusRequestCount,
                valueForQuestion: _session.response.valueFor,
                issuesForQuestion: summary.validation.issuesForQuestion,
                onAnswerChanged: (question, value) {
                  setState(() {
                    _session = _session.updateAnswer(
                      questionId: question.id,
                      value: value,
                    );
                  });
                },
              ),
              _PreviewPager(
                pageCount: pages.length,
                selectedPageIndex: selectedPageIndex,
                onPrevious: selectedPageIndex == 0
                    ? null
                    : () => _selectPage(selectedPageIndex - 1),
                onNext: selectedPageIndex >= pages.length - 1
                    ? null
                    : () => _selectPage(selectedPageIndex + 1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _clampedPageIndex(int pageCount) {
    if (pageCount == 0) {
      return 0;
    }

    if (_selectedPageIndex >= pageCount) {
      return pageCount - 1;
    }

    return _selectedPageIndex;
  }

  void _selectPage(int index) {
    setState(() {
      _focusState = _focusState.selectPage(index);
    });
  }

  void _focusIssueItem(SurveyResponseIssueSummaryItem item) {
    setState(() {
      _focusState = _focusState.focusQuestion(
        pageIndex: item.pageIndex,
        questionId: item.firstQuestionId,
      );
    });
  }

  void _resetPreview() {
    setState(() {
      _session = _session.reset();
      _focusState = const SurveyResponseFocusState();
    });
  }
}

/// Shows compact previous and next controls for preview pages.
class _PreviewPager extends StatelessWidget {
  final int pageCount;
  final int selectedPageIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PreviewPager({
    required this.pageCount,
    required this.selectedPageIndex,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.chevron_left),
          label: const Text('Back'),
          onPressed: onPrevious,
        ),
        const Spacer(),
        Text('${selectedPageIndex + 1} of $pageCount'),
        const Spacer(),
        FilledButton.icon(
          icon: const Icon(Icons.chevron_right),
          label: const Text('Next'),
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Communicates that the survey has no previewable questions yet.
class _PreviewEmptyState extends StatelessWidget {
  final ColorScheme colorScheme;

  const _PreviewEmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.playlist_add_outlined),
            SizedBox(width: 12),
            Expanded(child: Text('Add questions to preview the survey flow.')),
          ],
        ),
      ),
    );
  }
}
