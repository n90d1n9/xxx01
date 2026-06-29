import 'package:flutter_riverpod/legacy.dart';

import '../model/mcp_registry_entry.dart';

final mcpRegistryProvider =
    StateNotifierProvider<MCPRegistryNotifier, List<MCPRegistryEntry>>(
      (ref) => MCPRegistryNotifier(),
    );

class MCPRegistryNotifier extends StateNotifier<List<MCPRegistryEntry>> {
  MCPRegistryNotifier() : super(_generateSampleRegistries());

  static List<MCPRegistryEntry> _generateSampleRegistries() {
    return [
      MCPRegistryEntry(
        id: 'reg-1',
        name: 'Data Processing Suite',
        description: 'Complete toolkit for data transformation and validation',
        type: MCPRegistryType.tool,
        itemIds: ['tool-1', 'tool-3'],
        author: 'MCP Data Team',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        isPublic: true,
      ),
      MCPRegistryEntry(
        id: 'reg-2',
        name: 'Integration Hub',
        description: 'Enterprise integration and API management tools',
        type: MCPRegistryType.tool,
        itemIds: ['tool-2'],
        author: 'Integration Team',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isPublic: true,
      ),
      MCPRegistryEntry(
        id: 'reg-3',
        name: 'Production Servers',
        description: 'Production-ready MCP server configurations',
        type: MCPRegistryType.server,
        itemIds: ['1'],
        author: 'DevOps Team',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        isPublic: true,
      ),
    ];
  }

  void addRegistry(MCPRegistryEntry registry) {
    state = [...state, registry];
  }

  void updateRegistry(String id, MCPRegistryEntry updatedRegistry) {
    state = [
      for (final registry in state)
        if (registry.id == id) updatedRegistry else registry,
    ];
  }

  void deleteRegistry(String id) {
    state = state.where((registry) => registry.id != id).toList();
  }
}
