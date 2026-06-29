import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/diagram_provider.dart';
import '../utils/mermaid_validator.dart';
//import 'package:flutter_mermaid/flutter_mermaid.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _controller = TextEditingController();
  String? _error;

  void _validateContent() {
    setState(() {
      _error = MermaidValidator.validate(_controller.text) 
          ? null 
          : 'Invalid Mermaid syntax';
    });
  }

  Future<void> _saveDiagram() async {
    if (_error != null) return;
    
    final id = await ref.read(diagramProvider.notifier)
        .saveDiagram(_controller.text);
        
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagram saved! ID: $id'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => _shareDiagram(id),
          ),
        ),
      );
    }
  }

  Future<void> _shareDiagram(String id) async {
    final url = 'your-domain.com/view/$id';
    await Share.share('Check out my Mermaid diagram: $url');
  }

  Future<void> _importDiagram() async {
    // Implement file picker logic here
  }

  Future<void> _exportDiagram() async {
    // Implement file download logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mermaid Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importDiagram,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportDiagram,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDiagram,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Enter Mermaid diagram code here...',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => _validateContent(),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: FlutterMermaid(
                        chart: _controller.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
