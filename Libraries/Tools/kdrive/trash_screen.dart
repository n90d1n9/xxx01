// lib/screens/trash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashed = ref.watch(trashedFilesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        backgroundColor: colorScheme.surface,
        actions: [
          if (trashed.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmEmptyTrash(context, ref),
              icon: Icon(Icons.delete_forever_rounded, color: Colors.red.shade600, size: 18),
              label: Text('Empty trash', style: TextStyle(color: Colors.red.shade600)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: trashed.isEmpty
          ? _EmptyTrash()
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Items in trash are permanently deleted after 30 days.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: trashed.length,
                    itemBuilder: (_, i) => _TrashTile(file: trashed[i]),
                  ),
                ),
              ],
            ),
    );
  }

  void _confirmEmptyTrash(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Empty trash?'),
        content: const Text('All items in trash will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(filesNotifierProvider.notifier).emptyTrash();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Empty trash'),
          ),
        ],
      ),
    );
  }
}

class _TrashTile extends ConsumerWidget {
  final FileItem file;
  const _TrashTile({required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = FileUtils.getFileColor(file.type);
    final daysLeft = file.daysUntilPermanentDelete;
    final isExpiringSoon = daysLeft <= 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        ),
        child: ListTile(
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(FileUtils.getFileIcon(file.type), color: color, size: 20),
          ),
          title: Text(file.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Row(
            children: [
              Text(file.displaySize,
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              const Text(' · ', style: TextStyle(color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isExpiringSoon
                      ? Colors.red.withOpacity(0.1)
                      : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$daysLeft days left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isExpiringSoon ? Colors.red.shade700 : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  ref.read(filesNotifierProvider.notifier).restoreFile(file.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('"${file.name}" restored'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    action: SnackBarAction(label: 'Undo', onPressed: () {
                      ref.read(filesNotifierProvider.notifier).trashFile(file.id);
                    }),
                  ));
                },
                icon: Icon(Icons.restore_rounded, color: colorScheme.primary),
                tooltip: 'Restore',
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, ref),
                icon: Icon(Icons.delete_forever_rounded, color: Colors.red.shade400),
                tooltip: 'Delete permanently',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete permanently?'),
        content: Text('"${file.name}" will be permanently deleted and cannot be recovered.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(filesNotifierProvider.notifier).deleteFilePermanently(file.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete forever'),
          ),
        ],
      ),
    );
  }
}

class _EmptyTrash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline_rounded, size: 40, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text('Trash is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Deleted files will appear here for 30 days.',
            style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
