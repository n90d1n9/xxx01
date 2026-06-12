import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/provider.dart';

class ComponentTreePanel extends ConsumerWidget {
  const ComponentTreePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);

    return Container(
      width: 250,
      color: state.isDarkMode ? Colors.grey.shade900 : Colors.white,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_tree, size: 20),
                SizedBox(width: 8),
                Text(
                  'Component Tree',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: state.components.length,
              itemBuilder: (context, index) {
                final component = state.components[index];
                return ListTile(
                  dense: true,
                  selected: state.selectedComponentIds.contains(component.id),
                  leading: const Icon(Icons.widgets, size: 16),
                  title: Text(
                    component.name!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: component.locked
                      ? const Icon(Icons.lock, size: 14)
                      : null,
                  onTap: () => ref
                      .read(designerProvider.notifier)
                      .selectComponent(component.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
