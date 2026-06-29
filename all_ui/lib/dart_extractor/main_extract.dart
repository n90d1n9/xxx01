import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import 'package:path/path.dart' as path;

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart dart_extractor.dart path/to/input.dart [output_dir]',
    );
    stderr.writeln('Options:');
    stderr.writeln(
      '  path/to/input.dart - Required: Path to the Dart file to analyze',
    );
    stderr.writeln(
      '  output_dir         - Optional: Output directory for extracted files (default: ./extracted)',
    );
    stderr.writeln('');
    stderr.writeln('Examples:');
    stderr.writeln('  dart dart_extractor.dart monolith.dart');
    stderr.writeln('  dart dart_extractor.dart monolith.dart ./lib/src');
    stderr.writeln('  dart dart_extractor.dart monolith.dart --json-only');
    exit(1);
  }

  try {
    final inputPath = args[0];
    final outputDir =
        args.length > 1 && !args[1].startsWith('--') ? args[1] : './extracted';
    final jsonOnly = args.contains('--json-only');
    final separateFiles = args.contains('--separate-files');

    final result = await _extractDartCode(inputPath);

    if (jsonOnly) {
      // Original JSON output mode
      stdout.writeln(jsonEncode(result));
    } else {
      // Extract to separate files
      await _extractToSeparateFiles(
        inputPath,
        result,
        outputDir,
        separateFiles,
      );
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(2);
  }
}

Future<List<Map<String, dynamic>>> _extractDartCode(String filePath) async {
  final input = File(filePath);

  if (!input.existsSync()) {
    throw FileSystemException('File not found: $filePath');
  }

  final content = input.readAsStringSync();
  final result = parseString(content: content);
  final unit = result.unit;
  final List<Map<String, dynamic>> out = [];

  // Extract imports and exports
  final imports =
      unit.directives
          .whereType<ImportDirective>()
          .map((import) => import.toSource())
          .toList();

  final exports =
      unit.directives
          .whereType<ExportDirective>()
          .map((export) => export.toSource())
          .toList();

  // Process declarations
  for (final decl in unit.declarations) {
    final declarationData = _processDeclaration(decl, imports, exports);
    if (declarationData != null) {
      out.add(declarationData);
    }
  }

  return out;
}

Map<String, dynamic>? _processDeclaration(
  AstNode decl,
  List<String> imports,
  List<String> exports,
) {
  final allImports = [...imports, ...exports];

  if (decl is ClassDeclaration) {
    // Check if class is abstract by looking for 'abstract' keyword
    final isAbstract = decl.abstractKeyword != null;

    return {
      'type': 'class',
      'name': decl.name.lexeme,
      'imports': allImports,
      'content': decl.toSource(),
      'offset': decl.offset,
      'end': decl.end,
      'isAbstract': isAbstract,
      'hasImplements': decl.implementsClause != null,
      'hasExtends': decl.extendsClause != null,
      'hasWith': decl.withClause != null,
    };
  } else if (decl is FunctionDeclaration) {
    return {
      'type': 'function',
      'name': decl.name.lexeme,
      'imports': allImports,
      'content': decl.toSource(),
      'offset': decl.offset,
      'end': decl.end,
      'isGetter': decl.isGetter,
    };
  } else if (decl is EnumDeclaration) {
    return {
      'type': 'enum',
      'name': decl.name.lexeme,
      'imports': allImports,
      'content': decl.toSource(),
      'offset': decl.offset,
      'end': decl.end,
    };
  } else if (decl is MixinDeclaration) {
    return {
      'type': 'mixin',
      'name': decl.name.lexeme,
      'imports': allImports,
      'content': decl.toSource(),
      'offset': decl.offset,
      'end': decl.end,
    };
  } else if (decl is ExtensionDeclaration) {
    return {
      'type': 'extension',
      'name': decl.name?.lexeme,
      'imports': allImports,
      'content': decl.toSource(),
      'offset': decl.offset,
      'end': decl.end,
    };
  } else if (decl is TopLevelVariableDeclaration) {
    final variables =
        decl.variables.variables.map((v) => v.name.lexeme).toList();

    return {
      'type': 'top_level_variable',
      'names': variables,
      'imports': allImports,
      'content': decl.toSource(),
      'offset': decl.offset,
      'end': decl.end,
    };
  }

  return null;
}

