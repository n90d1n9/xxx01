import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:json_schema/json_schema.dart';
import 'dart:convert';

void main() {
  runApp(const YamlEditorApp());
}

class YamlEditorApp extends StatelessWidget {
  const YamlEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAML Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const YamlEditorScreen(),
    );
  }
}

class YamlEditorScreen extends StatefulWidget {
  const YamlEditorScreen({super.key});

  @override
  State<YamlEditorScreen> createState() => _YamlEditorScreenState();
}

class _YamlEditorScreenState extends State<YamlEditorScreen> {
  final TextEditingController _editorController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _schemaController = TextEditingController();
  String _currentFilePath = '';
  String _currentSchemaPath = '';
  String _errorMessage = '';
  bool _isValid = true;
  bool _isSchemaValid = true;
  bool _isDirty = false;
  bool _isShowingPreview = false;
  bool _isShowingSchema = false;
  JsonSchema? _schema;

  @override
  void initState() {
    super.initState();
    _editorController.addListener(_onTextChanged);
    _schemaController.addListener(_onSchemaChanged);
    _loadDefaultSchema();
  }

  @override
  void dispose() {
    _editorController.removeListener(_onTextChanged);
    _schemaController.removeListener(_onSchemaChanged);
    _editorController.dispose();
    _scrollController.dispose();
    _schemaController.dispose();
    super.dispose();
  }

  void _loadDefaultSchema() {
    // Example default schema - replace with your own
    _schemaController.text = '''
type: object
properties:
  name:
    type: string
    description: Name of the entity
  version:
    type: string
    pattern: ^\\d+\\.\\d+\\.\\d+\$
  enabled:
    type: boolean
  settings:
    type: object
    properties:
      timeout:
        type: integer
        minimum: 0
      retries:
        type: integer
        minimum: 1
        maximum: 10
required:
  - name
  - version
''';
    _parseSchema();
  }

  void _onTextChanged() {
    setState(() {
      _isDirty = true;
      _validateYaml();
    });
  }

  void _onSchemaChanged() {
    _parseSchema();
    _validateYaml();
  }

  void _parseSchema() {
    try {
      if (_schemaController.text.trim().isEmpty) {
        setState(() {
          _schema = null;
          _isSchemaValid = true;
        });
        return;
      }

      final yamlSchema = loadYaml(_schemaController.text);
      // Convert YAML to JSON to use with json_schema package
      final jsonSchemaString = json.encode(yamlSchema);
      final jsonSchemaMap = json.decode(jsonSchemaString);

      _schema = JsonSchema.create(jsonSchemaMap);

      setState(() {
        _isSchemaValid = true;
      });
    } catch (e) {
      setState(() {
        _schema = null;
        _isSchemaValid = false;
        _errorMessage = 'Schema error: ${e.toString()}';
      });
    }
  }

  void _validateYaml() {
    if (_editorController.text.trim().isEmpty) {
      setState(() {
        _isValid = true;
        _errorMessage = '';
      });
      return;
    }

    try {
      final yamlDoc = loadYaml(_editorController.text);

      // First check if the YAML is valid
      setState(() {
        _isValid = true;
        _errorMessage = '';
      });

      // Then validate against schema if available
      if (_schema != null && _isSchemaValid) {
        // Convert YAML to JSON to validate with json_schema
        final jsonString = json.encode(yamlDoc);
        final jsonData = json.decode(jsonString);

        final validation = _schema!.validate(jsonData);

        /* if (!validation.isValid) {
          setState(() {
            _isValid = false;
            _errorMessage = 'Schema validation errors: ' +
                validation.errors.map((e) => e.message).join(', ');
          });
        } */
      }
    } catch (e) {
      setState(() {
        _isValid = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _newFile() async {
    if (_isDirty) {
      final shouldDiscard = await _showDiscardChangesDialog();
      if (shouldDiscard != true) return;
    }

    setState(() {
      _editorController.text = '';
      _currentFilePath = '';
      _isDirty = false;
      _isValid = true;
      _errorMessage = '';
    });
  }

  Future<void> _openFile() async {
    if (_isDirty) {
      final shouldDiscard = await _showDiscardChangesDialog();
      if (shouldDiscard != true) return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        setState(() {
          _editorController.text = content;
          _currentFilePath = result.files.single.path!;
          _isDirty = false;
          _validateYaml();
        });
      }
    } catch (e) {
      _showErrorDialog('Error opening file: ${e.toString()}');
    }
  }

  Future<void> _openSchema() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml', 'json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        setState(() {
          _schemaController.text = content;
          _currentSchemaPath = result.files.single.path!;
        });
      }
    } catch (e) {
      _showErrorDialog('Error opening schema: ${e.toString()}');
    }
  }

  Future<void> _saveFile() async {
    if (_currentFilePath.isEmpty) {
      await _saveFileAs();
    } else {
      await _saveToFile(_currentFilePath);
    }
  }

