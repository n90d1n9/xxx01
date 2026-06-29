import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../code_generator/code_generation_dialog.dart';
import '../state/ui_provider.dart';
import '../state/workflow/workflow_provider.dart';
import '../widget/editor_toolbar.dart';
import '../widget/minimap/minimap_widget.dart';
import '../widget/palette/node_palette.dart';
import '../widget/pattern/pattern_library_panel.dart';
import '../widget/properties_panel.dart';
import '../widget/canvas/workflow_canvas.dart';
import '../widget/workflow_testing_panel.dart';

class EnhancedVisualEditorScreen extends ConsumerStatefulWidget {
  const EnhancedVisualEditorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedVisualEditorScreen> createState() =>
      _EnhancedVisualEditorScreenState();
}

class _EnhancedVisualEditorScreenState
    extends ConsumerState<EnhancedVisualEditorScreen> {
  bool _showMinimap = true;
  bool _showPatternLibrary = false;
  bool _showTesting = false;

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    final uiState = ref.watch(uiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(workflowState.currentWorkflow?.name ?? 'AI Agent Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: workflowState.canUndo
                ? () => ref.read(workflowProvider.notifier).undo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: workflowState.canRedo
                ? () => ref.read(workflowProvider.notifier).redo()
                : null,
          ),
          const VerticalDivider(),
          IconButton(
            icon: Icon(_showMinimap ? Icons.map : Icons.map_outlined),
            tooltip: 'Toggle Minimap',
            onPressed: () => setState(() => _showMinimap = !_showMinimap),
          ),
          IconButton(
            icon: Icon(
              _showPatternLibrary
                  ? Icons.library_books
                  : Icons.library_books_outlined,
            ),
            tooltip: 'Pattern Library',
            onPressed: () =>
                setState(() => _showPatternLibrary = !_showPatternLibrary),
          ),
          IconButton(
            icon: Icon(
              _showTesting ? Icons.bug_report : Icons.bug_report_outlined,
            ),
            tooltip: 'Testing Panel',
            onPressed: () => setState(() => _showTesting = !_showTesting),
          ),
          const VerticalDivider(),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Generate Code',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CodeGenerationDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save workflow
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              setState(() => _showTesting = true);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Node Palette
          if (uiState.isLeftPanelVisible)
            Container(
              width: 280,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: const NodePalette(),
            ),

          // Center - Canvas
          Expanded(
            child: Column(
              children: [
                const EditorToolbar(),
                Expanded(
                  child: Stack(
                    children: [
                      workflowState.currentWorkflow != null
                          ? const WorkflowCanvas()
                          : const Center(
                              child: Text('Create or load a workflow to begin'),
                            ),

                      // Minimap overlay
                      if (_showMinimap && workflowState.currentWorkflow != null)
                        MinimapWidget(canvasSize: MediaQuery.of(context).size),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Panel - Properties/Pattern Library/Testing
          if (uiState.isRightPanelVisible ||
              _showPatternLibrary ||
              _showTesting)
            _buildRightPanel(),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    if (_showPatternLibrary) {
      return const PatternLibraryPanel();
    }

    if (_showTesting) {
      return const WorkflowTestingPanel();
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: const PropertiesPanel(),
    );
  }
}
