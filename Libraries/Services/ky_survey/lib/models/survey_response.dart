import 'answer.dart';
import 'question.dart';
import 'survey_evidence.dart';
import 'survey_response_review.dart';

enum SurveyResponseStatus { draft, submitted, discarded }

SurveyResponseStatus surveyResponseStatusFromJson(Object? value) {
  if (value is SurveyResponseStatus) {
    return value;
  }

  if (value is String) {
    for (final status in SurveyResponseStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
  }

  return SurveyResponseStatus.draft;
}

class SurveyResponse {
  final String id;
  final String surveyId;
  final String? surveyVersionId;
  final String respondentId;
  final String respondentName;
  final String? collectorId;
  final String? collectorName;
  final SurveyResponseStatus status;
  final SurveyResponseReviewStatus reviewStatus;
  final String? reviewerId;
  final String? reviewerName;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final List<ResponseAnswer> answers;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final List<SurveyEvidence> evidence;
  final Map<String, dynamic> metadata;

  const SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.respondentId,
    required this.respondentName,
    required this.startedAt,
    this.surveyVersionId,
    this.collectorId,
    this.collectorName,
    this.status = SurveyResponseStatus.draft,
    this.reviewStatus = SurveyResponseReviewStatus.pending,
    this.reviewerId,
    this.reviewerName,
    this.reviewedAt,
    this.reviewNote,
    this.answers = const [],
    this.submittedAt,
    this.evidence = const [],
    this.metadata = const {},
  });

  ResponseAnswer? answerFor(String questionId) {
    for (final answer in answers) {
      if (answer.questionId == questionId) {
        return answer;
      }
    }

    return null;
  }

  dynamic valueFor(String questionId) => answerFor(questionId)?.value;

  List<SurveyEvidence> get responseEvidence {
    return evidence
        .where((item) => item.scope == SurveyEvidenceScope.response)
        .toList();
  }

  List<SurveyEvidence> evidenceForQuestion(String questionId) {
    return evidence.where((item) => item.questionId == questionId).toList();
  }

  List<SurveyEvidence> evidenceByKind(SurveyEvidenceKind kind) {
    return evidence.where((item) => item.kind == kind).toList();
  }

  double completionRate(List<Question> questions) {
    if (questions.isEmpty) {
      return 0;
    }

    final answered = questions
        .where(
          (question) =>
              ResponseAnswer.hasMeaningfulValue(valueFor(question.id)),
        )
        .length;
    return answered / questions.length;
  }

  List<Question> unansweredRequiredQuestions(List<Question> questions) {
    return questions.where((question) {
      if (!question.required) {
        return false;
      }

      return !ResponseAnswer.hasMeaningfulValue(valueFor(question.id));
    }).toList();
  }

  SurveyResponse upsertAnswer({
    required String questionId,
    required dynamic value,
    DateTime? answeredAt,
  }) {
    final updatedAnswer = ResponseAnswer(
      questionId: questionId,
      value: value,
      answeredAt: answeredAt ?? DateTime.now(),
    );
    final existingIndex = answers.indexWhere(
      (answer) => answer.questionId == questionId,
    );

    if (existingIndex == -1) {
      return copyWith(answers: [...answers, updatedAnswer]);
    }

    final updatedAnswers = [...answers];
    updatedAnswers[existingIndex] = updatedAnswer;
    return copyWith(answers: updatedAnswers);
  }

  SurveyResponse upsertEvidence(SurveyEvidence item) {
    final existingIndex = evidence.indexWhere(
      (evidenceItem) => evidenceItem.id == item.id,
    );

    if (existingIndex == -1) {
      return copyWith(evidence: [...evidence, item]);
    }

    final updatedEvidence = [...evidence];
    updatedEvidence[existingIndex] = item;
    return copyWith(evidence: updatedEvidence);
  }

  SurveyResponse removeEvidence(String evidenceId) {
    return copyWith(
      evidence: evidence
          .where((evidenceItem) => evidenceItem.id != evidenceId)
          .toList(),
    );
  }

  SurveyResponse submit({DateTime? submittedAt, String? surveyVersionId}) {
    return copyWith(
      status: SurveyResponseStatus.submitted,
      reviewStatus: SurveyResponseReviewStatus.pending,
      submittedAt: submittedAt ?? DateTime.now(),
      surveyVersionId: surveyVersionId,
    );
  }

  SurveyResponse review({
    required SurveyResponseReviewStatus status,
    String? reviewerId,
    String? reviewerName,
    String? note,
    DateTime? reviewedAt,
  }) {
    return copyWith(
      reviewStatus: status,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewedAt: reviewedAt ?? DateTime.now(),
      reviewNote: note,
    );
  }

  SurveyResponse copyWith({
    String? id,
    String? surveyId,
    String? surveyVersionId,
    String? respondentId,
    String? respondentName,
    String? collectorId,
    String? collectorName,
    SurveyResponseStatus? status,
    SurveyResponseReviewStatus? reviewStatus,
    String? reviewerId,
    String? reviewerName,
    DateTime? reviewedAt,
    String? reviewNote,
    List<ResponseAnswer>? answers,
    DateTime? startedAt,
    DateTime? submittedAt,
    List<SurveyEvidence>? evidence,
    Map<String, dynamic>? metadata,
  }) {
    return SurveyResponse(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      surveyVersionId: surveyVersionId ?? this.surveyVersionId,
      respondentId: respondentId ?? this.respondentId,
      respondentName: respondentName ?? this.respondentName,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      status: status ?? this.status,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNote: reviewNote ?? this.reviewNote,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      evidence: evidence ?? this.evidence,
      metadata: metadata ?? this.metadata,
    );
  }

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      surveyVersionId: json['surveyVersionId'] as String?,
      respondentId: json['respondentId'] as String? ?? 'anonymous',
      respondentName: json['respondentName'] as String? ?? 'Participant',
      collectorId: json['collectorId'] as String?,
      collectorName: json['collectorName'] as String?,
      status: surveyResponseStatusFromJson(json['status']),
      reviewStatus: surveyResponseReviewStatusFromJson(json['reviewStatus']),
      reviewerId: json['reviewerId'] as String?,
      reviewerName: json['reviewerName'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewNote: json['reviewNote'] as String?,
      answers: (json['answers'] as List? ?? const [])
          .map((answer) => ResponseAnswer.fromJson(answer))
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      evidence: (json['evidence'] as List? ?? const [])
          .map(
            (item) =>
                SurveyEvidence.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'surveyVersionId': surveyVersionId,
      'respondentId': respondentId,
      'respondentName': respondentName,
      'collectorId': collectorId,
      'collectorName': collectorName,
      'status': status.name,
      'reviewStatus': reviewStatus.name,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNote': reviewNote,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'evidence': evidence.map((item) => item.toJson()).toList(),
      'metadata': metadata,
    };
  }
}
