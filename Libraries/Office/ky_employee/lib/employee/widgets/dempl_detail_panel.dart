import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee.dart';
import '../models/employee_detail_summary.dart';
import '../models/shift.dart';
import '../states/employee_provider.dart';
import 'detail/employee_detail_info_panel.dart';
import 'detail/employee_detail_summary_grid.dart';
import 'detail/employee_detail_tabs.dart';
import 'detail/employee_profile_header.dart';

class EmployeeDetailPanel extends ConsumerWidget {
  final int employeeId;

  const EmployeeDetailPanel({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailRecordProvider(employeeId));
    final summaryAsync = ref.watch(employeeDetailSummaryProvider(employeeId));
    final shiftsAsync = ref.watch(employeeShiftsProvider(employeeId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
      child: employeeAsync.when(
        data:
            (employee) =>
                employee == null
                    ? const _EmployeeDetailStatePanel(
                      icon: Icons.person_off_outlined,
                      title: 'Employee not found',
                      message: 'Select another employee from the directory.',
                    )
                    : _EmployeeDetailWorkspace(
                      employee: employee,
                      summaryAsync: summaryAsync,
                      shiftsAsync: shiftsAsync,
                    ),
        loading:
            () => const _EmployeeDetailStatePanel(
              icon: Icons.hourglass_empty_outlined,
              title: 'Loading employee',
              message: 'Fetching profile and shift details.',
              loading: true,
            ),
        error:
            (error, stackTrace) => _EmployeeDetailStatePanel(
              icon: Icons.error_outline,
              title: 'Unable to load employee',
              message: error.toString(),
            ),
      ),
    );
  }
}

class _EmployeeDetailWorkspace extends StatelessWidget {
  final Employee employee;
  final AsyncValue<EmployeeDetailSummary?> summaryAsync;
  final AsyncValue<List<Shift>> shiftsAsync;

  const _EmployeeDetailWorkspace({
    required this.employee,
    required this.summaryAsync,
    required this.shiftsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final summary = summaryAsync.asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EmployeeDetailToolbar(employee: employee),
        const SizedBox(height: 12),
        EmployeeProfileHeader(employee: employee),
        const SizedBox(height: 12),
        summaryAsync.when(
          data:
              (summary) =>
                  summary == null
                      ? const HrisEmptyState(
                        message: 'No employee summary available.',
                      )
                      : EmployeeDetailSummaryGrid(summary: summary),
          loading:
              () => const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (error, stackTrace) =>
                  HrisEmptyState(message: 'Unable to load summary: $error'),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabs = EmployeeDetailTabs(
                shifts: shiftsAsync,
                summary: summary,
              );

              if (constraints.maxWidth < 860) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      EmployeeDetailInfoPanel(employee: employee),
                      const SizedBox(height: 12),
                      SizedBox(height: 460, child: tabs),
                    ],
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 340,
                    child: SingleChildScrollView(
                      child: EmployeeDetailInfoPanel(employee: employee),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: tabs),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmployeeDetailToolbar extends StatelessWidget {
  final Employee employee;

  const _EmployeeDetailToolbar({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Employee Details',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Edit employee',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showMessage(context, 'Edit ${employee.name}'),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Delete employee',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showMessage(context, 'Delete ${employee.name}'),
        ),
      ],
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmployeeDetailStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  const _EmployeeDetailStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: hrisPanelDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            const CircularProgressIndicator()
          else
            Icon(icon, size: 42, color: HrisColors.primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
