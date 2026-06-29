// screen_state.dart
class ScreenState {
  final String currentScreen;
  final String? lastClicked;

  ScreenState({required this.currentScreen, this.lastClicked});

  ScreenState copyWith({String? currentScreen, String? lastClicked}) {
    return ScreenState(
      currentScreen: currentScreen ?? this.currentScreen,
      lastClicked: lastClicked ?? this.lastClicked,
    );
  }
}