Future<void> _extractToSeparateFiles(
  String inputFilePath,
  List<Map<String, dynamic>> declarations,
  String outputDir,
  bool separateFiles,
) async {
  final inputFile = File(inputFilePath);
  final inputFileName = path.basenameWithoutExtension(inputFilePath);
  final outputDirectory = Directory(outputDir);

  // Create output directory
  if (!outputDirectory.existsSync()) {
    outputDirectory.createSync(recursive: true);
  }

  // Generate main file that exports all extracted classes
  final mainFile = File(path.join(outputDir, '$inputFileName.dart'));
  final mainExports = StringBuffer();

  // Extract only classes for file separation
  final classes = declarations.where((d) => d['type'] == 'class').toList();
  final otherDeclarations =
      declarations.where((d) => d['type'] != 'class').toList();

  if (separateFiles) {
    // Extract each class to its own file
    for (final classDecl in classes) {
      final className = classDecl['name'] as String;
      final classFile = File(
        path.join(outputDir, '${_toSnakeCase(className)}.dart'),
      );

      final classContent = _buildClassFileContent(classDecl);
      await classFile.writeAsString(classContent);

      // Add export to main file
      mainExports.writeln("export '${_toSnakeCase(className)}.dart';");

      print('✓ Extracted class $className to ${classFile.path}');
    }

    // Write main export file
    if (classes.isNotEmpty) {
      await mainFile.writeAsString(mainExports.toString());
      print('✓ Created main export file: ${mainFile.path}');
    }
  } else {
    // Extract all classes to a single organized file
    final organizedContent = _buildOrganizedFileContent(declarations);
    await mainFile.writeAsString(organizedContent);
    print('✓ Created organized file: ${mainFile.path}');
  }

  // Create a summary report
  final classCount = classes.length;
  final otherCount = otherDeclarations.length;

  print('\n📊 Extraction Summary:');
  print('  Classes: $classCount');
  print('  Other declarations: $otherCount');
  print('  Output directory: ${outputDirectory.absolute.path}');
}

String _buildClassFileContent(Map<String, dynamic> classDecl) {
  final buffer = StringBuffer();

  // Add imports
  final imports = (classDecl['imports'] as List).cast<String>();
  for (final import in imports) {
    buffer.writeln(import);
  }
  buffer.writeln();

  // Add class content
  buffer.writeln(classDecl['content']);

  return buffer.toString();
}

String _buildOrganizedFileContent(List<Map<String, dynamic>> declarations) {
  final buffer = StringBuffer();

  // Collect all unique imports
  final allImports = <String>{};
  for (final decl in declarations) {
    final imports = (decl['imports'] as List).cast<String>();
    allImports.addAll(imports);
  }

  // Add imports
  for (final import in allImports) {
    buffer.writeln(import);
  }
  buffer.writeln();

  // Group by type for better organization
  final groups = <String, List<Map<String, dynamic>>>{};
  for (final decl in declarations) {
    final type = decl['type'] as String;
    groups.putIfAbsent(type, () => []).add(decl);
  }

  // Write in logical order
  const writeOrder = [
    'class',
    'mixin',
    'enum',
    'extension',
    'function',
    'top_level_variable',
  ];

  for (final type in writeOrder) {
    final declarationsOfType = groups[type];
    if (declarationsOfType != null && declarationsOfType.isNotEmpty) {
      buffer.writeln('// ${type.toUpperCase()}S');
      buffer.writeln();

      for (final decl in declarationsOfType) {
        buffer.writeln(decl['content']);
        buffer.writeln();
      }
    }
  }

  return buffer.toString();
}

String _toSnakeCase(String className) {
  // Convert ClassName to class_name
  return className
      .replaceAllMapped(
        RegExp(r'(?<=[a-z])[A-Z]'),
        (Match m) => '_${m.group(0)!.toLowerCase()}',
      )
      .toLowerCase();
}

// Helper extension for firstOrNull
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstOrNull() {
    for (E element in this) {
      return element;
    }
    return null;
  }
}
