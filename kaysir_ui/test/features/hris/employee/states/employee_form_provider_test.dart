import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/employee/states/employee_form_provider.dart';

void main() {
  test('employee form provider initializes from employee', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(employeeFormDraftProvider.notifier)
        .initialize(
          Employee(
            id: 7,
            name: 'Nadia Rahman',
            position: 'Product Designer',
            department: 'Design',
            email: 'nadia@example.com',
            phone: '555-0101',
            hireDate: DateTime(2024, 1, 15),
            salary: 95000,
          ),
        );

    final draft = container.read(employeeFormDraftProvider);

    expect(draft.name, 'Nadia Rahman');
    expect(draft.salary, '95000');
    expect(draft.isReadyToSave, isTrue);
  });

  test('employee form provider updates individual draft fields', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(employeeFormDraftProvider.notifier);
    notifier.setName('Rizky');
    notifier.setPosition('Operations Lead');
    notifier.setDepartment('Operations');
    notifier.setEmail('rizky@example.com');
    notifier.setPhone('555-0102');
    notifier.setSalary('88000');
    notifier.setHireDate(DateTime(2024, 2, 20));

    final draft = container.read(employeeFormDraftProvider);

    expect(draft.name, 'Rizky');
    expect(draft.department, 'Operations');
    expect(draft.isReadyToSave, isTrue);
  });

  test('employee form provider clears back to empty draft', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(employeeFormDraftProvider.notifier);
    notifier.setName('Rizky');
    notifier.clear();

    final draft = container.read(employeeFormDraftProvider);

    expect(draft.name, isEmpty);
    expect(draft.isReadyToSave, isFalse);
  });
}
