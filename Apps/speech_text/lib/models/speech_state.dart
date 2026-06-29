class SpeechState {
  final bool isListening;
  final bool isAvailable;
  final String recognizedText;
  final String errorMessage;
  final double confidence;

  SpeechState({
    this.isListening = false,
    this.isAvailable = false,
    this.recognizedText = '',
    this.errorMessage = '',
    this.confidence = 0.0,
  });

  SpeechState copyWith({
    bool? isListening,
    bool? isAvailable,
    String? recognizedText,
    String? errorMessage,
    double? confidence,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      isAvailable: isAvailable ?? this.isAvailable,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: errorMessage ?? this.errorMessage,
      confidence: confidence ?? this.confidence,
    );
  }
}
