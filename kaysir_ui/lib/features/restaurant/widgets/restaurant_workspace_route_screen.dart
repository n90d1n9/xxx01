import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../repositories/restaurant_workspace_preferences_repository.dart';
import '../services/restaurant_workspace_preferences_autosave.dart';

class RestaurantWorkspaceRouteScreen extends StatefulWidget {
  const RestaurantWorkspaceRouteScreen({
    super.key,
    required this.initialView,
    this.restoreSavedView = false,
    this.preferencesRepository,
    this.autosaveDelay = const Duration(milliseconds: 300),
    this.onViewChanged,
  });

  final RestaurantWorkspaceView initialView;
  final bool restoreSavedView;
  final RestaurantWorkspacePreferencesRepository? preferencesRepository;
  final Duration autosaveDelay;
  final ValueChanged<RestaurantWorkspaceView>? onViewChanged;

  @override
  State<RestaurantWorkspaceRouteScreen> createState() =>
      _RestaurantWorkspaceRouteScreenState();
}

class _RestaurantWorkspaceRouteScreenState
    extends State<RestaurantWorkspaceRouteScreen> {
  late RestaurantWorkspacePreferencesRepository _preferencesRepository;
  late RestaurantWorkspacePreferencesAutosave _preferencesAutosave;
  RestaurantWorkspacePreferencesController? _preferencesController;
  var _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _preferencesRepository = _repositoryForWidget();
    _preferencesAutosave = _autosaveForRepository();
    _loadPreferences();
  }

  @override
  void didUpdateWidget(RestaurantWorkspaceRouteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final repositoryChanged =
        widget.preferencesRepository != oldWidget.preferencesRepository;
    final autosaveDelayChanged =
        widget.autosaveDelay != oldWidget.autosaveDelay;
    final shouldReload =
        repositoryChanged ||
        widget.initialView != oldWidget.initialView ||
        widget.restoreSavedView != oldWidget.restoreSavedView;

    if (repositoryChanged || autosaveDelayChanged) {
      unawaited(_preferencesAutosave.flush());
      _preferencesAutosave.dispose();
      if (repositoryChanged) {
        _preferencesRepository = _repositoryForWidget();
      }
      _preferencesAutosave = _autosaveForRepository();
    }

    if (!shouldReload) return;

    _disposePreferencesController();
    _loadPreferences();
  }

  @override
  void dispose() {
    _loadVersion += 1;
    unawaited(_preferencesAutosave.flush());
    _preferencesAutosave.dispose();
    _disposePreferencesController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferencesController = _preferencesController;
    if (preferencesController == null) {
      return Scaffold(
        body: Center(
          child: Semantics(
            label: 'Loading restaurant workspace',
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    return RestaurantWorkspaceScreen(
      initialView: preferencesController.selectedView,
      preferencesController: preferencesController,
      onViewChanged: widget.onViewChanged,
      onPreferencesChanged: _queuePreferencesSave,
    );
  }

  RestaurantWorkspacePreferencesRepository _repositoryForWidget() {
    return widget.preferencesRepository ??
        RestaurantWorkspacePreferencesRepository.local();
  }

  RestaurantWorkspacePreferencesAutosave _autosaveForRepository() {
    return RestaurantWorkspacePreferencesAutosave(
      repository: _preferencesRepository,
      delay: widget.autosaveDelay,
    );
  }

  Future<void> _loadPreferences() async {
    final version = ++_loadVersion;
    final loadedPreferences = await _preferencesRepository.load();
    if (!mounted || version != _loadVersion) return;

    final routePreferences =
        widget.restoreSavedView
            ? loadedPreferences
            : loadedPreferences.copyWith(view: widget.initialView);
    final nextController = RestaurantWorkspacePreferencesController(
      initialPreferences: routePreferences,
    );

    _disposePreferencesController();
    setState(() {
      _preferencesController = nextController;
    });

    if (routePreferences != loadedPreferences) {
      _queuePreferencesSave(routePreferences);
    }
  }

  void _queuePreferencesSave(RestaurantWorkspacePreferences preferences) {
    _preferencesAutosave.schedule(preferences);
  }

  void _disposePreferencesController() {
    _preferencesController?.dispose();
    _preferencesController = null;
  }
}
