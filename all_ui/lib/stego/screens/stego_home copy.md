import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message.dart';
import '../service/audio_stego_service.dart';
import '../service/docx_service.dart';
import '../service/encryption_service.dart';
import '../service/image_stego_service.dart';
import '../states/stego_provider.dart';

class SteganographyHome extends ConsumerWidget {
  const SteganographyHome({super.key});

  Future<String> _getAudioDuration(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final duration = (bytes.length / 44100).toStringAsFixed(2);
      final minutes = (bytes.length / 44100 ~/ 60);
      final seconds = ((bytes.length / 44100) % 60).toInt();
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '0:00';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stegoStateProvider);
    final notifier = ref.read(stegoStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Steganography Suite'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.reset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Media Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<MediaType>(
                      segments: const [
                        ButtonSegment(
                          label: Text('Image'),
                          value: MediaType.image,
                        ),
                        ButtonSegment(
                          label: Text('Audio'),
                          value: MediaType.audio,
                        ),
                      ],
                      selected: {state.mediaType},
                      onSelectionChanged: (value) {
                        notifier.setMediaType(value.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Media Section
            if (state.mediaType == MediaType.image)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.image != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.memory(
                            Uint8List.fromList(img.encodePng(state.image!)),
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: const Center(child: Text('No image selected')),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (file != null) {
                                  final bytes = await file.readAsBytes();
                                  final image = img.decodeImage(bytes);
                                  if (image != null) {
                                    notifier.setImage(image, File(file.path));
                                  }
                                }
                              },
                              icon: const Icon(Icons.image),
                              label: const Text('Gallery'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final file = await picker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (file != null) {
                                  final bytes = await file.readAsBytes();
                                  final image = img.decodeImage(bytes);
                                  if (image != null) {
                                    notifier.setImage(image, File(file.path));
                                  }
                                }
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final newImage = img.Image(
                                  width: 200,
                                  height: 200,
                                );
                                for (int y = 0; y < 200; y++) {
                                  for (int x = 0; x < 200; x++) {
                                    final r = (x * 1.27).toInt();
                                    final g = (y * 1.27).toInt();
                                    final b = ((x + y) * 0.63).toInt();
                                    newImage.setPixelRgba(x, y, r, g, b, 255);
                                  }
                                }
                                notifier.setImage(newImage, null);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Generate'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.audioFile != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.audio_file, size: 48),
                              const SizedBox(height: 8),
                              Text(state.audioFile!.path.split('/').last),
                              const SizedBox(height: 4),
                              Text(
                                'Duration: ${state.audioDuration}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: const Center(child: Text('No audio selected')),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(type: FileType.audio);
                                if (result != null) {
                                  final file = File(result.files.single.path!);
                                  final bytes = await file.readAsBytes();
                                  final duration = await _getAudioDuration(
                                    file,
                                  );
                                  notifier.setAudio(file, bytes, duration);
                                }
                              },
                              icon: const Icon(Icons.folder),
                              label: const Text('Select'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Message Source Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message Source',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<MessageSource>(
                      segments: const [
                        ButtonSegment(
                          label: Text('Text'),
                          value: MessageSource.text,
                        ),
                        ButtonSegment(
                          label: Text('DOCX'),
                          value: MessageSource.docx,
                        ),
                        ButtonSegment(
                          label: Text('File'),
                          value: MessageSource.file,
                        ),
                      ],
                      selected: {state.messageSource},
                      onSelectionChanged: (value) {
                        notifier.setMessageSource(value.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Message Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (state.messageSource == MessageSource.text)
                      TextField(
                        onChanged: notifier.updateMessage,
                        decoration: InputDecoration(
                          hintText: 'Enter message to hide',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 4,
                      )
                    else if (state.messageSource == MessageSource.docx)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['docx'],
                                    );
                                if (result != null) {
                                  final file = File(result.files.single.path!);
                                  final content =
                                      await DocumentService.extractFromDocx(
                                        file,
                                      );
                                  notifier.updateMessage(content);
                                }
                              },
                              icon: const Icon(Icons.description),
                              label: const Text('Pick DOCX'),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result =
                                    await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  final file = File(result.files.single.path!);
                                  final content = await file.readAsString();
                                  notifier.updateMessage(content);
                                }
                              },
                              icon: const Icon(Icons.file_copy),
                              label: const Text('Pick File'),
                            ),
                          ),
                        ],
                      ),
                    if (state.messageCapacity > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Capacity: ${state.message.length}/${state.messageCapacity} characters',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              state.message.length > state.messageCapacity
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Steganography Method
            if (state.mediaType == MediaType.image)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Steganography Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(label: Text('LSB'), value: 'LSB'),
                          ButtonSegment(label: Text('SHA'), value: 'SHA'),
                        ],
                        selected: {state.stegoMethod},
                        onSelectionChanged: (value) {
                          notifier.setStegoMethod(value.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Encryption Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: state.useEncryption,
                          onChanged: (value) {
                            notifier.toggleEncryption(value ?? false);
                          },
                        ),
                        const Text('Use Encryption'),
                      ],
                    ),
                    if (state.useEncryption) ...[
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(label: Text('AES'), value: 'AES'),
                          ButtonSegment(label: Text('XOR'), value: 'XOR'),
                        ],
                        selected: {state.encryptionMethod},
                        onSelectionChanged: (value) {
                          notifier.setEncryptionMethod(value.first);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: notifier.updateEncryptionKey,
                        decoration: InputDecoration(
                          hintText: 'Encryption key (min 6 characters)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (!state.isProcessing)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        ((state.mediaType == MediaType.image &&
                                        state.image != null) ||
                                    (state.mediaType == MediaType.audio &&
                                        state.audioData != null)) &&
                                state.message.isNotEmpty
                            ? () async {
                              notifier.setProcessing(true);
                              try {
                                String processedMessage = state.message;

                                if (state.useEncryption &&
                                    state.encryptionKey.isNotEmpty) {
                                  if (state.encryptionMethod == 'AES') {
                                    processedMessage =
                                        EncryptionService.encryptAES(
                                          state.message,
                                          state.encryptionKey,
                                        );
                                  } else {
                                    processedMessage =
                                        EncryptionService.encryptXOR(
                                          state.message,
                                          state.encryptionKey,
                                        );
                                  }
                                }

                                if (state.mediaType == MediaType.image) {
                                  var workImage = state.image!.clone();
                                  final hex =
                                      ImageSteganographyService.messageToHex(
                                        processedMessage,
                                      );
                                  final binary =
                                      ImageSteganographyService.hexToBinary(
                                        hex,
                                      );

                                  if (binary.length >
                                      state.messageCapacity * 8) {
                                    notifier.setResult(
                                      'Message too large! Max: ${state.messageCapacity} characters',
                                    );
                                  } else {
                                    workImage =
                                        ImageSteganographyService.embedLSB(
                                          workImage,
                                          binary,
                                        );

                                    final pngData = img.encodePng(workImage);
                                    final timestamp =
                                        DateTime.now().millisecondsSinceEpoch;
                                    final file = File(
                                      '/tmp/stego_$timestamp.png',
                                    );
                                    await file.writeAsBytes(pngData);

                                    notifier.setResult(
                                      'Message hidden successfully!\nMethod: ${state.stegoMethod}\nBits: ${binary.length}\nEncryption: ${state.useEncryption ? state.encryptionMethod : 'None'}\nFile: ${file.path}',
                                    );
                                    notifier.setImage(workImage, file);
                                  }
                                } else {
                                  final hex =
                                      ImageSteganographyService.messageToHex(
                                        processedMessage,
                                      );
                                  final binary =
                                      ImageSteganographyService.hexToBinary(
                                        hex,
                                      );

                                  if (binary.length >
                                      state.messageCapacity * 8) {
                                    notifier.setResult(
                                      'Message too large! Max: ${state.messageCapacity} characters',
                                    );
                                  } else {
                                    final encodedAudio =
                                        AudioSteganographyService.embedInAudio(
                                          state.audioData!,
                                          binary,
                                        );

                                    final timestamp =
                                        DateTime.now().millisecondsSinceEpoch;
                                    final file = File(
                                      '/tmp/stego_$timestamp.wav',
                                    );
                                    await file.writeAsBytes(encodedAudio);

                                    notifier.setResult(
                                      'Message hidden in audio successfully!\nBits: ${binary.length}\nEncryption: ${state.useEncryption ? state.encryptionMethod : 'None'}\nFile: ${file.path}',
                                    );
                                    notifier.setAudio(
                                      file,
                                      encodedAudio,
                                      state.audioDuration,
                                    );
                                  }
                                }
                              } catch (e) {
                                notifier.setResult('Error: $e');
                              } finally {
                                notifier.setProcessing(false);
                              }
                            }
                            : null,
                    icon: const Icon(Icons.lock),
                    label: const Text('Hide Message'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed:
                        ((state.mediaType == MediaType.image &&
                                    state.image != null) ||
                                (state.mediaType == MediaType.audio &&
                                    state.audioData != null))
                            ? () async {
                              notifier.setProcessing(true);
                              try {
                                String message = '';

                                if (state.mediaType == MediaType.image) {
                                  final extractedHex =
                                      ImageSteganographyService.extractLSB(
                                        state.image!,
                                      );

                                  message =
                                      ImageSteganographyService.hexToMessage(
                                        extractedHex,
                                      );
                                } else {
                                  message =
                                      AudioSteganographyService.extractFromAudio(
                                        state.audioData!,
                                      );
                                }

                                if (state.useEncryption &&
                                    state.encryptionKey.isNotEmpty) {
                                  if (state.encryptionMethod == 'AES') {
                                    message = EncryptionService.decryptAES(
                                      message,
                                      state.encryptionKey,
                                    );
                                  } else {
                                    message = EncryptionService.decryptXOR(
                                      message,
                                      state.encryptionKey,
                                    );
                                  }
                                }

                                notifier.setExtractedMessage(message);
                                notifier.setResult(
                                  'Extracted Successfully!\n\n$message',
                                );
                              } catch (e) {
                                notifier.setResult('Extraction Error: $e');
                              } finally {
                                notifier.setProcessing(false);
                              }
                            }
                            : null,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Extract Message'),
                  ),
                  const SizedBox(height: 8),
                  if (state.outputFile != null ||
                      state.mediaType == MediaType.audio)
                    ElevatedButton.icon(
                      onPressed:
                          state.outputFile != null || state.audioFile != null
                              ? () async {
                                final fileToShare =
                                    state.outputFile ?? state.audioFile;
                                if (fileToShare != null) {
                                  await Share.shareXFiles([
                                    XFile(fileToShare.path),
                                  ]);
                                }
                              }
                              : null,
                      icon: const Icon(Icons.share),
                      label: const Text('Share File'),
                    ),
                ],
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),

            // Result Section
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Result',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      state.result.isEmpty
                          ? 'Results will appear here'
                          : state.result,
                      style: const TextStyle(fontSize: 13),
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
