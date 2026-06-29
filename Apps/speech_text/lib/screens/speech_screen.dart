import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/speech_provider.dart';
import '../states/tts_provider.dart';

class SpeechHomePage extends ConsumerWidget {
  const SpeechHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechToTextProvider);
    final ttsState = ref.watch(textToSpeechProvider);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Speech-to-Text Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Speech to Text',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (speechState.errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          speechState.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speechState.recognizedText.isEmpty
                                ? 'Tap the microphone to start speaking...'
                                : speechState.recognizedText,
                            style: TextStyle(
                              fontSize: 16,
                              color: speechState.recognizedText.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          if (speechState.confidence > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Confidence: ${(speechState.confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              speechState.isAvailable &&
                                  !speechState.isListening
                              ? () => ref
                                    .read(speechToTextProvider.notifier)
                                    .startListening()
                              : null,
                          icon: Icon(
                            speechState.isListening
                                ? Icons.mic
                                : Icons.mic_none,
                          ),
                          label: Text(
                            speechState.isListening ? 'Listening...' : 'Start',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: speechState.isListening
                                ? Colors.red
                                : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: speechState.isListening
                              ? () => ref
                                    .read(speechToTextProvider.notifier)
                                    .stopListening()
                              : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                        ),
                        ElevatedButton.icon(
                          onPressed: speechState.recognizedText.isNotEmpty
                              ? () => ref
                                    .read(speechToTextProvider.notifier)
                                    .clearText()
                              : null,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Text-to-Speech Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text to Speech',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter text to speak...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              ttsState.isInitialized && !ttsState.isSpeaking
                              ? () {
                                  final text = textController.text.trim();
                                  if (text.isNotEmpty) {
                                    ref
                                        .read(textToSpeechProvider.notifier)
                                        .speak(text);
                                  }
                                }
                              : null,
                          icon: Icon(
                            ttsState.isSpeaking
                                ? Icons.volume_up
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            ttsState.isSpeaking ? 'Speaking...' : 'Speak',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ttsState.isSpeaking
                                ? Colors.green
                                : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: ttsState.isSpeaking
                              ? () => ref
                                    .read(textToSpeechProvider.notifier)
                                    .stop()
                              : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                        ),
                        ElevatedButton.icon(
                          onPressed: speechState.recognizedText.isNotEmpty
                              ? () {
                                  textController.text =
                                      speechState.recognizedText;
                                  ref
                                      .read(textToSpeechProvider.notifier)
                                      .speak(speechState.recognizedText);
                                }
                              : null,
                          icon: const Icon(Icons.record_voice_over),
                          label: const Text('Speak STT'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // TTS Controls
                    Column(
                      children: [
                        Row(
                          children: [
                            const Text('Speed: '),
                            Expanded(
                              child: Slider(
                                value: ttsState.speechRate,
                                min: 0.1,
                                max: 1.0,
                                divisions: 9,
                                label: ttsState.speechRate.toStringAsFixed(1),
                                onChanged: (value) {
                                  ref
                                      .read(textToSpeechProvider.notifier)
                                      .setSpeechRate(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Pitch: '),
                            Expanded(
                              child: Slider(
                                value: ttsState.pitch,
                                min: 0.5,
                                max: 2.0,
                                divisions: 15,
                                label: ttsState.pitch.toStringAsFixed(1),
                                onChanged: (value) {
                                  ref
                                      .read(textToSpeechProvider.notifier)
                                      .setPitch(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
