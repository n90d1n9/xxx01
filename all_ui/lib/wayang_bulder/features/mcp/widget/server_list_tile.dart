import 'package:flutter/material.dart';

import '../model/mcp.dart';
import '../model/mcp_server.dart';

class ServerListTile extends StatelessWidget {
  final MCPServer server;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleConnection;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ServerListTile({
    super.key,
    required this.server,
    required this.isSelected,
    required this.onTap,
    required this.onToggleConnection,
    required this.onDelete,
    required this.onEdit,
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
          server.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${server.host}:${server.port}'),
            Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  server.config.transport.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'connect':
                onToggleConnection();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'connect',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    server.status == MCPServerStatus.connected
                        ? Icons.link_off
                        : Icons.link,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    server.status == MCPServerStatus.connected
                        ? 'Disconnect'
                        : 'Connect',
                  ),
                ],
              ),
            ),
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
    switch (server.status) {
      case MCPServerStatus.connected:
        return const Icon(Icons.check_circle, color: Colors.green);
      case MCPServerStatus.connecting:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case MCPServerStatus.error:
        return const Icon(Icons.error, color: Colors.red);
      case MCPServerStatus.maintenance:
        return const Icon(Icons.build, color: Colors.orange);
      case MCPServerStatus.initializing:
        return const Icon(Icons.hourglass_empty, color: Colors.blue);
      case MCPServerStatus.disconnected:
        return const Icon(Icons.circle_outlined, color: Colors.grey);
      default:
        return const Icon(Icons.circle_outlined, color: Colors.grey);
    }
  }
}
