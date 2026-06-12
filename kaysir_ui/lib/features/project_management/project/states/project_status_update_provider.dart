import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/project_status_update_preferences_repository.dart';
import '../services/project_status_update_domain_profile_service.dart';
import '../services/project_status_update_preferences_service.dart';
import '../services/project_status_update_service.dart';
import 'project_portfolio_provider.dart';

final projectStatusUpdatePreferencesRepositoryProvider =
    Provider<ProjectStatusUpdatePreferencesRepository>((ref) {
      return ProjectStatusUpdatePreferencesRepository(
        store: LocalDbProjectStatusUpdatePreferencesSnapshotStore(),
      );
    });

final projectStatusUpdatePreferencesProvider = StateNotifierProvider<
  ProjectStatusUpdatePreferencesNotifier,
  ProjectStatusUpdatePreferences
>((ref) {
  return ProjectStatusUpdatePreferencesNotifier(
    repository: ref.watch(projectStatusUpdatePreferencesRepositoryProvider),
  );
});

final projectStatusUpdatePreferencesHydrationProvider = FutureProvider<void>((
  ref,
) {
  return ref.read(projectStatusUpdatePreferencesProvider.notifier).hydrate();
});

final projectStatusUpdateVocabularyIdProvider = Provider<String>(
  (ref) => ref.watch(projectStatusUpdatePreferencesProvider).vocabularyId,
);

final projectStatusUpdateAudienceIdProvider = Provider<String>(
  (ref) => ref.watch(projectStatusUpdatePreferencesProvider).audienceId,
);

final projectStatusUpdateSelectionForProjectProvider = Provider.family<
  ProjectStatusUpdatePreferenceSelection,
  String
>((ref, projectId) {
  final preferences = ref.watch(projectStatusUpdatePreferencesProvider);
  final normalizedProjectId = _normalizedId(projectId);
  if (normalizedProjectId != null) {
    final projectSelection = preferences.projectSelections[normalizedProjectId];
    if (projectSelection != null) return projectSelection;
  }

  final project =
      normalizedProjectId == null
          ? null
          : ref.watch(projectByIdProvider(normalizedProjectId));
  final domainProfile =
      project == null
          ? null
          : projectStatusUpdateDomainProfileFor(project.businessDomain);
  final useDomainVocabulary =
      preferences.vocabularyId ==
      ProjectStatusUpdatePreferences.defaultVocabularyId;
  final useDomainAudience =
      useDomainVocabulary &&
      preferences.audienceId ==
          ProjectStatusUpdatePreferences.defaultAudienceId;

  return ProjectStatusUpdatePreferenceSelection(
    vocabularyId:
        useDomainVocabulary
            ? domainProfile?.vocabulary.id ?? preferences.vocabularyId
            : preferences.vocabularyId,
    audienceId:
        useDomainAudience
            ? domainProfile?.audience.id ?? preferences.audienceId
            : preferences.audienceId,
  );
});

final projectStatusUpdateVocabularyIdForProjectProvider =
    Provider.family<String, String>((ref, projectId) {
      return ref
          .watch(projectStatusUpdateSelectionForProjectProvider(projectId))
          .vocabularyId;
    });

final projectStatusUpdateAudienceIdForProjectProvider =
    Provider.family<String, String>((ref, projectId) {
      return ref
          .watch(projectStatusUpdateSelectionForProjectProvider(projectId))
          .audienceId;
    });

final selectedProjectStatusUpdateVocabularyProvider =
    Provider<ProjectStatusUpdateVocabulary>((ref) {
      return resolveStatusUpdateVocabulary(
        availableVocabularies: ProjectStatusUpdateVocabulary.defaults,
        vocabularyId: ref.watch(projectStatusUpdateVocabularyIdProvider),
      );
    });

final selectedProjectStatusUpdateAudienceProvider =
    Provider<ProjectStatusUpdateAudience>((ref) {
      return resolveStatusUpdateAudience(
        availableAudiences: ProjectStatusUpdateAudience.values,
        audienceId: ref.watch(projectStatusUpdateAudienceIdProvider),
      );
    });

final selectedProjectStatusUpdateVocabularyForProjectProvider =
    Provider.family<ProjectStatusUpdateVocabulary, String>((ref, projectId) {
      return resolveStatusUpdateVocabulary(
        availableVocabularies: ProjectStatusUpdateVocabulary.defaults,
        vocabularyId: ref.watch(
          projectStatusUpdateVocabularyIdForProjectProvider(projectId),
        ),
      );
    });

