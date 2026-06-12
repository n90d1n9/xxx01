import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../../models/employee.dart';

class EmployeeDetailInfoPanel extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailInfoPanel({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Employee Profile',
      icon: Icons.badge_outlined,
      subtitle: employee.employeeId ?? 'Internal ID ${employee.id}',
      children: [
        _EmployeeInfoTile(
          icon: Icons.apartment_outlined,
          title: 'Department',
          value: employee.department ?? 'Not assigned',
        ),
        _EmployeeInfoTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value: employee.email ?? 'No email',
        ),
        _EmployeeInfoTile(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: employee.phone ?? 'No phone',
        ),
        _EmployeeInfoTile(
          icon: Icons.location_on_outlined,
          title: 'Address',
          value: employee.address ?? 'No address',
        ),
        _EmployeeInfoTile(
          icon: Icons.cake_outlined,
          title: 'Date of Birth',
          value: employee.dateOfBirth ?? 'Not set',
        ),
        _EmployeeInfoTile(
          icon: Icons.calendar_today_outlined,
          title: 'Hire Date',
          value:
              employee.hireDate == null
                  ? 'Not set'
                  : DateFormat('MMM d, yyyy').format(employee.hireDate!),
        ),
        _EmployeeInfoTile(
          icon: Icons.supervisor_account_outlined,
          title: 'Manager',
          value: employee.managerName ?? 'No manager assigned',
        ),
        _EmployeeInfoTile(
          icon: Icons.payments_outlined,
          title: 'Salary',
          value:
              employee.salary == null
                  ? 'Not set'
                  : NumberFormat.currency(symbol: r'$').format(employee.salary),
        ),
      ],
    );
  }
}

class _EmployeeInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _EmployeeInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: HrisColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
