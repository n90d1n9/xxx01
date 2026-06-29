import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reading_mode.dart';

import '../states/quran_provider.dart';

class AudioPlayerSheet extends ConsumerStatefulWidget {
  const AudioPlayerSheet({super.key});
  @override
  ConsumerState<AudioPlayerSheet> createState() => _AudioPlayerSheetState();
}

class _AudioPlayerSheetState extends ConsumerState<AudioPlayerSheet> {
  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioStateProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: audioState.when(
        data: (state) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Now Playing',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.currentSurah}:${state.currentAyah}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          Slider(
                            value: state.position.inSeconds.toDouble(),
                            max: state.duration.inSeconds.toDouble().clamp(
                              1,
                              double.infinity,
                            ),
                            onChanged: (value) {
                              ref
                                  .read(audioServiceProvider)
                                  .seek(Duration(seconds: value.toInt()));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(state.position)),
                                Text(_formatDuration(state.duration)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 48,
                            onPressed: () {
                              ref.read(audioServiceProvider).playPrevious();
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                state.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              iconSize: 48,
                              onPressed: () {
                                if (state.isPlaying) {
                                  ref.read(audioServiceProvider).pause();
                                } else {
                                  ref.read(audioServiceProvider).resume();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 48,
                            onPressed: () {
                              ref.read(audioServiceProvider).playNext();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          PopupMenuButton<double>(
                            icon: const Icon(Icons.speed),
                            tooltip: 'Speed',
                            onSelected: (speed) {
                              ref.read(audioServiceProvider).setSpeed(speed);
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 0.5,
                                    child: Text('0.5x'),
                                  ),
                                  const PopupMenuItem(
                                    value: 0.75,
                                    child: Text('0.75x'),
                                  ),
                                  const PopupMenuItem(
                                    value: 1.0,
                                    child: Text('1.0x'),
                                  ),
                                  const PopupMenuItem(
                                    value: 1.25,
                                    child: Text('1.25x'),
                                  ),
                                  const PopupMenuItem(
                                    value: 1.5,
                                    child: Text('1.5x'),
                                  ),
                                  const PopupMenuItem(
                                    value: 2.0,
                                    child: Text('2.0x'),
                                  ),
                                ],
                          ),
                          PopupMenuButton<RepeatMode>(
                            icon: Icon(
                              state.repeatMode == RepeatMode.none
                                  ? Icons.repeat
                                  : Icons.repeat_on,
                            ),
                            tooltip: 'Repeat',
                            onSelected: (mode) {
                              ref
                                  .read(audioServiceProvider)
                                  .setRepeatMode(mode);
                            },
                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value: RepeatMode.none,
                                    child: Text('No Repeat'),
                                  ),
                                  PopupMenuItem(
                                    value: RepeatMode.ayah,
                                    child: Text('Repeat Ayah'),
                                  ),
                                  PopupMenuItem(
                                    value: RepeatMode.surah,
                                    child: Text('Repeat Surah'),
                                  ),
                                ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              ref.read(audioServiceProvider).stop();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading:
            () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: $error'),
            ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
