import '../models/answer.dart';
import '../models/question.dart';
import '../models/question_visibility_rule.dart';
import '../models/survey_response.dart';

class QuestionVisibilityEvaluator {
  const QuestionVisibilityEvaluator._();

  static List<Question> visibleQuestions(
    List<Question> questions,
    SurveyResponse response,
  ) {
    return questions
        .where((question) => isVisible(question, response))
        .toList(growable: false);
  }

  static bool isVisible(Question question, SurveyResponse response) {
    if (question.visibilityRules.isEmpty) {
      return true;
    }

    return question.visibilityRules.every((rule) {
      return matches(rule, response.valueFor(rule.sourceQuestionId));
    });
  }

  static bool matches(QuestionVisibilityRule rule, dynamic answerValue) {
    switch (rule.operator) {
      case QuestionVisibilityOperator.answered:
        return ResponseAnswer.hasMeaningfulValue(answerValue);
      case QuestionVisibilityOperator.unanswered:
        return !ResponseAnswer.hasMeaningfulValue(answerValue);
      case QuestionVisibilityOperator.equals:
        return _equals(answerValue, rule.value);
      case QuestionVisibilityOperator.notEquals:
        return !_equals(answerValue, rule.value);
      case QuestionVisibilityOperator.contains:
        return _contains(answerValue, rule.value);
      case QuestionVisibilityOperator.notContains:
        return !_contains(answerValue, rule.value);
      case QuestionVisibilityOperator.greaterThan:
        return _compare(answerValue, rule.value, (left, right) => left > right);
      case QuestionVisibilityOperator.greaterThanOrEqual:
        return _compare(
          answerValue,
          rule.value,
          (left, right) => left >= right,
        );
      case QuestionVisibilityOperator.lessThan:
        return _compare(answerValue, rule.value, (left, right) => left < right);
      case QuestionVisibilityOperator.lessThanOrEqual:
        return _compare(
          answerValue,
          rule.value,
          (left, right) => left <= right,
        );
    }
  }

  static bool _equals(dynamic left, dynamic right) {
    if (left is Iterable && right is Iterable) {
      final leftValues = left.map((value) => value.toString()).toList();
      final rightValues = right.map((value) => value.toString()).toList();
      if (leftValues.length != rightValues.length) {
        return false;
      }

      for (var index = 0; index < leftValues.length; index += 1) {
        if (leftValues[index] != rightValues[index]) {
          return false;
        }
      }

      return true;
    }

    return left?.toString() == right?.toString();
  }

  static bool _contains(dynamic answerValue, dynamic expectedValue) {
    if (!ResponseAnswer.hasMeaningfulValue(answerValue)) {
      return false;
    }

    final expected = expectedValue?.toString();
    if (expected == null || expected.isEmpty) {
      return false;
    }

    if (answerValue is Iterable) {
      return answerValue.any((value) => value.toString() == expected);
    }

    return answerValue.toString().toLowerCase().contains(
      expected.toLowerCase(),
    );
  }

  static bool _compare(
    dynamic answerValue,
    dynamic expectedValue,
    bool Function(double left, double right) test,
  ) {
    final left = _asDouble(answerValue);
    final right = _asDouble(expectedValue);
    if (left == null || right == null) {
      return false;
    }

    return test(left, right);
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
