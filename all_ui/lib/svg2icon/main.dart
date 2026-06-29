import 'dart:io';
import 'package:args/args.dart';
import 'icon_font_generator.dart';

void main(List<String> arguments) async {
  final parser =
      ArgParser()
        ..addOption(
          'input',
          abbr: 'i',
          help: 'Input directory containing SVG files',
        )
        ..addOption(
          'output',
          abbr: 'o',
          help: 'Output directory for generated files',
        )
        ..addOption(
          'font-name',
          help: 'Name of the font family',
          defaultsTo: 'CustomIcons',
        )
        ..addOption(
          'class-name',
          help: 'Name of the Dart class',
          defaultsTo: 'CustomIcons',
        )
        ..addOption(
          'font-file',
          help: 'Name of the font file',
          defaultsTo: 'custom_icons',
        )
        ..addFlag(
          'help',
          abbr: 'h',
          help: 'Show usage information',
          negatable: false,
        );

  try {
    final results = parser.parse(arguments);

    if (results['help'] || arguments.isEmpty) {
      print('''
Icon Font Generator

Usage: dart main.dart -i <input_dir> -o <output_dir> [options]

Options:
${parser.usage}

Example:
  dart main.dart -i ./assets/svg -o ./lib/icons --font-name MyIcons --class-name MyIcons
''');
      return;
    }

    final inputDir = results['input'] as String?;
    final outputDir = results['output'] as String?;

    if (inputDir == null || outputDir == null) {
      throw ArgumentError('Both input and output directories are required');
    }

    // Validate input directory exists
    final inputDirectory = Directory(inputDir);
    if (!await inputDirectory.exists()) {
      throw ArgumentError('Input directory does not exist: $inputDir');
    }

    final generator = IconFontGenerator(
      inputDir: inputDir,
      outputDir: outputDir,
      fontName: results['font-name'] as String,
      className: results['class-name'] as String,
      fontFileName: results['font-file'] as String,
    );

    await generator.generate();
    print('Icon font generation completed successfully!');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
