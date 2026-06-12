import '../models/question.dart';
import '../models/survey_response.dart';
import 'question_visibility_evaluator.dart';

class SurveyResponseAnswerSanitizer {
  const SurveyResponseAnswerSanitizer._();

  static SurveyResponseAnswerSanitization sanitize({
    required List<Question> questions,
    required SurveyResponse response,
  }) {
    var current = response;
    final removedQuestionIds = <String>{};

    for (var pass = 0; pass <= questions.length; pass += 1) {
      final visibleQuestionIds = QuestionVisibilityEvaluator.visibleQuestions(
        questions,
        current,
      ).map((question) => question.id).toSet();
      final keptAnswers = current.answers
          .where((answer) => visibleQuestionIds.contains(answer.questionId))
          .toList(growable: false);

      if (keptAnswers.length == current.answers.length) {
        return SurveyResponseAnswerSanitization(
          response: current,
          removedQuestionIds: removedQuestionIds,
        );
      }

      for (final answer in current.answers) {
        if (!visibleQuestionIds.contains(answer.questionId)) {
          removedQuestionIds.add(answer.questionId);
        }
      }

      current = current.copyWith(answers: keptAnswers);
    }

    return SurveyResponseAnswerSanitization(
      response: current,
      removedQuestionIds: removedQuestionIds,
    );
  }

  static SurveyResponse pruneHiddenAnswers({
    required List<Question> questions,
    required SurveyResponse response,
  }) {
    return sanitize(questions: questions, response: response).response;
  }
}

class SurveyResponseAnswerSanitization {
  final SurveyResponse response;
  final Set<String> removedQuestionIds;

  const SurveyResponseAnswerSanitization({
    required this.response,
    required this.removedQuestionIds,
  });

  bool get changed => removedQuestionIds.isNotEmpty;

  int get removedAnswerCount => removedQuestionIds.length;
}
