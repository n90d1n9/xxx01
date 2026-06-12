import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

class CodePreviewDialog extends StatefulWidget {
  final String initialCode;
  final String initialLanguage;
  final bool initialReadOnly;

  const CodePreviewDialog({
    Key? key,
    this.initialCode = '',
    this.initialLanguage = 'yaml',
    this.initialReadOnly = false,
  }) : super(key: key);

  @override
  _CodePreviewDialogState createState() => _CodePreviewDialogState();
}

class _CodePreviewDialogState extends State<CodePreviewDialog> {
  late String code;
  late String language;
  late bool isReadOnly;
  late TextEditingController _codeController;

  final List<String> supportedLanguages = [
    'yaml',
    'json',
    'java',
    'python',
    'typescript',
  ];

  @override
  void initState() {
    super.initState();
    code = widget.initialCode;
    language = widget.initialLanguage;
    isReadOnly = widget.initialReadOnly;
    _codeController = TextEditingController(text: code);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code Preview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Language dropdown
                DropdownButton<String>(
                  value: language,
                  onChanged:
                      isReadOnly
                          ? null
                          : (newValue) {
                            setState(() {
                              language = newValue!;
                            });
                          },
                  items:
                      supportedLanguages.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
                const SizedBox(width: 16),
                // Read-only toggle
                Row(
                  children: [
                    Text('Read Only:'),
                    Switch(
                      value: isReadOnly,
                      onChanged: (value) {
                        setState(() {
                          isReadOnly = value;
                        });
                      },
                    ),
                  ],
                ),
                const Spacer(),
                // Copy button
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy to clipboard',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  isReadOnly
                      ? SingleChildScrollView(
                        child: HighlightView(
                          code,
                          language: language,
                          theme: githubTheme,
                          padding: const EdgeInsets.all(12),
                          textStyle: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      )
                      : TextField(
                        controller: _codeController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your code here',
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          setState(() {
                            code = value;
                          });
                        },
                      ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(code),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use the dialog

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () => showCodePreviewDialog(context),
        child: Text('show'),
      ),
    );
  }

  void showCodePreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CodePreviewDialog(
          initialCode: '''
# Example YAML
name: my_app
description: A Flutter application
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
''',
          initialLanguage: 'yaml',
          initialReadOnly: false,
        );
      },
    ).then((returnedCode) {
      if (returnedCode != null) {
        print('Returned code: $returnedCode');
        // Do something with the returned code
      }
    });
  }
}

void main(List<String> args) {
  runApp(MaterialApp(home: MyWidget()));
}
