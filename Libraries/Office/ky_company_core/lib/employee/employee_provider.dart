// Repository provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'employee.dart';
import 'employee_repository.dart';

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
