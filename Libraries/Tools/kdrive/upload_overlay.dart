// lib/widgets/upload_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class UploadOverlay extends ConsumerWidget {
  const UploadOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(uploadTasksProvider);
    if (tasks.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: 80,
      right: 16,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
              child: Row(
                children: [
                  Text('Uploading ${tasks.length} file${tasks.length > 1 ? 's' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      for (final t in tasks) {
                        ref.read(uploadTasksProvider.notifier).cancelUpload(t.id);
                      }
                    },
                    icon: const Icon(Icons.close_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            ...tasks.map((task) => _UploadTaskRow(task: task)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _UploadTaskRow extends ConsumerWidget {
  final UploadTask task;
  const _UploadTaskRow({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = FileUtils.getFileColor(task.fileType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: task.isComplete
                ? Icon(Icons.check_circle_rounded, color: Colors.green, size: 18)
                : task.isFailed
                    ? Icon(Icons.error_rounded, color: Colors.red, size: 18)
                    : Icon(FileUtils.getFileIcon(task.fileType), color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.fileName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                if (!task.isComplete && !task.isFailed) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.progress,
                      minHeight: 3,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ] else if (task.isComplete)
                  Text('Upload complete',
                    style: TextStyle(fontSize: 10, color: Colors.green.shade700))
                else
                  Text('Upload failed',
                    style: TextStyle(fontSize: 10, color: Colors.red.shade700)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (!task.isComplete)
            Text('${(task.progress * 100).toInt()}%',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
