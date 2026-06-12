import 'package:flutter/material.dart';

import '../logic/survey_response_section_flow.dart';

class SurveyResponseSectionProgress extends StatelessWidget {
  final List<SurveyResponseSectionPage> pages;
  final List<SurveyResponseSectionPageStatus> pageStatuses;
  final int selectedIndex;
  final ValueChanged<int> onPageSelected;

  const SurveyResponseSectionProgress({
    super.key,
    required this.pages,
    this.pageStatuses = const [],
    required this.selectedIndex,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (pages.length <= 1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final page = pages[index];
          final status = pageStatuses.length > index
              ? pageStatuses[index]
              : null;
          final isSelected = index == selectedIndex;
          final hasIssues = status?.hasIssues ?? false;
          final complete =
              status?.isComplete ?? page.unansweredRequiredQuestions.isEmpty;
          final issueCount = status?.issueCount ?? 0;

          return ChoiceChip(
            selected: isSelected,
            avatar: Icon(
              hasIssues
                  ? Icons.error_outline
                  : complete
                  ? Icons.task_alt_outlined
                  : Icons.radio_button_unchecked,
              size: 18,
            ),
            label: Text(
              _labelFor(page: page, issueCount: issueCount),
              overflow: TextOverflow.ellipsis,
            ),
            onSelected: (_) => onPageSelected(index),
          );
        },
      ),
    );
  }

  String _labelFor({
    required SurveyResponseSectionPage page,
    required int issueCount,
  }) {
    final completion = (page.completionRate * 100).round();
    if (issueCount == 0) {
      return '${page.title} $completion%';
    }

    return '${page.title} $completion% ($issueCount)';
  }
}
