import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/mcp.dart';
import '../model/mcp_server.dart';
import '../states/mcp_provider.dart';
import '../states/mcp_server_notifier.dart';
import '../widget/empty_selection_panel.dart';
import '../widget/server_detail_panel.dart';
import '../widget/server_list_tile.dart';

class MCPServerManagementScreen extends ConsumerWidget {
  const MCPServerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(mcpServersProvider);
    final selectedServer = ref.watch(selectedServerProvider);

    return Row(
      children: [
        Container(
          width: 450,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildServerListHeader(context, servers),
              Expanded(
                child: ListView.builder(
                  itemCount: servers.length,
                  itemBuilder: (context, index) {
                    final server = servers[index];
                    final isSelected = selectedServer?.id == server.id;

                    return ServerListTile(
                      server: server,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedServerProvider.notifier).state =
                            server;
                      },
                      onToggleConnection: () {
                        ref
                            .read(mcpServersProvider.notifier)
                            .toggleConnection(server.id);
                      },
                      onDelete: () {
                        ref
                            .read(mcpServersProvider.notifier)
                            .deleteServer(server.id);
                        ref.read(selectedServerProvider.notifier).state = null;
                      },
                      onEdit: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedServer != null
              ? ServerDetailsPanel(server: selectedServer)
              : const EmptySelectionPanel(),
        ),
      ],
    );
  }

  Widget _buildServerListHeader(BuildContext context, List<MCPServer> servers) {
    final connected = servers
        .where((s) => s.status == MCPServerStatus.connected)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dns, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Servers (${servers.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$connected Online',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
