import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../models/audio_playback.dart';
import '../models/reading_mode.dart';
import '../models/surah.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final StreamController<AudioPlaybackState> _stateController =
      StreamController<AudioPlaybackState>.broadcast();

  AudioPlaybackState _currentState = AudioPlaybackState();
  List<Ayah>? _playlist;
  int _currentIndex = 0;

  Stream<AudioPlaybackState> get stateStream => _stateController.stream;
  AudioPlaybackState get currentState => _currentState;

  AudioService() {
    _initializeListeners();
  }

  void _initializeListeners() {
    _player.playerStateStream.listen((state) {
      _updateState(
        _currentState.copyWith(
          isPlaying: state.playing,
          isLoading: state.processingState == ProcessingState.loading,
        ),
      );

      if (state.processingState == ProcessingState.completed) {
        _handleAyahCompleted();
      }
    });

    _player.positionStream.listen((position) {
      _updateState(_currentState.copyWith(position: position));
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _updateState(_currentState.copyWith(duration: duration));
      }
    });
  }

  Future<void> playAyah(
    int surahNumber,
    int ayahNumber,
    String reciterId,
  ) async {
    try {
      _updateState(_currentState.copyWith(isLoading: true));

      final url = _getAudioUrl(reciterId, surahNumber, ayahNumber);
      await _player.setUrl(url);
      await _player.play();

      _updateState(
        _currentState.copyWith(
          currentSurah: surahNumber,
          currentAyah: ayahNumber,
          isLoading: false,
          isPlaying: true,
        ),
      );
    } catch (e) {
      _updateState(_currentState.copyWith(isLoading: false, isPlaying: false));
      throw Exception('Failed to play Ayah: $e');
    }
  }

  Future<void> playAudioUrl(
    String url, {
    int? surahNumber,
    int? ayahNumber,
  }) async {
    try {
      _updateState(_currentState.copyWith(isLoading: true));

      await _player.setUrl(url);
      await _player.play();

      _updateState(
        _currentState.copyWith(
          currentSurah: surahNumber,
          currentAyah: ayahNumber,
          isLoading: false,
          isPlaying: true,
        ),
      );
    } catch (e) {
      _updateState(_currentState.copyWith(isLoading: false, isPlaying: false));
      throw Exception('Failed to play audio URL: $e');
    }
  }

  Future<void> playPlaylist(List<Ayah> ayahs, String reciterId) async {
    _playlist = ayahs;
    _currentIndex = 0;
    if (ayahs.isNotEmpty) {
      await playAyah(ayahs[0].surahNumber, ayahs[0].numberInSurah, reciterId);
    }
  }

  Future<void> playSurah(int surahNumber, String reciterId) async {
    // This would need QuranService to get all ayahs
    // For now, just play first ayah
    await playAyah(surahNumber, 1, reciterId);
  }

  Future<void> playNext() async {
    if (_playlist != null && _currentIndex < _playlist!.length - 1) {
      _currentIndex++;
      final ayah = _playlist![_currentIndex];
      await playAyah(ayah.surahNumber, ayah.numberInSurah, 'ar.alafasy');
    }
  }

  Future<void> playPrevious() async {
    if (_playlist != null && _currentIndex > 0) {
      _currentIndex--;
      final ayah = _playlist![_currentIndex];
      await playAyah(ayah.surahNumber, ayah.numberInSurah, 'ar.alafasy');
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _updateState(_currentState.copyWith(isPlaying: false));
  }

  Future<void> resume() async {
    await _player.play();
    _updateState(_currentState.copyWith(isPlaying: true));
  }

  Future<void> stop() async {
    await _player.stop();
    _updateState(AudioPlaybackState());
    _playlist = null;
    _currentIndex = 0;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    _updateState(_currentState.copyWith(speed: speed));
  }

  void setRepeatMode(RepeatMode mode) {
    _updateState(_currentState.copyWith(repeatMode: mode));
  }

  void _handleAyahCompleted() {
    final mode = _currentState.repeatMode;

    if (mode == RepeatMode.ayah) {
      _player.seek(Duration.zero);
      _player.play();
    } else if (mode == RepeatMode.surah || mode == RepeatMode.range) {
      playNext();
    }
  }

  String _getAudioUrl(String reciterId, int surahNumber, int ayahNumber) {
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio-surah/128/$reciterId/$surahPadded$ayahPadded.mp3';
  }

  void _updateState(AudioPlaybackState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _player.dispose();
    _stateController.close();
  }
}
