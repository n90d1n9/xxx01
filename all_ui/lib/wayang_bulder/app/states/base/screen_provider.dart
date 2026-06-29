import 'package:flutter_riverpod/legacy.dart';
import 'screen_state.dart';

class ScreenNotifier extends StateNotifier<ScreenState> {
  ScreenNotifier() : super(ScreenState(currentScreen: "home"));

  void setScreen(String screenName) {
    state = state.copyWith(currentScreen: screenName);
  }

  void setLastClicked(String element) {
    state = state.copyWith(lastClicked: element);
  }
}

final screenProvider = StateNotifierProvider<ScreenNotifier, ScreenState>(
  (ref) => ScreenNotifier(),
);
