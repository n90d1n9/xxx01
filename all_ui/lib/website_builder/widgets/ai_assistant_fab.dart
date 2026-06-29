import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class AIAssistantFAB extends ConsumerWidget {
  const AIAssistantFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showAIDialog(context, ref),
      icon: const Icon(Icons.auto_awesome),
      label: const Text('AI Assistant'),
      backgroundColor: Colors.purple,
    );
  }

  void _showAIDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text('AI Assistant'),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Describe what you want to create...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(designerProvider.notifier)
                      .generateUIFromPrompt(controller.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Generate'),
              ),
            ],
          ),
    );
  }
}
