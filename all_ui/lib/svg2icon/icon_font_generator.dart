import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

class IconFontGenerator {
  final String inputDir;
  final String outputDir;
  final String fontName;
  final String className;
  final String fontFileName;

  IconFontGenerator({
    required this.inputDir,
    required this.outputDir,
    required this.fontName,
    required this.className,
    required this.fontFileName,
  });

  Future<void> generate() async {
    // Create output directory if it doesn't exist
    await Directory(outputDir).create(recursive: true);

    // Get all SVG files
    final svgFiles = await _getSvgFiles();

    if (svgFiles.isEmpty) {
      throw Exception('No SVG files found in $inputDir');
    }

    // Generate font configurations
    await _generateFontConfigs(svgFiles);

    // Generate Dart class
    await _generateDartClass(svgFiles);

    print('Generated ${svgFiles.length} icons:');
    for (final icon in svgFiles) {
      print('  ${icon['fileName']} -> ${icon['name']} (${icon['codePoint']})');
    }
  }

  Future<List<Map<String, String>>> _getSvgFiles() async {
    final dir = Directory(inputDir);

    // Check if directory exists
    if (!await dir.exists()) {
      throw Exception('Input directory does not exist: $inputDir');
    }

    // List all files in the directory
    final List<FileSystemEntity> files;
    try {
      files = await dir.list().toList();
    } catch (e) {
      throw Exception('Failed to list directory $inputDir: $e');
    }

    final svgFiles = <Map<String, String>>[];
    int codePoint = 0xE000; // Start from private use area

    for (final file in files) {
      // Only process files (not directories) that end with .svg
      if (file is File && file.path.toLowerCase().endsWith('.svg')) {
        final fileName = path.basenameWithoutExtension(file.path);
        final iconName = _toCamelCase(fileName);

        svgFiles.add({
          'name': iconName,
          'fileName': fileName,
          'filePath': file.path,
          'codePoint': '0x${codePoint.toRadixString(16).toUpperCase()}',
        });

        codePoint++;

        // Safety check to avoid too many icons
        if (codePoint > 0xE0FF) {
          print('Warning: Reached maximum number of icons (256)');
          break;
        }
      }
    }

    // Sort by name for consistent output
    svgFiles.sort((a, b) => a['fileName']!.compareTo(b['fileName']!));

    return svgFiles;
  }

  String _toCamelCase(String input) {
    // Handle empty strings
    if (input.isEmpty) return 'icon';

    // Convert snake_case, kebab-case, and spaces to camelCase
    final parts = input.replaceAll('-', '_').replaceAll(' ', '_').split('_');

    // Handle cases where the string might start with numbers or special characters
    var result = parts.first.toLowerCase();

    for (int i = 1; i < parts.length; i++) {
      final part = parts[i];
      if (part.isNotEmpty) {
        result += part[0].toUpperCase() + part.substring(1).toLowerCase();
      }
    }

    // Ensure the name is a valid Dart identifier
    if (result.isEmpty) return 'icon';
    if (result[0].contains(RegExp(r'[0-9]'))) {
      result = 'icon$result';
    }

    return result;
  }

  Future<void> _generateFontConfigs(List<Map<String, String>> icons) async {
    // Generate IcoMoon configuration
    final icomoonConfig = {
      'IcoMoonType': 'selection',
      'icons':
          icons
              .map(
                (icon) => {
                  'icon': {
                    'paths': [
                      'M50,0C22.4,0,0,22.4,0,50s22.4,50,50,50s50-22.4,50-50S77.6,0,50,0z M50,85c-19.3,0-35-15.7-35-35s15.7-35,35-35s35,15.7,35,35S69.3,85,50,85z',
                    ],
                    'tags': [icon['name']],
                    'grid': 16,
                  },
                  'attrs': [],
                  'properties': {
                    'order': icons.indexOf(icon) + 1,
                    'id': icons.indexOf(icon) + 1,
                    'name': icon['fileName'],
                    'prevSize': 32,
                    'code': int.parse(
                      icon['codePoint']!.replaceFirst('0x', ''),
                      radix: 16,
                    ),
                  },
                  'setIdx': 0,
                  'setId': 0,
                },
              )
              .toList(),
      'height': 1024,
      'metadata': {'name': fontName},
      'preferences': {
        'showGlyphs': true,
        'showCodes': true,
        'showQuickUse': true,
        'showQuickUse2': true,
        'showSVGs': true,
        'fontPref': {
          'prefix': 'icon',
          'metadata': {'fontFamily': fontName},
          'metrics': {'emSize': 1024, 'baseline': 6.25, 'whitespace': 50},
          'embed': false,
        },
        'imagePref': {
          'prefix': 'icon',
          'png': true,
          'useClassSelector': true,
          'color': 0,
          'bgColor': 16777215,
        },
        'historySize': 50,
      },
    };

    final icomoonFile = File(
      path.join(outputDir, '${fontFileName}_icomoon.json'),
    );
    await icomoonFile.writeAsString(jsonEncode(icomoonConfig));

    // Generate flutter-iconfont configuration
    final flutterConfig = {
      'font_family': fontName,
      'font_package': null,
      'icons':
          icons
              .map(
                (icon) => {
                  'name': icon['fileName'],
                  'style': 'regular',
                  'code': int.parse(
                    icon['codePoint']!.replaceFirst('0x', ''),
                    radix: 16,
                  ),
                },
              )
              .toList(),
    };

    final flutterFile = File(
      path.join(outputDir, '${fontFileName}_config.json'),
    );
    await flutterFile.writeAsString(jsonEncode(flutterConfig));

    print('Generated configuration files:');
    print('  - ${icomoonFile.path}');
    print('  - ${flutterFile.path}');
  }

  Future<void> _generateDartClass(List<Map<String, String>> icons) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('''
// This file is generated by icon_font_generator.dart
// Don't edit this file manually.

import 'package:flutter/widgets.dart';

''');

    // Class definition
    buffer.writeln('class $className {');
    buffer.writeln('  $className._();\n');

    // Font family constant
    buffer.writeln("  static const String _fontFamily = '$fontName';\n");

    // Icon data constants
    for (final icon in icons) {
      final name = icon['name']!;
      final codePoint = icon['codePoint']!;

      buffer.writeln('''
  /// ${icon['fileName']} icon
  static const IconData $name = IconData(
    $codePoint,
    fontFamily: _fontFamily,
  );''');
    }

    // All icons getter
    buffer.writeln('\n  /// All available icons as a map');
    buffer.writeln(
      '  static const Map<String, IconData> all = <String, IconData>{',
    );
    for (final icon in icons) {
      buffer.writeln("    '${icon['name']}': ${icon['name']},");
    }
    buffer.writeln('  };');

    buffer.writeln('}');

    // Save Dart file
    final dartFile = File(
      path.join(outputDir, '${className.toLowerCase()}.dart'),
    );
    await dartFile.writeAsString(buffer.toString());

    print('  - ${dartFile.path}');
  }
}
