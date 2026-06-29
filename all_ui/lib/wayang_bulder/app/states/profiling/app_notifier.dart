import 'package:flutter_riverpod/legacy.dart';
import 'package:logging/logging.dart';
import 'app_state.dart';

final log = Logger('profilingProvider');

final profilingProvider = StateNotifierProvider<AppNotifier, AppState>(
  (ref) => AppNotifier(),
);

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier()
      : super(AppState(hasFinishedGuide: false, hasOnboarding: false));
}
