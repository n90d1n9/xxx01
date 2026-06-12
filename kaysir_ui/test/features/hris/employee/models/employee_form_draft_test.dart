import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/employee/models/employee_form_draft.dart';

void main() {
  test('employee form draft validates required fields and email', () {
    expect(
      EmployeeFormDraft.validateRequired('', 'a name'),
      'Please enter a name',
    );
    expect(
      EmployeeFormDraft.validateEmail('not-an-email'),
      'Please enter a valid email',
    );
    expect(
      EmployeeFormDraft.validateSalary('-10'),
      'Please enter a valid salary',
    );
    expect(EmployeeFormDraft.validateSalary(''), 'Please enter a salary');
    expect(
      EmployeeFormDraft.validateHireDate(null),
      'Please select a hire date',
    );
    expect(EmployeeFormDraft.validateSalary('85000'), isNull);
  });

  test('employee form draft trims and parses employee values', () {
    final draft = EmployeeFormDraft(
      name: '  Nadia Rahman  ',
      position: ' Product Designer ',
      department: ' Design ',
      email: ' nadia@example.com ',
      phone: ' 555-0101 ',
      salary: ' 95000 ',
      hireDate: DateTime(2026, 1, 15),
    );

    final employee = draft.toEmployee(id: 42);

    expect(employee.id, 42);
    expect(employee.name, 'Nadia Rahman');
    expect(employee.position, 'Product Designer');
    expect(employee.department, 'Design');
    expect(employee.email, 'nadia@example.com');
    expect(employee.phone, '555-0101');
    expect(employee.salary, 95000);
    expect(employee.hireDate, DateTime(2026, 1, 15));
  });

  test('employee form draft tracks completion and readiness', () {
    final empty = EmployeeFormDraft.empty();

    expect(empty.completionRatio, 0);
    expect(empty.isReadyToSave, isFalse);
    expect(empty.validationErrors.length, 7);

    final ready = empty.copyWith(
      name: 'Nadia',
      position: 'Designer',
      department: 'Design',
      email: 'nadia@example.com',
      phone: '555-0101',
      salary: '95000',
      hireDate: DateTime(2026, 1, 15),
    );

    expect(ready.completionRatio, 1);
    expect(ready.isReadyToSave, isTrue);
  });

  test('employee form draft can initialize and preserve existing metadata', () {
    final existing = Employee(
      id: 12,
      name: 'Sarah Lee',
      position: 'HR Manager',
      department: 'HR',
      email: 'sarah@example.com',
      phone: '555-0102',
      hireDate: DateTime(2020, 5, 1),
      salary: 120000,
      employeeId: 'EMP012',
      address: '123 Main',
      managerName: 'Michael',
      isActive: false,
    );

    final draft = EmployeeFormDraft.fromEmployee(
      existing,
    ).copyWith(name: 'Sarah Lim');
    final employee = draft.toEmployee(id: existing.id, existing: existing);

    expect(draft.salary, '120000');
    expect(employee.name, 'Sarah Lim');
    expect(employee.employeeId, 'EMP012');
    expect(employee.address, '123 Main');
    expect(employee.managerName, 'Michael');
    expect(employee.isActive, isFalse);
  });
}
