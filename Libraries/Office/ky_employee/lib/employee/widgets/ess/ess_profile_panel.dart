import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class EssProfilePanel extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEditProfile;

  const EssProfilePanel({
    super.key,
    required this.employee,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: hrisPanelDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: HrisColors.primary.withValues(alpha: 0.12),
                child: Text(
                  _initials(employee.name),
                  style: const TextStyle(
                    color: HrisColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.position ?? 'Role not set',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
                    ),
                    Text(
                      employee.department ?? 'Department not set',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit profile',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEditProfile,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Join Date',
                value:
                    employee.hireDate == null
                        ? 'Not set'
                        : DateFormat('MMM d, yyyy').format(employee.hireDate!),
              ),
              const HrisMetricStripItem(label: 'Time Off', value: '18 days'),
              HrisMetricStripItem(
                label: 'Status',
                value: employee.isActive ? 'Active' : 'Inactive',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
