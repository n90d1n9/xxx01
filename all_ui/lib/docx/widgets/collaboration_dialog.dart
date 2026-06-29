import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class CollaborationDialog extends ConsumerWidget {
  const CollaborationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.read(documentProvider).isCollaborationEnabled;
    return AlertDialog(
      title: const Text('Collaboration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEnabled) ...[
            const Text(
              'Enable collaboration to work with others in real-time.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: This is a demo feature. In production, integrate with Firebase or WebSockets.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ] else ...[
            const Text('Collaboration is active!'),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final collaborators = ref.watch(documentProvider).collaborators;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active users: ${collaborators.length}'),
                    const SizedBox(height: 8),
                    ...collaborators.map((user) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: user.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(user.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(documentProvider.notifier)
                    .addMockCollaborator('User ${DateTime.now().millisecond}');
              },
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Add Mock User'),
            ),
          ],
        ],
      ),
      actions: [
        if (!isEnabled)
          ElevatedButton(
            onPressed: () {
              ref
                  .read(documentProvider.notifier)
                  .enableCollaboration('local_user', 'You');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Collaboration enabled')),
              );
            },
            child: const Text('Enable'),
          )
        else
          TextButton(
            onPressed: () {
              ref.read(documentProvider.notifier).disableCollaboration();
              Navigator.pop(context);
            },
            child: const Text('Disable'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
