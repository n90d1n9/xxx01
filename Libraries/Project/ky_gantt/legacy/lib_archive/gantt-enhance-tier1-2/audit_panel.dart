import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

class AuditPanel extends ConsumerWidget {
  const AuditPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(auditLogProvider);

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
            const Icon(Icons.history,
                size: 16, color: GanttTheme.textSecondary),
            const SizedBox(width: 8),
            const Text('Audit Log',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
            const SizedBox(width: 6),
            if (log.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: GanttTheme.surface3,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${log.length}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: GanttTheme.textMuted)),
              ),
            const Spacer(),
            if (log.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 14),
                color: GanttTheme.textMuted,
                tooltip: 'Clear log',
                onPressed: () => ref.read(auditLogProvider.notifier).clear(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 14),
              color: GanttTheme.textMuted,
              onPressed: () =>
                  ref.read(auditPanelOpenProvider.notifier).state = false,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ]),
        ),

        // Log list
        Expanded(
          child: log.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.history_toggle_off,
                      size: 32, color: GanttTheme.textDisabled),
                  const SizedBox(height: 8),
                  const Text('No actions recorded yet',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: GanttTheme.textMuted)),
                  const SizedBox(height: 4),
                  const Text('Actions appear here as you edit tasks.',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: GanttTheme.textDisabled)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: log.length,
                  itemBuilder: (_, i) => _AuditRow(entry: log[i]),
                ),
        ),
      ]),
    );
  }
}

class _AuditRow extends StatelessWidget {
  final AuditEntry entry;
  const _AuditRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(entry.commandDescription);
    final color = _colorFor(entry.commandDescription);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.commandDescription,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: GanttTheme.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(children: [
            if (entry.newValue != null) ...[
              Expanded(
                  child: Text(entry.newValue!,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: GanttTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4),
            ],
            Text(GanttDateUtils.formatRelativeDate(entry.timestamp),
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: GanttTheme.textDisabled)),
          ]),
        ])),
      ]),
    );
  }

  IconData _iconFor(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('add') || d.contains('create'))
      return Icons.add_circle_outline;
    if (d.contains('delete') || d.contains('remove'))
      return Icons.delete_outline;
    if (d.contains('reschedule') || d.contains('move')) return Icons.event;
    if (d.contains('update') || d.contains('edit')) return Icons.edit_outlined;
    if (d.contains('undo')) return Icons.undo;
    if (d.contains('redo')) return Icons.redo;
    if (d.contains('level')) return Icons.balance;
    if (d.contains('baseline')) return Icons.bookmark_outline;
    if (d.contains('batch')) return Icons.layers_outlined;
    return Icons.info_outline;
  }

  Color _colorFor(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('delete') || d.contains('remove')) return GanttTheme.danger;
    if (d.contains('add') || d.contains('create')) return GanttTheme.success;
    if (d.contains('level') || d.contains('baseline')) return GanttTheme.accent;
    return GanttTheme.textSecondary;
  }
}
