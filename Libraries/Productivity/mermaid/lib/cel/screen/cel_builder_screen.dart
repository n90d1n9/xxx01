import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/expression_node.dart';
import '../model/node_type.dart';
import '../model/validation_result.dart';
import '../widget/edit_node_dialog.dart';
import '../widget/output_panel.dart';
import '../widget/script_editor.dart';
import '../state/expression_provider.dart';
import '../widget/add_node_dialog.dart';
import '../widget/test_expression_dialog.dart';

class CELBuilderHome extends ConsumerWidget {
  const CELBuilderHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expressionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CEL Expression Builder'),
        actions: [
          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: state.undoStack.isNotEmpty
                ? () => ref.read(expressionProvider.notifier).undo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: state.redoStack.isNotEmpty
                ? () => ref.read(expressionProvider.notifier).redo()
                : null,
          ),
          const VerticalDivider(),
          // Import/Export
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'import':
                  _showImportDialog(context, ref);
                  break;
                case 'export':
                  _exportExpression(context, ref);
                  break;
                case 'templates':
                  _showTemplatesDialog(context, ref);
                  break;
                case 'context':
                  _showContextDialog(context, ref);
                  break;
                case 'test':
                  _showTestDialog(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'templates',
                child: Text('Load Template'),
              ),
              const PopupMenuItem(value: 'import', child: Text('Import JSON')),
              const PopupMenuItem(value: 'export', child: Text('Export JSON')),
              const PopupMenuItem(
                value: 'context',
                child: Text('Edit Context'),
              ),
              const PopupMenuItem(
                value: 'test',
                child: Text('Test Expression'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(state.isVisualMode ? Icons.code : Icons.account_tree),
            onPressed: () => ref.read(expressionProvider.notifier).toggleMode(),
            tooltip: state.isVisualMode
                ? 'Switch to Script'
                : 'Switch to Visual',
          ),
        ],
      ),
      body: Column(
        children: [
          // Validation Banner
          if (state.validationResult != null)
            _buildValidationBanner(state.validationResult!),
          Expanded(
            child: state.isVisualMode
                ? const VisualBuilder()
                : const ScriptEditor(),
          ),
          const OutputPanel(),
        ],
      ),
      floatingActionButton: state.isVisualMode
          ? FloatingActionButton(
              onPressed: () => _showAddNodeDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildValidationBanner(CELValidationResult result) {
    if (result.isValid && result.warnings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.green[100],
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Expression is valid',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (!result.isValid) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.red[100],
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error: ${result.error}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.orange[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Warnings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ...result.warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Text('• $w'),
            ),
          ),
        ],
      ),
    );
  }

  void _showTemplatesDialog(BuildContext context, WidgetRef ref) {
    final templates = ref.read(expressionProvider).templates;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expression Templates'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Card(
                child: ListTile(
                  title: Text(template.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template.description),
                      const SizedBox(height: 4),
                      Text(
                        template.celExpression,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Chip(label: Text(template.category)),
                  onTap: () {
                    ref
                        .read(expressionProvider.notifier)
                        .loadFromTemplate(template);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContextDialog(BuildContext context, WidgetRef ref) {
    final currentContext = ref.read(expressionProvider).context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CEL Context'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Available Variables:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...currentContext.variables.keys.map(
                (key) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• $key'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Available Functions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...currentContext.availableFunctions.map(
                (fn) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• $fn()'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import JSON'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Paste JSON here...',
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
                  .read(expressionProvider.notifier)
                  .importFromJson(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _exportExpression(BuildContext context, WidgetRef ref) {
    if (ref.read(expressionProvider).rootNode == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No expression to export')));
      return;
    }

    final json = jsonEncode(ref.read(expressionProvider).rootNode!.toJson());
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expression copied to clipboard')),
    );
  }

  void _showTestDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const TestExpressionDialog(),
    );
  }

  void _showAddNodeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddNodeDialog(
        onNodeCreated: (node) {
          ref.read(expressionProvider.notifier).setRootNode(node);
        },
      ),
    );
  }
}

// Visual Builder
class VisualBuilder extends ConsumerWidget {
  const VisualBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootNode = ref.watch(expressionProvider).rootNode;

