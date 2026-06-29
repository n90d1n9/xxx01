import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/footnote.dart';
import '../states/provider.dart';

class FootnotesDialog extends ConsumerStatefulWidget {
  const FootnotesDialog({super.key});

  @override
  ConsumerState<FootnotesDialog> createState() => _FootnotesDialogState();
}

class _FootnotesDialogState extends ConsumerState<FootnotesDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes),
                const SizedBox(width: 8),
                const Text(
                  'Footnotes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pop(context);
                    _addFootnoteDialog(context);
                  },
                  tooltip: 'Add Footnote',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final footnotes = ref.watch(documentProvider).footnotes;

                  if (footnotes.isEmpty) {
                    return const Center(child: Text('No footnotes yet'));
                  }

                  return ListView.builder(
                    itemCount: footnotes.length,
                    itemBuilder: (context, index) {
                      final footnote = footnotes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${footnote.number}'),
                          ),
                          title: Text(footnote.text),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () {
                                  _editFootnoteDialog(context, footnote);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                onPressed: () {
                                  ref
                                      .read(documentProvider.notifier)
                                      .deleteFootnote(footnote.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addFootnoteDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Footnote'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Footnote Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    ref
                        .read(documentProvider.notifier)
                        .addFootnote(controller.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Footnote added')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _editFootnoteDialog(BuildContext context, Footnote footnote) {
    final controller = TextEditingController(text: footnote.text);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Footnote ${footnote.number}'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Footnote Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    ref
                        .read(documentProvider.notifier)
                        .updateFootnote(footnote.id, controller.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Footnote updated')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
