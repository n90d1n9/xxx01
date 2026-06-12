import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee.dart';
import '../screens/empl_phone_detail_screen.dart';
import '../states/employee_provider.dart';

class EmployeeListTile extends ConsumerWidget {
  final Employee employee;

  const EmployeeListTile({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Text(
            employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(employee.name),
        subtitle: Text('${employee.position} • ${employee.department}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(selectedEmployeeIdProvider.notifier).state = employee.id;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EmployeeDetailScreen(employeeId: employee.id),
            ),
          );
        },
      ),
    );
  }
}
