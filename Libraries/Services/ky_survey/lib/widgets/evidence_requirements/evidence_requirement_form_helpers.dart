import '../../models/question.dart';
import '../../models/survey_evidence.dart';

String evidenceKindLabel(SurveyEvidenceKind kind) {
  switch (kind) {
    case SurveyEvidenceKind.location:
      return 'GPS location';
    case SurveyEvidenceKind.image:
      return 'Image';
    case SurveyEvidenceKind.audio:
      return 'Audio';
    case SurveyEvidenceKind.file:
      return 'File';
  }
}

String evidenceScopeLabel(SurveyEvidenceScope scope) {
  switch (scope) {
    case SurveyEvidenceScope.response:
      return 'Response';
    case SurveyEvidenceScope.question:
      return 'Question';
  }
}

String evidenceQuestionLabel(Question question) {
  final label = question.text.trim();
  return label.isEmpty ? 'Untitled question' : label;
}

String bytesToMegabytesText(int? bytes) {
  if (bytes == null) {
    return '';
  }

  return compactNumberText(bytes / (1024 * 1024));
}

String millisecondsToSecondsText(int? milliseconds) {
  if (milliseconds == null) {
    return '';
  }

  return compactNumberText(milliseconds / 1000);
}

String compactNumberText(num? value) {
  if (value == null) {
    return '';
  }

  final asDouble = value.toDouble();
  if (asDouble == asDouble.roundToDouble()) {
    return asDouble.round().toString();
  }

  return asDouble.toStringAsFixed(1);
}

int? megabytesToBytes(String value) {
  final megabytes = positiveDouble(value);
  if (megabytes == null) {
    return null;
  }

  return (megabytes * 1024 * 1024).round();
}

int? secondsToMilliseconds(String value) {
  final seconds = positiveDouble(value);
  if (seconds == null) {
    return null;
  }

  return (seconds * 1000).round();
}

double? positiveDouble(String value) {
  final parsed = double.tryParse(value.trim());
  if (parsed == null || parsed <= 0) {
    return null;
  }

  return parsed;
}
