import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/diagram_type.dart';
import '../states/mermaid_provider.dart';
import '../states/mermaid_state.dart';
import '../widgets/diagram_info_dialog.dart';
import '../widgets/diagram_viewer.dart';
import '../widgets/template_selector.dart';

class MermaidEditorScreen extends ConsumerStatefulWidget {
  const MermaidEditorScreen({super.key});

  @override
  ConsumerState<MermaidEditorScreen> createState() =>
      _MermaidEditorScreenState();
}

class _MermaidEditorScreenState extends ConsumerState<MermaidEditorScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(mermaidProvider).code);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDiagram() {
    ref.read(mermaidProvider.notifier).updateCode(_controller.text);
  }

  void _showTemplates() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TemplateSelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mermaidState = ref.watch(mermaidProvider);
    final isEditMode = ref.watch(isEditModeProvider);

    ref.listen<MermaidState>(mermaidProvider, (previous, next) {
      if (previous?.code != next.code) {
        _controller.text = next.code;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mermaid Diagram Editor'),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.visibility : Icons.edit),
            onPressed: () {
              ref.read(isEditModeProvider.notifier).state = !isEditMode;
            },
            tooltip: isEditMode ? 'View Only' : 'Edit Mode',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DiagramInfoDialog(),
              );
            },
            tooltip: 'Diagram Info',
          ),
          IconButton(
            icon: const Icon(Icons.abc),
            onPressed: _showTemplates,
            tooltip: 'Templates',
          ),
        ],
      ),
      body:
          isEditMode
              ? Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.blue[50],
                            child: Row(
                              children: [
                                const Icon(Icons.code, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Mermaid Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: _updateDiagram,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Render'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller: _controller,
                                maxLines: null,
                                expands: true,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Enter Mermaid code...',
                                ),
                              ),
                            ),
                          ),
                          if (mermaidState.error != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.red[100],
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Error: ${mermaidState.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.green[50],
                            child: Row(
                              children: [
                                const Icon(Icons.preview, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _getDiagramTypeName(
                                    mermaidState.diagram.type,
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: DiagramViewer(diagram: mermaidState.diagram),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : DiagramViewer(diagram: mermaidState.diagram),
      floatingActionButton:
          isEditMode
              ? FloatingActionButton(
                onPressed: _updateDiagram,
                tooltip: 'Render Diagram',
                child: const Icon(Icons.play_arrow),
              )
              : null,
    );
  }

  String _getDiagramTypeName(DiagramType type) {
    return switch (type) {
      DiagramType.flowchart => 'Flowchart',
      DiagramType.sequence => 'Sequence Diagram',
      DiagramType.classDiagram => 'Class Diagram',
      DiagramType.stateDiagram => 'State Diagram',
      DiagramType.erDiagram => 'ER Diagram',
      DiagramType.gantt => 'Gantt Chart',
      DiagramType.pie => 'Pie Chart',
      DiagramType.quadrant => 'Quadrant Chart',
      DiagramType.gitGraph => 'Git Graph',
      DiagramType.mindmap => 'Mindmap',
      DiagramType.timeline => 'Timeline',
      DiagramType.journey => 'User Journey',
    };
  }
}
