import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/project_created_portfolio_repository.dart';
import '../data/project_portfolio_repository.dart';
import '../data/project_portfolio_view_repository.dart';
import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_domain_gap_focus_service.dart';
import '../services/project_form_creation_service.dart';
import '../services/project_priority_service.dart';
import '../services/project_portfolio_query_service.dart';
import '../services/project_portfolio_view_service.dart';
import '../services/project_saved_view_service.dart';
import '../services/project_table_profile_recommendation_service.dart';
import '../services/project_table_view_service.dart';

final projectPortfolioRepositoryProvider = Provider<ProjectPortfolioRepository>(
  (ref) => const ProjectPortfolioRepository(),
);

final projectPortfolioViewRepositoryProvider =
    Provider<ProjectPortfolioViewRepository>((ref) {
      return ProjectPortfolioViewRepository(
        store: LocalDbProjectPortfolioViewSnapshotStore(),
      );
    });

final projectPortfolioViewPreferencesProvider = StateNotifierProvider<
  ProjectPortfolioViewNotifier,
  ProjectPortfolioViewPreferences
>((ref) {
  return ProjectPortfolioViewNotifier(
    repository: ref.watch(projectPortfolioViewRepositoryProvider),
  );
});

final projectPortfolioViewHydrationProvider = FutureProvider<void>((ref) {
  return ref.read(projectPortfolioViewPreferencesProvider.notifier).hydrate();
});

final projectSearchQueryProvider = Provider<String>(
  (ref) => ref.watch(projectPortfolioViewPreferencesProvider).query,
);
final projectHealthFilterProvider = Provider<ProjectHealth?>(
  (ref) => ref.watch(projectPortfolioViewPreferencesProvider).healthFilter,
);
final projectDomainReadinessFilterProvider =
    Provider<ProjectDomainReadinessFilter>(
      (ref) =>
          ref
              .watch(projectPortfolioViewPreferencesProvider)
              .domainReadinessFilter,
    );
final projectDomainGapFocusProvider = Provider<ProjectDomainGapFocus>(
  (ref) => ref.watch(projectPortfolioViewPreferencesProvider).domainGapFocus,
);
final projectSortProvider = Provider<ProjectPortfolioSortOption>(
  (ref) => ref.watch(projectPortfolioViewPreferencesProvider).sortOption,
);
final projectPortfolioViewProvider = Provider<ProjectPortfolioViewPreset>(
  (ref) => ref.watch(projectPortfolioViewPreferencesProvider).viewPreset,
);

final projectTableColumnProfileProvider = Provider<ProjectTableColumnProfile>(
  (ref) =>
      ref.watch(projectPortfolioViewPreferencesProvider).tableColumnProfile,
);

final projectFormCreationServiceProvider = Provider<ProjectFormCreationService>(
  (ref) => const ProjectFormCreationService(),
);

final projectCreatedPortfolioRepositoryProvider =
    Provider<ProjectCreatedPortfolioRepository>((ref) {
      return ProjectCreatedPortfolioRepository(
        store: LocalDbProjectCreatedPortfolioSnapshotStore(),
      );
    });

final createdProjectPortfolioProvider = StateNotifierProvider<
  CreatedProjectPortfolioNotifier,
  List<ProjectPortfolioItem>
>((ref) {
  return CreatedProjectPortfolioNotifier(
    creationService: ref.watch(projectFormCreationServiceProvider),
    repository: ref.watch(projectCreatedPortfolioRepositoryProvider),
  );
});

final createdProjectPortfolioHydrationProvider = FutureProvider<void>((ref) {
  return ref.read(createdProjectPortfolioProvider.notifier).hydrate();
});

final createdProjectPortfolioIdsProvider = Provider<Set<String>>((ref) {
  return Set.unmodifiable(
    ref.watch(createdProjectPortfolioProvider).map((project) => project.id),
  );
});

final projectPortfolioProvider = Provider<List<ProjectPortfolioItem>>((ref) {
  return List.unmodifiable([
    ...ref.watch(projectPortfolioRepositoryProvider).fetchProjects(),
    ...ref.watch(createdProjectPortfolioProvider),
  ]);
});

final filteredProjectPortfolioProvider = Provider<List<ProjectPortfolioItem>>((
  ref,
) {
  final projects = ref.watch(projectPortfolioProvider);
  final preferences = ref.watch(projectPortfolioViewPreferencesProvider);

  return queryProjectPortfolio(
    projects: projects,
    query: ProjectPortfolioQuery.fromPreferences(preferences),
  );
});

final projectByIdProvider = Provider.family<ProjectPortfolioItem?, String>((
  ref,
  projectId,
) {
  for (final project in ref.watch(projectPortfolioProvider)) {
    if (project.id == projectId) return project;
  }
  return null;
});

