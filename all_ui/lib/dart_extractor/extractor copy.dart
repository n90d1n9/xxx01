import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart dart_extractor.dart path/to/input.dart [output_dir]',
    );
    stderr.writeln('  path/to/input.dart - Dart file to extract classes from');
    stderr.writeln(
      '  output_dir         - Output directory (default: ./extracted)',
    );
    exit(1);
  }

  try {
    final inputPath = args[0];
    final outputDir = args.length > 1 ? args[1] : './extracted';

    await _extractClassesToSeparateFiles(inputPath, outputDir);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(2);
  }
}

Future<void> _extractClassesToSeparateFiles(
  String inputFilePath,
  String outputDir,
) async {
  final inputFile = File(inputFilePath);

  if (!inputFile.existsSync()) {
    throw FileSystemException('File not found: $inputFilePath');
  }

  final content = inputFile.readAsStringSync();
  final result = parseString(content: content);
  final unit = result.unit;

  // Create output directory
  final outputDirectory = Directory(outputDir);
  if (!outputDirectory.existsSync()) {
    outputDirectory.createSync(recursive: true);
    print('📁 Created directory: $outputDir');
  }

  // Extract original imports from the file
  final originalImports =
      unit.directives
          .whereType<ImportDirective>()
          .map((import) => import.toSource())
          .toList();

  // First pass: collect all declaration names
  final allDeclarations = <Map<String, dynamic>>[];
  final allClassNames = <String>{};

  for (final decl in unit.declarations) {
    if (decl is ClassDeclaration) {
      final className = decl.name.lexeme;
      allClassNames.add(className);
      allDeclarations.add({
        'type': 'class',
        'name': className,
        'declaration': decl,
      });
    } else if (decl is EnumDeclaration) {
      final enumName = decl.name.lexeme;
      allClassNames.add(enumName);
      allDeclarations.add({
        'type': 'enum',
        'name': enumName,
        'declaration': decl,
      });
    } else if (decl is MixinDeclaration) {
      final mixinName = decl.name.lexeme;
      allClassNames.add(mixinName);
      allDeclarations.add({
        'type': 'mixin',
        'name': mixinName,
        'declaration': decl,
      });
    } else if (decl is ExtensionDeclaration) {
      final extensionName =
          decl.name?.lexeme ?? 'extension_${allDeclarations.length}';
      allDeclarations.add({
        'type': 'extension',
        'name': extensionName,
        'declaration': decl,
      });
    }
  }

  // Second pass: find dependencies now that we have all class names
  for (final declData in allDeclarations) {
    final declaration = declData['declaration'] as AstNode;
    final dependencies = _findDependencies(declaration, allClassNames);
    declData['dependencies'] = dependencies;
  }

  // Now create files with proper imports
  int createdCount = 0;
  for (final declData in allDeclarations) {
    await _createDeclarationFile(declData, originalImports, outputDir);
    createdCount++;
  }

  // Create main export file
  await _createMainExportFile(allDeclarations, outputDir);

  print('\n✅ Extraction Complete!');
  print('📊 Summary:');
  print('   Files created: $createdCount');
  print('   Output directory: ${outputDirectory.absolute.path}');
}

Set<String> _findDependencies(AstNode decl, Set<String> availableClasses) {
  final dependencies = <String>{};
  final sourceCode = decl.toSource();

  // Look for class names in the source code that match available classes
  for (final className in availableClasses) {
    // Use regex to find class usage (avoid matching in comments and strings)
    final pattern = RegExp(r'\b' + className + r'\b');
    if (pattern.hasMatch(sourceCode)) {
      // Basic check to avoid false positives
      if (_isLikelyDependency(sourceCode, className)) {
        dependencies.add(className);
      }
    }
  }

  // Remove self-reference
  if (decl is ClassDeclaration) {
    dependencies.remove(decl.name.lexeme);
  } else if (decl is EnumDeclaration) {
    dependencies.remove(decl.name.lexeme);
  } else if (decl is MixinDeclaration) {
    dependencies.remove(decl.name.lexeme);
  }

  return dependencies;
}

bool _isLikelyDependency(String sourceCode, String className) {
  // Simple heuristic to avoid false positives
  // Look for patterns that suggest actual usage rather than just the name appearing
  final usagePatterns = [
    RegExp(r'\b' + className + r'\s+\w+'), // ClassName variableName
    RegExp(r'\b' + className + r'\([^)]*\)'), // ClassName(...)
    RegExp(r'\b' + className + r'\.'), // ClassName.
    RegExp(r'\b' + className + r'\[[^\]]*\]'), // ClassName[...]
    RegExp(r'<\s*' + className + r'\s*>'), // <ClassName>
    RegExp(r'List<\s*' + className + r'\s*>'), // List<ClassName>
    RegExp(r'Map<[^,]*,\s*' + className + r'\s*>'), // Map<Something, ClassName>
    RegExp(r'Future<\s*' + className + r'\s*>'), // Future<ClassName>
  ];

  return usagePatterns.any((pattern) => pattern.hasMatch(sourceCode));
}

Future<void> _createDeclarationFile(
  Map<String, dynamic> declData,
  List<String> originalImports,
  String outputDir,
) async {
  final type = declData['type'] as String;
  final name = declData['name'] as String;
  final declaration = declData['declaration'] as AstNode;
  final dependencies = (declData['dependencies'] as Set<String>).cast<String>();

  final fileName = '${_toSnakeCase(name)}.dart';
  final filePath = path.join(outputDir, fileName);

  final content = StringBuffer();

  // Add original imports
  for (final import in originalImports) {
    content.writeln(import);
  }

  // Add imports for dependencies (other classes in the same directory)
  final localImports = <String>{};
  for (final dependency in dependencies) {
    final dependencyFile = '${_toSnakeCase(dependency)}.dart';
    localImports.add("import '$dependencyFile';");
  }

  // Add local imports after package imports
  if (localImports.isNotEmpty) {
    content.writeln();
    for (final import in localImports) {
      content.writeln(import);
    }
  }

  content.writeln();

  // Add declaration content
  content.writeln(declaration.toSource());

  await File(filePath).writeAsString(content.toString());

  final dependencyInfo =
      dependencies.isNotEmpty
          ? ' (depends on: ${dependencies.join(', ')})'
          : '';
  print('✓ Created: $fileName$dependencyInfo');
}

Future<void> _createMainExportFile(
  List<Map<String, dynamic>> allDeclarations,
  String outputDir,
) async {
  final exports = StringBuffer();
  exports.writeln(
    '// Main export file - import this to get all extracted classes',
  );
  exports.writeln();

  for (final declData in allDeclarations) {
    final name = declData['name'] as String;
    final fileName = '${_toSnakeCase(name)}.dart';
    exports.writeln("export '$fileName';");
  }

  if (exports.isNotEmpty) {
    final mainFile = File(path.join(outputDir, 'all_exports.dart'));
    await mainFile.writeAsString(exports.toString());
    print('✓ Created: all_exports.dart');
  }
}

String _toSnakeCase(String className) {
  return className
      .replaceAllMapped(
        RegExp(r'(?<=[a-z])[A-Z]'),
        (Match m) => '_${m.group(0)!.toLowerCase()}',
      )
      .toLowerCase();
}
