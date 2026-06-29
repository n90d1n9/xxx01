import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/template_list_item.dart';
import '../../states/template_search_provider.dart';

class TemplateSearchWidget extends ConsumerWidget {
  const TemplateSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(templateSearchProvider);
    final filteredTemplates = ref.watch(filteredTemplatesProvider);

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(templateSearchProvider.notifier).state = '';
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              ref.read(templateSearchProvider.notifier).state = value;
            },
          ),
        ),

        // Search Results
        Expanded(
          child:
              filteredTemplates.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No templates found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          'Try adjusting your search terms',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = filteredTemplates[index];
                      return TemplateListItem(template: template);
                    },
                  ),
        ),

        // Search Stats
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${filteredTemplates.length} template(s)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (searchQuery.isNotEmpty)
                Text(
                  'Search: "$searchQuery"',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