class ProjectPortfolioViewNotifier
    extends StateNotifier<ProjectPortfolioViewPreferences> {
  ProjectPortfolioViewNotifier({ProjectPortfolioViewRepository? repository})
    : _repository = repository,
      super(ProjectPortfolioViewPreferences.initial);

  final ProjectPortfolioViewRepository? _repository;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  var _hasLocalMutations = false;

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromRepository();
  }

  Future<void> flushPersistence() {
    return _persistFuture ?? Future<void>.value();
  }

  void setSearchQuery(String query) {
    _setAndPersist(state.copyWith(query: query));
  }

  void setHealthFilter(ProjectHealth? health) {
    _setAndPersist(state.copyWith(healthFilter: health));
  }

  void setDomainReadinessFilter(ProjectDomainReadinessFilter filter) {
    final nextState = state.copyWith(domainReadinessFilter: filter);
    _setAndPersist(
      nextState.copyWith(tableColumnProfile: _recommendedProfile(nextState)),
    );
  }

  void setDomainGapFocus(ProjectDomainGapFocus focus) {
    final nextState = state.copyWith(domainGapFocus: focus);
    _setAndPersist(
      nextState.copyWith(
        tableColumnProfile:
            focus == ProjectDomainGapFocus.all
                ? nextState.tableColumnProfile
                : ProjectTableColumnProfile.domainContext,
      ),
    );
  }

  void setSortOption(ProjectPortfolioSortOption sortOption) {
    final nextState = state.copyWith(sortOption: sortOption);
    _setAndPersist(
      nextState.copyWith(tableColumnProfile: _recommendedProfile(nextState)),
    );
  }

  void setViewPreset(ProjectPortfolioViewPreset viewPreset) {
    final nextState = state.copyWith(
      viewPreset: viewPreset,
      sortOption: viewPreset.recommendedSortOption,
      domainGapFocus:
          viewPreset == ProjectPortfolioViewPreset.domainGaps
              ? ProjectDomainGapFocus.missingAny
              : null,
    );
    _setAndPersist(
      nextState.copyWith(tableColumnProfile: _recommendedProfile(nextState)),
    );
  }

  void setTableColumnProfile(ProjectTableColumnProfile profile) {
    _setAndPersist(state.copyWith(tableColumnProfile: profile));
  }

  void resetView() {
    _setAndPersist(ProjectPortfolioViewPreferences.initial);
  }

  ProjectTableColumnProfile _recommendedProfile(
    ProjectPortfolioViewPreferences preferences,
  ) {
    return recommendedProjectTableColumnProfile(
      viewPreset: preferences.viewPreset,
      domainReadinessFilter: preferences.domainReadinessFilter,
      sortOption: preferences.sortOption,
    );
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

  void _setAndPersist(ProjectPortfolioViewPreferences nextState) {
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

class CreatedProjectPortfolioNotifier
    extends StateNotifier<List<ProjectPortfolioItem>> {
  CreatedProjectPortfolioNotifier({
    ProjectFormCreationService creationService =
        const ProjectFormCreationService(),
    ProjectCreatedPortfolioRepository? repository,
  }) : _creationService = creationService,
       _repository = repository,
       super(const []);

  final ProjectFormCreationService _creationService;
  final ProjectCreatedPortfolioRepository? _repository;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  var _hasLocalMutations = false;

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromRepository();
  }

  Future<void> flushPersistence() {
    return _persistFuture ?? Future<void>.value();
  }

  ProjectPortfolioItem createFromDraft({
    required ProjectFormDraft draft,
    required Iterable<ProjectPortfolioItem> existingProjects,
  }) {
    final project = _creationService.createProject(
      draft: draft,
      existingProjects: existingProjects,
    );

    state = List.unmodifiable([...state, project]);
    _hasLocalMutations = true;
    unawaited(_queuePersist());
    return project;
  }

  ProjectPortfolioItem? updateFromDraft({
    required String projectId,
    required ProjectFormDraft draft,
  }) {
    final index = state.indexWhere((project) => project.id == projectId);
    if (index == -1) return null;

    final updatedProject = _creationService.updateProject(
      project: state[index],
      draft: draft,
    );
    final nextProjects = [...state];
    nextProjects[index] = updatedProject;
    state = List.unmodifiable(nextProjects);
    _hasLocalMutations = true;
    unawaited(_queuePersist());
    return updatedProject;
  }

  bool removeById(String projectId) {
    final nextProjects =
        state.where((project) => project.id != projectId).toList();
    if (nextProjects.length == state.length) return false;

    state = List.unmodifiable(nextProjects);
    _hasLocalMutations = true;
    unawaited(_queuePersist());
    return true;
  }

  void clear() {
    state = const [];
    _hasLocalMutations = true;
    unawaited(_queuePersist());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = _repository;
    if (repository == null) return;

    final restoredProjects = await repository.load();
    if (_hasLocalMutations) {
      await _queuePersist();
      return;
    }

    state = restoredProjects;
  }

  Future<void> _queuePersist() {
    final repository = _repository;
    if (repository == null) return Future<void>.value();

    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    final snapshot = state;
    return _persistFuture = pending.then((_) => repository.save(snapshot));
  }
}
