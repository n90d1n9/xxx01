import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../data/project_delivery_command_view_repository.dart';
import '../data/project_delivery_saved_lens_repository.dart';
import '../services/project_delivery_command_service.dart';
import '../services/project_delivery_command_view_service.dart';
import '../services/project_delivery_saved_lens_service.dart';
import 'project_portfolio_provider.dart';

final projectDeliveryCommandViewRepositoryProvider =
    Provider<ProjectDeliveryCommandViewRepository>((ref) {
      return ProjectDeliveryCommandViewRepository(
        store: LocalDbProjectDeliveryCommandViewSnapshotStore(),
      );
    });

final projectDeliveryCommandViewProvider = StateNotifierProvider<
  ProjectDeliveryCommandViewNotifier,
  ProjectDeliveryCommandViewPreferences
>((ref) {
  return ProjectDeliveryCommandViewNotifier(
    repository: ref.watch(projectDeliveryCommandViewRepositoryProvider),
  );
});

final projectDeliveryCommandViewHydrationProvider = FutureProvider<void>((ref) {
  return ref.read(projectDeliveryCommandViewProvider.notifier).hydrate();
});

final projectDeliveryCommandFilterProvider =
    Provider<ProjectDeliveryCommandFilter>(
      (ref) => ref.watch(projectDeliveryCommandViewProvider).filter,
    );

final projectDeliveryCommandSummaryProvider =
    Provider<ProjectDeliveryCommandSummary>((ref) {
      final projects = ref.watch(projectPortfolioProvider);
      final tasks = ref.watch(gantt.tasksProvider);

      return buildProjectDeliveryCommandSummary(
        projects: projects,
        tasks: tasks,
      );
    });

final filteredProjectDeliveryCommandsProvider =
    Provider<List<ProjectDeliveryCommand>>((ref) {
      final summary = ref.watch(projectDeliveryCommandSummaryProvider);
      final filter = ref.watch(projectDeliveryCommandFilterProvider);

      return filterProjectDeliveryCommands(
        commands: summary.commands,
        filter: filter,
      );
    });

final projectDeliverySavedLensProfileProvider =
    Provider<ProjectDeliverySavedLensProfile>(
      (ref) => ref.watch(projectDeliveryCommandViewProvider).profile,
    );

final projectDeliverySavedLensRepositoryProvider =
    Provider<ProjectDeliverySavedLensRepository>((ref) {
      return const DemoProjectDeliverySavedLensRepository();
    });

final projectDeliverySavedLensesProvider =
    Provider<List<ProjectDeliverySavedCommandLens>>((ref) {
      final profile = ref.watch(projectDeliverySavedLensProfileProvider);
      final repository = ref.watch(projectDeliverySavedLensRepositoryProvider);

      return repository.fetchSavedLenses(profile: profile);
    });

class ProjectDeliveryCommandViewNotifier
    extends StateNotifier<ProjectDeliveryCommandViewPreferences> {
  ProjectDeliveryCommandViewNotifier({
    ProjectDeliveryCommandViewRepository? repository,
  }) : _repository = repository,
       super(ProjectDeliveryCommandViewPreferences.initial);

  final ProjectDeliveryCommandViewRepository? _repository;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  var _hasLocalMutations = false;

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromRepository();
  }

  Future<void> flushPersistence() {
    return _persistFuture ?? Future<void>.value();
  }

  void setProfile(ProjectDeliverySavedLensProfile profile) {
    _setAndPersist(state.copyWith(profile: profile));
  }

  void setFilter(ProjectDeliveryCommandFilter filter) {
    _setAndPersist(state.copyWith(filter: filter));
  }

  void setLevel(ProjectDeliveryCommandLevel? level) {
    setFilter(state.filter.withLevel(level));
  }

  void setKind(ProjectDeliveryCommandKind? kind) {
    setFilter(state.filter.withKind(kind));
  }

  void resetFilter() {
    setFilter(ProjectDeliveryCommandFilter.empty);
  }

  void resetView() {
    _setAndPersist(ProjectDeliveryCommandViewPreferences.initial);
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

  void _setAndPersist(ProjectDeliveryCommandViewPreferences nextState) {
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
