class VoiceNote {
  final String url;
  final Duration duration;
  final List<double> waveform;
  final bool isPlaying;

  VoiceNote({
    required this.url,
    required this.duration,
    this.waveform = const [],
    this.isPlaying = false,
  });
}
