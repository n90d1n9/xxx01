import 'question.dart';
import 'survey_evidence_requirement.dart';
import 'survey_section.dart';

class SurveyVersion {
  final String id;
  final String surveyId;
  final int versionNumber;
  final String title;
  final String description;
  final List<SurveySection> sections;
  final List<Question> questions;
  final List<SurveyEvidenceRequirement> evidenceRequirements;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String? note;

  const SurveyVersion({
    required this.id,
    required this.surveyId,
    required this.versionNumber,
    required this.title,
    required this.description,
    required this.sections,
    required this.questions,
    this.evidenceRequirements = const [],
    required this.createdAt,
    this.publishedAt,
    this.note,
  });

  SurveyVersion copyWith({
    String? id,
    String? surveyId,
    int? versionNumber,
    String? title,
    String? description,
    List<SurveySection>? sections,
    List<Question>? questions,
    List<SurveyEvidenceRequirement>? evidenceRequirements,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? note,
  }) {
    return SurveyVersion(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      versionNumber: versionNumber ?? this.versionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      questions: questions ?? this.questions,
      evidenceRequirements: evidenceRequirements ?? this.evidenceRequirements,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      note: note ?? this.note,
    );
  }

  factory SurveyVersion.fromJson(Map<String, dynamic> json) {
    return SurveyVersion(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      versionNumber: json['versionNumber'] as int? ?? 1,
      title: json['title'] as String? ?? 'Untitled survey',
      description: json['description'] as String? ?? '',
      sections: (json['sections'] as List? ?? const [])
          .map(
            (section) => SurveySection.fromJson(
              Map<String, dynamic>.from(section as Map),
            ),
          )
          .toList(),
      questions: (json['questions'] as List? ?? const [])
          .map(
            (question) =>
                Question.fromJson(Map<String, dynamic>.from(question as Map)),
          )
          .toList(),
      evidenceRequirements: (json['evidenceRequirements'] as List? ?? const [])
          .map(
            (requirement) => SurveyEvidenceRequirement.fromJson(
              Map<String, dynamic>.from(requirement as Map),
            ),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'versionNumber': versionNumber,
      'title': title,
      'description': description,
      'sections': sections.map((section) => section.toJson()).toList(),
      'questions': questions.map((question) => question.toJson()).toList(),
      'evidenceRequirements': evidenceRequirements
          .map((requirement) => requirement.toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'note': note,
    };
  }
}
