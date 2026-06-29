import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow_node.dart';
import '../../state/canvas_provider.dart';
import '../../state/ui_provider.dart';
import '../../state/workflow/workflow_provider.dart';
import '../../state/workflow/workflow_state.dart';
import '../node/node_template_dialog.dart';

class CanvasContextMenu extends ConsumerWidget {
  final Offset position;
  final WorkflowNode? targetNode;
  final Offset? canvasPosition;

  const CanvasContextMenu({
    super.key,
    required this.position,
    this.targetNode,
    this.canvasPosition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ContextMenuOverlay(
      position: position,
      onDismiss: () => Navigator.of(context).pop(),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                targetNode != null
                    ? _buildNodeActions(context, ref)
                    : _buildCanvasActions(context, ref),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNodeActions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workflowState = ref.read(workflowProvider);
    final isSelected = workflowState.selectedNodes.any(
      (n) => n.id == targetNode!.id,
    );

    return [
      // Node Information Header
      _buildSectionHeader(
        icon: Icons.account_tree,
        title: targetNode!.name,
        subtitle: targetNode!.type.name.toUpperCase(),
        color: _getNodeTypeColor(targetNode!.type),
      ),

      const Divider(height: 1),

      // Selection & Visibility
      _buildMenuItem(
        icon: isSelected ? Icons.check_box : Icons.check_box_outline_blank,
        label: isSelected ? 'Deselect' : 'Select',
        shortcut: 'Click',
        onTap: () {
          Navigator.of(context).pop();
          if (isSelected) {
            ref.read(workflowProvider.notifier).deselectNode(targetNode!.id);
          } else {
            ref.read(workflowProvider.notifier).selectNode(targetNode!.id);
          }
        },
      ),

      _buildMenuItem(
        icon: Icons.visibility,
        label: 'Focus View',
        shortcut: 'F',
        onTap: () {
          Navigator.of(context).pop();
          ref
              .read(canvasProvider.notifier)
              .centerOnNode(
                targetNode!.id,
                workflowState.currentWorkflow?.nodes ?? [],
                MediaQuery.of(context).size,
              );
        },
      ),

      const Divider(height: 1),

      // Edit Actions
      _buildMenuItem(
        icon: Icons.edit,
        label: 'Edit Properties',
        shortcut: 'Enter',
        onTap: () {
          Navigator.of(context).pop();
          ref.read(uiProvider.notifier).selectNodeForConfig(targetNode!.id);
        },
      ),

      _buildMenuItem(
        icon: Icons.content_copy,
        label: 'Duplicate',
        shortcut: 'Ctrl+D',
        onTap: () {
          Navigator.of(context).pop();
          ref.read(workflowProvider.notifier).duplicateNode(targetNode!.id);
        },
      ),

      _buildMenuItem(
        icon: Icons.schema,
        label: 'Create Connection',
        shortcut: 'C',
        onTap: () {
          Navigator.of(context).pop();
          ref.read(workflowProvider.notifier).startConnection(targetNode!.id);
        },
      ),

      const Divider(height: 1),

      // Template & Export
      _buildMenuItem(
        icon: Icons.bookmark,
        label: 'Save as Template',
        onTap: () {
          Navigator.of(context).pop();
          _showTemplateDialog(context, ref);
        },
      ),

      _buildMenuItem(
        icon: Icons.export_notes,
        label: 'Export Node',
        onTap: () {
          Navigator.of(context).pop();
          _exportNode(context, ref);
        },
      ),

      const Divider(height: 1),

      // Danger Zone
      _buildMenuItem(
        icon: Icons.delete,
        label: 'Delete Node',
        shortcut: 'Del',
        color: colorScheme.error,
        onTap: () {
          Navigator.of(context).pop();
          _showDeleteConfirmation(context, ref);
        },
      ),
    ];
  }

  List<Widget> _buildCanvasActions(BuildContext context, WidgetRef ref) {
    final workflowState = ref.read(workflowProvider);
    final hasNodes = workflowState.currentWorkflow?.nodes.isNotEmpty ?? false;
    final hasClipboardData = ref.read(clipboardProvider).isNotEmpty;

    return [
      _buildSectionHeader(
        icon: Icons.palette,
        title: 'Canvas Actions',
        subtitle: 'Workflow Tools',
      ),

      const Divider(height: 1),

      // Add Nodes
      _buildMenuItem(
        icon: Icons.add_circle,
        label: 'Add Node',
        shortcut: 'A',
        onTap: () {
          Navigator.of(context).pop();
          _showQuickAddMenu(context, ref);
        },
      ),

      _buildMenuItem(
        icon: Icons.bolt,
        label: 'AI Assistant',
        shortcut: 'Ctrl+Space',
        color: Colors.purple,
        onTap: () {
          Navigator.of(context).pop();
          ref.read(uiProvider.notifier).toggleAIAssistant();
        },
      ),

      if (hasClipboardData) ...[
        const Divider(height: 1),
        _buildMenuItem(
          icon: Icons.content_paste,
          label: 'Paste',
          shortcut: 'Ctrl+V',
          onTap: () {
            Navigator.of(context).pop();
            ref
                .read(workflowProvider.notifier)
                .pasteNodes(canvasPosition ?? position);
          },
        ),
      ],

      const Divider(height: 1),

      // Selection & View
      if (hasNodes) ...[
        _buildMenuItem(
          icon: Icons.select_all,
          label: 'Select All',
          shortcut: 'Ctrl+A',
          onTap: () {
            Navigator.of(context).pop();
            ref.read(workflowProvider.notifier).selectAllNodes();
          },
        ),

        _buildMenuItem(
          icon: Icons.clear_all,
          label: 'Clear Selection',
          shortcut: 'Esc',
          onTap: () {
            Navigator.of(context).pop();
            ref.read(workflowProvider.notifier).clearSelection();
          },
        ),
      ],

      _buildMenuItem(
        icon: Icons.zoom_out_map,
        label: 'Fit to View',
        shortcut: 'Ctrl+0',
        onTap: () {
          Navigator.of(context).pop();
          final nodes = workflowState.currentWorkflow?.nodes ?? [];
          if (nodes.isNotEmpty) {
            ref.read(canvasProvider.notifier).fitToView(nodes);
          }
        },
      ),

      const Divider(height: 1),

      // Canvas Settings
      _buildMenuItem(
        icon: Icons.grid_on,
        label: 'Toggle Grid',
        shortcut: 'G',
        onTap: () {
          Navigator.of(context).pop();
          ref.read(canvasProvider.notifier).toggleGrid();
        },
      ),

      _buildMenuItem(
        icon: Icons.snap,
        label: 'Toggle Snap',
        shortcut: 'S',
        onTap: () {
          Navigator.of(context).pop();
          ref.read(canvasProvider.notifier).toggleSnapToGrid();
        },
      ),

      const Divider(height: 1),

      // Import/Export
      _buildMenuItem(
        icon: Icons.import_export,
        label: 'Import Workflow',
        onTap: () {
          Navigator.of(context).pop();
          _showImportDialog(context, ref);
        },
      ),

      if (hasNodes)
        _buildMenuItem(
          icon: Icons.download,
          label: 'Export Workflow',
          onTap: () {
            Navigator.of(context).pop();
            _showExportDialog(context, ref);
          },
        ),
    ];
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? shortcut,
    Color? color,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: color, fontSize: 13),
                ),
              ),
              if (shortcut != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shortcut,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNodeTypeColor(NodeType type) {
    switch (type) {
      case NodeType.llm:
        return Colors.purple;
      case NodeType.tool:
        return Colors.orange;
      case NodeType.decision:
        return Colors.blue;
      case NodeType.transform:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showQuickAddMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              NodePaletteBottomSheet(position: canvasPosition ?? position),
    );
  }

  void _showTemplateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => NodeTemplateDialog(node: targetNode!),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Node?'),
            content: Text(
              'Are you sure you want to delete "${targetNode!.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .read(workflowProvider.notifier)
                      .deleteNode(targetNode!.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _exportNode(BuildContext context, WidgetRef ref) {
    // Implement node export functionality
    final nodeJson = targetNode!.toJson();
    // Share or save the node configuration
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ImportWorkflowDialog(),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ExportWorkflowDialog(),
    );
  }
}

class _ContextMenuOverlay extends StatelessWidget {
  final Offset position;
  final VoidCallback onDismiss;
  final Widget child;

  const _ContextMenuOverlay({
    required this.position,
    required this.onDismiss,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Backdrop
          Container(color: Colors.transparent),

          // Context menu positioned to stay within screen bounds
          Positioned(
            left: _calculateAdjustedLeft(context, position.dx),
            top: _calculateAdjustedTop(context, position.dy),
            child: GestureDetector(
              onTap: () {}, // Prevent tap from closing when clicking menu
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAdjustedLeft(BuildContext context, double left) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = 280.0;

    if (left + menuWidth > screenWidth) {
      return screenWidth - menuWidth - 16;
    }
    return left;
  }

  double _calculateAdjustedTop(BuildContext context, double top) {
    final screenHeight = MediaQuery.of(context).size.height;
    final estimatedHeight = 400.0; // Approximate max height

    if (top + estimatedHeight > screenHeight) {
      return screenHeight - estimatedHeight - 16;
    }
    return top;
  }
}

// Usage in your WorkflowCanvas:
