import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final voiceRecordingProvider =
    StateNotifierProvider<VoiceRecordingNotifier, VoiceRecordingState>((ref) {
      return VoiceRecordingNotifier();
    });

class VoiceRecordingState {
  final bool isRecording;
  final Duration duration;
  final List<double> waveform;
  final String? filePath;

  VoiceRecordingState({
    this.isRecording = false,
    this.duration = Duration.zero,
    this.waveform = const [],
    this.filePath,
  });

  VoiceRecordingState copyWith({
    bool? isRecording,
    Duration? duration,
    List<double>? waveform,
    String? filePath,
  }) {
    return VoiceRecordingState(
      isRecording: isRecording ?? this.isRecording,
      duration: duration ?? this.duration,
      waveform: waveform ?? this.waveform,
      filePath: filePath ?? this.filePath,
    );
  }
}

class VoiceRecordingNotifier extends StateNotifier<VoiceRecordingState> {
  VoiceRecordingNotifier() : super(VoiceRecordingState());

  void startRecording() {
    state = state.copyWith(isRecording: true);
  }

  void stopRecording() {
    state = state.copyWith(isRecording: false);
  }

  void updateDuration(Duration duration) {
    state = state.copyWith(duration: duration);
  }

  void updateWaveform(List<double> waveform) {
    state = state.copyWith(waveform: waveform);
  }
}
