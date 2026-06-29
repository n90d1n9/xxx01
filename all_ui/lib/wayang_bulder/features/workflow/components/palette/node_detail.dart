import 'package:flutter/material.dart';

import '../node/model/schema/node_type_config.dart';

class NodeDetail extends StatelessWidget {
  final NodeConfig nodeType;
  const NodeDetail({super.key, required this.nodeType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(nodeType.icon, color: nodeType.style!.color),
          const SizedBox(width: 12),
          Text(nodeType.label, style: const TextStyle()),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nodeType.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            const Text(
              'Inputs:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (nodeType.inputs.isEmpty)
              const Text('None', style: TextStyle(fontSize: 12))
            else
              ...nodeType.inputs.map(
                (port) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${port.label} (${port.type.toString().split('.').last})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Outputs:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (nodeType.outputs.isEmpty)
              const Text('None', style: TextStyle(fontSize: 12))
            else
              ...nodeType.outputs.map(
                (port) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${port.label} (${port.type.toString().split('.').last})',
                    style: const TextStyle(fontSize: 12),
                  ),
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
    );
  }
}
