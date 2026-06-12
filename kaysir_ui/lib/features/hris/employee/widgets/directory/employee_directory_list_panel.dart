import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import 'employee_directory_styles.dart';

class EmployeeDirectoryListPanel extends StatelessWidget {
  final List<EmployeeDirectoryMember> employees;
  final DateTime asOfDate;
  final ValueChanged<EmployeeDirectoryMember> onOpenProfile;
  final ValueChanged<EmployeeDirectoryMember> onMessage;
  final ValueChanged<EmployeeDirectoryMember> onSchedule;
  final ValueChanged<EmployeeDirectoryMember> onRemove;

  const EmployeeDirectoryListPanel({
    super.key,
    required this.employees,
    required this.asOfDate,
    required this.onOpenProfile,
    required this.onMessage,
    required this.onSchedule,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.people_alt_outlined,
      title: 'Employee profiles',
      subtitle: 'People data with quick actions',
      emptyMessage: 'No employees match the current filters',
      children:
          employees
              .map(
                (employee) => _EmployeeDirectoryTile(
                  employee: employee,
                  asOfDate: asOfDate,
                  onOpenProfile: () => onOpenProfile(employee),
                  onMessage: () => onMessage(employee),
                  onSchedule: () => onSchedule(employee),
                  onRemove: () => onRemove(employee),
                ),
              )
              .toList(),
    );
  }
}

class _EmployeeDirectoryTile extends StatelessWidget {
  final EmployeeDirectoryMember employee;
  final DateTime asOfDate;
  final VoidCallback onOpenProfile;
  final VoidCallback onMessage;
  final VoidCallback onSchedule;
  final VoidCallback onRemove;

  const _EmployeeDirectoryTile({
    required this.employee,
    required this.asOfDate,
    required this.onOpenProfile,
    required this.onMessage,
    required this.onSchedule,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final performanceColor = employeePerformanceColor(employee.performance);
    final statusColor = employeeDirectoryStatusColor(employee.status);

    return HrisListSurface(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onOpenProfile,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final content = Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(employee.avatarUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              employee.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            HrisStatusPill(
                              label: employee.status.label,
                              color: statusColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${employee.position} • ${employee.department}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                        const SizedBox(height: 10),
                        HrisMetricStrip(
                          items: [
                            HrisMetricStripItem(
                              label: 'Rating',
                              value: employee.performance.toStringAsFixed(1),
                            ),
                            HrisMetricStripItem(
                              label: 'Tenure',
                              value: '${employee.tenureMonths(asOfDate)} mo',
                            ),
                            HrisMetricStripItem(
                              label: 'Location',
                              value: employee.location,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Message',
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    onPressed: onMessage,
                  ),
                  IconButton(
                    tooltip: 'Schedule',
                    icon: const Icon(Icons.event_available_outlined),
                    onPressed: onSchedule,
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'remove') onRemove();
                    },
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove employee'),
                          ),
                        ],
                  ),
                ],
              );

              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_outlined,
                          size: 18,
                          color: performanceColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Performance ${employee.performance.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: performanceColor),
                        ),
                        const Spacer(),
                        actions,
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.trending_up_outlined,
                    size: 18,
                    color: performanceColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    employee.performance.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: performanceColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
