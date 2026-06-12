import 'package:flutter/material.dart';

import '../controllers/restaurant_workspace_controller.dart';
import '../controllers/restaurant_workspace_preferences_controller.dart';
import '../controllers/restaurant_workspace_state.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_preferences.dart';
import '../models/restaurant_workspace_view.dart';
import '../models/restaurant_workspace_view_availability.dart';
import '../repositories/restaurant_snapshot_repository.dart';
import '../services/restaurant_operational_insight_builder.dart';
import '../services/restaurant_workspace_action_dispatcher.dart';
import '../services/workspace_action_coordinator.dart';
import '../services/workspace_preference_coordinator.dart';
import '../services/workspace_screen_bindings.dart';
import 'reservation_qr_panel_binding.dart';
import 'restaurant_workspace_ready_view.dart';
import 'restaurant_workspace_scaffold.dart';
import 'restaurant_workspace_state_views.dart';
import 'workspace_ready_view_composer.dart';

/// Hosts the restaurant operations workspace and binds controllers to UI state.
class RestaurantWorkspaceScreen extends StatefulWidget {
  const RestaurantWorkspaceScreen({
    super.key,
    this.snapshot,
    this.repository = const DemoRestaurantSnapshotRepository(),
    this.controller,
    this.preferencesController,
    this.initialView = RestaurantWorkspaceView.pulse,
    this.initialFilters = const RestaurantWorkspacePanelFilters(),
    this.onViewChanged,
    this.onPreferencesChanged,
    this.views = RestaurantWorkspaceView.values,
    this.insightBuilder = const RestaurantOperationalInsightBuilder(),
    this.reservationQrPanelBinding,
  });

  final RestaurantOperatingSnapshot? snapshot;
  final RestaurantSnapshotRepository repository;
  final RestaurantWorkspaceController? controller;
  final RestaurantWorkspacePreferencesController? preferencesController;
  final RestaurantWorkspaceView initialView;
  final RestaurantWorkspacePanelFilters initialFilters;
  final ValueChanged<RestaurantWorkspaceView>? onViewChanged;
  final ValueChanged<RestaurantWorkspacePreferences>? onPreferencesChanged;
  final List<RestaurantWorkspaceView> views;
  final RestaurantOperationalInsightBuilder insightBuilder;
  final RestaurantReservationQrPanelBinding? reservationQrPanelBinding;

  @override
  State<RestaurantWorkspaceScreen> createState() =>
      _RestaurantWorkspaceScreenState();
}

class _RestaurantWorkspaceScreenState extends State<RestaurantWorkspaceScreen> {
  late RestaurantWorkspaceControllerBinding _controllerBinding;
  late RestaurantWorkspacePreferencesBinding _preferencesBinding;

  RestaurantWorkspaceController get _controller =>
      _controllerBinding.controller;

  RestaurantWorkspacePreferencesController get _preferencesController =>
      _preferencesBinding.controller;

  RestaurantWorkspaceActionDispatcher get _actionDispatcher =>
      _controllerBinding.actionDispatcher;

  RestaurantWorkspaceView get _selectedView => _preferencesBinding.selectedView;

  RestaurantWorkspacePanelFilters get _panelFilters =>
      _preferencesBinding.filters;

  @override
  void initState() {
    super.initState();
    _controllerBinding = RestaurantWorkspaceControllerBinding(
      onChanged: _handleControllerChanged,
    );
    _preferencesBinding = RestaurantWorkspacePreferencesBinding(
      onChanged: _handlePreferencesChanged,
    );
    _attachController();
    _attachPreferencesController();
    _controller.load();
  }

  @override
  void didUpdateWidget(RestaurantWorkspaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.preferencesController != oldWidget.preferencesController) {
      _detachPreferencesController();
      _attachPreferencesController();
    } else if (widget.preferencesController == null) {
      _preferencesBinding.updateOwnedInitialPreferences(
        initialView: widget.initialView,
        previousInitialView: oldWidget.initialView,
        initialFilters: widget.initialFilters,
        previousInitialFilters: oldWidget.initialFilters,
      );
    }
    _ensureSelectedViewAvailable();

    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController();
      _controller.load();
      return;
    }

    if (widget.snapshot != oldWidget.snapshot) {
      _controllerBinding.applySnapshotOrRepository(
        snapshot: widget.snapshot,
        repository: widget.repository,
      );
      return;
    }

    if (widget.repository != oldWidget.repository && widget.snapshot == null) {
      _controllerBinding.updateRepository(widget.repository);
    }
  }

  @override
  void dispose() {
    _detachPreferencesController();
    _detachController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestaurantWorkspaceScaffold(child: _buildContent(_controller.state));
  }

  Widget _buildContent(RestaurantWorkspaceState state) {
    final snapshot = state.snapshot;
    if (snapshot == null) {
      return RestaurantWorkspaceStateNotice(
        state: state,
        onRetry: _controller.refresh,
      );
    }

    final composition =
        RestaurantWorkspaceReadyViewComposer(
          insightBuilder: widget.insightBuilder,
        ).compose(
          state: state,
          snapshot: snapshot,
          selectedView: _selectedView,
          filters: _panelFilters,
          focus: _preferencesController.focus,
          viewAvailability: _viewAvailability,
          controller: _controller,
          preferencesController: _preferencesController,
          actionCoordinator: _actionCoordinator,
          preferenceCoordinator: _preferenceCoordinator,
          reservationQrPanelBinding: widget.reservationQrPanelBinding,
        );
    return RestaurantWorkspaceReadyView(
      data: composition.data,
      controls: composition.controls,
      overviewCallbacks: composition.overviewCallbacks,
      panelActions: composition.panelActions,
    );
  }

  RestaurantWorkspaceActionCoordinator get _actionCoordinator =>
      RestaurantWorkspaceActionCoordinator.forMessenger(
        dispatcher: _actionDispatcher,
        messenger: ScaffoldMessenger.maybeOf(context),
      );

  RestaurantWorkspacePreferenceCoordinator get _preferenceCoordinator =>
      RestaurantWorkspacePreferenceCoordinator(
        controller: _preferencesController,
        viewAvailability: _viewAvailability,
        onViewChanged: widget.onViewChanged,
        onResetConfirmed: _actionCoordinator.showPreferenceResetConfirmation,
      );

  void _attachController() {
    _controllerBinding.attach(
      controller: widget.controller,
      snapshot: widget.snapshot,
      repository: widget.repository,
    );
  }

  void _detachController() {
    _controllerBinding.detach();
  }

  void _attachPreferencesController() {
    final normalized = _preferencesBinding.attach(
      controller: widget.preferencesController,
      initialView: widget.initialView,
      initialFilters: widget.initialFilters,
      viewAvailability: _viewAvailability,
    );
    if (normalized) {
      widget.onPreferencesChanged?.call(_preferencesBinding.preferences);
    }
  }

  void _detachPreferencesController() {
    _preferencesBinding.detach();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  void _handlePreferencesChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onPreferencesChanged?.call(_preferencesController.preferences);
  }

  RestaurantWorkspaceViewAvailability get _viewAvailability =>
      RestaurantWorkspaceViewAvailability.fromViews(
        widget.views,
        useAllWhenEmpty: true,
      );

  bool _ensureSelectedViewAvailable() {
    return _preferencesBinding.normalizeSelectedView(
      viewAvailability: _viewAvailability,
      preferredFallback: widget.initialView,
    );
  }
}
