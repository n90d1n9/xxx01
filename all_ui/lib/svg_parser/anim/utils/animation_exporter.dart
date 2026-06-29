import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../schema/animation_definition.dart';

class AnimationExporter {
  /// Export to JSON string
  static String exportToJson(
    SvgAnimationDefinition animation, {
    bool pretty = true,
  }) {
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(animation.toJson());
    }
    return jsonEncode(animation.toJson());
  }

  /// Export to Lottie JSON
  static String exportToLottie(
    SvgAnimationDefinition animation, {
    bool pretty = true,
  }) {
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(animation.toLottie());
    }
    return jsonEncode(animation.toLottie());
  }

  /// Export to Rive JSON
  static String exportToRive(
    SvgAnimationDefinition animation, {
    bool pretty = true,
  }) {
    if (pretty) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(animation.toRive());
    }
    return jsonEncode(animation.toRive());
  }

  /// Import from JSON string
  static SvgAnimationDefinition importFromJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SvgAnimationDefinition.fromJson(json);
  }

  /// Save to file (placeholder - implement with file_picker package)
  static Future<void> saveToFile(String content, String filename) async {
    // TODO: Implement file saving
    debugPrint('Saving $filename with ${content.length} bytes');
  }

  /// Load from file (placeholder - implement with file_picker package)
  static Future<String> loadFromFile(String filename) async {
    // TODO: Implement file loading
    return '';
  }
}
