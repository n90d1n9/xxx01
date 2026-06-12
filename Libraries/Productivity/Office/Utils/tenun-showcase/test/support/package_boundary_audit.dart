import 'dart:io';

class DartImportUsage {
  const DartImportUsage({
    required this.file,
    required this.directive,
    required this.uri,
    required this.lineNumber,
    required this.line,
  });

  final File file;
  final String directive;
  final String uri;
  final int lineNumber;
  final String line;
}

List<File> dartFilesIn(
  Directory packageRoot, {
  Iterable<String> directories = const ['lib'],
}) {
  final files = <File>[];

  for (final directoryName in directories) {
    final directory = Directory('${packageRoot.path}/$directoryName');
    if (!directory.existsSync()) {
      continue;
    }

    files.addAll(
      directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart')),
    );
  }

  files.sort((first, second) => first.path.compareTo(second.path));
  return List.unmodifiable(files);
}

List<DartImportUsage> dartImportUsagesIn(
  Directory packageRoot, {
  Iterable<String> directories = const ['lib'],
}) {
  final usages = <DartImportUsage>[];
  final directivePattern = RegExp(
    r'''^\s*(import|export)\s+['"]([^'"]+)['"]''',
  );

  for (final file in dartFilesIn(packageRoot, directories: directories)) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      final match = directivePattern.firstMatch(line);
      if (match == null) {
        continue;
      }

      usages.add(
        DartImportUsage(
          file: file,
          directive: match.group(1)!,
          uri: match.group(2)!,
          lineNumber: index + 1,
          line: line.trim(),
        ),
      );
    }
  }

  return List.unmodifiable(usages);
}

String relativePackagePath(File file, Directory packageRoot) {
  final rootPath = _normalizedDirectoryPath(packageRoot.absolute.path);
  final filePath = file.absolute.path.replaceAll(r'\', '/');
  if (!filePath.startsWith(rootPath)) {
    return filePath;
  }

  return filePath.substring(rootPath.length);
}

String formatImportUsages(
  Iterable<DartImportUsage> usages,
  Directory packageRoot,
) {
  return [
    for (final usage in usages)
      '${relativePackagePath(usage.file, packageRoot)}:${usage.lineNumber} '
          '${usage.directive} ${usage.uri}',
  ].join('\n');
}

String _normalizedDirectoryPath(String path) {
  final normalized = path.replaceAll(r'\', '/');
  return normalized.endsWith('/') ? normalized : '$normalized/';
}
