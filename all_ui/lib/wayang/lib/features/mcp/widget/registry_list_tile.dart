import 'package:flutter/material.dart';

import '../model/mcp_registry_entry.dart';

class RegistryListTile extends StatelessWidget {
  final MCPRegistryEntry registry;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RegistryListTile({
    super.key,
    required this.registry,
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
        leading: Icon(
          registry.type == MCPRegistryType.server ? Icons.dns : Icons.build,
          color: registry.type == MCPRegistryType.server
              ? Colors.blue
              : Colors.purple,
        ),
        title: Text(
          registry.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.apps, size: 14),
            const SizedBox(width: 4),
            Text('${registry.itemCount} items'),
            const SizedBox(width: 12),
            if (registry.isPublic)
              Row(
                children: [
                  Icon(Icons.public, size: 14, color: Colors.green),
                  const SizedBox(width: 2),
                  Text(
                    'Public',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
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
}
