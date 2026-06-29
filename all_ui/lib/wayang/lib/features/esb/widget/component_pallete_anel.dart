import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/component_palette_item.dart';
import '../model/component_type.dart';
import '../states/search_provider.dart';

class ComponentPalettePanel extends ConsumerWidget {
  const ComponentPalettePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredComponents = ref.watch(filteredComponentsProvider);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.widgets),
                    const SizedBox(width: 8),
                    Text(
                      'Components',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search components...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildCategory(context, 'Endpoints', filteredComponents, [
                  ComponentType.from,
                  ComponentType.to,
                ]),
                _buildCategory(context, 'Transformation', filteredComponents, [
                  ComponentType.transform,
                  ComponentType.setBody,
                  ComponentType.setHeader,
                  ComponentType.removeHeader,
                  ComponentType.removeHeaders,
                  ComponentType.convertBodyTo,
                ]),
                _buildCategory(context, 'Routing', filteredComponents, [
                  ComponentType.choice,
                  ComponentType.filter,
                  ComponentType.multicast,
                  ComponentType.split,
                  ComponentType.recipientList,
                  ComponentType.dynamicRouter,
                  ComponentType.loadBalance,
                ]),
                _buildCategory(context, 'Processing', filteredComponents, [
                  ComponentType.process,
                  ComponentType.log,
                  ComponentType.aggregate,
                  ComponentType.enrich,
                  ComponentType.pollEnrich,
                  ComponentType.wiretap,
                  ComponentType.script,
                ]),
                _buildCategory(context, 'Control Flow', filteredComponents, [
                  ComponentType.loop,
                  ComponentType.delay,
                  ComponentType.throttle,
                ]),
                _buildCategory(context, 'Data Format', filteredComponents, [
                  ComponentType.marshal,
                  ComponentType.unmarshal,
                ]),
                _buildCategory(context, 'Error Handling', filteredComponents, [
                  ComponentType.onException,
                  ComponentType.doTry,
                  ComponentType.doCatch,
                  ComponentType.doFinally,
                ]),
                _buildCategory(context, 'Advanced', filteredComponents, [
                  ComponentType.validate,
                  ComponentType.hystrix,
                  ComponentType.idempotentConsumer,
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title,
    List<ComponentType> filtered,
    List<ComponentType> types,
  ) {
    final visibleTypes = types.where((t) => filtered.contains(t)).toList();
    if (visibleTypes.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: true,
        children: visibleTypes
            .map((type) => ComponentPaletteItem(type: type))
            .toList(),
      ),
    );
  }
}
