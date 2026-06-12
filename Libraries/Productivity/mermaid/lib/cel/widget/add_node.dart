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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<NodeType>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Node Type'),
              items: NodeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                );
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
            const SizedBox(height: 8),
            Text(
              _getTypeDescription(selectedType),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
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

  String _getTypeLabel(NodeType type) {
    switch (type) {
      case NodeType.comparison:
        return 'Comparison (==, !=, <, etc.)';
      case NodeType.logical:
        return 'Logical (&&, ||, !)';
      case NodeType.arithmetic:
        return 'Arithmetic (+, -, *, etc.)';
      case NodeType.function:
        return 'Function Call';
      case NodeType.variable:
        return 'Variable Reference';
      case NodeType.literal:
        return 'Literal Value';
      case NodeType.member:
        return 'Member Access (.)';
      case NodeType.list:
        return 'List []';
      case NodeType.map:
        return 'Map {}';
      case NodeType.ternary:
        return 'Ternary (? :)';
    }
  }

  String _getTypeDescription(NodeType type) {
    switch (type) {
      case NodeType.comparison:
        return 'Compare two values: age >= 18';
      case NodeType.logical:
        return 'Combine conditions: A && B';
      case NodeType.arithmetic:
        return 'Math operations: price * quantity';
      case NodeType.function:
        return 'Call a function: size(list)';
      case NodeType.variable:
        return 'Reference a variable: user.name';
      case NodeType.literal:
        return 'A constant value: 42, "hello", true';
      case NodeType.member:
        return 'Access object property: .fieldName';
      case NodeType.list:
        return 'Create a list: [1, 2, 3]';
      case NodeType.map:
        return 'Create a map: {"key": "value"}';
      case NodeType.ternary:
        return 'Conditional: condition ? true : false';
    }
  }

  bool _needsOperator() {
    return selectedType == NodeType.comparison ||
        selectedType == NodeType.logical ||
        selectedType == NodeType.arithmetic;
  }

  bool _needsValue() {
    return selectedType == NodeType.literal ||
        selectedType == NodeType.variable ||
        selectedType == NodeType.function ||
        selectedType == NodeType.member;
  }

  Widget _buildOperatorDropdown() {
    List<String> operators;
    switch (selectedType) {
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

  Widget _buildValueField() {
    String label;
    String hint;
    switch (selectedType) {
      case NodeType.literal:
        label = 'Value';
        hint = '42, "hello", true, 3.14';
        break;
      case NodeType.variable:
        label = 'Variable Name';
        hint = 'user.age, request.path';
        break;
      case NodeType.function:
        label = 'Function Name';
        hint = 'size, contains, startsWith';
        break;
      case NodeType.member:
        label = 'Member Name';
        hint = 'age, name, id';
        break;
      default:
        label = 'Value';
        hint = '';
    }

    return TextField(
      controller: textController,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _createNode() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    dynamic value = textController.text;

    // Try to parse literal values
    if (selectedType == NodeType.literal) {
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