final selectedProjectStatusUpdateAudienceForProjectProvider =
    Provider.family<ProjectStatusUpdateAudience, String>((ref, projectId) {
      return resolveStatusUpdateAudience(
        availableAudiences: ProjectStatusUpdateAudience.values,
        audienceId: ref.watch(
          projectStatusUpdateAudienceIdForProjectProvider(projectId),
        ),
      );
    });

class ProjectStatusUpdatePreferencesNotifier
    extends StateNotifier<ProjectStatusUpdatePreferences> {
  ProjectStatusUpdatePreferencesNotifier({
    ProjectStatusUpdatePreferencesRepository? repository,
  }) : _repository = repository,
       super(ProjectStatusUpdatePreferences.initial);

  final ProjectStatusUpdatePreferencesRepository? _repository;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  var _hasLocalMutations = false;

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromRepository();
  }

  Future<void> flushPersistence() {
    return _persistFuture ?? Future<void>.value();
  }

  void setVocabulary(ProjectStatusUpdateVocabulary vocabulary) {
    setVocabularyId(vocabulary.id);
  }

  void setVocabularyId(String vocabularyId) {
    final normalizedVocabularyId = vocabularyId.trim();
    if (normalizedVocabularyId.isEmpty) return;

    _setAndPersist(state.copyWith(vocabularyId: normalizedVocabularyId));
  }

  void setAudience(ProjectStatusUpdateAudience audience) {
    setAudienceId(audience.id);
  }

  void setAudienceId(String audienceId) {
    final normalizedAudienceId = audienceId.trim();
    if (normalizedAudienceId.isEmpty) return;

    _setAndPersist(state.copyWith(audienceId: normalizedAudienceId));
  }

  void setProjectVocabulary({
    required String projectId,
    required ProjectStatusUpdateVocabulary vocabulary,
  }) {
    setProjectVocabularyId(projectId: projectId, vocabularyId: vocabulary.id);
  }

  void setProjectVocabularyId({
    required String projectId,
    required String vocabularyId,
  }) {
    final normalizedProjectId = _normalizedId(projectId);
    final normalizedVocabularyId = _normalizedId(vocabularyId);
    if (normalizedProjectId == null || normalizedVocabularyId == null) return;

    final selection = state
        .selectionForProject(normalizedProjectId)
        .copyWith(vocabularyId: normalizedVocabularyId);
    _setAndPersist(
      state.withProjectSelection(
        projectId: normalizedProjectId,
        selection: selection,
      ),
    );
  }

  void setProjectAudience({
    required String projectId,
    required ProjectStatusUpdateAudience audience,
  }) {
    setProjectAudienceId(projectId: projectId, audienceId: audience.id);
  }

  void setProjectAudienceId({
    required String projectId,
    required String audienceId,
  }) {
    final normalizedProjectId = _normalizedId(projectId);
    final normalizedAudienceId = _normalizedId(audienceId);
    if (normalizedProjectId == null || normalizedAudienceId == null) return;

    final selection = state
        .selectionForProject(normalizedProjectId)
        .copyWith(audienceId: normalizedAudienceId);
    _setAndPersist(
      state.withProjectSelection(
        projectId: normalizedProjectId,
        selection: selection,
      ),
    );
  }

  void resetProject(String projectId) {
    _setAndPersist(state.withoutProjectSelection(projectId));
  }

  void reset() {
    _setAndPersist(ProjectStatusUpdatePreferences.initial);
  }

  Future<void> _hydrateFromRepository() async {
    final repository = _repository;
    if (repository == null) return;

    final restored = await repository.load();
    if (_hasLocalMutations) {
      await _queuePersist();
      return;
    }

    state = restored;
  }

  void _setAndPersist(ProjectStatusUpdatePreferences nextState) {
    if (nextState == state) return;

    state = nextState;
    _hasLocalMutations = true;
    unawaited(_queuePersist());
  }

  Future<void> _queuePersist() {
    final repository = _repository;
    if (repository == null) return Future<void>.value();

    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    final snapshot = state;
    return _persistFuture = pending.then((_) => repository.save(snapshot));
  }
}

String? _normalizedId(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
