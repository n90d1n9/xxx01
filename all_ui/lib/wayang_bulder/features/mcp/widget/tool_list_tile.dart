import 'package:flutter/material.dart';

import '../model/mcp.dart';
import '../model/mcp_tool.dart';

class ToolListTile extends StatelessWidget {
  final MCPTool tool;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ToolListTile({
    super.key,
    required this.tool,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        leading: _buildStatusIcon(),
        title: Text(
          tool.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Row(
          children: [
            Text('v${tool.version}'),
            const SizedBox(width: 8),
            Icon(Icons.star, size: 14, color: Colors.amber),
            Text('${tool.rating}', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Text(
              tool.usageCount.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final colors = {
      MCPToolStatus.active: Colors.green,
      MCPToolStatus.beta: Colors.orange,
      MCPToolStatus.deprecated: Colors.red,
      MCPToolStatus.archived: Colors.grey,
    };

    return Icon(Icons.build_circle, color: colors[tool.status]);
  }
}
