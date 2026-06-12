import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_action_models.dart';
import '../../models/employee_directory_insight_models.dart';

class EmployeeDirectoryActionQueueTile extends StatelessWidget {
  final EmployeeDirectoryActionItem action;
  final ValueChanged<EmployeeDirectoryActionItem> onAssign;
  final ValueChanged<EmployeeDirectoryActionItem> onStart;
  final ValueChanged<EmployeeDirectoryActionItem> onResolve;
  final ValueChanged<EmployeeDirectoryActionItem> onSnooze;

  const EmployeeDirectoryActionQueueTile({
    super.key,
    required this.action,
    required this.onAssign,
    required this.onStart,
    required this.onResolve,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(action.priority);
    final statusColor = _statusColor(action.status);
    final resolved = action.status == EmployeeDirectoryActionStatus.resolved;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _typeIcon(action.type),
                  color: priorityColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          action.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        HrisStatusPill(
                          label: action.priority.label,
                          color: priorityColor,
                        ),
                        HrisStatusPill(
                          label: action.status.label,
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      action.detail,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.person_outline, label: action.owner),
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: 'Due ${_formatDate(action.dueDate)}',
              ),
              _MetaChip(
                icon: Icons.groups_2_outlined,
                label: '${action.affectedCount} affected',
              ),
              _MetaChip(
                icon: Icons.badge_outlined,
                label: _affectedPreview(action.affectedEmployeeNames),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: ValueKey('employee-directory-action-assign-${action.id}'),
                onPressed: resolved ? null : () => onAssign(action),
                icon: const Icon(Icons.assignment_ind_outlined),
                label: const Text('Assign'),
              ),
              OutlinedButton.icon(
                key: ValueKey('employee-directory-action-start-${action.id}'),
                onPressed:
                    resolved ||
                            action.status ==
                                EmployeeDirectoryActionStatus.inProgress
                        ? null
                        : () => onStart(action),
                icon: const Icon(Icons.play_arrow_outlined),
                label: const Text('Start'),
              ),
              FilledButton.tonalIcon(
                key: ValueKey('employee-directory-action-resolve-${action.id}'),
                onPressed: resolved ? null : () => onResolve(action),
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Resolve'),
              ),
              TextButton.icon(
                key: ValueKey('employee-directory-action-snooze-${action.id}'),
                onPressed: resolved ? null : () => onSnooze(action),
                icon: const Icon(Icons.snooze_outlined),
                label: const Text('Snooze'),
              ),
            ],
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
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _typeIcon(EmployeeDirectoryActionType type) {
  return switch (type) {
    EmployeeDirectoryActionType.watchlistReview =>
      Icons.manage_accounts_outlined,
    EmployeeDirectoryActionType.onboardingReadiness =>
      Icons.how_to_reg_outlined,
    EmployeeDirectoryActionType.performanceSupport =>
      Icons.trending_up_outlined,
    EmployeeDirectoryActionType.managerCoverage => Icons.hub_outlined,
  };
}

Color _priorityColor(EmployeeDirectoryInsightPriority priority) {
  return switch (priority) {
    EmployeeDirectoryInsightPriority.critical => const Color(0xFFB91C1C),
    EmployeeDirectoryInsightPriority.elevated => const Color(0xFFD97706),
    EmployeeDirectoryInsightPriority.steady => HrisColors.primary,
  };
}

Color _statusColor(EmployeeDirectoryActionStatus status) {
  return switch (status) {
    EmployeeDirectoryActionStatus.todo => HrisColors.muted,
    EmployeeDirectoryActionStatus.inProgress => HrisColors.primary,
    EmployeeDirectoryActionStatus.resolved => const Color(0xFF15803D),
    EmployeeDirectoryActionStatus.snoozed => const Color(0xFF7C3AED),
  };
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

String _affectedPreview(List<String> names) {
  if (names.isEmpty) return 'No profiles';
  final visible = names.take(2).join(', ');
  return names.length <= 2 ? visible : '$visible +${names.length - 2}';
}
