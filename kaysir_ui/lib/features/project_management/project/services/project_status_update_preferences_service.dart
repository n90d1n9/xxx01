import 'project_status_update_service.dart';

class ProjectStatusUpdatePreferenceSelection {
  const ProjectStatusUpdatePreferenceSelection({
    required this.vocabularyId,
    required this.audienceId,
  });

  static const defaultVocabularyId = 'general';
  static const defaultAudienceId = 'stakeholder';

  static const initial = ProjectStatusUpdatePreferenceSelection(
    vocabularyId: defaultVocabularyId,
    audienceId: defaultAudienceId,
  );

  final String vocabularyId;
  final String audienceId;

  ProjectStatusUpdatePreferenceSelection copyWith({
    String? vocabularyId,
    String? audienceId,
  }) {
    return ProjectStatusUpdatePreferenceSelection(
      vocabularyId: vocabularyId ?? this.vocabularyId,
      audienceId: audienceId ?? this.audienceId,
    );
  }

  Map<String, Object?> toJson() {
    return {'vocabularyId': vocabularyId, 'audienceId': audienceId};
  }

  factory ProjectStatusUpdatePreferenceSelection.fromJson(
    Map<String, Object?> json, {
    ProjectStatusUpdatePreferenceSelection fallback = initial,
  }) {
    final vocabularyId =
        _nonEmptyString(json['vocabularyId']) ?? fallback.vocabularyId;
    final audienceId =
        _nonEmptyString(json['audienceId']) ?? fallback.audienceId;

    return ProjectStatusUpdatePreferenceSelection(
      vocabularyId: vocabularyId,
      audienceId: audienceId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectStatusUpdatePreferenceSelection &&
        other.vocabularyId == vocabularyId &&
        other.audienceId == audienceId;
  }

  @override
  int get hashCode => Object.hash(vocabularyId, audienceId);
}

class ProjectStatusUpdatePreferences {
  const ProjectStatusUpdatePreferences({
    required this.vocabularyId,
    required this.audienceId,
    this.projectSelections = const {},
  });

  static const defaultVocabularyId =
      ProjectStatusUpdatePreferenceSelection.defaultVocabularyId;
  static const defaultAudienceId =
      ProjectStatusUpdatePreferenceSelection.defaultAudienceId;

  static const initial = ProjectStatusUpdatePreferences(
    vocabularyId: defaultVocabularyId,
    audienceId: defaultAudienceId,
  );

  final String vocabularyId;
  final String audienceId;
  final Map<String, ProjectStatusUpdatePreferenceSelection> projectSelections;

  ProjectStatusUpdatePreferenceSelection get defaultSelection {
    return ProjectStatusUpdatePreferenceSelection(
      vocabularyId: vocabularyId,
      audienceId: audienceId,
    );
  }

  ProjectStatusUpdatePreferenceSelection selectionForProject(String projectId) {
    final normalizedProjectId = _nonEmptyString(projectId);
    if (normalizedProjectId == null) return defaultSelection;

    return projectSelections[normalizedProjectId] ?? defaultSelection;
  }

  ProjectStatusUpdatePreferences copyWith({
    String? vocabularyId,
    String? audienceId,
    Map<String, ProjectStatusUpdatePreferenceSelection>? projectSelections,
  }) {
    return ProjectStatusUpdatePreferences(
      vocabularyId: vocabularyId ?? this.vocabularyId,
      audienceId: audienceId ?? this.audienceId,
      projectSelections:
          Map<String, ProjectStatusUpdatePreferenceSelection>.unmodifiable(
            projectSelections ?? this.projectSelections,
          ),
    );
  }

  ProjectStatusUpdatePreferences withProjectSelection({
    required String projectId,
    required ProjectStatusUpdatePreferenceSelection selection,
  }) {
    final normalizedProjectId = _nonEmptyString(projectId);
    if (normalizedProjectId == null) return this;

    return copyWith(
      projectSelections: {...projectSelections, normalizedProjectId: selection},
    );
  }

