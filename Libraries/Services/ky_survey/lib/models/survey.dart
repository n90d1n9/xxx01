// lib/models/survey.dart
import 'question.dart';
import 'survey_evidence_requirement.dart';
import 'survey_section.dart';
import 'survey_status.dart';
import 'survey_version.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final List<SurveySection> sections;
  final List<Question> questions;
  final List<SurveyEvidenceRequirement> evidenceRequirements;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SurveyStatus status;
  final int responseCount;
  final int targetResponses;
  final DateTime? publishedAt;
  final DateTime? closesAt;
  final String ownerName;
  final List<String> assigneeNames;
  final int currentVersion;
  final String? activeVersionId;
  final List<SurveyVersion> versions;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.createdAt,
    this.sections = const [],
    this.evidenceRequirements = const [],
    this.updatedAt,
    this.status = SurveyStatus.draft,
    this.responseCount = 0,
    this.targetResponses = 0,
    this.publishedAt,
    this.closesAt,
    this.ownerName = 'Admin',
    this.assigneeNames = const [],
    this.currentVersion = 0,
    this.activeVersionId,
    this.versions = const [],
  });

  Survey copyWith({
    String? id,
    String? title,
    String? description,
    List<SurveySection>? sections,
    List<Question>? questions,
    List<SurveyEvidenceRequirement>? evidenceRequirements,
    DateTime? createdAt,
    DateTime? updatedAt,
    SurveyStatus? status,
    int? responseCount,
    int? targetResponses,
    DateTime? publishedAt,
    DateTime? closesAt,
    String? ownerName,
    List<String>? assigneeNames,
    int? currentVersion,
    String? activeVersionId,
    List<SurveyVersion>? versions,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      questions: questions ?? this.questions,
      evidenceRequirements: evidenceRequirements ?? this.evidenceRequirements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      responseCount: responseCount ?? this.responseCount,
      targetResponses: targetResponses ?? this.targetResponses,
      publishedAt: publishedAt ?? this.publishedAt,
      closesAt: closesAt ?? this.closesAt,
      ownerName: ownerName ?? this.ownerName,
      assigneeNames: assigneeNames ?? this.assigneeNames,
      currentVersion: currentVersion ?? this.currentVersion,
      activeVersionId: activeVersionId ?? this.activeVersionId,
      versions: versions ?? this.versions,
    );
  }

  List<SurveySection> get orderedSections {
    final sortedSections = [...sections]
      ..sort((left, right) => left.order.compareTo(right.order));
    return sortedSections;
  }

  List<Question> questionsForSection(String sectionId) {
    return questions
        .where((question) => question.sectionId == sectionId)
        .toList();
  }

  List<Question> get unsectionedQuestions {
    final sectionIds = sections.map((section) => section.id).toSet();
    return questions.where((question) {
      final sectionId = question.sectionId;
      return sectionId == null || !sectionIds.contains(sectionId);
    }).toList();
  }

  SurveySection? sectionForQuestion(Question question) {
    final sectionId = question.sectionId;
    if (sectionId == null) {
      return null;
    }

    for (final section in sections) {
      if (section.id == sectionId) {
        return section;
      }
    }

    return null;
  }

  SurveyVersion? versionById(String versionId) {
    for (final version in versions) {
      if (version.id == versionId) {
        return version;
      }
    }

    return null;
  }

  SurveyVersion? get activeVersion {
    final versionId = activeVersionId;
    if (versionId == null) {
      return null;
    }

    return versionById(versionId);
  }

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sections: (json['sections'] as List? ?? const [])
          .map(
            (section) => SurveySection.fromJson(
              Map<String, dynamic>.from(section as Map),
            ),
          )
          .toList(),
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      evidenceRequirements: (json['evidenceRequirements'] as List? ?? const [])
          .map(
            (requirement) => SurveyEvidenceRequirement.fromJson(
              Map<String, dynamic>.from(requirement as Map),
            ),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      status: surveyStatusFromJson(json['status']),
      responseCount: json['responseCount'] as int? ?? 0,
      targetResponses: json['targetResponses'] as int? ?? 0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      closesAt: json['closesAt'] != null
          ? DateTime.parse(json['closesAt'])
          : null,
      ownerName: json['ownerName'] as String? ?? 'Admin',
      assigneeNames:
          (json['assigneeNames'] as List?)?.cast<String>() ?? const [],
      currentVersion: json['currentVersion'] as int? ?? 0,
      activeVersionId: json['activeVersionId'] as String?,
      versions: (json['versions'] as List? ?? const [])
          .map(
            (version) => SurveyVersion.fromJson(
              Map<String, dynamic>.from(version as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sections': sections.map((section) => section.toJson()).toList(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'evidenceRequirements': evidenceRequirements
          .map((requirement) => requirement.toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.name,
      'responseCount': responseCount,
      'targetResponses': targetResponses,
      'publishedAt': publishedAt?.toIso8601String(),
      'closesAt': closesAt?.toIso8601String(),
      'ownerName': ownerName,
      'assigneeNames': assigneeNames,
      'currentVersion': currentVersion,
      'activeVersionId': activeVersionId,
      'versions': versions.map((version) => version.toJson()).toList(),
    };
  }
}
