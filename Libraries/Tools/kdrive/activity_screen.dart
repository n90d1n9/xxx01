// lib/screens/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(activityLogProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: colorScheme.surface,
        actions: [
          if (log.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context, ref),
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: 'Clear log',
            ),
        ],
      ),
      body: log.isEmpty
          ? _EmptyLog()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: log.length,
              itemBuilder: (_, i) {
                final entry = log[i];
                final isFirst = i == 0 ||
                    !_sameDay(log[i - 1].timestamp, entry.timestamp);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirst)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Text(
                          _dayLabel(entry.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    _ActivityTile(entry: entry),
                  ],
                );
              },
            ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    if (_sameDay(d, now)) return 'TODAY';
    if (_sameDay(d, now.subtract(const Duration(days: 1)))) return 'YESTERDAY';
    const m = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return '${m[d.month-1]} ${d.day}, ${d.year}';
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear activity log?'),
        content: const Text('All activity history will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(activityLogProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityEntry entry;
  const _ActivityTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (icon, color, label) = _activityMeta(entry.activity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(label,
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: color, letterSpacing: 0.4)),
                      ),
                      const Spacer(),
                      Text(_timeLabel(entry.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(entry.fileName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600)),
                  if (entry.detail != null) ...[
                    const SizedBox(height: 3),
                    Text(entry.detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  (IconData, Color, String) _activityMeta(ActivityType type) {
    switch (type) {
      case ActivityType.created:    return (Icons.add_circle_outline_rounded, Colors.green, 'CREATED');
      case ActivityType.modified:   return (Icons.edit_rounded, Colors.blue, 'MODIFIED');
      case ActivityType.deleted:    return (Icons.delete_forever_rounded, Colors.red, 'DELETED');
      case ActivityType.moved:      return (Icons.drive_file_move_rounded, Colors.orange, 'MOVED');
      case ActivityType.shared:     return (Icons.share_rounded, Colors.purple, 'SHARED');
      case ActivityType.renamed:    return (Icons.drive_file_rename_outline_rounded, Colors.teal, 'RENAMED');
      case ActivityType.trashed:    return (Icons.delete_outline_rounded, Colors.deepOrange, 'TRASHED');
      case ActivityType.restored:   return (Icons.restore_rounded, Colors.green, 'RESTORED');
    }
  }
}

class _EmptyLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, size: 36, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text('No activity yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('File actions will be logged here.',
            style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
