import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'message.dart';

class StegoState {
  final img.Image? image;
  final File? audioFile;
  final Uint8List? audioData;
  final String message;
  final String encryptionKey;
  final bool useEncryption;
  final String encryptionMethod;
  final String result;
  final bool isProcessing;
  final String? extractedMessage;
  final File? outputFile;
  final int messageCapacity;
  final String stegoMethod;
  final MediaType mediaType;
  final MessageSource messageSource;
  final String audioDuration;
  final double progress; // 0.0 to 1.0
  final String currentOperation;
  final int currentStep;
  final int totalSteps;

  StegoState({
    this.image,
    this.audioFile,
    this.audioData,
    this.message = '',
    this.encryptionKey = '',
    this.useEncryption = false,
    this.encryptionMethod = 'AES',
    this.result = '',
    this.isProcessing = false,
    this.extractedMessage,
    this.outputFile,
    this.messageCapacity = 0,
    this.stegoMethod = 'LSB',
    this.mediaType = MediaType.image,
    this.messageSource = MessageSource.text,
    this.audioDuration = '0:00',
    this.progress = 0.0,
    this.currentOperation = '',
    this.currentStep = 0,
    this.totalSteps = 0,
  });

  StegoState copyWith({
    img.Image? image,
    File? audioFile,
    Uint8List? audioData,
    String? message,
    String? encryptionKey,
    bool? useEncryption,
    String? encryptionMethod,
    String? result,
    bool? isProcessing,
    String? extractedMessage,
    File? outputFile,
    int? messageCapacity,
    String? stegoMethod,
    MediaType? mediaType,
    MessageSource? messageSource,
    String? audioDuration,
    double? progress,
    String? currentOperation,
    int? currentStep,
    int? totalSteps,
  }) {
    return StegoState(
      image: image ?? this.image,
      audioFile: audioFile ?? this.audioFile,
      audioData: audioData ?? this.audioData,
      message: message ?? this.message,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      useEncryption: useEncryption ?? this.useEncryption,
      encryptionMethod: encryptionMethod ?? this.encryptionMethod,
      result: result ?? this.result,
      isProcessing: isProcessing ?? this.isProcessing,
      extractedMessage: extractedMessage ?? this.extractedMessage,
      outputFile: outputFile ?? this.outputFile,
      messageCapacity: messageCapacity ?? this.messageCapacity,
      stegoMethod: stegoMethod ?? this.stegoMethod,
      mediaType: mediaType ?? this.mediaType,
      messageSource: messageSource ?? this.messageSource,
      audioDuration: audioDuration ?? this.audioDuration,
      progress: progress ?? this.progress,
      currentOperation: currentOperation ?? this.currentOperation,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}
