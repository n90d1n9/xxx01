import '../models/answer.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../models/survey_section.dart';
import '../validation/survey_response_validator.dart';
import 'question_visibility_evaluator.dart';

/// Builds the visible, sectioned response flow for a survey response session.
class SurveyResponseSectionFlow {
  final Survey survey;
  final SurveyResponse response;

  const SurveyResponseSectionFlow({
    required this.survey,
    required this.response,
  });

  List<Question> get visibleQuestions {
    return QuestionVisibilityEvaluator.visibleQuestions(
      survey.questions,
      response,
    );
  }

  List<SurveyResponseSectionPage> get pages {
    final visible = visibleQuestions;
    final pages = <SurveyResponseSectionPage>[];
    var questionOffset = 0;

    for (final section in survey.orderedSections) {
      final sectionQuestions = visible
          .where((question) => question.sectionId == section.id)
          .toList(growable: false);
      if (sectionQuestions.isEmpty) {
        continue;
      }

      pages.add(
        SurveyResponseSectionPage(
          section: section,
          questions: sectionQuestions,
          response: response,
          questionOffset: questionOffset,
        ),
      );
      questionOffset += sectionQuestions.length;
    }

    final sectionIds = survey.sections.map((section) => section.id).toSet();
    final unsectionedQuestions = visible
        .where((question) {
          final sectionId = question.sectionId;
          return sectionId == null || !sectionIds.contains(sectionId);
        })
        .toList(growable: false);

    if (unsectionedQuestions.isNotEmpty) {
      pages.add(
        SurveyResponseSectionPage(
          section: null,
          questions: unsectionedQuestions,
          response: response,
          questionOffset: questionOffset,
        ),
      );
    }

    return pages;
  }

  double get completionRate => response.completionRate(visibleQuestions);

  List<SurveyResponseSectionPageStatus> pageStatuses(
    SurveyResponseValidationResult validation,
  ) {
    final issuesByQuestionId = <String, List<SurveyResponseValidationIssue>>{};
    for (final issue in validation.issues) {
      issuesByQuestionId
          .putIfAbsent(
            issue.question.id,
            () => <SurveyResponseValidationIssue>[],
          )
          .add(issue);
    }

    return pages
        .map((page) {
          final issues = <SurveyResponseValidationIssue>[];
          for (final question in page.questions) {
            issues.addAll(issuesByQuestionId[question.id] ?? const []);
          }

          return SurveyResponseSectionPageStatus(page: page, issues: issues);
        })
        .toList(growable: false);
  }

  int? firstIssuePageIndex(SurveyResponseValidationResult validation) {
    final statuses = pageStatuses(validation);
    for (var index = 0; index < statuses.length; index += 1) {
      if (statuses[index].hasIssues) {
        return index;
      }
    }

    return null;
  }

  int? pageIndexForQuestion(String questionId) {
    final pages = this.pages;
    for (var index = 0; index < pages.length; index += 1) {
      final page = pages[index];
      for (final question in page.questions) {
        if (question.id == questionId) {
          return index;
        }
      }
    }

    return null;
  }

  int get answeredQuestionCount {
    return visibleQuestions
        .where(
          (question) =>
              ResponseAnswer.hasMeaningfulValue(response.valueFor(question.id)),
        )
        .length;
  }

  int get visibleQuestionCount => visibleQuestions.length;
}

/// Represents one visible response page, usually mapped to a survey section.
class SurveyResponseSectionPage {
  final SurveySection? section;
  final List<Question> questions;
  final SurveyResponse response;
  final int questionOffset;

  const SurveyResponseSectionPage({
    required this.section,
    required this.questions,
    required this.response,
    required this.questionOffset,
  });

  String get title => section?.titleOrFallback ?? 'General';

  String get description => section?.description ?? '';

  int get answeredQuestionCount {
    return questions
        .where(
          (question) =>
              ResponseAnswer.hasMeaningfulValue(response.valueFor(question.id)),
        )
        .length;
  }

  List<Question> get unansweredRequiredQuestions {
    return response.unansweredRequiredQuestions(questions);
  }

  double get completionRate {
    if (questions.isEmpty) {
      return 0;
    }

    return answeredQuestionCount / questions.length;
  }

  int questionNumberAt(int index) => questionOffset + index + 1;
}

/// Describes completion and validation state for one response section page.
class SurveyResponseSectionPageStatus {
  final SurveyResponseSectionPage page;
  final List<SurveyResponseValidationIssue> issues;

  const SurveyResponseSectionPageStatus({
    required this.page,
    required this.issues,
  });

  bool get hasIssues => issues.isNotEmpty;

  int get issueCount => issues.length;

  int get questionCount => page.questions.length;

  int get answeredQuestionCount => page.answeredQuestionCount;

  int get unansweredRequiredCount => page.unansweredRequiredQuestions.length;

  int get completionPercent => (page.completionRate * 100).round();

  int get requiredIssueCount => issues
      .where(
        (issue) => issue.type == SurveyResponseValidationIssueType.required,
      )
      .length;

  int get invalidIssueCount => issueCount - requiredIssueCount;

  bool get isComplete => !hasIssues && page.unansweredRequiredQuestions.isEmpty;

  String get answerProgressLabel {
    return '$answeredQuestionCount of $questionCount answered';
  }

  String get statusLabel {
    if (hasIssues) {
      return _plural(issueCount, 'answer issue');
    }

    if (isComplete) {
      return 'Section ready';
    }

    return 'In progress';
  }

  String get detailLabel {
    if (hasIssues) {
      final details = <String>[
        if (requiredIssueCount > 0)
          _plural(requiredIssueCount, 'required missing', 'required missing'),
        if (invalidIssueCount > 0) _plural(invalidIssueCount, 'invalid answer'),
      ];
      return details.join(' • ');
    }

    if (isComplete) {
      return 'Required answers complete';
    }

    if (unansweredRequiredCount > 0) {
      return _plural(
        unansweredRequiredCount,
        'required missing',
        'required missing',
      );
    }

    return 'Optional questions remaining';
  }

  static String _plural(int count, String singular, [String? plural]) {
    return count == 1 ? '1 $singular' : '$count ${plural ?? '${singular}s'}';
  }
}
