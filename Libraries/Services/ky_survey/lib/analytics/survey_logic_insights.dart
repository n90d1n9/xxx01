import '../models/question.dart';
import '../models/question_type_details.dart';
import '../models/question_visibility_rule.dart';
import '../models/survey.dart';
import '../models/survey_section.dart';
import 'survey_logic_models.dart';

export 'survey_logic_models.dart';

class SurveyLogicInsights {
  final Survey survey;

  const SurveyLogicInsights(this.survey);

  int get totalVisibilityRules {
    return survey.questions.fold(
      0,
      (total, question) => total + question.visibilityRules.length,
    );
  }

  int get conditionalQuestionCount => conditionalQuestions.length;

  int get rootQuestionCount {
    return survey.questions
        .where((question) => question.visibilityRules.isEmpty)
        .length;
  }

  List<Question> get conditionalQuestions {
    return survey.questions
        .where((question) => question.visibilityRules.isNotEmpty)
        .toList(growable: false);
  }

  List<Question> get hiddenByDefaultQuestions => conditionalQuestions;

  int get maxDependencyDepth {
    var maxDepth = 0;
    for (final question in survey.questions) {
      final depth = dependencyDepthFor(question.id);
      if (depth > maxDepth) {
        maxDepth = depth;
      }
    }

    return maxDepth;
  }

  List<SurveyLogicIssue> get issues {
    final collectedIssues = <SurveyLogicIssue>[];
    final questionsById = _questionsById;
    final questionIndexes = _questionIndexes;

    for (final question in survey.questions) {
      final questionIndex = questionIndexes[question.id] ?? -1;
      for (final rule in question.visibilityRules) {
        final sourceQuestion = questionsById[rule.sourceQuestionId];
        final sourceIndex = questionIndexes[rule.sourceQuestionId] ?? -1;

        if (sourceQuestion == null) {
          collectedIssues.add(
            SurveyLogicIssue.blocker(
              type: SurveyLogicIssueType.missingSource,
              question: question,
              rule: rule,
              message: '${question.logicLabel} depends on a missing question',
            ),
          );
          continue;
        }

        if (sourceQuestion.id == question.id) {
          collectedIssues.add(
            SurveyLogicIssue.blocker(
              type: SurveyLogicIssueType.selfDependency,
              question: question,
              sourceQuestion: sourceQuestion,
              rule: rule,
              message: '${question.logicLabel} cannot depend on itself',
            ),
          );
        }

        if (sourceIndex > questionIndex) {
          collectedIssues.add(
            SurveyLogicIssue.blocker(
              type: SurveyLogicIssueType.forwardDependency,
              question: question,
              sourceQuestion: sourceQuestion,
              rule: rule,
              message: '${question.logicLabel} depends on a later question',
            ),
          );
        }

        if (rule.operator.needsValue && !_hasRuleValue(rule.value)) {
          collectedIssues.add(
            SurveyLogicIssue.blocker(
              type: SurveyLogicIssueType.incompleteValue,
              question: question,
              sourceQuestion: sourceQuestion,
              rule: rule,
              message:
                  '${question.logicLabel} has an incomplete condition value',
            ),
          );
        }

        if (rule.operator.usesNumericValue &&
            sourceQuestion.type != QuestionType.number &&
            sourceQuestion.type != QuestionType.rating) {
          collectedIssues.add(
            SurveyLogicIssue.blocker(
              type: SurveyLogicIssueType.numericOnNonNumeric,
              question: question,
              sourceQuestion: sourceQuestion,
              rule: rule,
              message:
                  '${question.logicLabel} uses a numeric condition on ${sourceQuestion.logicLabel}',
            ),
          );
        }

        if (_usesMissingOptionValue(sourceQuestion, rule)) {
          collectedIssues.add(
            SurveyLogicIssue.warning(
              type: SurveyLogicIssueType.optionValueMismatch,
              question: question,
              sourceQuestion: sourceQuestion,
              rule: rule,
              message:
                  '${question.logicLabel} references an option that is not available on ${sourceQuestion.logicLabel}',
            ),
          );
        }
      }
    }

    for (final questionId in _cyclicQuestionIds()) {
      final question = questionsById[questionId];
      if (question == null) {
        continue;
      }

      collectedIssues.add(
        SurveyLogicIssue.blocker(
          type: SurveyLogicIssueType.cycle,
          question: question,
          message: '${question.logicLabel} is part of a dependency cycle',
        ),
      );
    }

    return collectedIssues;
  }

  List<SurveyLogicQuestionSummary> get questionSummaries {
    final issuesByQuestionId = <String, List<SurveyLogicIssue>>{};
    for (final issue in issues) {
      issuesByQuestionId
          .putIfAbsent(issue.question.id, () => <SurveyLogicIssue>[])
          .add(issue);
    }

    return survey.questions
        .map((question) {
          return SurveyLogicQuestionSummary(
            question: question,
            dependencyCount: question.visibilityRules.length,
            dependentQuestionCount: dependentQuestionIds(question.id).length,
            dependencyDepth: dependencyDepthFor(question.id),
            issues: issuesByQuestionId[question.id] ?? const [],
          );
        })
        .toList(growable: false);
  }