    if (rootNode == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Click + to add a root node',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'or load a template from the menu',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: NodeWidget(node: rootNode),
    );
  }
}

class NodeWidget extends ConsumerWidget {
  final ExpressionNode node;

  const NodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(expressionProvider).selectedNodeId == node.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isSelected ? 8 : 2,
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: () => ref.read(expressionProvider.notifier).selectNode(node.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getNodeIcon(),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNodeContent()),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) => _handleAction(value, context, ref),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add',
                        child: Text('Add Child'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Node'),
                      ),
                      const PopupMenuItem(
                        value: 'comment',
                        child: Text('Add Comment'),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              if (node.comment != null && node.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.comment, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          node.comment!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (node.children.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    children: node.children
                        .map((child) => NodeWidget(node: child))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNodeIcon() {
    IconData icon;
    Color color;

    switch (node.type) {
      case NodeType.comparison:
        icon = Icons.compare_arrows;
        color = Colors.blue;
        break;
      case NodeType.logical:
        icon = Icons.psychology;
        color = Colors.purple;
        break;
      case NodeType.arithmetic:
        icon = Icons.calculate;
        color = Colors.orange;
        break;
      case NodeType.function:
        icon = Icons.functions;
        color = Colors.green;
        break;
      case NodeType.variable:
        icon = Icons.data_object;
        color = Colors.teal;
        break;
      case NodeType.literal:
        icon = Icons.format_quote;
        color = Colors.red;
        break;
      case NodeType.member:
        icon = Icons.subdirectory_arrow_right;
        color = Colors.indigo;
        break;
      case NodeType.list:
        icon = Icons.list;
        color = Colors.cyan;
        break;
      case NodeType.map:
        icon = Icons.map;
        color = Colors.deepOrange;
        break;
      case NodeType.ternary:
        icon = Icons.question_mark;
        color = Colors.amber;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildNodeContent() {
    switch (node.type) {
      case NodeType.literal:
        return Text(
          'Literal: ${node.value}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.variable:
        return Text(
          'Variable: ${node.value}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.member:
        return Text(
          'Member: .${node.value}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.comparison:
        return Text(
          'Comparison: ${node.operator}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.logical:
        return Text(
          'Logical: ${node.operator}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.arithmetic:
        return Text(
          'Arithmetic: ${node.operator}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.function:
        return Text(
          'Function: ${node.value}()',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.list:
        return const Text(
          'List []',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.map:
        return const Text(
          'Map {}',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case NodeType.ternary:
        return const Text(
          'Ternary: ? :',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
    }
  }

  void _handleAction(String action, BuildContext context, WidgetRef ref) {
    switch (action) {
      case 'add':
        _showAddChildDialog(context, ref);
        break;
      case 'edit':
        _showEditDialog(context, ref);
        break;
      case 'comment':
        _showCommentDialog(context, ref);
        break;
      case 'duplicate':
        _duplicateNode(ref);
        break;
      case 'delete':
        ref.read(expressionProvider.notifier).deleteNode(node.id);
        break;
    }
  }

  void _showAddChildDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddNodeDialog(
        onNodeCreated: (childNode) {
          ref
              .read(expressionProvider.notifier)
              .addChildNode(node.id, childNode);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => EditNodeDialog(
        node: node,
        onNodeUpdated: (updatedNode) {
          ref
              .read(expressionProvider.notifier)
              .updateNode(node.id, updatedNode);
        },
      ),
    );
  }

  void _showCommentDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: node.comment);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter comment...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = node.copyWith(comment: controller.text);
              ref
                  .read(expressionProvider.notifier)
                  .updateNode(node.id, updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _duplicateNode(WidgetRef ref) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final duplicated = _duplicateNodeRecursive(node, newId);
    // Add as sibling - this would need parent tracking in real implementation
    ref.read(expressionProvider.notifier).setRootNode(duplicated);
  }

  ExpressionNode _duplicateNodeRecursive(
    ExpressionNode original,
    String newId,
  ) {
    return ExpressionNode(
      id: newId,
      type: original.type,
      operator: original.operator,
      value: original.value,
      comment: original.comment,
      metadata: original.metadata,
      children: original.children
          .map((c) => _duplicateNodeRecursive(c, '${newId}_${c.id}'))
          .toList(),
    );
  }
}
