// Calendar Integration Provider
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';
//import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../service/calendar_integration_service.dart';

final calendarIntegrationProvider = Provider(
  (ref) => CalendarIntegrationService(),
);

class VoiceInputService {
  //final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      /*  _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      ); */
    }
    return _isInitialized;
  }

  Future<String?> listen() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    String? result;
    /* await _speech.listen(
      onResult: (val) {
        result = val.recognizedWords;
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
    ); */

    // Wait for recognition to complete
    await Future.delayed(const Duration(seconds: 4));
    return result;
  }

  void stop() {
    // _speech.stop();
  }

  // bool get isListening => _speech.isListening;
}