  List<SurveyLogicSectionSummary> get sectionSummaries {
    final summaries = <SurveyLogicSectionSummary>[];
    final questionSummariesById = {
      for (final summary in questionSummaries) summary.question.id: summary,
    };

    for (final section in survey.orderedSections) {
      final questions = survey.questionsForSection(section.id);
      summaries.add(
        _sectionSummary(
          id: section.id,
          title: section.titleOrFallback,
          questions: questions,
          questionSummariesById: questionSummariesById,
        ),
      );
    }

    if (survey.unsectionedQuestions.isNotEmpty) {
      summaries.add(
        _sectionSummary(
          id: 'general',
          title: 'General',
          questions: survey.unsectionedQuestions,
          questionSummariesById: questionSummariesById,
        ),
      );
    }

    return summaries;
  }

  int dependencyDepthFor(String questionId) {
    return _dependencyDepthFor(questionId, <String>{});
  }

  Set<String> dependentQuestionIds(String sourceQuestionId) {
    final dependents = <String>{};
    var changed = true;

    while (changed) {
      changed = false;
      for (final question in survey.questions) {
        if (dependents.contains(question.id)) {
          continue;
        }

        final dependsOnSource = question.visibilityRules.any((rule) {
          return rule.sourceQuestionId == sourceQuestionId ||
              dependents.contains(rule.sourceQuestionId);
        });
        if (dependsOnSource) {
          dependents.add(question.id);
          changed = true;
        }
      }
    }

    return dependents;
  }

  SurveyLogicSectionSummary _sectionSummary({
    required String id,
    required String title,
    required List<Question> questions,
    required Map<String, SurveyLogicQuestionSummary> questionSummariesById,
  }) {
    var visibilityRuleCount = 0;
    var conditionalQuestionCount = 0;
    var issueCount = 0;
    var maxDepth = 0;

    for (final question in questions) {
      visibilityRuleCount += question.visibilityRules.length;
      if (question.visibilityRules.isNotEmpty) {
        conditionalQuestionCount += 1;
      }

      final summary = questionSummariesById[question.id];
      if (summary == null) {
        continue;
      }

      issueCount += summary.issues.length;
      if (summary.dependencyDepth > maxDepth) {
        maxDepth = summary.dependencyDepth;
      }
    }

    return SurveyLogicSectionSummary(
      id: id,
      title: title,
      questionCount: questions.length,
      conditionalQuestionCount: conditionalQuestionCount,
      visibilityRuleCount: visibilityRuleCount,
      issueCount: issueCount,
      maxDependencyDepth: maxDepth,
    );
  }

  int _dependencyDepthFor(String questionId, Set<String> visiting) {
    final question = _questionsById[questionId];
    if (question == null || question.visibilityRules.isEmpty) {
      return 0;
    }

    if (!visiting.add(questionId)) {
      return 0;
    }

    var maxSourceDepth = 0;
    for (final rule in question.visibilityRules) {
      final sourceDepth = _dependencyDepthFor(rule.sourceQuestionId, {
        ...visiting,
      });
      if (sourceDepth > maxSourceDepth) {
        maxSourceDepth = sourceDepth;
      }
    }

    return maxSourceDepth + 1;
  }

  Set<String> _cyclicQuestionIds() {
    final cyclicIds = <String>{};
    final visited = <String>{};
    final visiting = <String>{};

    for (final question in survey.questions) {
      _visitForCycle(
        question.id,
        visited: visited,
        stack: <String>[],
        visiting: visiting,
        cyclicIds: cyclicIds,
      );
    }

    return cyclicIds;
  }

  void _visitForCycle(
    String questionId, {
    required Set<String> visited,
    required List<String> stack,
    required Set<String> visiting,
    required Set<String> cyclicIds,
  }) {
    if (visiting.contains(questionId)) {
      final cycleStart = stack.indexOf(questionId);
      if (cycleStart == -1) {
        cyclicIds.add(questionId);
      } else {
        cyclicIds.addAll(stack.skip(cycleStart));
      }
      return;
    }

    if (!visited.add(questionId)) {
      return;
    }

    visiting.add(questionId);
    stack.add(questionId);
    final question = _questionsById[questionId];
    for (final rule in question?.visibilityRules ?? const []) {
      if (_questionsById.containsKey(rule.sourceQuestionId)) {
        _visitForCycle(
          rule.sourceQuestionId,
          visited: visited,
          stack: stack,
          visiting: visiting,
          cyclicIds: cyclicIds,
        );
      }
    }
    stack.removeLast();
    visiting.remove(questionId);
  }

  Map<String, Question> get _questionsById {
    return {for (final question in survey.questions) question.id: question};
  }

  Map<String, int> get _questionIndexes {
    return {
      for (var index = 0; index < survey.questions.length; index += 1)
        survey.questions[index].id: index,
    };
  }

  bool _usesMissingOptionValue(
    Question sourceQuestion,
    QuestionVisibilityRule rule,
  ) {
    if (!sourceQuestion.type.usesOptions || !rule.operator.needsValue) {
      return false;
    }

    final value = rule.value?.toString();
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    final optionIds = {
      for (final option in sourceQuestion.options ?? const []) option.id,
    };
    return !optionIds.contains(value);
  }

  bool _hasRuleValue(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is String) {
      return value.trim().isNotEmpty;
    }

    if (value is Iterable) {
      return value.isNotEmpty;
    }

    return true;
  }
}

extension _QuestionLogicLabel on Question {
  String get logicLabel {
    final label = text.trim();
    return label.isEmpty ? 'Untitled question' : label;
  }
}
