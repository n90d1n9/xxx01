import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../state/version_control_provider.dart';
import '../../state/version_controller_state.dart';
import '../../state/workflow/workflow_provider.dart';
import 'version_history_card.dart';

class VersionHistoryDialog extends ConsumerWidget {
  final String workflowId;

  const VersionHistoryDialog({super.key, required this.workflowId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionProvider =
        StateNotifierProvider<VersionControlNotifier, VersionControlState>(
          (ref) => VersionControlNotifier(workflowId),
        );

    final versionState = ref.watch(versionProvider);

    return AlertDialog(
      title: const Text('Version History'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            if (versionState.hasUnsavedChanges)
              Card(
                color: Colors.orange.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('You have unsaved changes'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: versionState.versions.isEmpty
                  ? const Center(child: Text('No versions yet'))
                  : ListView.builder(
                      itemCount: versionState.versions.length,
                      itemBuilder: (context, index) {
                        final version = versionState.versions.reversed
                            .toList()[index];
                        final isCurrentCurrent =
                            version.id == versionState.currentVersion?.id;

                        return VersionHistoryCard(
                          version: version,
                          isCurrent: isCurrentCurrent,
                          onCheckout: () async {
                            final workflow = await ref
                                .read(versionProvider.notifier)
                                .checkout(version.id);
                            ref
                                .read(workflowProvider.notifier)
                                .loadWorkflow(workflow);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCommitDialog(context, ref, versionProvider),
          icon: const Icon(Icons.save),
          label: const Text('Commit Changes'),
        ),
      ],
    );
  }

  void _showCommitDialog(
    BuildContext context,
    WidgetRef ref,
    StateNotifierProvider<VersionControlNotifier, VersionControlState> provider,
  ) {
    final messageController = TextEditingController();
    final authorController = TextEditingController(text: 'User');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Commit Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Commit Message',
                border: OutlineInputBorder(),
                hintText: 'Describe your changes...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final workflow = ref.read(workflowProvider).currentWorkflow;
              if (workflow != null) {
                await ref
                    .read(provider.notifier)
                    .commit(
                      workflow,
                      messageController.text,
                      authorController.text,
                    );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Changes committed')),
                  );
                }
              }
            },
            child: const Text('Commit'),
          ),
        ],
      ),
    );
  }
}
