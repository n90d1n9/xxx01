import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee.dart';
import '../models/employee_form_draft.dart';

final employeeFormDraftProvider =
    StateNotifierProvider<EmployeeFormDraftNotifier, EmployeeFormDraft>(
      (ref) => EmployeeFormDraftNotifier(),
    );

class EmployeeFormDraftNotifier extends StateNotifier<EmployeeFormDraft> {
  EmployeeFormDraftNotifier() : super(EmployeeFormDraft.empty());

  void initialize(Employee? employee) {
    state = EmployeeFormDraft.fromEmployee(employee);
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setPosition(String value) {
    state = state.copyWith(position: value);
  }

  void setDepartment(String value) {
    state = state.copyWith(department: value);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPhone(String value) {
    state = state.copyWith(phone: value);
  }

  void setSalary(String value) {
    state = state.copyWith(salary: value);
  }

  void setHireDate(DateTime value) {
    state = state.copyWith(hireDate: value);
  }

  void clear() {
    state = EmployeeFormDraft.empty();
  }
}
