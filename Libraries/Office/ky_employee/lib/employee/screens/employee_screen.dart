import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// Assume these models are already defined elsewhere

// Providers
final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  // Fetch employees from your repository
  await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay
  return dummyEmployees;
});

final selectedEmployeeProvider = StateProvider<Employee?>((ref) => null);

final employeeShiftsProvider = FutureProvider.family<List<Shift>, int>((
  ref,
  employeeId,
) async {
  // Fetch shifts for a specific employee
  await Future.delayed(Duration(milliseconds: 600));
  return dummyShifts.where((shift) => shift.employeeId == employeeId).toList();
});

final filterProvider = StateProvider<String>((ref) => '');

final filteredEmployeesProvider = Provider<AsyncValue<List<Employee>>>((ref) {
  final filter = ref.watch(filterProvider);
  final employees = ref.watch(employeesProvider);

  return employees.whenData((data) {
    if (filter.isEmpty) return data;
    return data
        .where(
          (employee) =>
              employee.name.toLowerCase().contains(filter.toLowerCase()) ||
              employee.position.toLowerCase().contains(filter.toLowerCase()) ||
              employee.department.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  });
});

// Theme and styling
final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF3B82F6), // Blue primary color
    brightness: Brightness.light,
  ),
  fontFamily: 'Poppins',
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1F2937),
    ),
  ),
);

// Main screen
class EmployeeScreen extends ConsumerWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;
    final selectedEmployee = ref.watch(selectedEmployeeProvider);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Side navigation (only visible on large screens)
            if (isLargeScreen) NavigationSidebar(width: 240),

            // Main content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar / header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        if (!isLargeScreen)
                          IconButton(
                            icon: Icon(Icons.menu),
                            onPressed: () {
                              // Show drawer on medium screens
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        Expanded(
                          child: Text(
                            'Employees',
                            style: Theme.of(context).appBarTheme.titleTextStyle,
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee list panel
                        Flexible(
                          flex: isLargeScreen ? 3 : 5,
                          child: EmployeeListPanel(),
                        ),

                        // Employee detail panel
                        if (selectedEmployee != null || isLargeScreen)
                          Flexible(
                            flex: isLargeScreen ? 7 : 5,
                            child: selectedEmployee == null
                                ? EmptyDetailPanel()
                                : EmployeeDetailPanel(
                                    employeeId: selectedEmployee.id,
                                  ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: isLargeScreen ? null : NavigationDrawer(),
    );
  }
}

// Navigation sidebar (for large screens)
class NavigationSidebar extends StatelessWidget {
  final double width;

  const NavigationSidebar({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 40),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.business, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text(
                  'WorkPulse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(context, 'Dashboard', Icons.dashboard_outlined, false),
          _buildNavItem(context, 'Employees', Icons.people_outline, true),
          _buildNavItem(context, 'Shifts', Icons.access_time_outlined, false),
          _buildNavItem(context, 'Companies', Icons.business_outlined, false),
          _buildNavItem(context, 'Tenants', Icons.apartment_outlined, false),
          _buildNavItem(context, 'Users', Icons.person_outline, false),
          Spacer(),
          _buildNavItem(context, 'Settings', Icons.settings_outlined, false),
          _buildNavItem(context, 'Logout', Icons.logout_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Color(0xFF6B7280),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Color(0xFF6B7280),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          // Navigation logic
        },
      ),
    );
  }
}

// Navigation drawer (for medium screens)
class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(child: NavigationSidebar(width: 280));
  }
}

