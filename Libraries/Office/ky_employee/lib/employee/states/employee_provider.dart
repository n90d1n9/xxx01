import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../dummy.dart';
import '../models/employee.dart';
import '../models/employee_detail_summary.dart';
import '../models/shift.dart';
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

  Future<void> deleteEmployee(int id) async {
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
final selectedEmployeeIdProvider = StateProvider<int?>((ref) => null);

final selectedEmployeeProvider = FutureProvider<Employee?>((ref) async {
  final selectedId = ref.watch(selectedEmployeeIdProvider);
  if (selectedId == null) return null;

  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeById(selectedId);
});

final employeeByIdProvider = FutureProvider.family<Employee?, int>((
  ref,
  employeeId,
) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployeeById(employeeId);
});

/////

// Providers
final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  // Fetch employees from your repository
  await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay
  return dummyEmployees;
});

final employeeDetailAsOfDateProvider = Provider<DateTime>(
  (ref) => DateTime(2026, 5, 30),
);

final employeeDetailRecordProvider = FutureProvider.family<Employee?, int>((
  ref,
  employeeId,
) async {
  final employees = await ref.watch(employeesProvider.future);
  for (final employee in employees) {
    if (employee.id == employeeId) return employee;
  }
  return null;
});

final selectedEmployeeProvider2 = StateProvider<Employee?>((ref) => null);

final employeeShiftsProvider = FutureProvider.family<List<Shift>, int>((
  ref,
  employeeId,
) async {
  // Fetch shifts for a specific employee
  await Future.delayed(Duration(milliseconds: 600));
  return dummyShifts.where((shift) => shift.employeeId == employeeId).toList();
});

final employeeDetailSummaryProvider =
    FutureProvider.family<EmployeeDetailSummary?, int>((ref, employeeId) async {
      final employee = await ref.watch(
        employeeDetailRecordProvider(employeeId).future,
      );
      if (employee == null) return null;

      final shifts = await ref.watch(employeeShiftsProvider(employeeId).future);
      final asOfDate = ref.watch(employeeDetailAsOfDateProvider);
      return EmployeeDetailSummary.from(
        employee: employee,
        shifts: shifts,
        asOfDate: asOfDate,
      );
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
              employee.position!.toLowerCase().contains(filter.toLowerCase()) ||
              employee.department!.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  });
});
