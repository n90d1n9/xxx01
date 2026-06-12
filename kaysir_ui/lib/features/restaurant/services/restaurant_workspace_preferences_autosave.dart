import 'dart:async';

import 'package:ky_restaurant/ky_restaurant.dart';

import '../repositories/restaurant_workspace_preferences_repository.dart';

class RestaurantWorkspacePreferencesAutosave {
  RestaurantWorkspacePreferencesAutosave({
    required this.repository,
    this.delay = const Duration(milliseconds: 300),
  });

  final RestaurantWorkspacePreferencesRepository repository;
  final Duration delay;

  Timer? _timer;
  Future<void> _pendingWrite = Future<void>.value();
  RestaurantWorkspacePreferences? _pendingPreferences;

  void schedule(RestaurantWorkspacePreferences preferences) {
    _pendingPreferences = preferences;
    _timer?.cancel();

    if (delay == Duration.zero) {
      unawaited(flush());
      return;
    }

    _timer = Timer(delay, () {
      unawaited(flush());
    });
  }

  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;

    final preferences = _pendingPreferences;
    if (preferences == null) {
      await _pendingWrite;
      return;
    }

    _pendingPreferences = null;
    _pendingWrite = _pendingWrite
        .then((_) => repository.save(preferences))
        .catchError((_) {});
    await _pendingWrite;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
