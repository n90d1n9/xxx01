import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import 'employee_directory_styles.dart';

class EmployeeDirectoryIdentityCell extends StatelessWidget {
  final EmployeeDirectoryMember employee;

  const EmployeeDirectoryIdentityCell({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: HrisColors.primary.withValues(alpha: 0.12),
          child: Text(
            _initials(employee.name),
            style: const TextStyle(
              color: HrisColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                '#${employee.id} • ${employee.email}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmployeeDirectoryStatusCell extends StatelessWidget {
  final EmployeeDirectoryStatus status;

  const EmployeeDirectoryStatusCell({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return HrisStatusPill(
      label: status.label,
      color: employeeDirectoryStatusColor(status),
    );
  }
}

class EmployeeDirectoryPerformanceCell extends StatelessWidget {
  final double performance;

  const EmployeeDirectoryPerformanceCell({
    super.key,
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeePerformanceColor(performance);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.trending_up_outlined, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          performance.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class EmployeeDirectoryContactCell extends StatelessWidget {
  final EmployeeDirectoryMember employee;

  const EmployeeDirectoryContactCell({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          employee.phone,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          employee.location,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

class EmployeeDirectoryActionCell extends StatelessWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback onEdit;
  final VoidCallback onMessage;
  final VoidCallback onSchedule;
  final VoidCallback onRemove;
  final Key? moreActionsKey;

  const EmployeeDirectoryActionCell({
    super.key,
    required this.onOpenProfile,
    required this.onEdit,
    required this.onMessage,
    required this.onSchedule,
    required this.onRemove,
    this.moreActionsKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Open profile',
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.open_in_new_rounded),
          onPressed: onOpenProfile,
        ),
        IconButton(
          tooltip: 'Message',
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          onPressed: onMessage,
        ),
        SizedBox(
          width: 36,
          height: 36,
          child: PopupMenuButton<String>(
            key: moreActionsKey,
            tooltip: 'More actions',
            icon: const Icon(Icons.more_vert_rounded),
            iconSize: 20,
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'schedule') onSchedule();
              if (value == 'remove') onRemove();
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit employee')),
                  PopupMenuItem(
                    value: 'schedule',
                    child: Text('Schedule check-in'),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove employee'),
                  ),
                ],
          ),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
