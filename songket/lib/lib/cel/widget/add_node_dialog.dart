// Add Node Dialog
import 'package:flutter/material.dart';

import '../model/expression_node.dart';
import '../model/node_type.dart';

class AddNodeDialog extends StatefulWidget {
  final Function(ExpressionNode) onNodeCreated;

  const AddNodeDialog({super.key, required this.onNodeCreated});

  @override
  State<AddNodeDialog> createState() => _AddNodeDialogState();
}

class _AddNodeDialogState extends State<AddNodeDialog> {
  NodeType selectedType = NodeType.comparison;
  final textController = TextEditingController();
  String? selectedOperator;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Node'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<NodeType>(
            value: selectedType,
            decoration: const InputDecoration(labelText: 'Node Type'),
            items: NodeType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value!;
                selectedOperator = null;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_needsOperator()) _buildOperatorDropdown(),
          if (_needsValue()) _buildValueField(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _createNode, child: const Text('Add')),
      ],
    );
  }

  bool _needsOperator() {
    return selectedType == NodeType.comparison ||
        selectedType == NodeType.logical ||
        selectedType == NodeType.arithmetic;
  }

  bool _needsValue() {
    return selectedType == NodeType.literal ||
        selectedType == NodeType.variable ||
        selectedType == NodeType.function;
  }

  Widget _buildOperatorDropdown() {
    List<String> operators;
    switch (selectedType) {
      case NodeType.comparison:
        operators = ['==', '!=', '<', '<=', '>', '>='];
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

  Widget _buildValueField() {
    String label;
    switch (selectedType) {
      case NodeType.literal:
        label = 'Value (e.g., 42, "hello", true)';
        break;
      case NodeType.variable:
        label = 'Variable Name (e.g., user.age)';
        break;
      case NodeType.function:
        label = 'Function Name (e.g., size, contains)';
        break;
      default:
        label = 'Value';
    }

    return TextField(
      controller: textController,
      decoration: InputDecoration(labelText: label),
    );
  }

  void _createNode() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    dynamic value = textController.text;

    // Try to parse literal values
    if (selectedType == NodeType.literal) {
      if (value == 'true' || value == 'false') {
        value = value == 'true';
      } else if (int.tryParse(value) != null) {
        value = int.parse(value);
      } else if (double.tryParse(value) != null) {
        value = double.parse(value);
      }
    }

    final node = ExpressionNode(
      id: id,
      type: selectedType,
      operator: selectedOperator,
      value: value,
    );

    widget.onNodeCreated(node);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
