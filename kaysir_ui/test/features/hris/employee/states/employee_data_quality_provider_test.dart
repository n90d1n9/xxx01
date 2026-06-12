import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_data_quality_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_data_quality_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

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

  test('employee data quality seeds issues from profile completeness', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeDataQualityProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.issues, isNotEmpty);
    expect(profile.openCount, greaterThan(0));
    expect(profile.highRiskCount, greaterThan(0));
    expect(profile.score, inInclusiveRange(0, 100));
    expect(profile.nextAction, isNot('Employee data quality is clear.'));
    expect(
      profile.issues.map((issue) => issue.sourceLabel),
      contains('Profile completeness'),
    );
  });

  test('employee data quality adds reviews resolves and waives issues', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeDataQualityIssueDraftProvider('1').notifier,
    );
    draftNotifier.setTitle('Manager field mismatch');
    draftNotifier.setField('Manager');
    draftNotifier.setDetail('Manager name differs from reporting record.');
    draftNotifier.setSeverity(EmployeeDataQualitySeverity.high);

    final draft = container.read(employeeDataQualityIssueDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(employeeDataQualityProvider('1').notifier);
    final issue = notifier.addDraft(draft);

    var profile = container.read(employeeDataQualityProvider('1'))!;
    expect(issue.title, 'Manager field mismatch');
    expect(profile.issues.first.id, issue.id);
    expect(profile.highRiskCount, greaterThan(0));

    notifier.reviewIssue(issue.id);
    profile = container.read(employeeDataQualityProvider('1'))!;
    expect(profile.reviewedCount, 1);

    notifier.resolveIssue(issue.id);
    profile = container.read(employeeDataQualityProvider('1'))!;
    expect(profile.issues.first.status, EmployeeDataQualityStatus.resolved);

    notifier.waiveIssue(profile.sortedIssues.last.id);
    profile = container.read(employeeDataQualityProvider('1'))!;
    expect(profile.waivedCount, greaterThan(0));
  });

  test('employee data quality detects duplicate email records', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final members = container.read(employeeDirectoryMembersProvider);
    container
        .read(employeeDirectoryMembersProvider.notifier)
        .addMember(
          members.first.copyWith(
            name: 'Sarah Johnson Duplicate',
            position: 'HR Analyst',
          ),
        );

    final profile = container.read(employeeDataQualityProvider('1'))!;
    expect(
      profile.issues.map((issue) => issue.type),
      contains(EmployeeDataQualityIssueType.duplicateRisk),
    );
    expect(profile.highRiskCount, greaterThan(0));
  });

  test('employee data quality returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeDataQualityProvider('missing')), isNull);
    expect(
      container.read(employeeDataQualityIssueDraftProvider('missing')),
      isNull,
    );
  });
}
