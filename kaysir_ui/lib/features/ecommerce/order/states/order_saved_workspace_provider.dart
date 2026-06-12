import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/order_active_filter_summary.dart';
import '../models/order_saved_workspace.dart';
import '../models/order_workspace_view.dart';
import '../repositories/order_saved_workspace_repository.dart';

export '../repositories/order_saved_workspace_repository.dart';

final ecommerceOrderSavedWorkspaceRepositoryProvider =
    Provider<OrderSavedWorkspaceRepository>((ref) {
      return OrderSavedWorkspaceRepository(
        store: LocalDbOrderSavedWorkspaceStore(),
      );
    });

final ecommerceOrderSavedWorkspacesProvider = StateNotifierProvider.family<
  OrderSavedWorkspacesNotifier,
  List<OrderSavedWorkspace>,
  String
>((ref, profileId) {
  return OrderSavedWorkspacesNotifier(
    repository: ref.watch(ecommerceOrderSavedWorkspaceRepositoryProvider),
    profileId: profileId,
  );
});

class OrderSavedWorkspacesNotifier
    extends StateNotifier<List<OrderSavedWorkspace>> {
  final OrderSavedWorkspaceRepository repository;
  final String profileId;

  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _hasLocalMutations = false;

  OrderSavedWorkspacesNotifier({
    required this.repository,
    String profileId = ecommerceOrderSavedWorkspaceDefaultProfileId,
    List<OrderSavedWorkspace> initialWorkspaces = const [],
    bool autoHydrate = true,
  }) : profileId = normalizeOrderSavedWorkspaceProfileId(profileId),
       super(List.unmodifiable(initialWorkspaces)) {
    if (autoHydrate) hydrate();
  }

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrate();
  }

  Future<void> saveWorkspace(OrderSavedWorkspace workspace) {
    final nextState = ecommerceOrderSavedWorkspacesWithSaved(state, workspace);
    return _setAndPersist(nextState);
  }

  Future<void> updateWorkspace(OrderSavedWorkspace workspace) {
    final nextState = ecommerceOrderSavedWorkspacesWithDistinctUpdated(
      state,
      workspace,
    );
    return _setAndPersist(nextState);
  }

  Future<void> deleteWorkspace(String workspaceId) {
    final nextState = ecommerceOrderSavedWorkspacesWithout(
      workspaces: state,
      workspaceId: workspaceId,
    );
    return _setAndPersist(nextState);
  }

  Future<void> duplicateWorkspace(String workspaceId) {
    final nextState = ecommerceOrderSavedWorkspacesWithDuplicated(
      workspaces: state,
      workspaceId: workspaceId,
    );
    return _setAndPersist(nextState);
  }

  Future<void> pinWorkspace(String workspaceId, bool isPinned) {
    final nextState = ecommerceOrderSavedWorkspacesWithPinned(
      workspaces: state,
      workspaceId: workspaceId,
      isPinned: isPinned,
    );
    return _setAndPersist(nextState);
  }

  Future<void> renameWorkspace(String workspaceId, String label) {
    final nextState = ecommerceOrderSavedWorkspacesWithRenamed(
      workspaces: state,
      workspaceId: workspaceId,
      label: label,
    );
    return _setAndPersist(nextState);
  }

  Future<void> updateWorkspaceDescription(
    String workspaceId,
    String description,
  ) {
    final nextState = ecommerceOrderSavedWorkspacesWithDescription(
      workspaces: state,
      workspaceId: workspaceId,
      description: description,
    );
    return _setAndPersist(nextState);
  }

  Future<void> resetWorkspaceDescription(
    String workspaceId,
    List<OrderActiveFilterSummaryItem> summaryItems,
  ) {
    final nextState = ecommerceOrderSavedWorkspacesWithAutoDescription(
      workspaces: state,
      workspaceId: workspaceId,
      summaryItems: summaryItems,
    );
    return _setAndPersist(nextState);
  }

  Future<void> moveWorkspace(
    String workspaceId,
    OrderSavedWorkspaceMoveDirection direction,
  ) {
    final nextState = ecommerceOrderSavedWorkspacesWithMoved(
      workspaces: state,
      workspaceId: workspaceId,
      direction: direction,
    );
    return _setAndPersist(nextState);
  }

  Future<void> flush() {
    return _persistFuture ?? Future<void>.value();
  }

  Future<void> _hydrate() async {
    final restoredWorkspaces = await repository.load(profileId: profileId);
    if (_hasLocalMutations) {
      await _queuePersist();
      return;
    }

    state = List.unmodifiable(restoredWorkspaces);
  }

  Future<void> _setAndPersist(List<OrderSavedWorkspace> nextState) {
    if (_savedWorkspacesEqual(state, nextState)) {
      return Future<void>.value();
    }

    state = List.unmodifiable(nextState);
    _hasLocalMutations = true;
    return _queuePersist();
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    final snapshot = List<OrderSavedWorkspace>.unmodifiable(state);

    return _persistFuture = pending
        .then((_) => repository.save(snapshot, profileId: profileId))
        .catchError((_) {});
  }
}

bool _savedWorkspacesEqual(
  List<OrderSavedWorkspace> left,
  List<OrderSavedWorkspace> right,
) {
  if (left.length != right.length) return false;

  for (var index = 0; index < left.length; index += 1) {
    if (!_savedWorkspaceEqual(left[index], right[index])) return false;
  }

  return true;
}

bool _savedWorkspaceEqual(OrderSavedWorkspace left, OrderSavedWorkspace right) {
  return left.id == right.id &&
      left.label == right.label &&
      left.description == right.description &&
      left.isDescriptionCustom == right.isDescriptionCustom &&
      left.sortMode == right.sortMode &&
      left.isPinned == right.isPinned &&
      ecommerceOrderFiltersEqual(left.filter, right.filter);
}
