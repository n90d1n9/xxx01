import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/ai_suggestion_provider.dart';

class AISuggestionDialog extends ConsumerWidget {
  const AISuggestionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Suggestions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final suggestions = ref.watch(aiSuggestionsProvider);

                  if (suggestions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 64,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Great job! No suggestions at this time.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getSuggestionColor(
                                suggestion.category,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              suggestion.icon,
                              color: _getSuggestionColor(suggestion.category),
                            ),
                          ),
                          title: Text(
                            suggestion.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(suggestion.description),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      suggestion.category,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    padding: EdgeInsets.zero,
                                    backgroundColor: _getSuggestionColor(
                                      suggestion.category,
                                    ).withOpacity(0.2),
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.priority_high,
                                      size: 12,
                                      color:
                                          i < suggestion.priority
                                              ? Colors.red
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: suggestion.action,
                            child: const Text('Apply'),
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

  Color _getSuggestionColor(String category) {
    switch (category) {
      case 'performance':
        return Colors.blue;
      case 'reliability':
        return Colors.orange;
      case 'security':
        return Colors.red;
      case 'best-practice':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
