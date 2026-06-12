import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';

import 'package:uuid/uuid.dart';

// MODELS
// lib/models/employee.dart
class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final String email;
  final String phone;
  final DateTime? hireDate;
  final String? imageUrl;
  final double? salary;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    this.hireDate,
    this.imageUrl,
    this.salary,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? position,
    String? department,
    String? email,
    String? phone,
    DateTime? hireDate,
    String? imageUrl,
    double? salary,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hireDate: hireDate ?? this.hireDate,
      imageUrl: imageUrl ?? this.imageUrl,
      salary: salary ?? this.salary,
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      hireDate: json['hireDate'] != null
          ? DateTime.parse(json['hireDate'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      salary: json['salary'] != null ? json['salary'] as double : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'email': email,
      'phone': phone,
      'hireDate': hireDate?.toIso8601String(),
      'imageUrl': imageUrl,
      'salary': salary,
    };
  }
}

// REPOSITORIES
// lib/repositories/employee_repository.dart

abstract class EmployeeRepository {
  Future<List<Employee>> getEmployees();
  Future<Employee> getEmployeeById(String id);
  Future<Employee> addEmployee(Employee employee);
  Future<Employee> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String id);
}

// Implementation using a mock data source
// lib/repositories/employee_repository_impl.dart

class EmployeeRepositoryImpl implements EmployeeRepository {
  final List<Employee> _employees = [];

  EmployeeRepositoryImpl() {
    // Add some mock data
    _employees.addAll([
      Employee(
        id: '1',
        name: 'John Doe',
        position: 'Software Engineer',
        department: 'Engineering',
        email: 'john.doe@example.com',
        phone: '555-1234',
        hireDate: DateTime(2022, 3, 15),
        salary: 85000,
      ),
      Employee(
        id: '2',
        name: 'Jane Smith',
        position: 'Product Manager',
        department: 'Product',
        email: 'jane.smith@example.com',
        phone: '555-5678',
        hireDate: DateTime(2021, 6, 10),
        salary: 95000,
      ),
    ]);
  }

  @override
  Future<List<Employee>> getEmployees() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return [..._employees];
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _employees.firstWhere(
      (employee) => employee.id == id,
      orElse: () => throw Exception('Employee not found'),
    );
  }

  @override
  Future<Employee> addEmployee(Employee employee) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _employees.add(employee);
    return employee;
  }

  @override
  Future<Employee> updateEmployee(Employee employee) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index >= 0) {
      _employees[index] = employee;
      return employee;
    }
    throw Exception('Employee not found');
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _employees.removeWhere((employee) => employee.id == id);
  }
}

// PROVIDERS
// lib/providers/employee_providers.dart
/* import 'package:flutter_riverpod/legacy.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';
import '../repositories/employee_repository_impl.dart'; */

// Repository provider
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl();
});

// State notifier for employee list
class EmployeeListNotifier extends StateNotifier<AsyncValue<List<Employee>>> {
  final EmployeeRepository _repository;

  EmployeeListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    try {
      state = const AsyncValue.loading();
      final employees = await _repository.getEmployees();
      state = AsyncValue.data(employees);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      await _repository.addEmployee(employee);
      loadEmployees();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      await _repository.updateEmployee(employee);
      loadEmployees();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await _repository.deleteEmployee(id);
      loadEmployees();
    } catch (e) {
      rethrow;
    }
  }
}

// Employee list provider
final employeeListProvider =
    StateNotifierProvider<EmployeeListNotifier, AsyncValue<List<Employee>>>((
      ref,
    ) {
      final repository = ref.watch(employeeRepositoryProvider);
      return EmployeeListNotifier(repository);
    });

// Selected employee provider
final selectedEmployeeIdProvider = StateProvider<String?>((ref) => null);

final selectedEmployeeProvider = FutureProvider<Employee?>((ref) async {
  final selectedId = ref.watch(selectedEmployeeIdProvider);
  if (selectedId == null) return null;

  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeById(selectedId);
});

