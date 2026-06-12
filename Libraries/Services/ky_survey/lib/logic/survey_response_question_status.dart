import '../models/answer.dart';
import '../validation/survey_response_validator.dart';
import 'survey_response_section_flow.dart';

/// Defines the response state of one visible question inside a section page.
enum SurveyResponseQuestionStatusTone { answered, missing, invalid, optional }

/// Summarizes visible question states for a single response section page.
class SurveyResponseQuestionStatusSummary {
  final List<SurveyResponseQuestionStatusItem> items;

  const SurveyResponseQuestionStatusSummary({required this.items});

  factory SurveyResponseQuestionStatusSummary.fromPageStatus(
    SurveyResponseSectionPageStatus status,
  ) {
    final issuesByQuestionId = <String, List<SurveyResponseValidationIssue>>{};
    for (final issue in status.issues) {
      issuesByQuestionId
          .putIfAbsent(
            issue.question.id,
            () => <SurveyResponseValidationIssue>[],
          )
          .add(issue);
    }

    return SurveyResponseQuestionStatusSummary(
      items: [
        for (var index = 0; index < status.page.questions.length; index += 1)
          SurveyResponseQuestionStatusItem(
            questionId: status.page.questions[index].id,
            questionNumber: status.page.questionNumberAt(index),
            title: status.page.questions[index].text,
            isRequired: status.page.questions[index].required,
            hasAnswer: ResponseAnswer.hasMeaningfulValue(
              status.page.response.valueFor(status.page.questions[index].id),
            ),
            issues:
                issuesByQuestionId[status.page.questions[index].id] ?? const [],
          ),
      ],
    );
  }

  bool get hasItems => items.isNotEmpty;

  int get answeredCount {
    return items
        .where((item) => item.tone == SurveyResponseQuestionStatusTone.answered)
        .length;
  }

  int get missingRequiredCount {
    return items
        .where((item) => item.tone == SurveyResponseQuestionStatusTone.missing)
        .length;
  }

  int get invalidCount {
    return items
        .where((item) => item.tone == SurveyResponseQuestionStatusTone.invalid)
        .length;
  }

  int get optionalPendingCount {
    return items
        .where((item) => item.tone == SurveyResponseQuestionStatusTone.optional)
        .length;
  }

  String get statusLabel {
    final parts = <String>[
      if (answeredCount > 0) _plural(answeredCount, 'answered'),
      if (missingRequiredCount > 0)
        _plural(missingRequiredCount, 'required missing', 'required missing'),
      if (invalidCount > 0) _plural(invalidCount, 'invalid'),
      if (optionalPendingCount > 0)
        _plural(optionalPendingCount, 'optional open', 'optional open'),
    ];

    return parts.isEmpty ? 'No visible questions' : parts.join(' - ');
  }

  static String _plural(int count, String singular, [String? plural]) {
    return count == 1 ? '1 $singular' : '$count ${plural ?? '${singular}s'}';
  }
}

/// Describes the response state and display labels for one question shortcut.
class SurveyResponseQuestionStatusItem {
  final String questionId;
  final int questionNumber;
  final String title;
  final bool isRequired;
  final bool hasAnswer;
  final List<SurveyResponseValidationIssue> issues;

  const SurveyResponseQuestionStatusItem({
    required this.questionId,
    required this.questionNumber,
    required this.title,
    required this.isRequired,
    required this.hasAnswer,
    required this.issues,
  });

  bool get hasIssues => issues.isNotEmpty;

  bool get hasMissingRequiredIssue {
    return issues.any(
      (issue) => issue.type == SurveyResponseValidationIssueType.required,
    );
  }

  SurveyResponseQuestionStatusTone get tone {
    if (hasMissingRequiredIssue) {
      return SurveyResponseQuestionStatusTone.missing;
    }

    if (hasIssues) {
      return SurveyResponseQuestionStatusTone.invalid;
    }

    if (hasAnswer) {
      return SurveyResponseQuestionStatusTone.answered;
    }

    return SurveyResponseQuestionStatusTone.optional;
  }

  String get questionLabel => 'Q$questionNumber';

  String get shortStatusLabel {
    return switch (tone) {
      SurveyResponseQuestionStatusTone.answered => 'Answered',
      SurveyResponseQuestionStatusTone.missing => 'Missing',
      SurveyResponseQuestionStatusTone.invalid => 'Invalid',
      SurveyResponseQuestionStatusTone.optional =>
        isRequired ? 'Required' : 'Optional',
    };
  }

  String get detailLabel {
    if (hasIssues) {
      return issues.first.message;
    }

    if (hasAnswer) {
      return 'Answered';
    }

    return isRequired ? 'Required unanswered' : 'Optional unanswered';
  }

  String get tooltipLabel {
    final cleanTitle = title.trim().isEmpty ? 'Question' : title.trim();
    return '$questionLabel: $cleanTitle - $detailLabel';
  }
}
