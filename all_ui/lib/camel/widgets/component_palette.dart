import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component_template.dart';
import '../states/filtered_provider.dart';
import '../states/provider.dart';
import 'component_card.dart';

class ComponentPalette extends ConsumerWidget {
  const ComponentPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredComponents = ref.watch(filteredComponentsProvider);
    final sources =
        filteredComponents.where((c) => c.category == 'source').toList();
    final processors =
        filteredComponents.where((c) => c.category == 'processor').toList();
    final destinations =
        filteredComponents.where((c) => c.category == 'destination').toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search components...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          // Components list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (sources.isNotEmpty) ...[
                  _buildCategory('Sources', sources),
                  const SizedBox(height: 16),
                ],
                if (processors.isNotEmpty) ...[
                  _buildCategory('Processors', processors),
                  const SizedBox(height: 16),
                ],
                if (destinations.isNotEmpty) ...[
                  _buildCategory('Destinations', destinations),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<ComponentTemplate> components) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        ...components.map(
          (comp) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Draggable<ComponentTemplate>(
              data: comp,
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: ComponentCard(template: comp, isDragging: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: ComponentCard(template: comp),
              ),
              child: ComponentCard(template: comp),
            ),
          ),
        ),
      ],
    );
  }
}
