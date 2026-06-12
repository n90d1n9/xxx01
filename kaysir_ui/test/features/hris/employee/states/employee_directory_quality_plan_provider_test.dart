import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_plan_provider.dart';

void main() {
  test('employee directory quality fix plan prioritizes critical cleanup', () {
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

    final plan = container.read(employeeDirectoryQualityFixPlanProvider);

    expect(plan.issueCount, 3);
    expect(plan.affectedProfileCount, 2);
    expect(plan.estimatedMinutes, 19);
    expect(plan.targetReadinessScore, 67);
    expect(
      plan.summaryLabel,
      '3 fixes planned across 2 profiles, 19 min estimated',
    );
    expect(plan.recommendedActionLabel, 'Fix duplicate email for Maya Santoso');
    expect(
      plan.lanes.first.severity,
      EmployeeDirectoryQualitySeverity.critical,
    );
    expect(plan.lanes.first.issueCount, 2);
    expect(
      plan.groups.first.type,
      EmployeeDirectoryQualityIssueType.duplicateEmail,
    );
    expect(plan.groups.first.profileLabel, 'Maya Santoso, Sarah Johnson');
  });

  test('employee directory quality fix plan reports clear roster', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(id: '1', name: 'Sarah Johnson'),
            _member(id: '2', name: 'Maya Santoso', email: 'maya@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final plan = container.read(employeeDirectoryQualityFixPlanProvider);

    expect(plan.isClear, isTrue);
    expect(plan.issueCount, 0);
    expect(plan.targetReadinessScore, 100);
    expect(plan.nextFocusLabel, 'No fixes');
    expect(
      plan.summaryLabel,
      'Roster quality is ready for payroll and reporting',
    );
  });
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String phone = '+62 812 0000 0000',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: phone,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
