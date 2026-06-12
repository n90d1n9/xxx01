import '../models/survey.dart';
import '../models/survey_response.dart';
import '../models/survey_response_quality.dart';
import '../logic/survey_response_survey_resolver.dart';
import 'survey_response_quality_signal_builder.dart';

class SurveyResponseQualityInsights {
  final List<Survey> surveys;
  final List<SurveyResponse> responses;
  final Duration minimumCompletionDuration;
  final Duration staleDraftAge;
  final double minimumSubmittedCompletionRate;

  const SurveyResponseQualityInsights({
    required this.surveys,
    required this.responses,
    this.minimumCompletionDuration = const Duration(seconds: 30),
    this.staleDraftAge = const Duration(days: 1),
    this.minimumSubmittedCompletionRate = 0.5,
  });

  SurveyResponseQualitySignalBuilder get _signalBuilder {
    return SurveyResponseQualitySignalBuilder(
      minimumCompletionDuration: minimumCompletionDuration,
      staleDraftAge: staleDraftAge,
      minimumSubmittedCompletionRate: minimumSubmittedCompletionRate,
    );
  }

  SurveyResponseSurveyResolver get _surveyResolver {
    return SurveyResponseSurveyResolver(surveys: surveys);
  }

  List<SurveyResponseQualitySignal> signals({DateTime? now}) {
    final generatedAt = now ?? DateTime.now();
    return responses
        .expand((response) => signalsForResponse(response, now: generatedAt))
        .toList(growable: false);
  }

  List<SurveyResponseQualitySignal> signalsForResponse(
    SurveyResponse response, {
    DateTime? now,
  }) {
    final survey = surveyForResponse(response);
    if (survey == null) {
      return const [];
    }

    return _signalBuilder.signalsForResponse(
      survey: survey,
      response: response,
      now: now,
    );
  }

  int signalCount({DateTime? now}) => signals(now: now).length;

  int warningSignalCount({DateTime? now}) => signals(now: now)
      .where(
        (signal) => signal.severity == SurveyResponseQualitySeverity.warning,
      )
      .length;

  int criticalSignalCount({DateTime? now}) => signals(now: now)
      .where(
        (signal) => signal.severity == SurveyResponseQualitySeverity.critical,
      )
      .length;

  int flaggedResponseCount({DateTime? now}) {
    return signals(now: now).map((signal) => signal.response.id).toSet().length;
  }

  int get submittedResponseCount => responses
      .where((response) => response.status == SurveyResponseStatus.submitted)
      .length;

  int cleanSubmittedResponseCount({DateTime? now}) {
    final flaggedSubmitted = signals(now: now)
        .where(
          (signal) => signal.response.status == SurveyResponseStatus.submitted,
        )
        .map((signal) => signal.response.id)
        .toSet()
        .length;
    return submittedResponseCount - flaggedSubmitted;
  }

  List<SurveyResponseQualitySummary> get summaries {
    return surveys.map(summaryForSurvey).toList(growable: false);
  }

  SurveyResponseQualitySummary summaryForSurvey(
    Survey survey, {
    DateTime? now,
  }) {
    final surveyResponses = responses
        .where((response) => response.surveyId == survey.id)
        .toList(growable: false);
    final surveySignals = surveyResponses
        .expand((response) => signalsForResponse(response, now: now))
        .toList(growable: false);

    return SurveyResponseQualitySummary(
      survey: survey,
      responseCount: surveyResponses.length,
      flaggedResponseCount: surveySignals
          .map((signal) => signal.response.id)
          .toSet()
          .length,
      signalCount: surveySignals.length,
      criticalSignalCount: surveySignals
          .where(
            (signal) =>
                signal.severity == SurveyResponseQualitySeverity.critical,
          )
          .length,
    );
  }

  List<SurveyResponseQualitySignal> reviewQueue({
    int limit = 6,
    DateTime? now,
  }) {
    final queue = signals(now: now)
        .where(
          (signal) => signal.severity != SurveyResponseQualitySeverity.info,
        )
        .toList();
    queue.sort((left, right) {
      final severityCompare = _severityRank(
        right.severity,
      ).compareTo(_severityRank(left.severity));
      if (severityCompare != 0) {
        return severityCompare;
      }

      return right.response.startedAt.compareTo(left.response.startedAt);
    });

    return queue.take(limit).toList(growable: false);
  }

  Survey? surveyForResponse(SurveyResponse response) {
    return _surveyResolver.surveyForResponse(response);
  }

  int _severityRank(SurveyResponseQualitySeverity severity) {
    switch (severity) {
      case SurveyResponseQualitySeverity.info:
        return 0;
      case SurveyResponseQualitySeverity.warning:
        return 1;
      case SurveyResponseQualitySeverity.critical:
        return 2;
    }
  }
}
