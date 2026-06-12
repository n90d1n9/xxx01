import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/typescript.dart';

class CodePreviewDialog extends StatefulWidget {
  final String initialCode;

  const CodePreviewDialog({Key? key, required this.initialCode})
    : super(key: key);

  @override
  _CodePreviewDialogState createState() => _CodePreviewDialogState();
}

class _CodePreviewDialogState extends State<CodePreviewDialog> {
  late CodeController _codeController;
  String selectedLanguage = 'YAML';

  final Map<String, dynamic> languages = {
    'YAML': yaml,
    'JSON': json,
    'Java': java,
    'Python': python,
    'TypeScript': typescript,
  };

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.initialCode,
      language: yaml, // Default to YAML
    );
  }

  void _onLanguageChange(String? newLang) {
    if (newLang != null) {
      setState(() {
        selectedLanguage = newLang;
        _codeController.language = languages[newLang]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Code Editor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: selectedLanguage,
            onChanged: _onLanguageChange,
            items:
                languages.keys
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300, // Set a fixed height
            child: CodeField(
              controller: _codeController,
              readOnly: false, // Editing enabled
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}

// Show the dialog
void showCodeEditor(BuildContext context, String code) {
  showDialog(
    context: context,
    builder: (context) => CodePreviewDialog(initialCode: code),
  );
}

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
void main(List<String> args) {
  runApp(
    MaterialApp(home: Scaffold(body: CodePreviewDialog(initialCode: java))),
  );
}
