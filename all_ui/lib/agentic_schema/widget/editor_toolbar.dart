import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/model/model_validator.dart';
import '../state/canvas_provider.dart';
import '../state/workflow/workflow_provider.dart';

class EditorToolbar extends ConsumerWidget {
  const EditorToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    final workflowState = ref.watch(workflowProvider);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),

          // Selection tools
          IconButton(
            icon: const Icon(
              Icons.arrow_right_alt_outlined,
            ), //Icons.arrow_selector_tool),
            tooltip: 'Select',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.pan_tool),
            tooltip: 'Pan',
            onPressed: () {},
          ),

          const VerticalDivider(),

          // Edit tools
          IconButton(
            icon: const Icon(Icons.content_cut),
            tooltip: 'Cut',
            onPressed: workflowState.selectedNodes.isNotEmpty
                ? () {
                    ref.read(workflowProvider.notifier).copySelectedNodes();
                    ref.read(workflowProvider.notifier).deleteSelectedNodes();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: 'Copy',
            onPressed: workflowState.selectedNodes.isNotEmpty
                ? () => ref.read(workflowProvider.notifier).copySelectedNodes()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.content_paste),
            tooltip: 'Paste',
            onPressed: workflowState.clipboard.isNotEmpty
                ? () => ref
                      .read(workflowProvider.notifier)
                      .pasteNodes(Offset.zero)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: workflowState.selectedNodes.isNotEmpty
                ? () =>
                      ref.read(workflowProvider.notifier).deleteSelectedNodes()
                : null,
          ),

          const VerticalDivider(),

          // View tools
          IconButton(
            icon: const Icon(Icons.grid_on),
            tooltip: 'Toggle Grid',
            color: canvasState.showGrid ? Colors.blue : null,
            onPressed: () => ref.read(canvasProvider.notifier).toggleGrid(),
          ),
          IconButton(
            icon: const Icon(Icons.grid_4x4),
            tooltip: 'Snap to Grid',
            color: canvasState.snapToGrid ? Colors.blue : null,
            onPressed: () =>
                ref.read(canvasProvider.notifier).toggleSnapToGrid(),
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            tooltip: 'Fit to View',
            onPressed: () {
              final nodes = workflowState.currentWorkflow?.nodes ?? [];
              if (nodes.isNotEmpty) {
                ref
                    .read(canvasProvider.notifier)
                    .fitToView(nodes); // Use fitToView instead of fitToScreen
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            onPressed: () =>
                ref.read(canvasProvider.notifier).zoom(0.1, Offset.zero),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            onPressed: () =>
                ref.read(canvasProvider.notifier).zoom(-0.1, Offset.zero),
          ),
          Text('${(canvasState.zoom * 100).toInt()}%'),

          const Spacer(),

          // Validation
          if (workflowState.currentWorkflow != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildValidationStatus(ref),
            ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus(WidgetRef ref) {
    final workflow = ref.watch(workflowProvider).currentWorkflow;
    if (workflow == null) return const SizedBox.shrink();

    final error = ModelValidator.validateWorkflow(workflow);

    if (error == null) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 4),
          Text('Valid', style: TextStyle(color: Colors.green)),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.error, color: Colors.red, size: 20),
        const SizedBox(width: 4),
        Text(error, style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
