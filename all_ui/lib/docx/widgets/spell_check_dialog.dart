import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class SpellCheckDialog extends ConsumerWidget {
  const SpellCheckDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const Icon(Icons.spellcheck),
                const SizedBox(width: 8),
                const Text(
                  'Spell Check',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
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
                  final errors = ref.watch(documentProvider).spellErrors;

                  if (errors.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 60,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text('No spelling errors found!'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: errors.length,
                    itemBuilder: (context, index) {
                      final error = errors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          title: Text(
                            error.word,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.red,
                              decorationStyle: TextDecorationStyle.wavy,
                            ),
                          ),
                          subtitle:
                              error.suggestions.isEmpty
                                  ? const Text('No suggestions')
                                  : Text(
                                    '${error.suggestions.length} suggestions',
                                  ),
                          children: [
                            if (error.suggestions.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Suggestions:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...error.suggestions.map((suggestion) {
                                return ListTile(
                                  dense: true,
                                  title: Text(suggestion),
                                  trailing: const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    ref
                                        .read(documentProvider.notifier)
                                        .replaceWithSuggestion(
                                          error,
                                          suggestion,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Replaced with "$suggestion"',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(documentProvider.notifier)
                                        .ignoreSpellingError(error.word);
                                  },
                                  icon: const Icon(
                                    Icons.visibility_off,
                                    size: 16,
                                  ),
                                  label: const Text('Ignore'),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(documentProvider.notifier)
                                        .addWordToDictionary(error.word);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to dictionary'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add to Dictionary'),
                                ),
                              ],
                            ),
                          ],
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
}