// Employee list panel
class EmployeeListPanel extends ConsumerWidget {
  const EmployeeListPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEmployees = ref.watch(filteredEmployeesProvider);
    final filterText = ref.watch(filterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and filter row
              TextField(
                onChanged: (value) =>
                    ref.read(filterProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, ref, 'All'),
                    _buildFilterChip(context, ref, 'Developer'),
                    _buildFilterChip(context, ref, 'Designer'),
                    _buildFilterChip(context, ref, 'Manager'),
                    _buildFilterChip(context, ref, 'HR'),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Employee list
              Expanded(
                child: filteredEmployees.when(
                  data: (employees) {
                    if (employees.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Color(0xFFD1D5DB),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No employees found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: employees.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return EmployeeListItem(employee: employee);
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('Error loading employees: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, WidgetRef ref, String label) {
    final filter = ref.watch(filterProvider);
    final isActive = label == 'All'
        ? filter.isEmpty
        : filter.toLowerCase() == label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        showCheckmark: false,
        backgroundColor: Color(0xFFF3F4F6),
        selectedColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Color(0xFF6B7280),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            ref.read(filterProvider.notifier).state = label == 'All'
                ? ''
                : label;
          } else {
            ref.read(filterProvider.notifier).state = '';
          }
        },
      ),
    );
  }
}

// Employee list item
class EmployeeListItem extends ConsumerWidget {
  final Employee employee;

  const EmployeeListItem({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEmployee = ref.watch(selectedEmployeeProvider);
    final isSelected = selectedEmployee?.id == employee.id;

    return InkWell(
      onTap: () {
        ref.read(selectedEmployeeProvider.notifier).state = employee;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
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
                    employee.position,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: employee.isActive
                    ? Color(0xFFDCFCE7)
                    : Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                employee.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: employee.isActive
                      ? Color(0xFF166534)
                      : Color(0xFFBE123C),
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

// Empty detail panel
class EmptyDetailPanel extends StatelessWidget {
  const EmptyDetailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
      child: Card(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search, size: 64, color: Color(0xFFD1D5DB)),
              SizedBox(height: 16),
              Text(
                'Select an employee to view details',
                style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Employee detail panel
class EmployeeDetailPanel extends ConsumerWidget {
  final int employeeId;

  const EmployeeDetailPanel({Key? key, required this.employeeId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsyncValue = ref.watch(employeesProvider);
    final shiftsAsyncValue = ref.watch(employeeShiftsProvider(employeeId));

    return employeesAsyncValue.when(
      data: (employees) {
        final employee = employees.firstWhere((e) => e.id == employeeId);

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employee header with actions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Employee Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined),
                        onPressed: () {
                          // Edit employee action
                        },
                        tooltip: 'Edit employee',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          // Delete employee action
                        },
                        tooltip: 'Delete employee',
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Employee profile
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and basic info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 64,
                            backgroundColor: _getAvatarColor(employee.id),
                            child: Text(
                              employee.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            employee.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            employee.position,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: employee.isActive
                                  ? Color(0xFFDCFCE7)
                                  : Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              employee.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: employee.isActive
                                    ? Color(0xFF166534)
                                    : Color(0xFFBE123C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 32),

                      // Employee details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailSection(
                              context,
                              'Personal Information',
                              [
                                _buildDetailItem(
                                  Icons.email_outlined,
                                  'Email',
                                  employee.email,
                                ),
                                _buildDetailItem(
                                  Icons.phone_outlined,
                                  'Phone',
                                  employee.phone,
                                ),
                                _buildDetailItem(
                                  Icons.location_on_outlined,
                                  'Address',
                                  employee.address,
                                ),
                                _buildDetailItem(
                                  Icons.cake_outlined,
                                  'Date of Birth',
                                  employee.dateOfBirth,
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            _buildDetailSection(
                              context,
                              'Employee Information',
                              [
                                _buildDetailItem(
                                  Icons.work_outline,
                                  'Department',
                                  employee.department,
                                ),
                                _buildDetailItem(
                                  Icons.badge_outlined,
                                  'Employee ID',
                                  '#${employee.employeeId}',
                                ),
                                _buildDetailItem(
                                  Icons.calendar_month_outlined,
                                  'Hire Date',
                                  employee.hireDate,
                                ),
                                _buildDetailItem(
                                  Icons.supervisor_account_outlined,
                                  'Manager',
                                  employee.managerName ?? 'N/A',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Tabs for additional info
                  DefaultTabController(
                    length: 3,
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor: Color(0xFF6B7280),
                            indicatorColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            tabs: [
                              Tab(text: 'Shifts'),
                              Tab(text: 'Performance'),
                              Tab(text: 'Documents'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Shifts tab
                                shiftsAsyncValue.when(
                                  data: (shifts) =>
                                      ShiftsListView(shifts: shifts),
                                  loading: () => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (error, stackTrace) => Center(
                                    child: Text('Error loading shifts: $error'),
                                  ),
                                ),

                                // Performance tab (placeholder)
                                Center(
                                  child: Text(
                                    'Performance metrics coming soon',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ),

                                // Documents tab (placeholder)
                                Center(
                                  child: Text(
                                    'Employee documents coming soon',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
        child: Card(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 24, 24),
        child: Card(
          child: Center(child: Text('Error loading employee: $error')),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Color(0xFF6B7280)),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
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

// Shifts list view
class ShiftsListView extends StatelessWidget {
  final List<Shift> shifts;

  const ShiftsListView({Key? key, required this.shifts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text(
              'No shifts found for this employee',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ListView.builder(
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            color: Color(0xFFF9FAFB),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getShiftStatusColor(shift.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(shift.date),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4),
                      Text(
                        shift.location,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  // Shift status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getShiftStatusColor(
                        shift.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getShiftStatusText(shift.status),
                      style: TextStyle(
                        color: _getShiftStatusColor(shift.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getShiftStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'missed':
        return 'Missed';
      default:
        return 'Unknown';
    }
  }

  Color _getShiftStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Color(0xFF3B82F6); // Blue
      case 'in_progress':
        return Color(0xFFF59E0B); // Amber
      case 'completed':
        return Color(0xFF10B981); // Green
      case 'missed':
        return Color(0xFFEF4444); // Red
      default:
        return Color(0xFF6B7280); // Gray
    }
  }
}

// Dummy data for testing
List<Employee> dummyEmployees = [
  Employee(
    id: 1,
    name: 'John Doe',
    position: 'Senior Developer',
    department: 'Engineering',
    email: 'john.doe@example.com',
    phone: '+1 (555) 123-4567',
    address: '123 Main St, New York, NY',
    dateOfBirth: '1985-05-15',
    employeeId: 'EMP001',
    hireDate: '2018-03-10',
    managerName: 'Jane Smith',
    isActive: true,
  ),
  Employee(
    id: 2,
    name: 'Jane Smith',
    position: 'Engineering Manager',
    department: 'Engineering',
    email: 'jane.smith@example.com',
    phone: '+1 (555) 234-5678',
    address: '456 Park Ave, New York, NY',
    dateOfBirth: '1982-08-20',
    employeeId: 'EMP002',
    hireDate: '2016-07-15',
    managerName: 'Michael Johnson',
    isActive: true,
  ),
  Employee(
    id: 3,
    name: 'Robert Brown',
    position: 'UI Designer',
    department: 'Design',
    email: 'robert.brown@example.com',
    phone: '+1 (555) 345-6789',
    address: '789 Broadway, New York, NY',
    dateOfBirth: '1990-02-10',
    employeeId: 'EMP003',
    hireDate: '2020-01-05',
    managerName: 'Jane Smith',
    isActive: true,
  ),
  Employee(
    id: 4,
    name: 'Emily Wilson',
    position: 'QA Engineer',
    department: 'Engineering',
    email: 'emily.wilson@example.com',
    phone: '+1 (555) 456-7890',
    address: '321 Queens Blvd, New York, NY',
    dateOfBirth: '1988-11-25',
    employeeId: 'EMP004',
    hireDate: '2019-05-20',
    managerName: 'Jane Smith',
    isActive: false,
  ),
  Employee(
    id: 5,
    name: 'Michael Johnson',
    position: 'CTO',
    department: 'Executive',
    email: 'michael.johnson@example.com',
    phone: '+1 (555) 567-8901',
    address: '567 5th Ave, New York, NY',
    dateOfBirth: '1975-07-30',
    employeeId: 'EMP005',
    hireDate: '2015-02-10',
    managerName: null,
    isActive: true,
  ),
  Employee(
    id: 6,
    name: 'Sarah Lee',
    position: 'HR Manager',
    department: 'HR',
    email: 'sarah.lee@example.com',
    phone: '+1 (555) 678-9012',
    address: '432 Madison Ave, New York, NY',
    dateOfBirth: '1983-04-18',
    employeeId: 'EMP006',
    hireDate: '2017-11-15',
    managerName: 'Michael Johnson',
    isActive: true,
  ),
];

List<Shift> dummyShifts = [
  Shift(
    id: 1,
    employeeId: 1,
    date: DateTime.now().add(Duration(days: 1)),
    startTime: DateTime.now().add(Duration(days: 1, hours: 9)),
    endTime: DateTime.now().add(Duration(days: 1, hours: 17)),
    location: 'Main Office',
    status: 'scheduled',
  ),
  Shift(
    id: 2,
    employeeId: 1,
    date: DateTime.now(),
    startTime: DateTime.now().copyWith(hour: 9, minute: 0),
    endTime: DateTime.now().copyWith(hour: 17, minute: 0),
    location: 'Main Office',
    status: 'in_progress',
  ),
  Shift(
    id: 3,
    employeeId: 1,
    date: DateTime.now().subtract(Duration(days: 1)),
    startTime: DateTime.now()
        .subtract(Duration(days: 1))
        .copyWith(hour: 9, minute: 0),
    endTime: DateTime.now()
        .subtract(Duration(days: 1))
        .copyWith(hour: 17, minute: 0),
    location: 'Main Office',
    status: 'completed',
  ),
  Shift(
    id: 4,
    employeeId: 1,
    date: DateTime.now().subtract(Duration(days: 2)),
    startTime: DateTime.now()
        .subtract(Duration(days: 2))
        .copyWith(hour: 9, minute: 0),
    endTime: DateTime.now()
        .subtract(Duration(days: 2))
        .copyWith(hour: 17, minute: 0),
    location: 'Branch Office',
    status: 'completed',
  ),
  Shift(
    id: 5,
    employeeId: 1,
    date: DateTime.now().subtract(Duration(days: 7)),
    startTime: DateTime.now()
        .subtract(Duration(days: 7))
        .copyWith(hour: 9, minute: 0),
    endTime: DateTime.now()
        .subtract(Duration(days: 7))
        .copyWith(hour: 17, minute: 0),
    location: 'Client Site',
    status: 'missed',
  ),
  Shift(
    id: 6,
    employeeId: 2,
    date: DateTime.now(),
    startTime: DateTime.now().copyWith(hour: 9, minute: 0),
    endTime: DateTime.now().copyWith(hour: 17, minute: 0),
    location: 'Main Office',
    status: 'in_progress',
  ),
];

// Entity classes (minimal implementations)

class Employee {
  final int id;
  final String name;
  final String position;
  final String department;
  final String email;
  final String phone;
  final String address;
  final String dateOfBirth;
  final String employeeId;
  final String hireDate;
  final String? managerName;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.employeeId,
    required this.hireDate,
    this.managerName,
    required this.isActive,
  });
}

class Shift {
  final int id;
  final int employeeId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String status; // scheduled, in_progress, completed, missed

  Shift({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.status,
  });
}

// Main app entry point
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management',
      theme: appTheme,
      home: EmployeeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