  ProjectStatusUpdatePreferences withoutProjectSelection(String projectId) {
    final normalizedProjectId = _nonEmptyString(projectId);
    if (normalizedProjectId == null ||
        !projectSelections.containsKey(normalizedProjectId)) {
      return this;
    }

    final nextSelections = {...projectSelections}..remove(normalizedProjectId);

    return copyWith(projectSelections: nextSelections);
  }

  Map<String, Object?> toJson() {
    return {
      'vocabularyId': vocabularyId,
      'audienceId': audienceId,
      if (projectSelections.isNotEmpty)
        'projectSelections': {
          for (final entry in projectSelections.entries)
            entry.key: entry.value.toJson(),
        },
    };
  }

  factory ProjectStatusUpdatePreferences.fromJson(Map<String, Object?> json) {
    final defaultSelection = ProjectStatusUpdatePreferenceSelection.fromJson(
      json,
    );

    return ProjectStatusUpdatePreferences(
      vocabularyId: defaultSelection.vocabularyId,
      audienceId: defaultSelection.audienceId,
      projectSelections: _projectSelectionsFromJson(
        json['projectSelections'],
        fallback: defaultSelection,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectStatusUpdatePreferences &&
        other.vocabularyId == vocabularyId &&
        other.audienceId == audienceId &&
        _selectionMapsEqual(other.projectSelections, projectSelections);
  }

  @override
  int get hashCode {
    return Object.hash(
      vocabularyId,
      audienceId,
      _projectSelectionsHash(projectSelections),
    );
  }
}

ProjectStatusUpdateVocabulary resolveStatusUpdateVocabulary({
  required Iterable<ProjectStatusUpdateVocabulary> availableVocabularies,
  required String vocabularyId,
  ProjectStatusUpdateVocabulary fallback =
      ProjectStatusUpdateVocabulary.general,
}) {
  final vocabularies = availableVocabularies.toList(growable: false);
  if (vocabularies.isEmpty) return fallback;

  for (final vocabulary in vocabularies) {
    if (vocabulary.id == vocabularyId) return vocabulary;
  }

  for (final vocabulary in vocabularies) {
    if (vocabulary.id == fallback.id) return vocabulary;
  }

  return vocabularies.first;
}

ProjectStatusUpdateAudience resolveStatusUpdateAudience({
  required Iterable<ProjectStatusUpdateAudience> availableAudiences,
  required String audienceId,
  ProjectStatusUpdateAudience fallback =
      ProjectStatusUpdateAudience.stakeholder,
}) {
  final audiences = availableAudiences.toList(growable: false);
  if (audiences.isEmpty) return fallback;

  for (final audience in audiences) {
    if (audience.id == audienceId) return audience;
  }

  for (final audience in audiences) {
    if (audience.id == fallback.id) return audience;
  }

  return audiences.first;
}

String? _nonEmptyString(Object? value) {
  if (value is! String) return null;

  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

Map<String, ProjectStatusUpdatePreferenceSelection> _projectSelectionsFromJson(
  Object? value, {
  required ProjectStatusUpdatePreferenceSelection fallback,
}) {
  if (value is! Map) return const {};

  final selections = <String, ProjectStatusUpdatePreferenceSelection>{};
  for (final entry in value.entries) {
    final projectId = _nonEmptyString(entry.key);
    final rawSelection = entry.value;
    if (projectId == null || rawSelection is! Map) continue;

    selections[projectId] = ProjectStatusUpdatePreferenceSelection.fromJson(
      Map<String, Object?>.from(rawSelection),
      fallback: fallback,
    );
  }

  return Map<String, ProjectStatusUpdatePreferenceSelection>.unmodifiable(
    selections,
  );
}

bool _selectionMapsEqual(
  Map<String, ProjectStatusUpdatePreferenceSelection> left,
  Map<String, ProjectStatusUpdatePreferenceSelection> right,
) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;

  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }

  return true;
}

int _projectSelectionsHash(
  Map<String, ProjectStatusUpdatePreferenceSelection> selections,
) {
  final keys = selections.keys.toList()..sort();
  return Object.hashAll([
    for (final key in keys) Object.hash(key, selections[key]),
  ]);
}
