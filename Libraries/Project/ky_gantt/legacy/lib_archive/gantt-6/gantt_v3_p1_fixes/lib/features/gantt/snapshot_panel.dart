import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class SnapshotPanel extends ConsumerWidget {
  const SnapshotPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshots = ref.watch(snapshotsProvider);

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(left: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Column(children: [
        // Header
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
          child: Row(children: [
            const Icon(Icons.camera_alt_outlined,
                size: 16, color: GanttTheme.textSecondary),
            const SizedBox(width: 8),
            const Text('Snapshots',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
            const Spacer(),
            // Save new snapshot
            TextButton.icon(
              onPressed: () => _showSaveDialog(context, ref),
              icon: const Icon(Icons.add, size: 13),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: GanttTheme.accentLight,
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 14),
              color: GanttTheme.textMuted,
              onPressed: () =>
                  ref.read(snapshotPanelOpenProvider.notifier).state = false,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ]),
        ),

        // Explanation
        Container(
          padding: const EdgeInsets.all(12),
          color: GanttTheme.surface2,
          child: const Row(children: [
            Icon(Icons.info_outline, size: 12, color: GanttTheme.textMuted),
            SizedBox(width: 8),
            Expanded(
                child: Text(
              'Snapshots capture the full project state. Restore to roll back all task dates and progress.',
              style: TextStyle(fontSize: 10, color: GanttTheme.textMuted),
            )),
          ]),
        ),

        // List
        Expanded(
          child: snapshots.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.camera_alt_outlined,
                      size: 32, color: GanttTheme.textDisabled),
                  const SizedBox(height: 8),
                  const Text('No snapshots yet',
                      style:
                          TextStyle(fontSize: 12, color: GanttTheme.textMuted)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showSaveDialog(context, ref),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Save first snapshot'),
                  ),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: snapshots.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: GanttTheme.surface4),
                  itemBuilder: (_, i) => _SnapshotRow(
                    snapshot: snapshots[i],
                    onRestore: () =>
                        _confirmRestore(context, ref, snapshots[i]),
                    onDelete: () => ref
                        .read(snapshotsProvider.notifier)
                        .delete(snapshots[i].id),
                  ),
                ),
        ),
      ]),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(
        text:
            'Snapshot ${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}');
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: GanttTheme.surface2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GanttTheme.surface4)),
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 360,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Save Snapshot',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GanttTheme.textPrimary)),
                    const SizedBox(height: 16),
                    TextField(
                        controller: ctrl,
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 13, color: GanttTheme.textPrimary),
                        decoration:
                            const InputDecoration(labelText: 'Snapshot name')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 13, color: GanttTheme.textPrimary),
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)')),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () {
                            ctrl.dispose();
                            notesCtrl.dispose();
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(tasksProvider.notifier).saveSnapshot(
                              ctrl.text.trim(),
                              notes: notesCtrl.text.trim().isEmpty
                                  ? null
                                  : notesCtrl.text.trim());
                          ctrl.dispose();
                          notesCtrl.dispose();
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ]),
                  ]),
            )),
      ),
    );
  }

  void _confirmRestore(
      BuildContext context, WidgetRef ref, ProjectSnapshot snap) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: GanttTheme.surface2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GanttTheme.surface4)),
        title: const Row(children: [
          Icon(Icons.restore, size: 18, color: GanttTheme.warning),
          SizedBox(width: 8),
          Text('Restore Snapshot',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: GanttTheme.textPrimary)),
        ]),
        content: Text(
            'Restore to "${snap.label}"?\n\nAll current task dates and progress will be replaced with the snapshot state. This can be undone with Ctrl+Z.',
            style:
                const TextStyle(fontSize: 13, color: GanttTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(tasksProvider.notifier).restoreSnapshot(snap);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: GanttTheme.warning),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  final ProjectSnapshot snapshot;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _SnapshotRow(
      {required this.snapshot,
      required this.onRestore,
      required this.onDelete});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: GanttTheme.accentDim,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.camera_alt_outlined,
                size: 16, color: GanttTheme.accentLight),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(snapshot.label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: GanttTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Text(GanttDateUtils.formatShortDate(snapshot.capturedAt),
                      style: const TextStyle(
                          fontSize: 10, color: GanttTheme.textMuted)),
                  const SizedBox(width: 6),
                  Text('${snapshot.tasks.length} tasks',
                      style: const TextStyle(
                          fontSize: 10, color: GanttTheme.textDisabled)),
                ]),
                if (snapshot.notes != null && snapshot.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(snapshot.notes!,
                      style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: GanttTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ])),
          IconButton(
            icon: const Icon(Icons.restore, size: 14),
            tooltip: 'Restore this snapshot',
            color: GanttTheme.textSecondary,
            onPressed: onRestore,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 14),
            tooltip: 'Delete',
            color: GanttTheme.textMuted,
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ]),
      );
}
