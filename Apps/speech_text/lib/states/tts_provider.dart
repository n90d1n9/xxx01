import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/tts_state.dart';

final textToSpeechProvider =
    StateNotifierProvider<TextToSpeechNotifier, TtsState>((ref) {
      return TextToSpeechNotifier();
    });

class TextToSpeechNotifier extends StateNotifier<TtsState> {
  final FlutterTts _flutterTts = FlutterTts();

  TextToSpeechNotifier() : super(TtsState()) {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(state.speechRate);
      await _flutterTts.setVolume(state.volume);
      await _flutterTts.setPitch(state.pitch);

      _flutterTts.setStartHandler(() {
        state = state.copyWith(isSpeaking: true);
      });

      _flutterTts.setCompletionHandler(() {
        state = state.copyWith(isSpeaking: false);
      });

      _flutterTts.setErrorHandler((msg) {
        state = state.copyWith(isSpeaking: false);
      });

      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('TTS initialization error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!state.isInitialized || text.isEmpty) return;

    try {
      state = state.copyWith(currentText: text);
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
      state = state.copyWith(isSpeaking: false);
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      state = state.copyWith(isSpeaking: false);
    } catch (e) {
      print('TTS stop error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      state = state.copyWith(isSpeaking: false);
    } catch (e) {
      print('TTS pause error: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
      state = state.copyWith(speechRate: rate);
    } catch (e) {
      print('TTS setSpeechRate error: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
      state = state.copyWith(pitch: pitch);
    } catch (e) {
      print('TTS setPitch error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
      state = state.copyWith(volume: volume);
    } catch (e) {
      print('TTS setVolume error: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