// SCREENS
// lib/screens/employee_list_screen.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import 'employee_detail_screen.dart';
import 'add_edit_employee_screen.dart'; */

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesState = ref.watch(employeeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(employeeListProvider.notifier).loadEmployees(),
          ),
        ],
      ),
      body: employeesState.when(
        data: (employees) => employees.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No employees found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditEmployeeScreen(),
                        ),
                      ),
                      child: const Text('Add Employee'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return EmployeeListTile(employee: employee);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(employeeListProvider.notifier).loadEmployees(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditEmployeeScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EmployeeListTile extends ConsumerWidget {
  final Employee employee;

  const EmployeeListTile({Key? key, required this.employee}) : super(key: key);

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
              builder: (context) =>
                  EmployeeDetailScreen(employeeId: employee.id),
            ),
          );
        },
      ),
    );
  }
}

// lib/screens/employee_detail_screen.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/employee_providers.dart';
import 'add_edit_employee_screen.dart'; */

class EmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailScreen({Key? key, required this.employeeId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(selectedEmployeeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          employeeAsync.when(
            data: (employee) => employee != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditEmployeeScreen(employee: employee),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: employeeAsync.when(
        data: (employee) => employee == null
            ? const Center(child: Text('Employee not found'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueGrey.shade300,
                        child: Text(
                          employee.name.isNotEmpty
                              ? employee.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        employee.position,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoCard(
                      icon: Icons.business,
                      title: 'Department',
                      value: employee.department,
                    ),
                    _buildInfoCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: employee.email,
                    ),
                    _buildInfoCard(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: employee.phone,
                    ),
                    if (employee.hireDate != null)
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Hire Date',
                        value:
                            '${employee.hireDate!.day}/${employee.hireDate!.month}/${employee.hireDate!.year}',
                      ),
                    if (employee.salary != null)
                      _buildInfoCard(
                        icon: Icons.attach_money,
                        title: 'Salary',
                        value: '\$${employee.salary!.toStringAsFixed(2)}',
                      ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Employee'),
                              content: const Text(
                                'Are you sure you want to delete this employee? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(employeeListProvider.notifier)
                                        .deleteEmployee(employee.id);
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context); // Go back to list
                                  },
                                  child: const Text(
                                    'DELETE',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete Employee',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/add_edit_employee_screen.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart'; */

class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  final Employee? employee;

  const AddEditEmployeeScreen({Key? key, this.employee}) : super(key: key);

  @override
  ConsumerState<AddEditEmployeeScreen> createState() =>
      _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends ConsumerState<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _positionController;
  late final TextEditingController _departmentController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _salaryController;
  DateTime? _hireDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _positionController = TextEditingController(
      text: widget.employee?.position ?? '',
    );
    _departmentController = TextEditingController(
      text: widget.employee?.department ?? '',
    );
    _emailController = TextEditingController(
      text: widget.employee?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.employee?.phone ?? '',
    );
    _salaryController = TextEditingController(
      text: widget.employee?.salary?.toString() ?? '',
    );
    _hireDate = widget.employee?.hireDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final employee = Employee(
        id: widget.employee?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        position: _positionController.text.trim(),
        department: _departmentController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        hireDate: _hireDate,
        salary: _salaryController.text.isNotEmpty
            ? double.parse(_salaryController.text)
            : null,
      );

      if (widget.employee == null) {
        await ref.read(employeeListProvider.notifier).addEmployee(employee);
      } else {
        await ref.read(employeeListProvider.notifier).updateEmployee(employee);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _hireDate) {
      setState(() {
        _hireDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _positionController,
                      decoration: const InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a position';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hire Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _hireDate == null
                              ? 'Select a date'
                              : '${_hireDate!.day}/${_hireDate!.month}/${_hireDate!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _salaryController,
                      decoration: const InputDecoration(
                        labelText: 'Salary',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveEmployee,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.employee == null
                            ? 'Add Employee'
                            : 'Update Employee',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// MAIN APP
// lib/main.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'screens/employee_list_screen.dart';
 */
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const EmployeeListScreen(),
    );
  }
}
