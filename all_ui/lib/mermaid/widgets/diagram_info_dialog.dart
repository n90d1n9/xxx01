import 'package:flutter/material.dart';

class DiagramInfoDialog extends StatelessWidget {
  const DiagramInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supported Diagrams'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem('Flowchart', 'graph TD / flowchart'),
              _buildInfoItem('Sequence Diagram', 'sequenceDiagram'),
              _buildInfoItem('Class Diagram', 'classDiagram'),
              _buildInfoItem('State Diagram', 'stateDiagram-v2'),
              _buildInfoItem('ER Diagram', 'erDiagram'),
              _buildInfoItem('Gantt Chart', 'gantt'),
              _buildInfoItem('Pie Chart', 'pie'),
              _buildInfoItem('Timeline', 'timeline'),
              _buildInfoItem('User Journey', 'journey'),
              _buildInfoItem('Mindmap', 'mindmap'),
              _buildInfoItem('Git Graph', 'gitGraph'),
              _buildInfoItem('Quadrant Chart', 'quadrantChart'),
            ],
          ),
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

  Widget _buildInfoItem(String name, String syntax) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  syntax,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
