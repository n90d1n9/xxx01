import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee.dart';
import '../states/employee_provider.dart';
import '../widgets/detail/employee_detail_content.dart';
import 'employee_form.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final int employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeByIdProvider(employeeId));

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          employeeAsync.maybeWhen(
            data:
                (employee) =>
                    employee == null
                        ? const SizedBox.shrink()
                        : IconButton(
                          tooltip: 'Edit employee',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddEditEmployeeScreen(
                                        employee: employee,
                                      ),
                                ),
                              ),
                        ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: employeeAsync.when(
        data:
            (employee) =>
                employee == null
                    ? const Center(child: Text('Employee not found'))
                    : EmployeeDetailContent(
                      employee: employee,
                      onDelete: () => _confirmDelete(context, ref, employee),
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Employee'),
            content: Text(
              'Delete ${employee.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;
    await ref.read(employeeListProvider.notifier).deleteEmployee(employee.id);
    ref.invalidate(employeeByIdProvider(employee.id));

    if (!context.mounted) return;
    Navigator.pop(context);
  }
}
