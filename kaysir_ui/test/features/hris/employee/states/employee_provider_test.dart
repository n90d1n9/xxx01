import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/employee/states/employee_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_repository.dart';

void main() {
  test(
    'employeeByIdProvider fetches employee directly from route id',
    () async {
      final repository = _FakeEmployeeRepository([
        Employee(
          id: 7,
          name: 'Nadia Rahman',
          position: 'Product Designer',
          department: 'Design',
          email: 'nadia@example.com',
          phone: '555-0101',
        ),
      ]);
      final container = ProviderContainer(
        overrides: [employeeRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final employee = await container.read(employeeByIdProvider(7).future);

      expect(employee?.name, 'Nadia Rahman');
      expect(employee?.department, 'Design');
    },
  );

  test(
    'employeeByIdProvider is independent from selected employee state',
    () async {
      final repository = _FakeEmployeeRepository([
        Employee(
          id: 7,
          name: 'Nadia Rahman',
          position: 'Product Designer',
          department: 'Design',
          email: 'nadia@example.com',
          phone: '555-0101',
        ),
        Employee(
          id: 8,
          name: 'Rizky Pratama',
          position: 'Operations Lead',
          department: 'Operations',
          email: 'rizky@example.com',
          phone: '555-0102',
        ),
      ]);
      final container = ProviderContainer(
        overrides: [employeeRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      container.read(selectedEmployeeIdProvider.notifier).state = 8;

      final employee = await container.read(employeeByIdProvider(7).future);

      expect(employee?.name, 'Nadia Rahman');
    },
  );
}

class _FakeEmployeeRepository implements EmployeeRepository {
  final List<Employee> employees;

  _FakeEmployeeRepository(this.employees);

  @override
  Future<Employee> addEmployee(Employee employee) async => employee;

  @override
  Future<void> deleteEmployee(int id) async {}

  @override
  Future<Employee> getEmployeeById(int id) async {
    return employees.firstWhere(
      (employee) => employee.id == id,
      orElse: () => throw Exception('Employee not found'),
    );
  }

  @override
  Future<List<Employee>> getEmployees() async => employees;

  @override
  Future<Employee> updateEmployee(Employee employee) async => employee;
}
