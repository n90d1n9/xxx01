import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_management_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_management_provider.dart';

void main() {
  test('employee management snapshot highlights watchlist record risk', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = container.read(employeeManagementSnapshotProvider('4'));

    expect(snapshot, isNotNull);
    expect(snapshot!.member.name, 'David Kim');
    expect(snapshot.health, EmployeeManagementHealth.actionRequired);
    expect(snapshot.readinessScore, 48);
    expect(snapshot.payrollGroup, 'ID-Monthly');
    expect(snapshot.jobLevel, 'M2');
    expect(snapshot.costCenter, 'PRO-001');
    expect(snapshot.documentAttentionCount, 2);
    expect(snapshot.missingDocumentCount, 1);
    expect(snapshot.pendingAssetCount, 0);
    expect(snapshot.nextAction, 'Complete missing employee documents.');
    expect(snapshot.latestEvent?.title, 'Manager follow-up required');
    expect(snapshot.documents.map((document) => document.title), [
      'Identity verification',
      'Employment agreement',
      'Manager coaching notes',
      'Performance improvement plan',
    ]);
  });

  test('employee management snapshot tracks onboarding payroll and assets', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = container.read(employeeManagementSnapshotProvider('5'));

    expect(snapshot, isNotNull);
    expect(snapshot!.member.name, 'Olivia Wilson');
    expect(snapshot.health, EmployeeManagementHealth.actionRequired);
    expect(snapshot.readinessScore, 44);
    expect(snapshot.employmentType, 'Probationary');
    expect(snapshot.jobLevel, 'L1');
    expect(snapshot.documentAttentionCount, 2);
    expect(snapshot.overdueDocumentCount, 1);
    expect(snapshot.pendingAssetCount, 1);
    expect(snapshot.activeAssetCount, 1);
    expect(snapshot.nextAction, 'Resolve overdue employee documents.');
    expect(snapshot.latestEvent?.title, 'Onboarding checkpoint');
  });

  test('employee management directory summary aggregates filtered records', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(employeeManagementDirectorySummaryProvider);

    expect(summary.employeeCount, 5);
    expect(summary.healthyCount, 1);
    expect(summary.reviewCount, 2);
    expect(summary.actionRequiredCount, 2);
    expect(summary.documentAttentionCount, 6);
    expect(summary.pendingAssetCount, 1);
    expect(summary.onboardingCount, 1);
    expect(summary.nextAction, 'Resolve 2 employee records needing action.');
  });

  test('employee management summary follows directory filters', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectoryHighPerformerOnlyProvider.notifier).state =
        true;

    final snapshots = container.read(employeeManagementSnapshotsProvider);
    final summary = container.read(employeeManagementDirectorySummaryProvider);

    expect(snapshots.map((snapshot) => snapshot.member.name), [
      'Sarah Johnson',
      'Michael Chen',
      'Olivia Wilson',
    ]);
    expect(summary.employeeCount, 3);
    expect(summary.reviewCount, 2);
    expect(summary.actionRequiredCount, 1);
    expect(summary.documentAttentionCount, 4);
  });
}