  Future<void> _saveFileAs() async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save YAML File',
        fileName: 'document.yaml',
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
      );

      if (outputFile != null) {
        await _saveToFile(outputFile);
      }
    } catch (e) {
      _showErrorDialog('Error saving file: ${e.toString()}');
    }
  }

  Future<void> _saveSchema() async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Schema File',
        fileName: 'schema.yaml',
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(_schemaController.text);
        setState(() {
          _currentSchemaPath = outputFile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Schema saved to ${path.basename(outputFile)}')),
        );
      }
    } catch (e) {
      _showErrorDialog('Error saving schema: ${e.toString()}');
    }
  }

  Future<void> _saveToFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.writeAsString(_editorController.text);
      setState(() {
        _currentFilePath = filePath;
        _isDirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${path.basename(filePath)}')),
      );
    } catch (e) {
      _showErrorDialog('Error saving file: ${e.toString()}');
    }
  }

  Future<bool?> _showDiscardChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _togglePreview() {
    setState(() {
      _isShowingPreview = !_isShowingPreview;
      _isShowingSchema = false;
    });
  }

  void _toggleSchema() {
    setState(() {
      _isShowingSchema = !_isShowingSchema;
      _isShowingPreview = false;
    });
  }

  Widget _buildPreviewWidget() {
    if (_editorController.text.trim().isEmpty) {
      return const Center(child: Text('No content to preview'));
    }

    if (!_isValid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Invalid YAML: $_errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    try {
      final yaml = loadYaml(_editorController.text);
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview (parsed structure):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildYamlTree(yaml, 0),
          ],
        ),
      );
    } catch (e) {
      return Center(
        child: Text('Error parsing YAML: ${e.toString()}'),
      );
    }
  }

  Widget _buildSchemaEditor() {
    return Column(
      children: [
        if (!_isSchemaValid)
          Container(
            color: Colors.orange.shade100,
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            child: Text(
              'Schema Error: $_errorMessage',
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Schema Editor ${_currentSchemaPath.isEmpty ? "" : "- ${path.basename(_currentSchemaPath)}"}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.folder_open),
                tooltip: 'Open Schema',
                onPressed: _openSchema,
              ),
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save Schema',
                onPressed: _saveSchema,
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              HighlightView(
                _schemaController.text,
                language: 'yaml',
                theme: githubTheme,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontFamily: 'monospace'),
              ),
              TextField(
                controller: _schemaController,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.transparent,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                  contentPadding: EdgeInsets.all(16),
                ),
                maxLines: null,
                expands: true,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYamlTree(dynamic node, int depth) {
    if (node is YamlMap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(left: 16.0 * depth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ${entry.value is YamlMap || entry.value is YamlList ? '' : entry.value}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (entry.value is YamlMap || entry.value is YamlList)
                  _buildYamlTree(entry.value, depth + 1),
              ],
            ),
          );
        }).toList(),
      );
    } else if (node is YamlList) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(left: 16.0 * depth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '- ${entry.value is YamlMap || entry.value is YamlList ? '' : entry.value}',
                ),
                if (entry.value is YamlMap || entry.value is YamlList)
                  _buildYamlTree(entry.value, depth + 1),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(left: 16.0 * depth),
        child: Text(node.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName =
        _currentFilePath.isEmpty ? 'Untitled' : path.basename(_currentFilePath);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('YAML Editor'),
            const SizedBox(width: 12),
            Text(
              '[$fileName${_isDirty ? '*' : ''}]',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New File',
            onPressed: _newFile,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Open File',
            onPressed: _openFile,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _saveFile,
          ),
          IconButton(
            icon: const Icon(Icons.save_as),
            tooltip: 'Save As',
            onPressed: _saveFileAs,
          ),
          IconButton(
            icon: Icon(_isShowingSchema ? Icons.code : Icons.schema),
            tooltip: _isShowingSchema ? 'Back to Editor' : 'Edit Schema',
            onPressed: _toggleSchema,
          ),
          IconButton(
            icon: Icon(_isShowingPreview ? Icons.edit : Icons.preview),
            tooltip: _isShowingPreview ? 'Edit' : 'Preview',
            onPressed: _togglePreview,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isValid && !_isShowingSchema)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              child: Text(
                'YAML Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _isShowingPreview
                ? _buildPreviewWidget()
                : _isShowingSchema
                    ? _buildSchemaEditor()
                    : Stack(
                        children: [
                          HighlightView(
                            _editorController.text,
                            language: 'yaml',
                            theme: githubTheme,
                            padding: const EdgeInsets.all(16),
                            textStyle: const TextStyle(fontFamily: 'monospace'),
                          ),
                          TextField(
                            controller: _editorController,
                            scrollController: _scrollController,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.transparent,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: true,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            maxLines: null,
                            expands: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            cursorColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isValid ? Icons.check_circle : Icons.error,
                    color: _isValid ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isValid ? 'Valid' : 'Invalid',
                    style: TextStyle(
                      color: _isValid ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _schema != null && _isSchemaValid
                        ? Icons.schema
                        : Icons.schema_outlined,
                    color: _schema != null && _isSchemaValid
                        ? Colors.blue
                        : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _schema != null && _isSchemaValid
                        ? 'Schema Active'
                        : 'No Schema',
                    style: TextStyle(
                      color: _schema != null && _isSchemaValid
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (!_isShowingSchema && !_isShowingPreview)
                Text(
                  'Line: ${'\n'.allMatches(_editorController.text.substring(0, _editorController.selection.baseOffset.clamp(0, _editorController.text.length))).length + 1}, Column: ${_editorController.selection.baseOffset - (_editorController.text.lastIndexOf('\n', (_editorController.selection.baseOffset - 1).clamp(0, _editorController.text.length)) + 1)}',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
