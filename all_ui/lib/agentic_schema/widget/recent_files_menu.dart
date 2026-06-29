import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/recents_files_provider.dart';

class RecentFilesMenu extends ConsumerWidget {
  const RecentFilesMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFiles = ref.watch(recentFilesProvider);

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Recent Files',
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: recentFiles.isEmpty
          ? [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent files'),
              ),
            ]
          : [
              ...recentFiles.map((file) {
                return MenuItemButton(
                  leadingIcon: const Icon(Icons.description, size: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.name),
                      Text(
                        _formatTime(file.lastOpened),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onPressed: () {
                    // Open file
                  },
                );
              }),
              const Divider(),
              MenuItemButton(
                leadingIcon: const Icon(Icons.clear_all, size: 18),
                child: const Text('Clear Recent'),
                onPressed: () {
                  ref.read(recentFilesProvider.notifier).clear();
                },
              ),
            ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
