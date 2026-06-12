import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

void main() {
  test('employee directory summary rolls up default population', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(employeeDirectorySummaryProvider);

    expect(summary.headcount, 5);
    expect(summary.departmentCount, 5);
    expect(summary.highPerformerCount, 3);
    expect(summary.averagePerformance, 4.6);
    expect(summary.averageTenureMonths, 51);
    expect(summary.watchlistCount, 1);
  });

  test('employee directory filters by department and search query', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(employeeDirectorySelectedDepartmentProvider.notifier).state =
        'Engineering';
    container.read(employeeDirectorySearchQueryProvider.notifier).state =
        'developer';

    final employees = container.read(filteredEmployeeDirectoryMembersProvider);

    expect(employees, hasLength(1));
    expect(employees.single.name, 'Michael Chen');
    expect(container.read(employeeDirectorySummaryProvider).headcount, 1);
  });

  test('employee directory high performer view can be toggled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(employeeDirectoryHighPerformerOnlyProvider.notifier).state =
        true;

    final employees = container.read(filteredEmployeeDirectoryMembersProvider);

    expect(employees, hasLength(3));
    expect(employees.every((employee) => employee.isHighPerformer), isTrue);
  });

  test('employee directory risk summary highlights talent signals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final risks = container.read(employeeDirectoryRiskSummaryProvider);

    expect(risks.watchlistCount, 1);
    expect(risks.onboardingCount, 1);
    expect(risks.lowPerformanceCount, 1);
    expect(risks.highPerformerCount, 3);
    expect(risks.departmentCount, 5);
    expect(risks.totalRisks, 3);
  });

  test('employee directory date override drives tenure summary', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2027, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(employeeDirectorySummaryProvider);

    expect(summary.averageTenureMonths, 63);
  });
}
