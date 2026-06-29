import 'dart:io';

import 'dart:io';

class FileCombiner {
  final String inputDirectory;
  final String outputFile;
  final List<String> fileExtensions;
  final bool showFilePaths;
  final bool verbose;

  FileCombiner({
    required this.inputDirectory,
    required this.outputFile,
    required this.fileExtensions,
    this.showFilePaths = false, // Changed default to false
    this.verbose = false,
  });

  Future<CombinerResult> combine() async {
    final directory = Directory(inputDirectory);
    final output = File(outputFile);
    final outputSink = output.openWrite();

    int totalFiles = 0;
    int skippedFiles = 0;
    final processedFiles = <String>[];
    final skippedFilesList = <String>[];

    if (!directory.existsSync()) {
      throw Exception('Input directory does not exist: ${directory.path}');
    }

    print('Combining text files...');
    print('Input directory: ${directory.absolute.path}');
    print('Output file: ${output.absolute.path}');
    print('File extensions: ${fileExtensions.join(", ")}');
    print('Show file paths: $showFilePaths');
    print('---');

    await _processDirectory(directory, outputSink, (filePath, isProcessed) {
      if (isProcessed) {
        totalFiles++;
        processedFiles.add(filePath);
        if (verbose) {
          print('✓ Added: $filePath');
        }
      } else {
        skippedFiles++;
        skippedFilesList.add(filePath);
        if (verbose) {
          print('✗ Skipped: $filePath');
        }
      }
    });

    await outputSink.close();

    print('---');
    print('Combination completed!');
    print('Total files processed: $totalFiles');
    print('Files skipped: $skippedFiles');
    print('Output file: ${output.absolute.path}');

    return CombinerResult(
      totalFiles: totalFiles,
      skippedFiles: skippedFiles,
      processedFiles: processedFiles,
      skippedFilesList: skippedFilesList,
      outputPath: output.absolute.path,
    );
  }

  Future<void> _processDirectory(
    Directory directory,
    IOSink outputSink,
    void Function(String filePath, bool isProcessed) callback,
  ) async {
    final entities = directory.listSync(recursive: false);

    for (final entity in entities) {
      if (entity is File) {
        final file = entity;
        final filePath = file.path;
        final shouldProcess = _shouldProcessFile(filePath);

        if (shouldProcess) {
          try {
            if (showFilePaths) {
              // Only show headers if flag is enabled
              outputSink.writeln('=' * 80);
              outputSink.writeln('FILE: $filePath');
              outputSink.writeln('=' * 80);
              outputSink.writeln();
            }

            final content = await file.readAsString();
            outputSink.writeln(content);
            outputSink.writeln();

            callback(filePath, true);
          } catch (e) {
            print('Error reading file $filePath: $e');
            callback(filePath, false);
          }
        } else {
          callback(filePath, false);
        }
      } else if (entity is Directory) {
        await _processDirectory(entity, outputSink, callback);
      }
    }
  }

  bool _shouldProcessFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return false;

    final fileExtension = _getFileExtension(filePath);
    return fileExtensions.any(
      (ext) => fileExtension.toLowerCase() == ext.toLowerCase(),
    );
  }

  String _getFileExtension(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex == -1 ? '' : fileName.substring(dotIndex);
  }
}

class CombinerResult {
  final int totalFiles;
  final int skippedFiles;
  final List<String> processedFiles;
  final List<String> skippedFilesList;
  final String outputPath;

  CombinerResult({
    required this.totalFiles,
    required this.skippedFiles,
    required this.processedFiles,
    required this.skippedFilesList,
    required this.outputPath,
  });
}

void main(List<String> arguments) async {
  // Default configuration
  String inputDirectory = '.';
  String outputFile = 'combined_files.txt';
  List<String> fileExtensions = [
    '.dart',
    '.java',
    '.kt',
    '.swift',
    '.js',
    '.ts',
    '.py',
    '.txt',
    '.md',
    '.yaml',
    '.yml',
    '.json',
    '.xml',
  ];
  bool verbose = false;
  bool showFilePaths = false; // Changed default to false

  // Simple argument parsing
  for (int i = 0; i < arguments.length; i++) {
    switch (arguments[i]) {
      case '--input':
      case '-i':
        if (i + 1 < arguments.length) {
          inputDirectory = arguments[++i];
        }
        break;
      case '--output':
      case '-o':
        if (i + 1 < arguments.length) {
          outputFile = arguments[++i];
        }
        break;
      case '--extensions':
      case '-e':
        if (i + 1 < arguments.length) {
          fileExtensions =
              arguments[++i]
                  .split(',')
                  .map((ext) => ext.startsWith('.') ? ext : '.$ext')
                  .toList();
        }
        break;
      case '--show-paths':
      case '-p': // New flag to show file paths
        showFilePaths = true;
        break;
      case '--verbose':
      case '-v':
        verbose = true;
        break;
      case '--help':
      case '-h':
        _printHelp();
        return;
    }
  }

  try {
    final combiner = FileCombiner(
      inputDirectory: inputDirectory,
      outputFile: outputFile,
      fileExtensions: fileExtensions,
      showFilePaths: showFilePaths, // Pass the flag
      verbose: verbose,
    );

    await combiner.combine();
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _printHelp() {
  print('''
File Combiner - Combine text files from a directory and its subdirectories

Usage: dart combine_files.dart [options]

Options:
  -i, --input <dir>      Input directory (default: current directory)
  -o, --output <file>    Output file (default: combined_files.txt)
  -e, --extensions <ext> Comma-separated file extensions (default: .dart,.java,.txt,.md,etc.)
  -p, --show-paths       Show file paths in output (default: false)
  -v, --verbose          Verbose output
  -h, --help             Show this help message

Examples:
  dart combine_files.dart
  dart combine_files.dart -i ./src -o output.txt
  dart combine_files.dart -i ./project -e .dart,.java,.kt -v
  dart combine_files.dart -p  # Show file paths in output
''');
}
