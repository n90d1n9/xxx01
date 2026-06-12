import 'package:flutter/foundation.dart';

import '../controllers/restaurant_workspace_controller.dart';
import '../controllers/restaurant_workspace_preferences_controller.dart';
import '../controllers/restaurant_workspace_state.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_preferences.dart';
import '../models/restaurant_workspace_view.dart';
import '../models/restaurant_workspace_view_availability.dart';
import '../repositories/restaurant_snapshot_repository.dart';
import 'restaurant_workspace_action_dispatcher.dart';

/// Manages workspace controller ownership, listener wiring, and dispatcher setup.
class RestaurantWorkspaceControllerBinding {
  RestaurantWorkspaceControllerBinding({required this.onChanged});

  final VoidCallback onChanged;
  late RestaurantWorkspaceController _controller;
  late RestaurantWorkspaceActionDispatcher _actionDispatcher;
  bool _ownsController = false;
  bool _attached = false;

  RestaurantWorkspaceController get controller => _controller;

  RestaurantWorkspaceActionDispatcher get actionDispatcher => _actionDispatcher;

  void attach({
    required RestaurantSnapshotRepository repository,
    required RestaurantOperatingSnapshot? snapshot,
    RestaurantWorkspaceController? controller,
  }) {
    if (_attached) detach();

    _ownsController = controller == null;
    _controller =
        controller ??
        RestaurantWorkspaceController(
          repository: _repositoryFor(
            snapshot: snapshot,
            repository: repository,
          ),
          initialState: snapshot == null
              ? const RestaurantWorkspaceState()
              : RestaurantWorkspaceState.ready(snapshot: snapshot),
        );
    _actionDispatcher = RestaurantWorkspaceActionDispatcher(
      controller: _controller,
    );
    _controller.addListener(onChanged);
    _attached = true;
  }

  void applySnapshotOrRepository({
    required RestaurantOperatingSnapshot? snapshot,
    required RestaurantSnapshotRepository repository,
  }) {
    if (snapshot case final replacement?) {
      _controller.replaceSnapshot(replacement);
      return;
    }
    _controller.repository = repository;
  }

  void updateRepository(RestaurantSnapshotRepository repository) {
    _controller.repository = repository;
  }

  void detach() {
    if (!_attached) return;

    _controller.removeListener(onChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _attached = false;
  }

  RestaurantSnapshotRepository _repositoryFor({
    required RestaurantOperatingSnapshot? snapshot,
    required RestaurantSnapshotRepository repository,
  }) {
    if (snapshot case final providedSnapshot?) {
      return DemoRestaurantSnapshotRepository(snapshot: providedSnapshot);
    }
    return repository;
  }
}

/// Manages workspace preference controller ownership and view availability.
class RestaurantWorkspacePreferencesBinding {
  RestaurantWorkspacePreferencesBinding({required this.onChanged});

  final VoidCallback onChanged;
  late RestaurantWorkspacePreferencesController _controller;
  bool _ownsController = false;
  bool _attached = false;

  RestaurantWorkspacePreferencesController get controller => _controller;

  RestaurantWorkspacePreferences get preferences => _controller.preferences;

  RestaurantWorkspaceView get selectedView => _controller.selectedView;

  RestaurantWorkspacePanelFilters get filters => _controller.filters;

  bool attach({
    required RestaurantWorkspaceView initialView,
    required RestaurantWorkspacePanelFilters initialFilters,
    required RestaurantWorkspaceViewAvailability viewAvailability,
    RestaurantWorkspacePreferencesController? controller,
  }) {
    if (_attached) detach();

    _ownsController = controller == null;
    _controller =
        controller ??
        RestaurantWorkspacePreferencesController(
          initialPreferences: RestaurantWorkspacePreferences(
            view: initialView,
            filters: initialFilters,
          ),
        );
    final normalized = normalizeSelectedView(
      viewAvailability: viewAvailability,
      preferredFallback: initialView,
    );
    _controller.addListener(onChanged);
    _attached = true;
    return normalized;
  }

  void updateOwnedInitialPreferences({
    required RestaurantWorkspaceView initialView,
    required RestaurantWorkspaceView previousInitialView,
    required RestaurantWorkspacePanelFilters initialFilters,
    required RestaurantWorkspacePanelFilters previousInitialFilters,
  }) {
    if (!_ownsController) return;

    if (initialView != previousInitialView) {
      _controller.selectView(initialView);
    }
    if (initialFilters != previousInitialFilters) {
      _controller.setFilters(initialFilters);
    }
  }

  bool normalizeSelectedView({
    required RestaurantWorkspaceViewAvailability viewAvailability,
    RestaurantWorkspaceView? preferredFallback,
  }) {
    final effectiveView = viewAvailability.selectedOrFallback(
      _controller.selectedView,
      preferredFallback: preferredFallback,
    );
    if (effectiveView == null || effectiveView == _controller.selectedView) {
      return false;
    }
    return _controller.selectView(effectiveView);
  }

  void detach() {
    if (!_attached) return;

    _controller.removeListener(onChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _attached = false;
  }
}
