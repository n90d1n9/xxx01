import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../code_generator/code_generation_dialog.dart';
import '../state/cloud_sync_provider.dart';
import '../state/ui_provider.dart';
import '../state/workflow/workflow_provider.dart';
import '../widget/ai_assistant_panel.dart';
import '../widget/collaboration/collaboration_bar.dart';
import '../widget/collaboration/collaborative_cursor_overlay.dart';
import '../widget/editor_toolbar.dart';
import '../widget/export_import_dialog.dart';
import '../widget/minimap/minimap_widget.dart';
import '../widget/palette/node_palette.dart';
import '../widget/pattern/pattern_library_panel.dart';
import '../widget/properties_panel.dart';
import '../widget/version/version_history_dialog.dart';
import '../widget/canvas/workflow_canvas.dart';
import '../widget/workflow_testing_panel.dart';

class CompleteVisualEditor extends ConsumerStatefulWidget {
  const CompleteVisualEditor({super.key});

  @override
  ConsumerState<CompleteVisualEditor> createState() =>
      _CompleteVisualEditorState();
}

class _CompleteVisualEditorState extends ConsumerState<CompleteVisualEditor> {
  bool _showMinimap = true;
  bool _showPatternLibrary = false;
  bool _showTesting = false;
  bool _showAIAssistant = false;
  bool _showCollaboration = false;

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    final uiState = ref.watch(uiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(workflowState.currentWorkflow?.name ?? 'AI Agent Builder'),
            if (workflowState.currentWorkflow != null) ...[
              const SizedBox(width: 16),
              _buildSyncIndicator(),
            ],
          ],
        ),
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          // Collaboration bar
          if (_showCollaboration && workflowState.currentWorkflow != null)
            const CollaborationBar(),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Left Panel - Node Palette
                if (uiState.isLeftPanelVisible)
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
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
                                    child: Text(
                                      'Create or load a workflow to begin',
                                    ),
                                  ),

                            // Collaborative cursors overlay
                            if (_showCollaboration &&
                                workflowState.currentWorkflow != null)
                              const CollaborativeCursorsOverlay(),

                            // Minimap overlay
                            if (_showMinimap &&
                                workflowState.currentWorkflow != null)
                              MinimapWidget(
                                canvasSize: MediaQuery.of(context).size,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Panel - Dynamic content
                _buildRightPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator() {
    final syncState = ref.watch(cloudSyncProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          syncState.isSynced ? Icons.cloud_done : Icons.cloud_queue,
          size: 16,
          color: syncState.isSynced ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          syncState.isSynced ? 'Saved' : 'Saving...',
          style: TextStyle(
            fontSize: 12,
            color: syncState.isSynced ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    final workflowState = ref.watch(workflowProvider);

    return [
      // Undo/Redo
      IconButton(
        icon: const Icon(Icons.undo),
        tooltip: 'Undo (Ctrl+Z)',
        onPressed: workflowState.canUndo
            ? () => ref.read(workflowProvider.notifier).undo()
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.redo),
        tooltip: 'Redo (Ctrl+Shift+Z)',
        onPressed: workflowState.canRedo
            ? () => ref.read(workflowProvider.notifier).redo()
            : null,
      ),
      const VerticalDivider(),

      // View options
      IconButton(
        icon: Icon(_showMinimap ? Icons.map : Icons.map_outlined),
        tooltip: 'Toggle Minimap',
        onPressed: () => setState(() => _showMinimap = !_showMinimap),
      ),
      const VerticalDivider(),

      // Panels
      IconButton(
        icon: Icon(
          _showPatternLibrary
              ? Icons.library_books
              : Icons.library_books_outlined,
        ),
        tooltip: 'Pattern Library',
        color: _showPatternLibrary ? Colors.blue : null,
        onPressed: () => setState(() {
          _showPatternLibrary = !_showPatternLibrary;
          if (_showPatternLibrary) {
            _showTesting = false;
            _showAIAssistant = false;
          }
        }),
      ),
      IconButton(
        icon: Icon(_showTesting ? Icons.bug_report : Icons.bug_report_outlined),
        tooltip: 'Testing Panel',
        color: _showTesting ? Colors.blue : null,
        onPressed: () => setState(() {
          _showTesting = !_showTesting;
          if (_showTesting) {
            _showPatternLibrary = false;
            _showAIAssistant = false;
          }
        }),
      ),
      IconButton(
        icon: Icon(
          _showAIAssistant ? Icons.psychology : Icons.psychology_outlined,
        ),
        tooltip: 'AI Assistant',
        color: _showAIAssistant ? Colors.purple : null,
        onPressed: () => setState(() {
          _showAIAssistant = !_showAIAssistant;
          if (_showAIAssistant) {
            _showPatternLibrary = false;
            _showTesting = false;
          }
        }),
      ),
      const VerticalDivider(),

      // Collaboration
      IconButton(
        icon: Icon(_showCollaboration ? Icons.people : Icons.people_outline),
        tooltip: 'Collaboration',
        color: _showCollaboration ? Colors.green : null,
        onPressed: () =>
            setState(() => _showCollaboration = !_showCollaboration),
      ),
      const VerticalDivider(),

      // Actions
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
        icon: const Icon(Icons.history),
        tooltip: 'Version History',
        onPressed: workflowState.currentWorkflow != null
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => VersionHistoryDialog(
                    workflowId: workflowState.currentWorkflow!.id,
                  ),
                );
              }
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.upload),
        tooltip: 'Export/Import',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ExportImportDialog(),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.save),
        tooltip: 'Save to Cloud',
        onPressed: workflowState.currentWorkflow != null
            ? () async {
                await ref
                    .read(cloudSyncProvider.notifier)
                    .saveToCloud(workflowState.currentWorkflow!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Workflow saved to cloud')),
                  );
                }
              }
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.play_arrow),
        tooltip: 'Run Test',
        onPressed: () => setState(() => _showTesting = true),
      ),
    ];
  }

  Widget _buildRightPanel() {
    if (_showPatternLibrary) {
      return const PatternLibraryPanel();
    }

    if (_showTesting) {
      return const WorkflowTestingPanel();
    }

    if (_showAIAssistant) {
      return const AIAssistantPanel();
    }

    final uiState = ref.watch(uiProvider);
    if (uiState.isRightPanelVisible) {
      return Container(
        width: 320,
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey.shade300)),
        ),
        child: const PropertiesPanel(),
      );
    }

    return const SizedBox.shrink();
  }
}
