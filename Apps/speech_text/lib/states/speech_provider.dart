import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/speech_state.dart';

final speechToTextProvider =
    StateNotifierProvider<SpeechToTextNotifier, SpeechState>((ref) {
      return SpeechToTextNotifier();
    });

// Text-to-Speech Provider

class SpeechToTextNotifier extends StateNotifier<SpeechState> {
  final SpeechToText _speech = SpeechToText();

  SpeechToTextNotifier() : super(SpeechState()) {
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      state = state.copyWith(errorMessage: 'Microphone permission denied');
      return;
    }
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {},
        onError: (error) {},
      );
      state = state.copyWith(
        isAvailable: available,
        errorMessage: available ? '' : 'Speech recognition not available',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to initialize speech recognition: $e',
      );
    }
  }

  Future<void> startListening() async {
    if (!state.isAvailable) return;

    try {
      state = state.copyWith(
        recognizedText: '',
        errorMessage: '',
        confidence: 0.0,
      );

      await _speech.listen(
        onResult: (result) {
          state = state.copyWith(
            recognizedText: result.recognizedWords,
            confidence: result.confidence,
          );
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
      state = state.copyWith(isListening: false);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to stop listening: $e');
    }
  }

  void clearText() {
    state = state.copyWith(
      recognizedText: '',
      confidence: 0.0,
      errorMessage: '',
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
