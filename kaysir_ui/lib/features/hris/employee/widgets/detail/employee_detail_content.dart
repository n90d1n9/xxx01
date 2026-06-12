import 'package:flutter/material.dart';

import '../../models/employee.dart';
import 'employee_detail_info_panel.dart';
import 'employee_profile_header.dart';

class EmployeeDetailContent extends StatelessWidget {
  final Employee employee;
  final VoidCallback onDelete;

  const EmployeeDetailContent({
    super.key,
    required this.employee,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmployeeProfileHeader(employee: employee),
            const SizedBox(height: 16),
            EmployeeDetailInfoPanel(employee: employee),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Employee'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
