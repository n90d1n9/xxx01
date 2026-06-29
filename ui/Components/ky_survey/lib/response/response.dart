class SurveyResponse {
  final String id;
  final String surveyId;
  final String respondentId;
  final Map<String, dynamic> answers;
  final DateTime submittedAt;
  final Map<String, String>? fileUploads;

  SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.respondentId,
    required this.answers,
    required this.submittedAt,
    this.fileUploads,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surveyId': surveyId,
    'respondentId': respondentId,
    'answers': answers,
    'submittedAt': submittedAt.toIso8601String(),
    'fileUploads': fileUploads,
  };
}


class SurveyResponse {
  final String id;
  final String surveyId;
  final String? respondentId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, Answer> answers;
  final ResponseMetadata metadata;
  final ResponseStatus status;

  SurveyResponse({
    required this.id,
    required this.surveyId,
    this.respondentId,
    required this.startedAt,
    this.completedAt,
    required this.answers,
    required this.metadata,
    required this.status,
  });


class Answer {
  final String questionId;
  final dynamic value;
  final DateTime answeredAt;
  final Map<String, dynamic>? metadata;

  Answer({
    required this.questionId,
    required this.value,
    required this.answeredAt,
    this.metadata,
  });
}