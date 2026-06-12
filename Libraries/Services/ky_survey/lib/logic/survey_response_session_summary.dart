import '../models/answer.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../validation/survey_response_validator.dart';

class SurveyResponseSessionSummary {
  final SurveyResponse response;
  final SurveyResponseValidationResult validation;
  final DateTime now;

  const SurveyResponseSessionSummary({
    required this.response,
    required this.validation,
    required this.now,
  });

  factory SurveyResponseSessionSummary.evaluate({
    required Survey survey,
    required SurveyResponse response,
    DateTime? now,
  }) {
    return SurveyResponseSessionSummary(
      response: response,
      validation: SurveyResponseValidator.validate(
        questions: survey.questions,
        response: response,
      ),
      now: now ?? DateTime.now(),
    );
  }

  List<Question> get visibleQuestions => validation.visibleQuestions;

  List<SurveyResponseValidationIssue> get issues => validation.issues;

  bool get isValid => validation.isValid;

  bool get isSubmitted => response.status == SurveyResponseStatus.submitted;

  bool get canSubmit =>
      !isSubmitted && visibleQuestionCount > 0 && validation.isValid;

  int get visibleQuestionCount => visibleQuestions.length;

  int get answeredQuestionCount {
    return visibleQuestions
        .where(
          (question) =>
              ResponseAnswer.hasMeaningfulValue(response.valueFor(question.id)),
        )
        .length;
  }

  int get requiredQuestionCount {
    return visibleQuestions.where((question) => question.required).length;
  }

  int get answeredRequiredQuestionCount {
    return visibleQuestions
        .where(
          (question) =>
              question.required &&
              ResponseAnswer.hasMeaningfulValue(response.valueFor(question.id)),
        )
        .length;
  }

  int get missingRequiredCount => validation.requiredIssues.length;

  int get invalidIssueCount => issues.length - missingRequiredCount;

  double get completionRate => response.completionRate(visibleQuestions);

  int get completionPercent => (completionRate * 100).round();

  Duration get sessionDuration {
    final end = response.submittedAt ?? now;
    final duration = end.difference(response.startedAt);
    if (duration.isNegative) {
      return Duration.zero;
    }

    return duration;
  }

  DateTime? get lastAnsweredAt {
    DateTime? latest;
    for (final answer in response.answers) {
      if (latest == null || answer.answeredAt.isAfter(latest)) {
        latest = answer.answeredAt;
      }
    }

    return latest;
  }

  String get primaryStatusLabel {
    if (isSubmitted) {
      return 'Submitted';
    }

    if (visibleQuestionCount == 0) {
      return 'No questions';
    }

    if (invalidIssueCount > 0) {
      return _plural(invalidIssueCount, 'answer issue');
    }

    if (missingRequiredCount > 0) {
      return _plural(
        missingRequiredCount,
        'required missing',
        'required missing',
      );
    }

    if (canSubmit) {
      return 'Ready to submit';
    }

    return '$answeredQuestionCount of $visibleQuestionCount answered';
  }

  String get secondaryStatusLabel {
    final savedLabel = lastAnsweredAt == null
        ? 'No answers yet'
        : 'Last saved ${_formatClock(lastAnsweredAt!)}';
    return '$savedLabel • ${_formatDuration(sessionDuration)} session';
  }

  String get requiredProgressLabel {
    if (requiredQuestionCount == 0) {
      return 'No required questions';
    }

    return '$answeredRequiredQuestionCount of $requiredQuestionCount required answered';
  }

  String? get firstIssueMessage => validation.firstIssue?.message;

  static String _plural(int count, String singular, [String? plural]) {
    return count == 1 ? '1 $singular' : '$count ${plural ?? '${singular}s'}';
  }

  static String _formatClock(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) {
      return '<1m';
    }

    if (minutes < 60) {
      return '${minutes}m';
    }

    final hours = duration.inHours;
    final remainingMinutes = minutes % 60;
    if (hours < 24) {
      return remainingMinutes == 0
          ? '${hours}h'
          : '${hours}h ${remainingMinutes}m';
    }

    final days = duration.inDays;
    final remainingHours = hours % 24;
    return remainingHours == 0 ? '${days}d' : '${days}d ${remainingHours}h';
  }
}
