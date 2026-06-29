import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/yaml.dart';

import '../state/wayang_providers.dart';

class PreviewDialog extends ConsumerStatefulWidget {
  final String yaml;
  final String json;

  const PreviewDialog({super.key, this.yaml = '', this.json = ''});

  @override
  ConsumerState<PreviewDialog> createState() => _PreviewDialogState();
}

class _PreviewDialogState extends ConsumerState<PreviewDialog> {
  String _selectedCode = '';
  String _selectedLanguage = 'yaml';
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();

    _updateCodeController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedCode = ref.watch(wayangProvider).wayangConfig.toYaml();
  }

  void _updateCodeController() {
    _codeController = CodeController(
      text: _selectedCode,
      language: _getLanguageFromString(_selectedLanguage),
    );
  }

  Mode _getLanguageFromString(String language) {
    switch (language) {
      case 'dart':
        return dart;
      case 'json':
        return json;
      case 'java':
        return java;
      case 'python':
        return python;
      case 'typescript':
        return typescript;
      default:
        return yaml;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                const Text(
                  'Preview Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Code'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _selectedCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            // Tab Bar and Tab Bar View
            DefaultTabController(
              length: 2,
              child: Expanded(
                child: Column(
                  children: [
                    // Tab Bar
                    TabBar(
                      tabs: const [
                        Tab(text: 'YAML'),
                        Tab(text: 'JSON'),
                      ],
                      onTap: (index) {
                        setState(() {
                          selectedTab(index);
                        });
                      },
                    ),
                    // Tab Bar View
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(child: content()),
                            SingleChildScrollView(child: content()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectedTab(int index) {
    setState(() {
      _selectedLanguage = index == 0 ? 'yaml' : 'json';
      switch (_selectedLanguage) {
        case 'json':
          _selectedCode = ref.watch(wayangProvider).wayangConfig.toJson();
          break;
        default:
          _selectedCode = ref.watch(wayangProvider).wayangConfig.toYaml();
      }

      _updateCodeController();
    });
  }

  Widget content() {
    return CodeTheme(
      data: CodeThemeData(
        styles: monokaiSublimeTheme,
      ), // Use a pre-defined theme
      child: CodeField(
        wrap: true,
        controller: _codeController,
        readOnly: false, // Make the editor read-only
        gutterStyle: const GutterStyle(showLineNumbers: true),
      ),
    );
  }
}
