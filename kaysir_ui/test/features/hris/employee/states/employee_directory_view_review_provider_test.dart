import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_view_review_provider.dart';

void main() {
  test('employee directory view review summarizes the default saved view', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final review = container.read(employeeDirectoryViewReviewProvider);

    expect(review.isSavedView, isTrue);
    expect(review.viewName, 'All employees');
    expect(review.visibleCount, 5);
    expect(review.totalCount, 5);
    expect(review.coveragePercent, 100);
    expect(review.focusLabel, 'Full roster');
    expect(review.readinessScore, 100);
    expect(review.readinessLabel, 'Ready');
    expect(review.activeFilterCount, 0);
    expect(review.filterStackLabel, 'No filters');
    expect(review.qualityGateLabel, 'Clear');
    expect(review.bulkScopeLabel, 'Roster-wide');
    expect(
      review.signals.map((signal) => signal.title),
      contains('Roster-wide view'),
    );
  });

  test('employee directory view review flags manual quality cohorts', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(
              id: '1',
              name: 'Sarah Johnson',
              email: 'shared@example.com',
            ),
            _member(
              id: '2',
              name: 'Maya Santoso',
              email: 'shared@example.com',
              manager: '',
            ),
            _member(id: '3', name: 'Rafi Pratama'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryTablePresetControllerProvider)
        .markManualChange();
    container.read(employeeDirectoryQualityFilterProvider.notifier).state =
        EmployeeDirectoryQualityFilter.duplicateEmail;

    final review = container.read(employeeDirectoryViewReviewProvider);

    expect(review.isSavedView, isFalse);
    expect(review.viewName, 'Custom view');
    expect(review.visibleCount, 2);
    expect(review.totalCount, 3);
    expect(review.coveragePercent, 67);
    expect(review.focusLabel, 'Segmented view');
    expect(review.activeFilterCount, 1);
    expect(review.filterStackDetail, 'Duplicate emails');
    expect(review.affectedVisibleCount, 2);
    expect(review.criticalVisibleCount, 2);
    expect(review.readinessScore, 0);
    expect(review.readinessLabel, 'Needs cleanup');
    expect(review.qualityGateLabel, '2 affected');
    expect(review.bulkScopeLabel, 'Review first');
    expect(
      review.signals.map((signal) => signal.title),
      containsAll(['Manual view active', 'Critical data issues']),
    );
  });
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: '+62 812 0000 0000',
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
