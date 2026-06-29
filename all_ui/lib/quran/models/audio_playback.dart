import 'reading_mode.dart';

class AudioPlaybackState {
  final bool isPlaying;
  final bool isLoading;
  final int? currentSurah;
  final int? currentAyah;
  final Duration position;
  final Duration duration;
  final double speed;
  final RepeatMode repeatMode;
  final int repeatCount;

  AudioPlaybackState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentSurah,
    this.currentAyah,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.repeatMode = RepeatMode.none,
    this.repeatCount = 0,
  });

  AudioPlaybackState copyWith({
    bool? isPlaying,
    bool? isLoading,
    int? currentSurah,
    int? currentAyah,
    Duration? position,
    Duration? duration,
    double? speed,
    RepeatMode? repeatMode,
    int? repeatCount,
  }) {
    return AudioPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      repeatMode: repeatMode ?? this.repeatMode,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }
}
