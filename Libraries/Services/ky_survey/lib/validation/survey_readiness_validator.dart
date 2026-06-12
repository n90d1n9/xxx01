import '../models/question.dart';
import '../models/question_type_details.dart';
import '../models/question_visibility_rule.dart';
import '../models/survey.dart';
import '../models/survey_evidence.dart';
import '../models/survey_status.dart';

class SurveyReadinessValidator {
  const SurveyReadinessValidator._();

  static SurveyReadinessResult validate(Survey survey) {
    final issues = <SurveyReadinessIssue>[];

    if (survey.title.trim().isEmpty) {
      issues.add(
        const SurveyReadinessIssue.blocker('Survey title is required'),
      );
    }

    if (survey.description.trim().isEmpty) {
      issues.add(
        const SurveyReadinessIssue.warning('Survey description is empty'),
      );
    }

    if (survey.questions.isEmpty) {
      issues.add(
        const SurveyReadinessIssue.blocker('Add at least one question'),
      );
    }

    final questionsById = {
      for (final question in survey.questions) question.id: question,
    };

    for (var index = 0; index < survey.questions.length; index += 1) {
      final question = survey.questions[index];
      issues.addAll(
        _validateQuestion(
          question: question,
          questionIndex: index,
          questions: survey.questions,
          questionsById: questionsById,
        ),
      );
    }

    issues.addAll(_validateSections(survey));
    issues.addAll(_validateEvidenceRequirements(survey));

    if (survey.targetResponses <= 0) {
      issues.add(
        const SurveyReadinessIssue.warning('Response target is not configured'),
      );
    }

    return SurveyReadinessResult(survey: survey, issues: issues);
  }

  static List<SurveyStatus> nextStatuses(Survey survey) {
    final readiness = validate(survey);

    switch (survey.status) {
      case SurveyStatus.draft:
        return readiness.canCollect
            ? const [SurveyStatus.review, SurveyStatus.published]
            : const [SurveyStatus.review];
      case SurveyStatus.review:
        return readiness.canCollect
            ? const [SurveyStatus.draft, SurveyStatus.published]
            : const [SurveyStatus.draft];
      case SurveyStatus.published:
        return const [SurveyStatus.collecting, SurveyStatus.closed];
      case SurveyStatus.collecting:
        return const [SurveyStatus.analyzing, SurveyStatus.closed];
      case SurveyStatus.analyzing:
        return const [SurveyStatus.collecting, SurveyStatus.closed];
      case SurveyStatus.closed:
        return const [SurveyStatus.analyzing, SurveyStatus.archived];
      case SurveyStatus.archived:
        return const [SurveyStatus.closed];
    }
  }

  static List<SurveyReadinessIssue> _validateQuestion({
    required Question question,
    required int questionIndex,
    required List<Question> questions,
    required Map<String, Question> questionsById,
  }) {
    final issues = <SurveyReadinessIssue>[];

    if (question.text.trim().isEmpty) {
      issues.add(
        const SurveyReadinessIssue.blocker('Question text is required'),
      );
    }

    if (question.type.usesOptions) {
      final filledOptions =
          question.options
              ?.map((option) => option.text.trim())
              .where((label) => label.isNotEmpty)
              .toList() ??
          const <String>[];

      if (filledOptions.length < 2) {
        issues.add(
          SurveyReadinessIssue.blocker(
            '${question.textOrFallback} needs at least 2 options',
          ),
        );
      }

      if (filledOptions.toSet().length != filledOptions.length) {
        issues.add(
          SurveyReadinessIssue.blocker(
            '${question.textOrFallback} has duplicate options',
          ),
        );
      }
    }

    if (question.type == QuestionType.rating) {
      final minRating = question.minRating ?? 1;
      final maxRating = question.maxRating ?? 5;
      if (minRating >= maxRating) {
        issues.add(
          SurveyReadinessIssue.blocker(
            '${question.textOrFallback} has an invalid rating scale',
          ),
        );
      }
    }

    for (final rule in question.visibilityRules) {
      issues.addAll(
        _validateVisibilityRule(
          question: question,
          questionIndex: questionIndex,
          rule: rule,
          questions: questions,
          questionsById: questionsById,
        ),
      );
    }

    return issues;
  }

  static List<SurveyReadinessIssue> _validateSections(Survey survey) {
    final issues = <SurveyReadinessIssue>[];
    final sectionTitles = <String>{};

    for (final section in survey.sections) {
      final title = section.title.trim();
      if (title.isEmpty) {
        issues.add(
          const SurveyReadinessIssue.blocker('Section title is required'),
        );
      } else if (!sectionTitles.add(title.toLowerCase())) {
        issues.add(
          SurveyReadinessIssue.warning('Duplicate section title: $title'),
        );
      }
    }

    final sectionIds = survey.sections.map((section) => section.id).toSet();
    for (final question in survey.questions) {
      final sectionId = question.sectionId;
      if (sectionId != null && !sectionIds.contains(sectionId)) {
        issues.add(
          SurveyReadinessIssue.warning(
            '${question.textOrFallback} references a missing section',
          ),
        );
      }
    }

    return issues;
  }

