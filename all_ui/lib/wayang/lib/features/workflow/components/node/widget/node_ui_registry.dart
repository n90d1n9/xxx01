import 'package:flutter/material.dart';

import '../../../model/workflow_node.dart';
import '../../../state/workflow_state.dart';
import 'node_card/node_card_port.dart';

typedef NodeEditorBuilder = Widget Function(WorkflowNode node);

final Map<String, NodeEditorBuilder> nodeEditorRegistry = {
  'webhook': (node) => HttpRequestEditor(node: node),
  'llm': (node) => ConditionEditor(node: node),
  // Add new types here — that's the only place you need to touch!
};

class ConditionEditor extends StatelessWidget {
  final WorkflowNode node;
  const ConditionEditor({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    // Build custom UI for Condition node
    return Column(
      children: [
        // Text('Condition Node Editor'),
        // Add more UI components as needed
      ],
    );
  }
}

class HttpRequestEditor extends StatelessWidget {
  final WorkflowNode node;
  const HttpRequestEditor({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    // Build custom UI for HTTP Request node
    return Column(
      children: [
        // Text('HTTP Request Node Editor'),
        // Add more UI components as needed
      ],
    );
  }
}

// Fallback: if no editor, just show ports
Widget buildNodeBody(WorkflowNode node, WorkflowState state) {
  final editor = nodeEditorRegistry[node.type];
  if (editor != null) {
    return editor(node);
  } else {
    // Default: show ports only (e.g., for simple nodes like "Start")
    return NodeCardPort(node: node);
  }
}
