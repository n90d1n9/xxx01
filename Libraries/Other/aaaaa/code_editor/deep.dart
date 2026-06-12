import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart'; // Pre-defined theme
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/php.dart';
import 'package:highlight/languages/yaml.dart'; // YAML language
import 'package:highlight/languages/json.dart'; // JSON language
import 'package:highlight/languages/java.dart'; // Java language
import 'package:highlight/languages/python.dart'; // Python language
import 'package:highlight/languages/typescript.dart'; // TypeScript language

class MultiLanguageCodeEditor extends StatefulWidget {
  final Map<String, String> codeSnippets; // Map of language to code snippet

  const MultiLanguageCodeEditor({super.key, required this.codeSnippets});

  @override
  State<MultiLanguageCodeEditor> createState() =>
      _MultiLanguageCodeEditorState();
}

class _MultiLanguageCodeEditorState extends State<MultiLanguageCodeEditor> {
  late CodeController _codeController;
  String _selectedLanguage = 'yaml'; // Default language

  @override
  void initState() {
    super.initState();
    _updateCodeController();
  }

  void _updateCodeController() {
    _codeController = CodeController(
      text: widget.codeSnippets[_selectedLanguage] ?? '',
      language: _getLanguageFromString(_selectedLanguage),
    );
  }

  Mode _getLanguageFromString(String language) {
    switch (language) {
      case 'yaml':
        return yaml;
      case 'json':
        return json;
      case 'java':
        return java;
      case 'python':
        return python;
      case 'typescript':
        return typescript;
      default:
        return php;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Language selection dropdown
        DropdownButton<String>(
          value: _selectedLanguage,
          items: const [
            DropdownMenuItem(value: 'yaml', child: Text('YAML')),
            DropdownMenuItem(value: 'json', child: Text('JSON')),
            DropdownMenuItem(value: 'java', child: Text('Java')),
            DropdownMenuItem(value: 'python', child: Text('Python')),
            DropdownMenuItem(value: 'typescript', child: Text('TypeScript')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
              _updateCodeController();
            });
          },
        ),
        const SizedBox(height: 16),
        // Code editor
        Expanded(
          child: CodeTheme(
            data: CodeThemeData(
              styles: monokaiSublimeTheme,
            ), // Use a pre-defined theme
            child: CodeField(
              controller: _codeController,
              readOnly: false, // Make the editor read-only
              gutterStyle: const GutterStyle(showLineNumbers: true),
            ),
          ),
        ),
      ],
    );
  }
}

void main(List<String> args) {
  final text = '''
name: Example App
version: 1.0.0
dependencies:
  flutter:
    sdk: flutter
  yaml: ^3.1.0
            ''';
  final json = '''
{
  "name": "Example App",
  "version": "1.0.0",
  "dependencies": {
    "flutter": {
      "sdk": "flutter"
    },
    "yaml": "^3.1.0"
  }
}
            ''';
  final java = '''
public class Main {
  public static void main(String[] args) {
    System.out.println("Hello, World!");
  }
}
            ''';
  final python = '''
def greet():
    print("Hello, World!")

greet()
            ''';
  final typescript = '''
function greet(): void {
  console.log("Hello, World!");
}

greet();
            ''';
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MultiLanguageCodeEditor(
          codeSnippets: {
            'yaml': '''
name: Example App
version: 1.0.0
dependencies:
  flutter:
    sdk: flutter
  yaml: ^3.1.0
            ''',
            'json': '''
{
  "name": "Example App",
  "version": "1.0.0",
  "dependencies": {
    "flutter": {
      "sdk": "flutter"
    },
    "yaml": "^3.1.0"
  }
}
            ''',
            'java': '''
public class Main {
  public static void main(String[] args) {
    System.out.println("Hello, World!");
  }
}
            ''',
            'python': '''
def greet():
    print("Hello, World!")

greet()
            ''',
            'typescript': '''
function greet(): void {
  console.log("Hello, World!");
}

greet();
            ''',
          },
        ),
      ),
    ),
  );
}
