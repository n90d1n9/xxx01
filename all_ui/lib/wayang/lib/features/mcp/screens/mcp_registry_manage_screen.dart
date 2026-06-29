import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/mcp_registry_entry.dart';
import '../states/mcp_provider.dart';
import '../states/mcp_registry_provider.dart';
import '../widget/empty_selection_panel.dart';
import '../widget/registry_detail_panel.dart';
import '../widget/registry_list_tile.dart';

class MCPRegistryManagementScreen extends ConsumerWidget {
  const MCPRegistryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registries = ref.watch(mcpRegistryProvider);
    final selectedRegistry = ref.watch(selectedRegistryProvider);

    return Row(
      children: [
        Container(
          width: 450,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Column(
            children: [
              _buildRegistryListHeader(context, registries),
              Expanded(
                child: ListView.builder(
                  itemCount: registries.length,
                  itemBuilder: (context, index) {
                    final registry = registries[index];
                    final isSelected = selectedRegistry?.id == registry.id;

                    return RegistryListTile(
                      registry: registry,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedRegistryProvider.notifier).state =
                            registry;
                      },
                      onDelete: () {
                        ref
                            .read(mcpRegistryProvider.notifier)
                            .deleteRegistry(registry.id);
                        ref.read(selectedRegistryProvider.notifier).state =
                            null;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedRegistry != null
              ? RegistryDetailsPanel(registry: selectedRegistry)
              : const EmptySelectionPanel(),
        ),
      ],
    );
  }

  Widget _buildRegistryListHeader(
    BuildContext context,
    List<MCPRegistryEntry> registries,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.library_books,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Registries (${registries.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${registries.fold<int>(0, (sum, r) => sum + r.itemCount)} Items',
              style: TextStyle(
                color: Colors.purple.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
