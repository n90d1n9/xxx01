import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/gantt_chart_workspace_preferences_repository.dart';
import '../services/gantt_chart_workspace_preferences_service.dart';
import '../services/gantt_timeline_range_preset_service.dart';
import 'gantt_chart_display_provider.dart';
import 'gantt_chart_interaction_provider.dart';

final ganttChartWorkspacePreferencesRepositoryProvider =
    Provider<GanttChartWorkspacePreferencesRepository>((ref) {
      return GanttChartWorkspacePreferencesRepository(
        store: LocalDbGanttChartWorkspacePreferencesSnapshotStore(),
      );
    });

final ganttChartWorkspacePreferencesProvider = StateNotifierProvider<
  GanttChartWorkspacePreferencesNotifier,
  GanttChartWorkspacePreferences
>((ref) {
  return GanttChartWorkspacePreferencesNotifier(
    repository: ref.watch(ganttChartWorkspacePreferencesRepositoryProvider),
  );
});

final ganttChartWorkspacePreferencesHydrationProvider = FutureProvider<void>((
  ref,
) {
  return ref.read(ganttChartWorkspacePreferencesProvider.notifier).hydrate();
});

final ganttChartDisplayPreferencesProvider =
    Provider<GanttChartDisplayPreferences>((ref) {
      return ref
          .watch(ganttChartWorkspacePreferencesProvider)
          .displayPreferences;
    });

final ganttChartInteractionPreferencesProvider =
    Provider<GanttChartInteractionPreferences>((ref) {
      return ref
          .watch(ganttChartWorkspacePreferencesProvider)
          .interactionPreferences;
    });

final ganttChartTimelineRangePresetProvider =
    Provider<GanttTimelineRangePreset>((ref) {
      return ref.watch(ganttChartWorkspacePreferencesProvider).rangePreset;
    });

final ganttChartControlsExpandedProvider = Provider<bool>((ref) {
  return ref.watch(ganttChartWorkspacePreferencesProvider).controlsExpanded;
});

class GanttChartWorkspacePreferencesNotifier
    extends StateNotifier<GanttChartWorkspacePreferences> {
  GanttChartWorkspacePreferencesNotifier({
    GanttChartWorkspacePreferencesRepository? repository,
  }) : _repository = repository,
       super(GanttChartWorkspacePreferences.initial);

  final GanttChartWorkspacePreferencesRepository? _repository;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  var _hasLocalMutations = false;

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromRepository();
  }

  Future<void> flushPersistence() {
    return _persistFuture ?? Future<void>.value();
  }

  void setDisplayPreferences(GanttChartDisplayPreferences preferences) {
    _setAndPersist(state.copyWith(displayPreferences: preferences));
  }

  void setInteractionPreferences(GanttChartInteractionPreferences preferences) {
    _setAndPersist(state.copyWith(interactionPreferences: preferences));
  }

  void setTimelineRangePreset(GanttTimelineRangePreset rangePreset) {
    _setAndPersist(state.copyWith(rangePreset: rangePreset));
  }

  void setControlsExpanded(bool controlsExpanded) {
    _setAndPersist(state.copyWith(controlsExpanded: controlsExpanded));
  }

  void resetPreferences() {
    _setAndPersist(GanttChartWorkspacePreferences.initial);
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

  void _setAndPersist(GanttChartWorkspacePreferences nextState) {
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
