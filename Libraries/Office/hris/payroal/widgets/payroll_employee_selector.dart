import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class PayrollEmployeeSelector extends StatelessWidget {
  final List<Employee> employees;
  final Employee? selectedEmployee;
  final Map<int, bool> paymentStatus;
  final ValueChanged<Employee> onSelected;

  const PayrollEmployeeSelector({
    super.key,
    required this.employees,
    required this.selectedEmployee,
    required this.paymentStatus,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Employee Pay Queue',
      icon: Icons.groups_2_outlined,
      subtitle: '${employees.length} employees',
      emptyMessage: 'No payroll employees available',
      children: [
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: employees.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final employee = employees[index];
              return _PayrollEmployeeCard(
                employee: employee,
                isSelected: selectedEmployee?.id == employee.id,
                isPaid: paymentStatus[employee.id] ?? false,
                onTap: () => onSelected(employee),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PayrollEmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isSelected;
  final bool isPaid;
  final VoidCallback onTap;

  const _PayrollEmployeeCard({
    required this.employee,
    required this.isSelected,
    required this.isPaid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? const Color(0xFF059669) : HrisColors.primary;

    return SizedBox(
      width: 138,
      child: Material(
        color: isSelected ? color.withValues(alpha: 0.08) : HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : HrisColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Text(
                        _initials(employee.name),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isPaid)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  employee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  employee.position ?? 'Employee',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ),
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
