// Employee list item
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/states/employee_provider.dart';

import '../models/employee.dart';

class EmployeeListItem extends ConsumerWidget {
  final Employee employee;

  const EmployeeListItem({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEmployee = ref.watch(selectedEmployeeProvider2);
    final isSelected = selectedEmployee?.id == employee.id;

    return InkWell(
      onTap: () {
        ref.read(selectedEmployeeProvider2.notifier).state = employee;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.05)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Employee avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getAvatarColor(employee.id),
              child: Text(
                employee.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),

            // Employee info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    employee.position!,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    employee.isActive ? Color(0xFFDCFCE7) : Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                employee.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color:
                      employee.isActive ? Color(0xFF166534) : Color(0xFFBE123C),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(int id) {
    final colors = [
      Color(0xFF3B82F6), // Blue
      Color(0xFF10B981), // Green
      Color(0xFFF59E0B), // Amber
      Color(0xFFEF4444), // Red
      Color(0xFF8B5CF6), // Purple
      Color(0xFFEC4899), // Pink
    ];

    return colors[id % colors.length];
  }
}
