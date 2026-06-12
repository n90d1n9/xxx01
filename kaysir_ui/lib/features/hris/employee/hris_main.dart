import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/widgets/hris_ui.dart';
import 'models/employee_directory_models.dart';
import 'states/employee_directory_provider.dart';
import 'widgets/directory/employee_directory_detail_sheet.dart';
import 'widgets/directory/employee_directory_list_panel.dart';
import 'widgets/directory/employee_directory_search_panel.dart';
import 'widgets/directory/employee_directory_summary_grid.dart';

class HRISScreen extends ConsumerWidget {
  const HRISScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(employeeDirectoryDepartmentsProvider);
    final selectedDepartment = ref.watch(
      employeeDirectorySelectedDepartmentProvider,
    );
    final highPerformerOnly = ref.watch(
      employeeDirectoryHighPerformerOnlyProvider,
    );
    final query = ref.watch(employeeDirectorySearchQueryProvider);
    final employees = ref.watch(filteredEmployeeDirectoryMembersProvider);
    final summary = ref.watch(employeeDirectorySummaryProvider);
    final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HrisCommandHeader(
                    title: 'Employee Directory',
                    subtitle:
                        'Search, segment, and act on employee profiles quickly',
                    icon: Icons.badge_outlined,
                    departments: departments,
                    departmentLabel: 'Department',
                    selectedDepartment: selectedDepartment,
                    attentionOnly: highPerformerOnly,
                    attentionLabel: 'High performers',
                    onDepartmentChanged: (value) {
                      if (value == null) return;
                      ref
                          .read(
                            employeeDirectorySelectedDepartmentProvider
                                .notifier,
                          )
                          .state = value;
                    },
                    onAttentionChanged:
                        (value) =>
                            ref
                                .read(
                                  employeeDirectoryHighPerformerOnlyProvider
                                      .notifier,
                                )
                                .state = value,
                  ),
                  const SizedBox(height: 16),
                  EmployeeDirectorySummaryGrid(summary: summary),
                  const SizedBox(height: 16),
                  EmployeeDirectorySearchPanel(
                    query: query,
                    resultCount: employees.length,
                    onChanged:
                        (value) =>
                            ref
                                .read(
                                  employeeDirectorySearchQueryProvider.notifier,
                                )
                                .state = value,
                    onAddEmployee: () => _addEmployee(context, ref),
                  ),
                  const SizedBox(height: 16),
                  EmployeeDirectoryListPanel(
                    employees: employees,
                    asOfDate: asOfDate,
                    onOpenProfile:
                        (employee) =>
                            _showEmployeeDetails(context, employee, asOfDate),
                    onMessage:
                        (employee) =>
                            _showMessage(context, 'Message ${employee.name}'),
                    onSchedule:
                        (employee) =>
                            _showMessage(context, 'Schedule ${employee.name}'),
                    onRemove:
                        (employee) =>
                            _confirmDeleteEmployee(context, ref, employee),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEmployee(context, ref),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add employee'),
      ),
    );
  }

  void _showEmployeeDetails(
    BuildContext context,
    EmployeeDirectoryMember employee,
    DateTime asOfDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder:
          (context) => EmployeeDirectoryDetailSheet(
            employee: employee,
            asOfDate: asOfDate,
            onMessage: () {
              Navigator.pop(context);
              _showMessage(context, 'Message ${employee.name}');
            },
            onSchedule: () {
              Navigator.pop(context);
              _showMessage(context, 'Schedule ${employee.name}');
            },
          ),
    );
  }

  void _confirmDeleteEmployee(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryMember employee,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove employee'),
            content: Text(
              'Remove ${employee.name} from this directory workspace?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  ref
                      .read(employeeDirectoryMembersProvider.notifier)
                      .removeMember(employee.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _addEmployee(BuildContext context, WidgetRef ref) {
    final nextId = DateTime.now().millisecondsSinceEpoch.toString();
    final member = EmployeeDirectoryMember(
      id: nextId,
      name: 'New Hire $nextId',
      position: 'Onboarding Specialist',
      department: 'Human Resources',
      avatarUrl: 'https://randomuser.me/api/portraits/lego/1.jpg',
      email: 'new.hire@company.com',
      phone: '+1 (555) 000-0000',
      joiningDate: DateTime(2026, 5, 30),
      performance: 4.2,
      location: 'Jakarta',
      manager: 'Emma Rodriguez',
      status: EmployeeDirectoryStatus.onboarding,
    );

    ref.read(employeeDirectoryMembersProvider.notifier).addMember(member);
    _showMessage(context, '${member.name} added to onboarding');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class HRISApp extends StatelessWidget {
  const HRISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'HRIS App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: HrisColors.primary),
          scaffoldBackgroundColor: HrisColors.pageBackground,
        ),
        home: const HRISScreen(),
      ),
    );
  }
}

void main() {
  runApp(const HRISApp());
}
