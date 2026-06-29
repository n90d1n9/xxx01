import 'employee.dart';

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
