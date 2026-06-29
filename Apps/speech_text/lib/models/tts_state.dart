class TtsState {
  final bool isSpeaking;
  final bool isInitialized;
  final String currentText;
  final double speechRate;
  final double pitch;
  final double volume;

  TtsState({
    this.isSpeaking = false,
    this.isInitialized = false,
    this.currentText = '',
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.volume = 1.0,
  });

  TtsState copyWith({
    bool? isSpeaking,
    bool? isInitialized,
    String? currentText,
    double? speechRate,
    double? pitch,
    double? volume,
  }) {
    return TtsState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isInitialized: isInitialized ?? this.isInitialized,
      currentText: currentText ?? this.currentText,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
    );
  }
}
