import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class TagsDialog extends ConsumerStatefulWidget {
  const TagsDialog({super.key});

  @override
  ConsumerState<TagsDialog> createState() => _TagsDialogState();
}

class _TagsDialogState extends ConsumerState<TagsDialog> {
  final tagController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);
    return AlertDialog(
      title: const Text('Manage Tags'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tagController,
            decoration: InputDecoration(
              labelText: 'Add Tag',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (tagController.text.trim().isNotEmpty) {
                    ref
                        .read(documentProvider.notifier)
                        .addTag(tagController.text.trim());
                    tagController.clear();
                    setState(() {});
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                ref.read(documentProvider.notifier).addTag(value.trim());
                tagController.clear();
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 16),
          if (docState.metadata.tags.isEmpty)
            const Text('No tags yet. Add one above!')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  docState.metadata.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () {
                        ref.read(documentProvider.notifier).removeTag(tag);
                        setState(() {});
                      },
                    );
                  }).toList(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
