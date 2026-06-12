import '../logic/question_visibility_evaluator.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../models/survey_response.dart';

class SurveyResponseValidator {
  const SurveyResponseValidator._();

  static SurveyResponseValidationResult validate({
    required List<Question> questions,
    required SurveyResponse response,
  }) {
    final visibleQuestions = QuestionVisibilityEvaluator.visibleQuestions(
      questions,
      response,
    );
    final issues = <SurveyResponseValidationIssue>[];

    for (final question in visibleQuestions) {
      issues.addAll(
        _validateQuestion(question, response.valueFor(question.id)),
      );
    }

    return SurveyResponseValidationResult(
      response: response,
      visibleQuestions: visibleQuestions,
      issues: issues,
    );
  }

  static List<SurveyResponseValidationIssue> _validateQuestion(
    Question question,
    dynamic value,
  ) {
    final hasValue = ResponseAnswer.hasMeaningfulValue(value);

    if (question.required && !hasValue) {
      return [
        SurveyResponseValidationIssue(
          question: question,
          type: SurveyResponseValidationIssueType.required,
          message: '${question.responseLabel} is required',
        ),
      ];
    }

    if (!hasValue) {
      return const [];
    }

    return switch (question.type) {
      QuestionType.singleChoice => _validateSingleChoice(question, value),
      QuestionType.multipleChoice => _validateMultipleChoice(question, value),
      QuestionType.singleLineText ||
      QuestionType.multiLineText => _validateText(question, value),
      QuestionType.number => _validateNumber(question, value),
      QuestionType.date => _validateDate(question, value),
      QuestionType.rating => _validateRating(question, value),
    };
  }

  static List<SurveyResponseValidationIssue> _validateSingleChoice(
    Question question,
    dynamic value,
  ) {
    final optionIds = _optionIds(question);
    if (value is String && optionIds.contains(value)) {
      return const [];
    }

    return [
      SurveyResponseValidationIssue(
        question: question,
        type: SurveyResponseValidationIssueType.invalidChoice,
        message: '${question.responseLabel} has an invalid option',
      ),
    ];
  }

  static List<SurveyResponseValidationIssue> _validateMultipleChoice(
    Question question,
    dynamic value,
  ) {
    if (value is! Iterable) {
      return [
        SurveyResponseValidationIssue(
          question: question,
          type: SurveyResponseValidationIssueType.invalidChoice,
          message: '${question.responseLabel} has invalid selections',
        ),
      ];
    }

    final optionIds = _optionIds(question);
    final selections = value.map((selection) => selection.toString()).toList();
    final uniqueSelections = selections.toSet();
    if (selections.length != uniqueSelections.length ||
        uniqueSelections.any((selection) => !optionIds.contains(selection))) {
      return [
        SurveyResponseValidationIssue(
          question: question,
          type: SurveyResponseValidationIssueType.invalidChoice,
          message: '${question.responseLabel} has invalid selections',
        ),
      ];
    }

    return const [];
  }

  static List<SurveyResponseValidationIssue> _validateText(
    Question question,
    dynamic value,
  ) {
    if (value is! String) {
      return [
        SurveyResponseValidationIssue(
          question: question,
          type: SurveyResponseValidationIssueType.invalidType,
          message: '${question.responseLabel} must be text',
        ),
      ];
    }

    final maxLength = question.maxLength;
    if (maxLength != null && value.length > maxLength) {
      return [
        SurveyResponseValidationIssue(
          question: question,
          type: SurveyResponseValidationIssueType.outOfRange,
          message:
              '${question.responseLabel} must be $maxLength characters or fewer',
        ),
      ];
    }

    return const [];
  }

  static List<SurveyResponseValidationIssue> _validateNumber(
    Question question,
    dynamic value,
  ) {
    if (_asDouble(value) != null) {
      return const [];
    }

    return [
      SurveyResponseValidationIssue(
        question: question,
        type: SurveyResponseValidationIssueType.invalidType,
        message: '${question.responseLabel} must be a number',
      ),
    ];
  }

  static List<SurveyResponseValidationIssue> _validateDate(
    Question question,
    dynamic value,
  ) {
    if (value is String && DateTime.tryParse(value) != null) {
      return const [];
    }

    return [
      SurveyResponseValidationIssue(
        question: question,
        type: SurveyResponseValidationIssueType.invalidType,
        message: '${question.responseLabel} must be a valid date',
      ),
    ];
  }

  static List<SurveyResponseValidationIssue> _validateRating(
    Question question,
    dynamic value,
  ) {
    final rating = _asDouble(value);
    final minRating = question.minRating ?? 1;
    final maxRating = question.maxRating ?? 5;
    if (rating != null && rating >= minRating && rating <= maxRating) {
      return const [];
    }

    return [
      SurveyResponseValidationIssue(
        question: question,
        type: SurveyResponseValidationIssueType.outOfRange,
        message:
            '${question.responseLabel} must be between $minRating and $maxRating',
      ),
    ];
  }

  static Set<String> _optionIds(Question question) {
    return {for (final option in question.options ?? const []) option.id};
  }

  static double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}

class SurveyResponseValidationResult {
  final SurveyResponse response;
  final List<Question> visibleQuestions;
  final List<SurveyResponseValidationIssue> issues;

  const SurveyResponseValidationResult({
    required this.response,
    required this.visibleQuestions,
    required this.issues,
  });

  bool get isValid => issues.isEmpty;

  SurveyResponseValidationIssue? get firstIssue {
    if (issues.isEmpty) {
      return null;
    }

    return issues.first;
  }

  List<SurveyResponseValidationIssue> get requiredIssues => issues
      .where(
        (issue) => issue.type == SurveyResponseValidationIssueType.required,
      )
      .toList();

  List<SurveyResponseValidationIssue> issuesForQuestion(String questionId) {
    return issues
        .where((issue) => issue.question.id == questionId)
        .toList(growable: false);
  }
}

class SurveyResponseValidationIssue {
  final Question question;
  final SurveyResponseValidationIssueType type;
  final String message;

  const SurveyResponseValidationIssue({
    required this.question,
    required this.type,
    required this.message,
  });
}

enum SurveyResponseValidationIssueType {
  required,
  invalidChoice,
  invalidType,
  outOfRange,
}

extension _QuestionResponseValidationLabel on Question {
  String get responseLabel {
    final label = text.trim();
    return label.isEmpty ? 'Question' : label;
  }
}
