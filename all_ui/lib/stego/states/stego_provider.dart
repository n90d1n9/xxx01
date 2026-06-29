import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

import '../models/message.dart';
import '../models/stego_state.dart';
import '../service/encryption_service.dart';
import '../service/image_stego_service.dart';

final stegoStateProvider = StateNotifierProvider<StegoNotifier, StegoState>(
  (ref) => StegoNotifier(),
);

class StegoNotifier extends StateNotifier<StegoState> {
  StegoNotifier() : super(StegoState());

  void _updateProgress(
    double progress,
    String operation, {
    int? currentStep,
    int? totalSteps,
  }) {
    state = state.copyWith(
      progress: progress,
      currentOperation: operation,
      currentStep: currentStep,
      totalSteps: totalSteps,
    );
  }

  Future<void> hideMessage() async {
    state = state.copyWith(isProcessing: true, progress: 0.0);

    try {
      _updateProgress(0.1, 'Preparing message...');

      String processedMessage = state.message;

      if (state.useEncryption && state.encryptionKey.isNotEmpty) {
        _updateProgress(0.3, 'Encrypting message...');
        if (state.encryptionMethod == 'AES') {
          processedMessage = EncryptionService.encryptAES(
            state.message,
            state.encryptionKey,
          );
        } else {
          processedMessage = EncryptionService.encryptXOR(
            state.message,
            state.encryptionKey,
          );
        }
      }

      _updateProgress(0.5, 'Embedding in media...');

      if (state.mediaType == MediaType.image) {
        var workImage = state.image!.clone();
        final hex = ImageSteganographyService.messageToHexB64(processedMessage);
        final binary = ImageSteganographyService.hexToBinary(hex);

        _updateProgress(0.7, 'Applying steganography...');
        workImage = ImageSteganographyService.embedLSB(workImage, binary);

        _updateProgress(0.9, 'Saving file...');
        final pngData = imglib.encodePng(workImage);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFile = File(
          '${(await getTemporaryDirectory()).path}/stego_$timestamp.png',
        );
        await tempFile.writeAsBytes(pngData);

        _updateProgress(1.0, 'Complete!');
        setResult('Message hidden successfully!');
        setImage(workImage, tempFile);
      }
    } catch (e) {
      setResult('Error: $e');
    } finally {
      state = state.copyWith(isProcessing: false, progress: 0.0);
    }
  }

  void updateMessage(String message) {
    state = state.copyWith(message: message);
  }

  void updateEncryptionKey(String key) {
    state = state.copyWith(encryptionKey: key);
  }

  void toggleEncryption(bool value) {
    state = state.copyWith(useEncryption: value);
  }

  void setEncryptionMethod(String method) {
    state = state.copyWith(encryptionMethod: method);
  }

  void setStegoMethod(String method) {
    state = state.copyWith(stegoMethod: method);
  }

  void setMediaType(MediaType type) {
    state = state.copyWith(mediaType: type, image: null, audioFile: null);
  }

  void setMessageSource(MessageSource source) {
    state = state.copyWith(messageSource: source, message: '');
  }

  void setImage(img.Image image, File? file) {
    final capacity = _calculateImageCapacity(image);
    state = state.copyWith(
      image: image,
      outputFile: file,
      messageCapacity: capacity,
      result:
          'Image loaded: ${image.width}x${image.height}. Capacity: $capacity chars',
    );
  }

  void setAudio(File file, Uint8List data, String duration) {
    final capacity = _calculateAudioCapacity(data.length);
    state = state.copyWith(
      audioFile: file,
      audioData: data,
      messageCapacity: capacity,
      audioDuration: duration,
      result: 'Audio loaded: $duration. Capacity: $capacity chars',
    );
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  void setResult(String result) {
    state = state.copyWith(result: result);
  }

  void setExtractedMessage(String message) {
    state = state.copyWith(extractedMessage: message);
  }

  int _calculateImageCapacity(img.Image image) {
    final pixels = image.width * image.height;
    return (pixels * 3) ~/ 8;
  }

  int _calculateAudioCapacity(int audioSize) {
    return (audioSize * 2) ~/ 8;
  }

  void reset() {
    state = StegoState();
  }
}
