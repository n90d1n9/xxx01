import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/template_list_item.dart';
import '../../states/template_search_provider.dart';

class TemplatesDialog extends ConsumerWidget {
  const TemplatesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(ref),
            _buildTemplatesList(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.library_books, color: Colors.white),
          const SizedBox(width: 8),
          const Text('Route Templates', style: TextStyle(color: Colors.white)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search templates...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          ref.read(templateSearchProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildTemplatesList(WidgetRef ref) {
    final templates = ref.watch(filteredTemplatesProvider);

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return TemplateListItem(template: template);
        },
      ),
    );
  }
}
