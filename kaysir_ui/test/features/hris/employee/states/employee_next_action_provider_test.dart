import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_next_action_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_next_action_provider.dart';

void main() {
  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
  }

  test('employee next action provider aggregates ranked HRIS signals', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeNextActionProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.actions, isNotEmpty);
    expect(profile.topActions.length, lessThanOrEqualTo(5));
    expect(profile.urgentCount, greaterThan(0));
    expect(profile.nextAction, isNot('No open employee actions.'));

    final topAction = profile.topActions.first;
    expect(topAction.priority, EmployeeNextActionPriority.critical);
    expect(topAction.isUrgent, isTrue);

    final areas = profile.actions.map((action) => action.area);
    expect(areas, contains(EmployeeNextActionArea.records));
    expect(areas, contains(EmployeeNextActionArea.security));

    final sources = profile.actions.map((action) => action.sourceLabel);
    expect(sources, contains('Profile completeness'));
    expect(sources, contains('Position control'));
    expect(sources, contains('Manager change readiness'));
    expect(sources, contains('Job history'));
    expect(sources, contains('Approval coverage'));
    expect(sources, contains('Approval policy'));
    expect(sources, contains('Workflow automation'));
    expect(sources, contains('Timekeeping'));
    expect(sources, contains('Payroll cutoff'));
    expect(sources, contains('Payroll variance'));
    expect(sources, contains('Payroll run'));
    expect(sources, contains('Payroll payment'));
    expect(sources, contains('Payslip delivery'));
    expect(sources, contains('Payroll close'));
    expect(sources, contains('Performance support'));
    expect(sources, contains('Skills inventory'));
    expect(sources, contains('Talent calibration'));
    expect(sources, contains('Succession coverage'));
    expect(sources, contains('Data quality'));
    expect(sources, contains('Data correction'));
    expect(sources, contains('Correction governance'));
    expect(sources, contains('Exit readiness'));
    expect(sources, contains('Mobility readiness'));
  });

  test('employee next action provider returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeNextActionProfileProvider('missing')),
      isNull,
    );
  });
}
