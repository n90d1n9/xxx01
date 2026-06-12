import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/states/employee_provider.dart';

void main() {
  test('employee detail record resolves selected employee safely', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final employee = await container.read(
      employeeDetailRecordProvider(1).future,
    );
    final missing = await container.read(
      employeeDetailRecordProvider(999).future,
    );

    expect(employee?.name, 'John Doe');
    expect(employee?.department, 'Engineering');
    expect(missing, isNull);
  });

  test(
    'employee detail summary aggregates profile and shift signals',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final summary = await container.read(
        employeeDetailSummaryProvider(1).future,
      );

      expect(summary, isNotNull);
      expect(summary!.isActive, isTrue);
      expect(summary.tenureMonths, 208);
      expect(summary.totalShifts, 5);
      expect(summary.scheduledShifts, 1);
      expect(summary.inProgressShifts, 1);
      expect(summary.completedShifts, 2);
      expect(summary.missedShifts, 1);
      expect(summary.primaryLocation, 'Main Office');
    },
  );

  test('employee detail summary returns null for missing employee', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = await container.read(
      employeeDetailSummaryProvider(999).future,
    );

    expect(summary, isNull);
  });
}
