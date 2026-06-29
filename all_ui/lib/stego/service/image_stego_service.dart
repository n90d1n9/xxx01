import 'dart:convert';
import 'package:image/image.dart' as imglib;

class ImageSteganographyService {
  static String messageToHexUtf8(String message) {
    final bytes = utf8.encode(message);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  // When embedding:
  static String messageToHexB64(String message) {
    final bytes = utf8.encode(message);
    final base64Encoded = base64.encode(bytes); // Encode to base64 first
    return base64Encoded.codeUnits
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join('');
  }

  // When extracting:
  static String hexToMessageB64(String hex) {
    try {
      final bytes = <int>[];
      for (int i = 0; i < hex.length; i += 2) {
        if (i + 2 <= hex.length) {
          final byteStr = hex.substring(i, i + 2);
          bytes.add(int.parse(byteStr, radix: 16));
        }
      }

      // Decode from base64 first, then to UTF-8
      final base64String = String.fromCharCodes(bytes);
      final decodedBytes = base64.decode(base64String);
      return utf8.decode(decodedBytes);
    } catch (e) {
      return 'Error decoding message: $e';
    }
  }

  static String hexToMessageUtf8(String hex) {
    try {
      final bytes = <int>[];
      for (int i = 0; i < hex.length; i += 2) {
        if (i + 2 <= hex.length) {
          final byteStr = hex.substring(i, i + 2);
          // Skip non-hex characters that might be from empty pixels
          if (byteStr.contains(RegExp(r'[^0-9a-fA-F]'))) continue;
          bytes.add(int.parse(byteStr, radix: 16));
        }
      }

      // Try to decode as UTF-8, but handle invalid sequences gracefully
      final utf8Decoder = Utf8Codec(allowMalformed: true);
      return utf8Decoder.decode(bytes);
    } catch (e) {
      return 'Error decoding message: $e';
    }
  }

  static String hexToBinary(String hex) {
    return hex
        .split('')
        .map((c) => int.parse(c, radix: 16).toRadixString(2).padLeft(4, '0'))
        .join('');
  }

  static imglib.Image embedLSB(imglib.Image image, String binaryData) {
    final width = image.width;
    final height = image.height;

    // Add termination marker (null character in hex: "00")
    binaryData += '0000'; // Two null bytes as termination marker

    for (int i = 0; i < binaryData.length; i++) {
      final pixelIndex = i ~/ 3;
      final row = pixelIndex ~/ width;
      final col = pixelIndex % width;
      final channel = i % 3;

      if (row >= height || col >= width) break;

      final pixel = image.getPixel(col, row);
      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();
      int a = pixel.a.toInt();

      final bit = int.parse(binaryData[i]);

      if (channel == 0) {
        r = (r & 0xFE) | bit;
      } else if (channel == 1) {
        g = (g & 0xFE) | bit;
      } else {
        b = (b & 0xFE) | bit;
      }

      image.setPixelRgba(col, row, r, g, b, a);
    }

    return image;
  }

  static String extractLSB(imglib.Image image) {
    final width = image.width;
    final height = image.height;
    String binary = '';

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final pixel = image.getPixel(col, row);
        binary += (pixel.r.toInt() & 1).toString();
        binary += (pixel.g.toInt() & 1).toString();
        binary += (pixel.b.toInt() & 1).toString();
      }
    }

    String hex = '';
    for (int i = 0; i < binary.length; i += 4) {
      if (i + 4 <= binary.length) {
        final nibble = binary.substring(i, i + 4);
        final hexChar = int.parse(nibble, radix: 2).toRadixString(16);
        hex += hexChar;

        // Check for termination marker (two consecutive null bytes: "0000" in binary becomes "00" in hex)
        if (hex.length >= 4 && hex.substring(hex.length - 4) == '0000') {
          hex = hex.substring(0, hex.length - 4); // Remove termination marker
          break; // Stop extraction
        }
      }
    }

    return hex;
  }
}
