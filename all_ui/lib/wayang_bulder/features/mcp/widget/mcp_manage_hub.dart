import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/mcp_registry_manage_screen.dart';
import '../screens/mcp_server_manage_screen.dart';
import '../screens/mcp_tool_registry_screen.dart';
import '../states/mcp_provider.dart';

class MCPManagementHub extends ConsumerWidget {
  const MCPManagementHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(appTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard),
            SizedBox(width: 8),
            Text('MCP Server & Tools Registry'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: currentTab,
        children: const [
          MCPServerManagementScreen(),
          MCPToolRegistryScreen(),
          MCPRegistryManagementScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(appTabProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dns),
            label: 'Servers',
            tooltip: 'Server Management',
          ),
          NavigationDestination(
            icon: Icon(Icons.build),
            label: 'Tools',
            tooltip: 'Tools Registry',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Registries',
            tooltip: 'Registry Management',
          ),
        ],
      ),
    );
  }
}
