import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:yaml/yaml.dart';

class YamlViewer extends StatefulWidget {
  final String yamlContent;

  const YamlViewer({super.key, required this.yamlContent});

  @override
  State<YamlViewer> createState() => _YamlViewerState();
}

class _YamlViewerState extends State<YamlViewer> {
  final CodeController _codeController = CodeController();
  bool _isValidYaml = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _validateAndSetYamlContent();
  }

  void _validateAndSetYamlContent() {
    try {
      // Parse the YAML content to check if it's valid
      loadYaml(widget.yamlContent);
      _isValidYaml = true;
      _errorMessage = '';
    } catch (e) {
      _isValidYaml = false;
      _errorMessage = e.toString();
    }

    // Set the YAML content in the code editor
    _codeController.text = widget.yamlContent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isValidYaml)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Invalid YAML: $_errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: CodeTheme(
              data: CodeThemeData(styles: _yamlHighlightStyle),
              child: CodeField(
                controller: _codeController,
                readOnly: true, // Make the editor read-only
                gutterStyle: const GutterStyle(showLineNumbers: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Custom syntax highlighting for YAML
  final _yamlHighlightStyle = {
    'keyword': TextStyle(color: Colors.blue),
    'string': TextStyle(color: Colors.green),
    'number': TextStyle(color: Colors.orange),
    'comment': TextStyle(color: Colors.grey),
  };
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
  runApp(MaterialApp(home: Scaffold(body: YamlViewer(yamlContent: text))));
}
