import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow_node.dart';
import '../../state/ui_provider.dart';
import 'palette_node_item.dart';

class NodePalette extends ConsumerWidget {
  const NodePalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search nodes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Category tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: NodeCategory.values.map((category) {
              final isSelected = uiState.selectedPaletteCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_getCategoryName(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref
                        .read(uiProvider.notifier)
                        .setPaletteCategory(selected ? category : null);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(),

        // Node list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: _getFilteredNodeTypes(
              uiState.selectedPaletteCategory,
            ).map((type) => PaletteNodeItem(type: type)).toList(),
          ),
        ),
      ],
    );
  }

  String _getCategoryName(NodeCategory category) {
    return category.name.replaceAll('_', ' ').toUpperCase();
  }

  List<NodeType> _getFilteredNodeTypes(NodeCategory? category) {
    if (category == null) return NodeType.values;
    return NodeType.values.where((type) => type.category == category).toList();
  }
}
