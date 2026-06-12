import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_selection_review_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_provider.dart';

void main() {
  test('employee directory selection review is empty by default', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final review = container.read(employeeDirectorySelectionReviewProvider);

    expect(review.hasSelection, isFalse);
    expect(review.selectedCount, 0);
    expect(review.primaryDepartment, 'None');
    expect(review.statusMixLabel, 'No selection');
    expect(review.signals.single.title, 'No cohort selected');
  });

  test('employee directory selection review summarizes selected cohort', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['1', '4']);

    final review = container.read(employeeDirectorySelectionReviewProvider);

    expect(review.selectedCount, 2);
    expect(review.departmentCount, 2);
    expect(review.locationCount, 1);
    expect(review.watchlistCount, 1);
    expect(review.highPerformerCount, 1);
    expect(review.averagePerformance.toStringAsFixed(1), '4.5');
    expect(review.averageTenureMonths, 44);
    expect(review.primaryDepartment, 'Design');
    expect(review.primaryLocation, 'Jakarta');
    expect(review.statusMixLabel, 'Mixed statuses');
    expect(
      review.signals.map((signal) => signal.title),
      containsAll([
        'Watchlist included',
        'Mixed departments',
        'High performers included',
      ]),
    );
  });
}
