import 'dart:convert';

import '../models/answer.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../logic/question_visibility_evaluator.dart';
import '../logic/survey_response_survey_resolver.dart';

class SurveyResponseInsights {
  final List<Survey> surveys;
  final List<SurveyResponse> responses;

  const SurveyResponseInsights({
    required this.surveys,
    required this.responses,
  });

  SurveyResponseSurveyResolver get _surveyResolver {
    return SurveyResponseSurveyResolver(surveys: surveys);
  }

  List<SurveyResponse> get submittedResponses => responses
      .where((response) => response.status == SurveyResponseStatus.submitted)
      .toList();

  int get submittedResponseCount => submittedResponses.length;

  int get draftResponseCount => responses
      .where((response) => response.status == SurveyResponseStatus.draft)
      .length;

  int get reportReadySurveyCount =>
      summaries.where((summary) => summary.submittedResponses > 0).length;

  double get averageCompletion {
    if (submittedResponses.isEmpty) {
      return 0;
    }

    final completionTotal = submittedResponses.fold<double>(0, (
      total,
      response,
    ) {
      return total +
          response.completionRate(
            _surveyResolver.visibleQuestionsForResponse(response),
          );
    });

    return completionTotal / submittedResponses.length;
  }

  List<SurveyResponseSummary> get summaries {
    return surveys.map(summaryForSurvey).toList();
  }

  SurveyResponseSummary summaryForSurvey(Survey survey) {
    final surveyResponses = responses
        .where((response) => response.surveyId == survey.id)
        .toList();
    final submitted = surveyResponses
        .where((response) => response.status == SurveyResponseStatus.submitted)
        .toList();
    final averageCompletion = submitted.isEmpty
        ? 0.0
        : submitted.fold<double>(
                0,
                (total, response) =>
                    total +
                    response.completionRate(
                      _surveyResolver.visibleQuestionsForResponse(response),
                    ),
              ) /
              submitted.length;

    return SurveyResponseSummary(
      survey: survey,
      totalResponses: surveyResponses.length,
      submittedResponses: submitted.length,
      draftResponses: surveyResponses.length - submitted.length,
      averageCompletion: averageCompletion,
    );
  }

  List<QuestionResponseBreakdown> questionBreakdowns(Survey survey) {
    final submitted = responses
        .where(
          (response) =>
              response.surveyId == survey.id &&
              response.status == SurveyResponseStatus.submitted,
        )
        .toList();

    return _questionBreakdownScopes(survey, submitted)
        .map((scope) {
          final question = scope.question;
          final visibleResponses = scope.responses
              .where(
                (response) =>
                    QuestionVisibilityEvaluator.isVisible(question, response),
              )
              .toList();
          final values = visibleResponses
              .map((response) => response.valueFor(question.id))
              .where(ResponseAnswer.hasMeaningfulValue)
              .toList();
          final ratings = values
              .map(_asDouble)
              .whereType<double>()
              .toList(growable: false);
          final optionCounts = _optionCounts(question, values);

          return QuestionResponseBreakdown(
            question: question,
            answeredCount: values.length,
            missingRequiredCount: question.required
                ? visibleResponses.length - values.length
                : 0,
            optionCounts: optionCounts,
            averageRating: ratings.isEmpty
                ? null
                : ratings.reduce((left, right) => left + right) /
                      ratings.length,
            textResponseCount: values
                .where((value) => value is String && value.trim().isNotEmpty)
                .length,
          );
        })
        .toList(growable: false);
  }

  List<QuestionResponseBreakdown> notableBreakdowns({int limit = 5}) {
    final breakdowns = <QuestionResponseBreakdown>[];
    for (final survey in surveys) {
      breakdowns.addAll(questionBreakdowns(survey));
    }

    final activeBreakdowns = breakdowns
        .where(
          (breakdown) =>
              breakdown.answeredCount > 0 || breakdown.missingRequiredCount > 0,
        )
        .toList();

    activeBreakdowns.sort(
      (left, right) => right.answeredCount.compareTo(left.answeredCount),
    );
    return activeBreakdowns.take(limit).toList();
  }

  List<_QuestionBreakdownScope> _questionBreakdownScopes(
    Survey survey,
    List<SurveyResponse> submitted,
  ) {
    final scopes = <String, _QuestionBreakdownScope>{};

    void addQuestion(Question question, [SurveyResponse? response]) {
      final key = _questionDefinitionKey(question);
      final scope = scopes.putIfAbsent(
        key,
        () => _QuestionBreakdownScope(question: question),
      );
      if (response != null) {
        scope.responses.add(response);
      }
    }

    for (final question in survey.questions) {
      addQuestion(question);
    }

    for (final response in submitted) {
      final responseSurvey = _surveyResolver.surveyForResponse(response);
      final questions = responseSurvey?.questions ?? survey.questions;
      for (final question in questions) {
        addQuestion(question, response);
      }
    }

    return scopes.values.toList(growable: false);
  }

  String _questionDefinitionKey(Question question) {
    return jsonEncode(question.toJson());
  }

  Map<String, int> _optionCounts(Question question, List<dynamic> values) {
    if (question.type != QuestionType.singleChoice &&
        question.type != QuestionType.multipleChoice) {
      return const {};
    }

    final labelsById = {
      for (final option in question.options ?? const []) option.id: option.text,
    };
    final counts = <String, int>{};

    for (final value in values) {
      final selectedIds = value is Iterable ? value : [value];
      for (final selectedId in selectedIds) {
        final key = selectedId.toString();
        final label = labelsById[key] ?? key;
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    return counts;
  }

  double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}

class _QuestionBreakdownScope {
  final Question question;
  final List<SurveyResponse> responses = [];

  _QuestionBreakdownScope({required this.question});
}

class SurveyResponseSummary {
  final Survey survey;
  final int totalResponses;
  final int submittedResponses;
  final int draftResponses;
  final double averageCompletion;

  const SurveyResponseSummary({
    required this.survey,
    required this.totalResponses,
    required this.submittedResponses,
    required this.draftResponses,
    required this.averageCompletion,
  });
}

class QuestionResponseBreakdown {
  final Question question;
  final int answeredCount;
  final int missingRequiredCount;
  final Map<String, int> optionCounts;
  final double? averageRating;
  final int textResponseCount;

  const QuestionResponseBreakdown({
    required this.question,
    required this.answeredCount,
    required this.missingRequiredCount,
    required this.optionCounts,
    this.averageRating,
    this.textResponseCount = 0,
  });

  String get primaryInsight {
    if (averageRating != null) {
      return 'Avg ${averageRating!.toStringAsFixed(1)}';
    }

    if (optionCounts.isNotEmpty) {
      final topOption = optionCounts.entries.reduce(
        (left, right) => left.value >= right.value ? left : right,
      );
      return '${topOption.key}: ${topOption.value}';
    }

    if (textResponseCount > 0) {
      return '$textResponseCount text responses';
    }

    return '$answeredCount answers';
  }
}
