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

  // Extract imports
  final imports =
      unit.directives
          .whereType<ImportDirective>()
          .map((import) => import.toSource())
          .toList();

  int classCount = 0;
  int otherCount = 0;

  // Process each declaration
  for (final decl in unit.declarations) {
    if (decl is ClassDeclaration) {
      await _createClassFile(decl, imports, outputDir);
      classCount++;
    } else if (decl is EnumDeclaration) {
      await _createEnumFile(decl, imports, outputDir);
      otherCount++;
    } else if (decl is MixinDeclaration) {
      await _createMixinFile(decl, imports, outputDir);
      otherCount++;
    } else if (decl is ExtensionDeclaration) {
      await _createExtensionFile(decl, imports, outputDir);
      otherCount++;
    }
  }

  // Create main export file
  await _createMainExportFile(unit, outputDir);

  print('\n✅ Extraction Complete!');
  print('📊 Summary:');
  print('   Classes: $classCount');
  print('   Other declarations: $otherCount');
  print('   Output directory: ${outputDirectory.absolute.path}');
}

Future<void> _createClassFile(
  ClassDeclaration classDecl,
  List<String> imports,
  String outputDir,
) async {
  final className = classDecl.name.lexeme;
  final fileName = '${_toSnakeCase(className)}.dart';
  final filePath = path.join(outputDir, fileName);

  final content = StringBuffer();

  // Add imports
  for (final import in imports) {
    content.writeln(import);
  }
  content.writeln();

  // Add class content
  content.writeln(classDecl.toSource());

  await File(filePath).writeAsString(content.toString());
  print('✓ Created: $fileName');
}

Future<void> _createEnumFile(
  EnumDeclaration enumDecl,
  List<String> imports,
  String outputDir,
) async {
  final enumName = enumDecl.name.lexeme;
  final fileName = '${_toSnakeCase(enumName)}.dart';
  final filePath = path.join(outputDir, fileName);

  final content = StringBuffer();

  // Add imports
  for (final import in imports) {
    content.writeln(import);
  }
  content.writeln();

  // Add enum content
  content.writeln(enumDecl.toSource());

  await File(filePath).writeAsString(content.toString());
  print('✓ Created: $fileName');
}

Future<void> _createMixinFile(
  MixinDeclaration mixinDecl,
  List<String> imports,
  String outputDir,
) async {
  final mixinName = mixinDecl.name.lexeme;
  final fileName = '${_toSnakeCase(mixinName)}.dart';
  final filePath = path.join(outputDir, fileName);

  final content = StringBuffer();

  // Add imports
  for (final import in imports) {
    content.writeln(import);
  }
  content.writeln();

  // Add mixin content
  content.writeln(mixinDecl.toSource());

  await File(filePath).writeAsString(content.toString());
  print('✓ Created: $fileName');
}

Future<void> _createExtensionFile(
  ExtensionDeclaration extensionDecl,
  List<String> imports,
  String outputDir,
) async {
  final extensionName = extensionDecl.name?.lexeme ?? 'extension';
  final fileName = '${_toSnakeCase(extensionName)}.dart';
  final filePath = path.join(outputDir, fileName);

  final content = StringBuffer();

  // Add imports
  for (final import in imports) {
    content.writeln(import);
  }
  content.writeln();

  // Add extension content
  content.writeln(extensionDecl.toSource());

  await File(filePath).writeAsString(content.toString());
  print('✓ Created: $fileName');
}

Future<void> _createMainExportFile(
  CompilationUnit unit,
  String outputDir,
) async {
  final exports = StringBuffer();

  for (final decl in unit.declarations) {
    if (decl is ClassDeclaration) {
      final className = decl.name.lexeme;
      exports.writeln("export '${_toSnakeCase(className)}.dart';");
    } else if (decl is EnumDeclaration) {
      final enumName = decl.name.lexeme;
      exports.writeln("export '${_toSnakeCase(enumName)}.dart';");
    } else if (decl is MixinDeclaration) {
      final mixinName = decl.name.lexeme;
      exports.writeln("export '${_toSnakeCase(mixinName)}.dart';");
    } else if (decl is ExtensionDeclaration) {
      final extensionName = decl.name?.lexeme ?? 'extension';
      exports.writeln("export '${_toSnakeCase(extensionName)}.dart';");
    }
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
