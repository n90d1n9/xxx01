// Edit Node Dialog
import 'package:flutter/material.dart';

import '../model/expression_node.dart';
import '../model/node_type.dart';

class EditNodeDialog extends StatefulWidget {
  final ExpressionNode node;
  final Function(ExpressionNode) onNodeUpdated;

  const EditNodeDialog({
    super.key,
    required this.node,
    required this.onNodeUpdated,
  });

  @override
  State<EditNodeDialog> createState() => _EditNodeDialogState();
}

class _EditNodeDialogState extends State<EditNodeDialog> {
  late TextEditingController textController;
  late String? selectedOperator;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.node.value?.toString());
    selectedOperator = widget.node.operator;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Node'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_needsOperator()) _buildOperatorDropdown(),
          if (_needsValue()) ...[
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _updateNode, child: const Text('Update')),
      ],
    );
  }

  bool _needsOperator() {
    return widget.node.type == NodeType.comparison ||
        widget.node.type == NodeType.logical ||
        widget.node.type == NodeType.arithmetic;
  }

  bool _needsValue() {
    return widget.node.type == NodeType.literal ||
        widget.node.type == NodeType.variable ||
        widget.node.type == NodeType.function ||
        widget.node.type == NodeType.member;
  }

  Widget _buildOperatorDropdown() {
    List<String> operators;
    switch (widget.node.type) {
      case NodeType.comparison:
        operators = ['==', '!=', '<', '<=', '>', '>=', 'in', '!in'];
        break;
      case NodeType.logical:
        operators = ['&&', '||', '!'];
        break;
      case NodeType.arithmetic:
        operators = ['+', '-', '*', '/', '%'];
        break;
      default:
        operators = [];
    }

    return DropdownButtonFormField<String>(
      value: selectedOperator,
      decoration: const InputDecoration(labelText: 'Operator'),
      items: operators.map((op) {
        return DropdownMenuItem(value: op, child: Text(op));
      }).toList(),
      onChanged: (value) {
        setState(() => selectedOperator = value);
      },
    );
  }

  void _updateNode() {
    dynamic value = textController.text;

    // Try to parse literal values
    if (widget.node.type == NodeType.literal) {
      if (value == 'true' || value == 'false') {
        value = value == 'true';
      } else if (value == 'null') {
        value = null;
      } else if (int.tryParse(value) != null) {
        value = int.parse(value);
      } else if (double.tryParse(value) != null) {
        value = double.parse(value);
      }
    }

    final updated = widget.node.copyWith(
      operator: selectedOperator,
      value: value,
    );

    widget.onNodeUpdated(updated);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
