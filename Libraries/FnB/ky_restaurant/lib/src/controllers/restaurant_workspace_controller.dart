import 'package:flutter/foundation.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_reservation.dart';
import '../repositories/restaurant_snapshot_repository.dart';
import '../services/restaurant_workspace_command_mutator.dart';
import '../services/workspace_mutation_state_reducer.dart';
import 'restaurant_workspace_state.dart';

class RestaurantWorkspaceController extends ChangeNotifier {
  RestaurantWorkspaceController({
    required RestaurantSnapshotRepository repository,
    RestaurantWorkspaceState initialState = const RestaurantWorkspaceState(),
    RestaurantWorkspaceCommandMutator commandMutator =
        const RestaurantWorkspaceCommandMutator(),
    RestaurantWorkspaceMutationStateReducer mutationStateReducer =
        const RestaurantWorkspaceMutationStateReducer(),
  }) : this._(repository, initialState, commandMutator, mutationStateReducer);

  RestaurantWorkspaceController._(
    this._repository,
    this._state,
    this._commandMutator,
    this._mutationStateReducer,
  );

  RestaurantSnapshotRepository _repository;
  RestaurantWorkspaceState _state;
  final RestaurantWorkspaceCommandMutator _commandMutator;
  final RestaurantWorkspaceMutationStateReducer _mutationStateReducer;
  bool _disposed = false;

  RestaurantWorkspaceState get state => _state;

  RestaurantSnapshotRepository get repository => _repository;

  set repository(RestaurantSnapshotRepository value) {
    if (identical(_repository, value)) return;
    _repository = value;
    load(forceRefresh: true);
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_state.status == RestaurantWorkspaceLoadStatus.loading) return;
    if (!forceRefresh && _state.status == RestaurantWorkspaceLoadStatus.ready) {
      return;
    }

    final previousSnapshot = _state.snapshot;
    _setState(
      RestaurantWorkspaceState.loading(
        previousSnapshot: previousSnapshot,
        previousActivities: _state.activities,
      ),
    );

    try {
      final snapshot = await _repository.fetchSnapshot();
      if (_disposed) return;

      if (snapshot == null) {
        _setState(const RestaurantWorkspaceState.empty());
        return;
      }

      _setState(
        RestaurantWorkspaceState.ready(
          snapshot: snapshot,
          activities: _state.activities,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (error) {
      if (_disposed) return;

      _setState(
        RestaurantWorkspaceState.error(
          message: error.toString(),
          previousSnapshot: previousSnapshot,
          previousActivities: _state.activities,
        ),
      );
    }
  }

  Future<void> refresh() => load(forceRefresh: true);

  void replaceSnapshot(RestaurantOperatingSnapshot snapshot) {
    _setState(
      RestaurantWorkspaceState.ready(
        snapshot: snapshot,
        activities: _state.activities,
        updatedAt: DateTime.now(),
      ),
    );
  }

  bool updateZoneStatus(String zoneId, RestaurantServiceStatus status) {
    return _applyMutation(
      (snapshot, now) => _commandMutator.updateZoneStatus(
        snapshot: snapshot,
        zoneId: zoneId,
        status: status,
        now: now,
      ),
    );
  }

  bool updateStationStatus(String stationId, RestaurantServiceStatus status) {
    return _applyMutation(
      (snapshot, now) => _commandMutator.updateStationStatus(
        snapshot: snapshot,
        stationId: stationId,
        status: status,
        now: now,
      ),
    );
  }

  bool updateReservationStatus(
    String reservationId,
    RestaurantReservationStatus status,
  ) {
    return _applyMutation(
      (snapshot, now) => _commandMutator.updateReservationStatus(
        snapshot: snapshot,
        reservationId: reservationId,
        status: status,
        now: now,
      ),
    );
  }

  bool completeTask(String taskId) {
    return _applyMutation(
      (snapshot, now) => _commandMutator.completeTask(
        snapshot: snapshot,
        taskId: taskId,
        now: now,
      ),
    );
  }

  bool resolveMenuRisk(String menuSignalId) {
    return _applyMutation(
      (snapshot, now) => _commandMutator.resolveMenuRisk(
        snapshot: snapshot,
        menuSignalId: menuSignalId,
        now: now,
      ),
    );
  }

  bool reviewCatalogItem(String menuItemId) {
    return _applyMutation(
      (snapshot, now) => _commandMutator.reviewCatalogItem(
        snapshot: snapshot,
        menuItemId: menuItemId,
        now: now,
      ),
    );
  }

  bool reviewRecipeProduction(String recipeId) {
    return _applyMutation(
      (snapshot, now) => _commandMutator.reviewRecipeProduction(
        snapshot: snapshot,
        recipeId: recipeId,
        now: now,
      ),
    );
  }

  bool undoLastAction() {
    final undoEntry = _state.undoEntry;
    if (undoEntry == null) return false;

    _setState(
      RestaurantWorkspaceState.ready(
        snapshot: undoEntry.snapshot,
        activities: undoEntry.activities,
        updatedAt: DateTime.now(),
      ),
    );
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _setState(RestaurantWorkspaceState nextState) {
    if (_disposed) return;
    _state = nextState;
    notifyListeners();
  }

  bool _applyMutation(
    RestaurantWorkspaceMutation? Function(
      RestaurantOperatingSnapshot snapshot,
      DateTime now,
    )
    buildMutation,
  ) {
    final current = _state.snapshot;
    if (current == null) return false;
    final now = DateTime.now();
    final mutation = buildMutation(current, now);
    if (mutation == null) return false;

    _setState(
      _mutationStateReducer.reduce(
        previousSnapshot: current,
        previousActivities: _state.activities,
        mutation: mutation,
        now: now,
      ),
    );
    return true;
  }
}
