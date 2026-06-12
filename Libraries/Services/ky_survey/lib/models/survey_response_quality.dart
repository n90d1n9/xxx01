import 'question.dart';
import 'survey.dart';
import 'survey_response.dart';

enum SurveyResponseQualitySignalType {
  validationIssue,
  lowCompletion,
  tooFast,
  staleDraft,
  hiddenAnswer,
  unknownQuestionAnswer,
}

enum SurveyResponseQualitySeverity { info, warning, critical }

class SurveyResponseQualitySignal {
  final Survey survey;
  final SurveyResponse response;
  final Question? question;
  final SurveyResponseQualitySignalType type;
  final SurveyResponseQualitySeverity severity;
  final String message;

  const SurveyResponseQualitySignal({
    required this.survey,
    required this.response,
    required this.type,
    required this.severity,
    required this.message,
    this.question,
  });
}

class SurveyResponseQualitySummary {
  final Survey survey;
  final int responseCount;
  final int flaggedResponseCount;
  final int signalCount;
  final int criticalSignalCount;

  const SurveyResponseQualitySummary({
    required this.survey,
    required this.responseCount,
    required this.flaggedResponseCount,
    required this.signalCount,
    required this.criticalSignalCount,
  });
}
