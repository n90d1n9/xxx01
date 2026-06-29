import 'package:flutter/material.dart';

import '../../../features/workflow/components/node/model/schema/node_template.dart';

class WContextMenu extends StatelessWidget {
  final Offset position;
  final List<NodeTemplate> templates;
  final Function(String, Offset) onCreateNode;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onDelete;

  const WContextMenu({
    super.key,
    required this.position,
    required this.templates,
    required this.onCreateNode,
    required this.onCopy,
    required this.onPaste,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onCopy,
                  value: 'copy',
                  child: Text('Copy'),
                ),
                PopupMenuItem(
                  onTap: onPaste,
                  value: 'paste',
                  child: Text('Paste'),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  value: 'delete',
                  child: Text('Delete'),
                ),
                PopupMenuItem(enabled: false, child: Text('Add Node')),
                ...templates.map(
                  (template) => PopupMenuItem(
                    value: 'template_${template.id}',
                    child: Text(template.name),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* onSelected: (value) {
                if (value == 'copy') {
                  onCopy();
                } else if (value == 'paste') {
                  onPaste();
                } else if (value == 'delete') {
                  onDelete();
                } else if (value.startsWith('template_')) {
                  final templateId = value.substring(9);
                  onCreateNode(templateId, position);
                }
              }, */
