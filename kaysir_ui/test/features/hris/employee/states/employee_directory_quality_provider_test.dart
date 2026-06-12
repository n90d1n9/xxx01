import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_provider.dart';

void main() {
  test('employee directory quality report detects roster cleanup issues', () {
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
              phone: '',
              joiningDate: DateTime(2026, 7, 1),
            ),
            _member(id: '3', name: 'Rafi Pratama'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final report = container.read(employeeDirectoryQualityReportProvider);

    expect(report.issueCount, 5);
    expect(report.criticalCount, 3);
    expect(report.affectedProfileCount, 2);
    expect(report.readyProfileCount, 1);
    expect(report.readinessScore, 33);
    expect(report.readinessLabel, 'Needs cleanup');
    expect(
      report.countForType(EmployeeDirectoryQualityIssueType.duplicateEmail),
      2,
    );
    expect(
      report.hasIssue('2', EmployeeDirectoryQualityIssueType.missingManager),
      isTrue,
    );
    expect(report.hasAnyIssue('3'), isFalse);
  });

  test('employee directory quality filters match affected profiles', () {
    final report = EmployeeDirectoryQualityReport.fromMembers(
      members: [
        _member(id: '1', name: 'Sarah Johnson', email: 'shared@example.com'),
        _member(
          id: '2',
          name: 'Maya Santoso',
          email: 'shared@example.com',
          manager: '',
        ),
        _member(id: '3', name: 'Rafi Pratama'),
      ],
      asOfDate: DateTime(2026, 5, 30),
    );

    expect(
      EmployeeDirectoryQualityFilter.duplicateEmail.matches(
        report.members.first,
        report,
      ),
      isTrue,
    );
    expect(
      EmployeeDirectoryQualityFilter.missingManager.matches(
        report.members[1],
        report,
      ),
      isTrue,
    );
    expect(
      EmployeeDirectoryQualityFilter.incompleteProfile.matches(
        report.members.last,
        report,
      ),
      isFalse,
    );
  });
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String phone = '+62 812 0000 0000',
  String manager = 'Emma Rodriguez',
  DateTime? joiningDate,
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: phone,
    joiningDate: joiningDate ?? DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