  static List<SurveyReadinessIssue> _validateEvidenceRequirements(
    Survey survey,
  ) {
    final issues = <SurveyReadinessIssue>[];
    final questionIds = survey.questions.map((question) => question.id).toSet();

    for (final requirement in survey.evidenceRequirements) {
      if (requirement.minCount <= 0) {
        issues.add(
          SurveyReadinessIssue.blocker(
            '${requirement.labelOrFallback} must require at least 1 capture',
          ),
        );
      }

      if (requirement.scope == SurveyEvidenceScope.question) {
        final questionId = requirement.questionId;
        if (questionId == null || questionId.trim().isEmpty) {
          issues.add(
            SurveyReadinessIssue.blocker(
              '${requirement.labelOrFallback} must reference a question',
            ),
          );
        } else if (!questionIds.contains(questionId)) {
          issues.add(
            SurveyReadinessIssue.blocker(
              '${requirement.labelOrFallback} references a missing question',
            ),
          );
        }
      }

      final maxSize = requirement.maxAttachmentSizeBytes;
      if (maxSize != null && maxSize <= 0) {
        issues.add(
          SurveyReadinessIssue.blocker(
            '${requirement.labelOrFallback} max file size must be positive',
          ),
        );
      }

      final minDuration = requirement.minAudioDurationMilliseconds;
      if (minDuration != null && minDuration <= 0) {
        issues.add(
          SurveyReadinessIssue.blocker(
            '${requirement.labelOrFallback} minimum audio duration must be positive',
          ),
        );
      }

      final maxAccuracy = requirement.maxLocationAccuracyMeters;
      if (maxAccuracy != null && maxAccuracy <= 0) {
        issues.add(
          SurveyReadinessIssue.blocker(
            '${requirement.labelOrFallback} max location accuracy must be positive',
          ),
        );
      }
    }

    return issues;
  }

  static List<SurveyReadinessIssue> _validateVisibilityRule({
    required Question question,
    required int questionIndex,
    required QuestionVisibilityRule rule,
    required List<Question> questions,
    required Map<String, Question> questionsById,
  }) {
    final issues = <SurveyReadinessIssue>[];
    final sourceQuestion = questionsById[rule.sourceQuestionId];

    if (sourceQuestion == null) {
      return [
        SurveyReadinessIssue.blocker(
          '${question.textOrFallback} has a visibility rule linked to a missing question',
        ),
      ];
    }

    if (sourceQuestion.id == question.id) {
      issues.add(
        SurveyReadinessIssue.blocker(
          '${question.textOrFallback} cannot depend on itself',
        ),
      );
    }

    final sourceIndex = questions.indexWhere(
      (candidate) => candidate.id == sourceQuestion.id,
    );
    if (sourceIndex > questionIndex) {
      issues.add(
        SurveyReadinessIssue.blocker(
          '${question.textOrFallback} must depend on an earlier question',
        ),
      );
    }

    if (rule.operator.needsValue && !_hasRuleValue(rule.value)) {
      issues.add(
        SurveyReadinessIssue.blocker(
          '${question.textOrFallback} has an incomplete visibility condition',
        ),
      );
    }

    if (rule.operator.usesNumericValue &&
        sourceQuestion.type != QuestionType.number &&
        sourceQuestion.type != QuestionType.rating) {
      issues.add(
        SurveyReadinessIssue.blocker(
          '${question.textOrFallback} uses a numeric condition on a non-numeric question',
        ),
      );
    }

    return issues;
  }

  static bool _hasRuleValue(dynamic value) {
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

class SurveyReadinessResult {
  final Survey survey;
  final List<SurveyReadinessIssue> issues;

  const SurveyReadinessResult({required this.survey, required this.issues});

  bool get hasBlockers =>
      issues.any((issue) => issue.severity == SurveyReadinessSeverity.blocker);

  bool get hasWarnings =>
      issues.any((issue) => issue.severity == SurveyReadinessSeverity.warning);

  bool get canCollect => !hasBlockers;

  List<SurveyReadinessIssue> get blockers => issues
      .where((issue) => issue.severity == SurveyReadinessSeverity.blocker)
      .toList();

  List<SurveyReadinessIssue> get warnings => issues
      .where((issue) => issue.severity == SurveyReadinessSeverity.warning)
      .toList();

  String get summary {
    if (hasBlockers) {
      return '${blockers.length} blockers';
    }

    if (hasWarnings) {
      return '${warnings.length} warnings';
    }

    return 'Ready';
  }
}

class SurveyReadinessIssue {
  final SurveyReadinessSeverity severity;
  final String message;

  const SurveyReadinessIssue({required this.severity, required this.message});

  const SurveyReadinessIssue.blocker(String message)
    : this(severity: SurveyReadinessSeverity.blocker, message: message);

  const SurveyReadinessIssue.warning(String message)
    : this(severity: SurveyReadinessSeverity.warning, message: message);
}

enum SurveyReadinessSeverity { blocker, warning }

extension _QuestionReadinessDetails on Question {
  String get textOrFallback {
    final label = text.trim();
    return label.isEmpty ? 'Question' : label;
  }
}
