import 'survey_response_section_flow.dart';

/// Summarizes response validation issues into section-level navigation targets.
class SurveyResponseIssueSummary {
  final List<SurveyResponseIssueSummaryItem> items;

  const SurveyResponseIssueSummary({required this.items});

  factory SurveyResponseIssueSummary.fromPageStatuses(
    List<SurveyResponseSectionPageStatus> statuses,
  ) {
    final items = <SurveyResponseIssueSummaryItem>[];

    for (var pageIndex = 0; pageIndex < statuses.length; pageIndex += 1) {
      final status = statuses[pageIndex];
      if (!status.hasIssues) {
        continue;
      }

      final firstIssue = status.issues.first;
      items.add(
        SurveyResponseIssueSummaryItem(
          pageIndex: pageIndex,
          pageTitle: status.page.title,
          issueCount: status.issueCount,
          requiredIssueCount: status.requiredIssueCount,
          invalidIssueCount: status.invalidIssueCount,
          firstIssueMessage: firstIssue.message,
          firstQuestionId: firstIssue.question.id,
          firstQuestionNumber: _questionNumberForIssue(
            page: status.page,
            questionId: firstIssue.question.id,
          ),
        ),
      );
    }

    return SurveyResponseIssueSummary(items: items);
  }

  bool get hasIssues => items.isNotEmpty;

  int get issueCount {
    return items.fold(0, (total, item) => total + item.issueCount);
  }

  int get requiredIssueCount {
    return items.fold(0, (total, item) => total + item.requiredIssueCount);
  }

  int get invalidIssueCount {
    return items.fold(0, (total, item) => total + item.invalidIssueCount);
  }

  String get titleLabel {
    return issueCount == 1
        ? '1 answer needs attention'
        : '$issueCount answers need attention';
  }

  String get detailLabel {
    final details = <String>[
      if (requiredIssueCount > 0)
        _plural(requiredIssueCount, 'required missing', 'required missing'),
      if (invalidIssueCount > 0) _plural(invalidIssueCount, 'invalid answer'),
    ];

    return details.isEmpty ? 'Review response quality' : details.join(' • ');
  }

  String? get firstIssueLabel => items.isEmpty ? null : items.first.issueLabel;

  static int? _questionNumberForIssue({
    required SurveyResponseSectionPage page,
    required String questionId,
  }) {
    final questionIndex = page.questions.indexWhere(
      (question) => question.id == questionId,
    );
    if (questionIndex < 0) {
      return null;
    }

    return page.questionNumberAt(questionIndex);
  }

  static String _plural(int count, String singular, [String? plural]) {
    return count == 1 ? '1 $singular' : '$count ${plural ?? '${singular}s'}';
  }
}

/// Describes one response section page that contains validation issues.
class SurveyResponseIssueSummaryItem {
  final int pageIndex;
  final String pageTitle;
  final int issueCount;
  final int requiredIssueCount;
  final int invalidIssueCount;
  final String firstIssueMessage;
  final String firstQuestionId;
  final int? firstQuestionNumber;

  const SurveyResponseIssueSummaryItem({
    required this.pageIndex,
    required this.pageTitle,
    required this.issueCount,
    required this.requiredIssueCount,
    required this.invalidIssueCount,
    required this.firstIssueMessage,
    required this.firstQuestionId,
    required this.firstQuestionNumber,
  });

  String get pageLabel {
    return issueCount == 1 ? pageTitle : '$pageTitle ($issueCount)';
  }

  String get issueLabel {
    final number = firstQuestionNumber;
    if (number == null) {
      return firstIssueMessage;
    }

    return 'Q$number: $firstIssueMessage';
  }
}
