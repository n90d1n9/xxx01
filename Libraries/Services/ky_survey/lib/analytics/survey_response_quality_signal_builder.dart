import '../logic/question_visibility_evaluator.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../models/survey_response_quality.dart';
import '../validation/survey_response_validator.dart';

class SurveyResponseQualitySignalBuilder {
  final Duration minimumCompletionDuration;
  final Duration staleDraftAge;
  final double minimumSubmittedCompletionRate;

  const SurveyResponseQualitySignalBuilder({
    this.minimumCompletionDuration = const Duration(seconds: 30),
    this.staleDraftAge = const Duration(days: 1),
    this.minimumSubmittedCompletionRate = 0.5,
  });

  List<SurveyResponseQualitySignal> signalsForResponse({
    required Survey survey,
    required SurveyResponse response,
    DateTime? now,
  }) {
    final generatedAt = now ?? DateTime.now();
    final signals = <SurveyResponseQualitySignal>[
      ..._validationSignals(survey, response),
      ..._hiddenAnswerSignals(survey, response),
    ];

    if (response.status == SurveyResponseStatus.submitted) {
      signals.addAll(_submittedTimingSignals(survey, response));
      signals.addAll(_completionSignals(survey, response));
    }

    if (response.status == SurveyResponseStatus.draft &&
        generatedAt.difference(response.startedAt) > staleDraftAge) {
      signals.add(
        _signal(
          survey: survey,
          response: response,
          type: SurveyResponseQualitySignalType.staleDraft,
          severity: SurveyResponseQualitySeverity.info,
          message:
              'Draft has been open for more than ${staleDraftAge.inDays} day',
        ),
      );
    }

    return signals;
  }

  List<SurveyResponseQualitySignal> _validationSignals(
    Survey survey,
    SurveyResponse response,
  ) {
    if (response.status != SurveyResponseStatus.submitted) {
      return const [];
    }

    final validation = SurveyResponseValidator.validate(
      questions: survey.questions,
      response: response,
    );

    return validation.issues
        .map((issue) {
          return _signal(
            survey: survey,
            response: response,
            type: SurveyResponseQualitySignalType.validationIssue,
            severity: issue.type == SurveyResponseValidationIssueType.required
                ? SurveyResponseQualitySeverity.warning
                : SurveyResponseQualitySeverity.critical,
            message: issue.message,
            question: issue.question,
          );
        })
        .toList(growable: false);
  }

  List<SurveyResponseQualitySignal> _hiddenAnswerSignals(
    Survey survey,
    SurveyResponse response,
  ) {
    final questionIds = survey.questions.map((question) => question.id).toSet();
    final visibleQuestionIds = QuestionVisibilityEvaluator.visibleQuestions(
      survey.questions,
      response,
    ).map((question) => question.id).toSet();
    final signals = <SurveyResponseQualitySignal>[];

    for (final answer in response.answers) {
      if (!ResponseAnswer.hasMeaningfulValue(answer.value)) {
        continue;
      }

      if (!questionIds.contains(answer.questionId)) {
        signals.add(
          _signal(
            survey: survey,
            response: response,
            type: SurveyResponseQualitySignalType.unknownQuestionAnswer,
            severity: SurveyResponseQualitySeverity.critical,
            message: 'Answer references an unknown question',
          ),
        );
      } else if (!visibleQuestionIds.contains(answer.questionId)) {
        signals.add(
          _signal(
            survey: survey,
            response: response,
            type: SurveyResponseQualitySignalType.hiddenAnswer,
            severity: SurveyResponseQualitySeverity.warning,
            message: 'Answer captured for a hidden question',
            question: _questionById(survey.questions, answer.questionId),
          ),
        );
      }
    }

    return signals;
  }

  List<SurveyResponseQualitySignal> _submittedTimingSignals(
    Survey survey,
    SurveyResponse response,
  ) {
    final submittedAt = response.submittedAt;
    if (submittedAt == null) {
      return const [];
    }

    final duration = submittedAt.difference(response.startedAt);
    if (duration >= minimumCompletionDuration) {
      return const [];
    }

    return [
      _signal(
        survey: survey,
        response: response,
        type: SurveyResponseQualitySignalType.tooFast,
        severity: SurveyResponseQualitySeverity.warning,
        message: 'Submitted unusually quickly',
      ),
    ];
  }

  List<SurveyResponseQualitySignal> _completionSignals(
    Survey survey,
    SurveyResponse response,
  ) {
    final visibleQuestions = QuestionVisibilityEvaluator.visibleQuestions(
      survey.questions,
      response,
    );
    final completionRate = response.completionRate(visibleQuestions);
    if (visibleQuestions.isEmpty ||
        completionRate >= minimumSubmittedCompletionRate) {
      return const [];
    }

    return [
      _signal(
        survey: survey,
        response: response,
        type: SurveyResponseQualitySignalType.lowCompletion,
        severity: SurveyResponseQualitySeverity.warning,
        message: 'Submitted with low completion',
      ),
    ];
  }

  Question? _questionById(List<Question> questions, String questionId) {
    for (final question in questions) {
      if (question.id == questionId) {
        return question;
      }
    }

    return null;
  }

  SurveyResponseQualitySignal _signal({
    required Survey survey,
    required SurveyResponse response,
    required SurveyResponseQualitySignalType type,
    required SurveyResponseQualitySeverity severity,
    required String message,
    Question? question,
  }) {
    return SurveyResponseQualitySignal(
      survey: survey,
      response: response,
      type: type,
      severity: severity,
      message: message,
      question: question,
    );
  }
}
