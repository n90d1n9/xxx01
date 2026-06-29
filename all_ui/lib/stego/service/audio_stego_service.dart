import 'dart:convert';
import 'dart:typed_data';

class AudioSteganographyService {
  static Uint8List embedInAudio(Uint8List audioData, String binaryData) {
    final workData = Uint8List.fromList(audioData);
    final maxBits = audioData.length * 2;

    if (binaryData.length > maxBits) {
      throw Exception('Message too large for audio');
    }

    for (int i = 0; i < binaryData.length; i++) {
      final byteIndex = i ~/ 2;
      final bitPosition = i % 2;
      final bit = int.parse(binaryData[i]);

      if (byteIndex < workData.length) {
        if (bitPosition == 0) {
          workData[byteIndex] = (workData[byteIndex] & 0xFE) | bit;
        } else {
          workData[byteIndex] = (workData[byteIndex] & 0xFD) | (bit << 1);
        }
      }
    }

    return workData;
  }

  static String extractFromAudio(Uint8List audioData) {
    String binary = '';

    for (int i = 0; i < audioData.length; i++) {
      binary += (audioData[i] & 1).toString();
      binary += ((audioData[i] >> 1) & 1).toString();
    }

    String hex = '';
    for (int i = 0; i < binary.length; i += 4) {
      if (i + 4 <= binary.length) {
        hex += int.parse(
          binary.substring(i, i + 4),
          radix: 2,
        ).toRadixString(16);
      }
    }

    try {
      final bytes = <int>[];
      for (int i = 0; i < hex.length; i += 2) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
      return utf8.decode(bytes);
    } catch (e) {
      return 'Error: $e';
    }
  }
}
