import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/ui_provider.dart';
import '../state/workflow/workflow_provider.dart';
import '../widget/editor_toolbar.dart';
import '../widget/palette/node_palette.dart';
import '../widget/properties_panel.dart';
import '../widget/canvas/workflow_canvas.dart';

class VisualEditorScreen extends ConsumerWidget {
  const VisualEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save workflow
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // Execute workflow
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings
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
                // Toolbar
                const EditorToolbar(),

                // Canvas
                Expanded(
                  child: workflowState.currentWorkflow != null
                      ? const WorkflowCanvas()
                      : const Center(
                          child: Text('Create or load a workflow to begin'),
                        ),
                ),
              ],
            ),
          ),

          // Right Panel - Properties
          if (uiState.isRightPanelVisible)
            Container(
              width: 320,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
              ),
              child: const PropertiesPanel(),
            ),
        ],
      ),
    );
  }
}
