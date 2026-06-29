import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final String avatarUrl;
  final String email;
  final String phone;
  final DateTime joiningDate;
  final double performance;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.joiningDate,
    required this.performance,
  });
}

// Providers
final employeesProvider =
    StateNotifierProvider<EmployeesNotifier, List<Employee>>((ref) {
      return EmployeesNotifier();
    });

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredEmployeesProvider = Provider<List<Employee>>((ref) {
  final employees = ref.watch(employeesProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return employees;
  }

  return employees.where((employee) {
    return employee.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        employee.department.toLowerCase().contains(searchQuery.toLowerCase()) ||
        employee.position.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();
});

final selectedDepartmentProvider = StateProvider<String?>((ref) => null);

final departmentsProvider = Provider<List<String>>((ref) {
  final employees = ref.watch(employeesProvider);
  return employees.map((e) => e.department).toSet().toList();
});

// Notifiers
class EmployeesNotifier extends StateNotifier<List<Employee>> {
  EmployeesNotifier()
    : super([
        Employee(
          id: '1',
          name: 'Sarah Johnson',
          position: 'UX Designer',
          department: 'Design',
          avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
          email: 'sarah.johnson@company.com',
          phone: '+1 (555) 123-4567',
          joiningDate: DateTime(2022, 4, 15),
          performance: 4.7,
        ),
        Employee(
          id: '2',
          name: 'Michael Chen',
          position: 'Senior Developer',
          department: 'Engineering',
          avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
          email: 'michael.chen@company.com',
          phone: '+1 (555) 987-6543',
          joiningDate: DateTime(2020, 11, 8),
          performance: 4.9,
        ),
        Employee(
          id: '3',
          name: 'Emma Rodriguez',
          position: 'HR Manager',
          department: 'Human Resources',
          avatarUrl: 'https://randomuser.me/api/portraits/women/23.jpg',
          email: 'emma.rodriguez@company.com',
          phone: '+1 (555) 456-7890',
          joiningDate: DateTime(2021, 7, 22),
          performance: 4.5,
        ),
        Employee(
          id: '4',
          name: 'David Kim',
          position: 'Product Manager',
          department: 'Product',
          avatarUrl: 'https://randomuser.me/api/portraits/men/68.jpg',
          email: 'david.kim@company.com',
          phone: '+1 (555) 789-0123',
          joiningDate: DateTime(2023, 2, 14),
          performance: 4.3,
        ),
        Employee(
          id: '5',
          name: 'Olivia Wilson',
          position: 'Marketing Specialist',
          department: 'Marketing',
          avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
          email: 'olivia.wilson@company.com',
          phone: '+1 (555) 234-5678',
          joiningDate: DateTime(2022, 9, 30),
          performance: 4.6,
        ),
      ]);

  void addEmployee(Employee employee) {
    state = [...state, employee];
  }

  void removeEmployee(String id) {
    state = state.where((employee) => employee.id != id).toList();
  }

  void updateEmployee(Employee updatedEmployee) {
    state = state.map((employee) {
      if (employee.id == updatedEmployee.id) {
        return updatedEmployee;
      }
      return employee;
    }).toList();
  }
}

// Main Screen
class HRISScreen extends ConsumerWidget {
  const HRISScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEmployees = ref.watch(filteredEmployeesProvider);
    final departments = ref.watch(departmentsProvider);
    final selectedDepartment = ref.watch(selectedDepartmentProvider);

    final displayedEmployees = selectedDepartment != null
        ? filteredEmployees
              .where((e) => e.department == selectedDepartment)
              .toList()
        : filteredEmployees;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HRIS Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your team efficiently',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey[400],
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    child: IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.blue,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ).animate().fade().slideY(
                begin: -10,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),

              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: 'Search employees',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ).animate().fade().slideY(
                begin: -5,
                end: 0,
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
              ),

              const SizedBox(height: 24),

              // Department Filters
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: selectedDepartment == null,
                        onSelected: (_) =>
                            ref
                                    .read(selectedDepartmentProvider.notifier)
                                    .state =
                                null,
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue[50],
                        checkmarkColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: selectedDepartment == null
                              ? Colors.blue
                              : Colors.blueGrey[700],
                          fontWeight: selectedDepartment == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: selectedDepartment == null
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                    ...departments.map(
                      (dept) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(dept),
                          selected: selectedDepartment == dept,
                          onSelected: (_) =>
                              ref
                                      .read(selectedDepartmentProvider.notifier)
                                      .state =
                                  dept,
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue[50],
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: selectedDepartment == dept
                                ? Colors.blue
                                : Colors.blueGrey[700],
                            fontWeight: selectedDepartment == dept
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: selectedDepartment == dept
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade().slideX(
                begin: -10,
                end: 0,
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
              ),

              const SizedBox(height: 20),

              // Employees List
              Expanded(
                child: displayedEmployees.isEmpty
                    ? const Center(
                        child: Text(
                          'No employees found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayedEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = displayedEmployees[index];
                          return GestureDetector(
                            onTap: () =>
                                _showEmployeeDetails(context, employee),
                            child:
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Avatar with performance indicator
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                employee.avatarUrl,
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getPerformanceColor(
                                                    employee.performance,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Text(
                                                  employee.performance
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        // Employee info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                employee.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                employee.position,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getDepartmentColor(
                                                            employee.department,
                                                          ).withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      employee.department,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            _getDepartmentColor(
                                                              employee
                                                                  .department,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Since ${_formatDate(employee.joiningDate)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Actions
                                        IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () => _showEmployeeOptions(
                                            context,
                                            ref,
                                            employee,
                                          ),
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fade().slideY(
                                  begin: 20,
                                  end: 0,
                                  delay: Duration(
                                    milliseconds: 100 + (index * 50),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEmployeeDialog(context, ref),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(delay: const Duration(milliseconds: 400)),
    );
  }

  // Helper methods
  Color _getPerformanceColor(double performance) {
    if (performance >= 4.5) return Colors.green;
    if (performance >= 3.5) return Colors.amber;
    return Colors.red;
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'Engineering':
        return Colors.blue;
      case 'Design':
        return Colors.purple;
      case 'Human Resources':
        return Colors.teal;
      case 'Marketing':
        return Colors.orange;
      case 'Product':
        return Colors.indigo;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final years = (difference.inDays / 365).floor();

    if (years > 0) {
      return years == 1 ? '1 year' : '$years years';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month' : '$months months';
    }
  }

  // Dialogs and Bottom Sheets
  void _showEmployeeDetails(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(employee.avatarUrl),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.position,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getDepartmentColor(
                                  employee.department,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                employee.department,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getDepartmentColor(
                                    employee.department,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Contact Information
                  _sectionTitle('Contact Information'),
                  const SizedBox(height: 16),
                  _infoTile(Icons.email_outlined, 'Email', employee.email),
                  const SizedBox(height: 12),
                  _infoTile(Icons.phone_outlined, 'Phone', employee.phone),

                  const SizedBox(height: 32),

                  // Employment Details
                  _sectionTitle('Employment Details'),
                  const SizedBox(height: 16),
                  _infoTile(
                    Icons.calendar_today_outlined,
                    'Joined',
                    '${employee.joiningDate.day}/${employee.joiningDate.month}/${employee.joiningDate.year}',
                  ),
                  const SizedBox(height: 12),
                  _infoTile(
                    Icons.trending_up,
                    'Performance Rating',
                    '${employee.performance} / 5.0',
                    color: _getPerformanceColor(employee.performance),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Add logic for messaging
                          },
                          icon: const Icon(Icons.message_outlined),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Add logic for scheduling
                          },
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: const Text('Schedule'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blueGrey[700], size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color ?? Colors.blueGrey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEmployeeOptions(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            _optionTile(
              context,
              Icons.edit_outlined,
              'Edit Employee',
              Colors.blue[50]!,
              Colors.blue,
              () {
                Navigator.pop(context);
                // Add edit logic
              },
            ),
            const SizedBox(height: 12),
            _optionTile(
              context,
              Icons.badge_outlined,
              'Change Department',
              Colors.purple[50]!,
              Colors.purple,
              () {
                Navigator.pop(context);
                // Add department change logic
              },
            ),
            const SizedBox(height: 12),
            _optionTile(
              context,
              Icons.delete_outline,
              'Remove Employee',
              Colors.red[50]!,
              Colors.red,
              () {
                Navigator.pop(context);
                _confirmDeleteEmployee(context, ref, employee);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteEmployee(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Employee'),
        content: Text(
          'Are you sure you want to remove ${employee.name} from the system?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(employeesProvider.notifier).removeEmployee(employee.id);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context, WidgetRef ref) {
    // In a real app, you'd have a form here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Employee'),
        content: const Text('This would contain a form to add a new employee.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Main app
class HRISApp extends StatelessWidget {
  const HRISApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'HRIS App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        home: const HRISScreen(),
      ),
    );
  }
}

void main() {
  runApp(const HRISApp());
}
