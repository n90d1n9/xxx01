import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/workflow_provider.dart';

class AppHeader extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    return AppBar(
      title: SizedBox(
        width: 200,
        child: GestureDetector(
          onTap: () => _editWorkflowName(workflowState.name),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  workflowState.name,

                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit, size: 16),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () {
            ref.read(workflowProvider.notifier).undo();
          },
          tooltip: 'Undo',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: () {
            ref.read(workflowProvider.notifier).redo();
          },
          tooltip: 'Redo',
        ),
        const VerticalDivider(),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: () {
            ref
                .read(workflowProvider.notifier)
                .updateZoom(workflowState.zoom + 0.1);
          },
          tooltip: 'Zoom In',
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: () {
            ref
                .read(workflowProvider.notifier)
                .updateZoom(workflowState.zoom - 0.1);
          },
          tooltip: 'Zoom Out',
        ),
        IconButton(
          icon: const Icon(Icons.center_focus_strong),
          onPressed: () {
            ref.read(workflowProvider.notifier).resetView();
          },
          tooltip: 'Reset View',
        ),
        const VerticalDivider(),
        IconButton(
          icon: Icon(
            //_showExecutionLog ? Icons.close : Icons.terminal,
            ref.watch(executionLogProvider) ? Icons.close : Icons.terminal,
          ),
          onPressed: () {
            setState(() {
              // _showExecutionLog = !_showExecutionLog;
              ref.watch(executionLogProvider.notifier).state = !ref
                  .watch(executionLogProvider.notifier)
                  .state;
            });
          },
          tooltip: 'Execution Log',
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () => _saveWorkflow(),
          tooltip: 'Save Workflow',
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: () => _loadWorkflow(),
          tooltip: 'Load Workflow',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmClearWorkflow(),
          tooltip: 'Clear Workflow',
        ),
        const VerticalDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton.icon(
            onPressed: workflowState.isExecuting
                ? null
                : () {
                    ref.read(workflowProvider.notifier).executeWorkflow();
                    setState(() {
                      // _showExecutionLog = true;
                      ref.watch(executionLogProvider.notifier).state = true;
                    });
                  },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Execute'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _saveWorkflow() {
    final workflow = ref.read(workflowProvider.notifier).exportWorkflow();
    Clipboard.setData(ClipboardData(text: workflow));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workflow copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editWorkflowName(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Rename Workflow'),
        content: TextField(
          controller: controller,

          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(workflowProvider.notifier)
                  .updateWorkflowName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _loadWorkflow() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text('Load Workflow'),
          content: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12),
            maxLines: 10,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              hintText: 'Paste workflow JSON here...',
              hintStyle: const TextStyle(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  ref
                      .read(workflowProvider.notifier)
                      .importWorkflow(controller.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workflow loaded successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading workflow: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Load'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearWorkflow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Clear Workflow'),
        content: const Text(
          'Are you sure you want to clear the entire workflow? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workflowProvider.notifier).clearWorkflow();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
