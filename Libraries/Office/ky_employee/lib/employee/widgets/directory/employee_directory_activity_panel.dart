import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_activity_models.dart';

class EmployeeDirectoryActivityPanel extends StatelessWidget {
  final EmployeeDirectoryActivitySummary summary;
  final List<EmployeeDirectoryActivityEvent> events;

  const EmployeeDirectoryActivityPanel({
    super.key,
    required this.summary,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-activity-panel'),
      icon: Icons.manage_history_outlined,
      title: 'Directory activity',
      subtitle: '${summary.totalCount} tracked employee record changes',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Created',
              value: '${summary.createCount}',
            ),
            HrisMetricStripItem(
              label: 'Updated',
              value: '${summary.updateCount}',
            ),
            HrisMetricStripItem(
              label: 'Actions',
              value: '${summary.queueActionCount}',
            ),
            HrisMetricStripItem(
              label: 'Imports',
              value: '${summary.importCount}',
            ),
          ],
        ),
        if (events.isEmpty)
          const HrisListSurface(
            child: Text('No directory activity has been recorded yet.'),
          )
        else
          ...events.map(
            (event) => _EmployeeDirectoryActivityTile(
              key: ValueKey('employee-directory-activity-${event.id}'),
              event: event,
            ),
          ),
      ],
    );
  }
}

class _EmployeeDirectoryActivityTile extends StatelessWidget {
  final EmployeeDirectoryActivityEvent event;

  const _EmployeeDirectoryActivityTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(event.type);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconFor(event.type), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: event.type.label, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(icon: Icons.person_outline, label: event.actor),
                    _MetaChip(
                      icon: Icons.groups_2_outlined,
                      label: '${event.affectedCount} affected',
                    ),
                    _MetaChip(
                      icon: Icons.schedule_outlined,
                      label: _formatTime(event.occurredAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(EmployeeDirectoryActivityType type) {
  return switch (type) {
    EmployeeDirectoryActivityType.created => Icons.person_add_alt_1_outlined,
    EmployeeDirectoryActivityType.updated => Icons.edit_outlined,
    EmployeeDirectoryActivityType.removed => Icons.person_remove_outlined,
    EmployeeDirectoryActivityType.bulkStatusChanged =>
      Icons.published_with_changes_outlined,
    EmployeeDirectoryActivityType.bulkProfileUpdated =>
      Icons.manage_accounts_outlined,
    EmployeeDirectoryActivityType.exported => Icons.file_download_outlined,
    EmployeeDirectoryActivityType.imported => Icons.upload_file_outlined,
    EmployeeDirectoryActivityType.actionUpdated =>
      Icons.assignment_turned_in_outlined,
  };
}

Color _colorFor(EmployeeDirectoryActivityType type) {
  return switch (type) {
    EmployeeDirectoryActivityType.created => const Color(0xFF15803D),
    EmployeeDirectoryActivityType.updated => HrisColors.primary,
    EmployeeDirectoryActivityType.removed => const Color(0xFFB91C1C),
    EmployeeDirectoryActivityType.bulkStatusChanged => const Color(0xFF7C3AED),
    EmployeeDirectoryActivityType.bulkProfileUpdated => const Color(0xFF7C2D12),
    EmployeeDirectoryActivityType.exported => const Color(0xFF0F766E),
    EmployeeDirectoryActivityType.imported => const Color(0xFF0369A1),
    EmployeeDirectoryActivityType.actionUpdated => const Color(0xFF2563EB),
  };
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
