import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final callProvider = StateNotifierProvider<CallNotifier, CallState>((ref) {
  return CallNotifier();
});

class CallNotifier extends StateNotifier<CallState> {
  CallNotifier() : super(CallState());

  void startVideoCall(String roomId) {
    // Implementation for starting video call
  }

  void startVoiceCall(String roomId) {
    // Implementation for starting voice call
  }
}

class CallState {
  // Call state properties
}
