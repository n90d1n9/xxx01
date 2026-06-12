import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_compliance_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_compliance_provider.dart';
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

  test('employee compliance summary highlights onboarding blockers', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final summary = container.read(employeeComplianceSummaryProvider('5'));
    final records = container.read(employeeComplianceRecordsProvider('5'));

    expect(records.map((record) => record.id), contains('5-tax'));
    expect(summary.pendingCount, 2);
    expect(summary.overdueCount, 1);
    expect(summary.nextAction, 'Review 1 overdue document.');
  });

  test('employee compliance document draft adds and verifies record', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeComplianceDocumentDraftProvider('1').notifier,
    );
    draftNotifier.setTitle('Security certification');
    draftNotifier.setType(EmployeeComplianceDocumentType.certification);
    draftNotifier.setOwner('Security Operations');
    draftNotifier.setDueDate(DateTime(2026, 6, 10));
    draftNotifier.setExpiresAt(DateTime(2027, 6, 10));
    draftNotifier.setNotes('Certification uploaded for annual compliance.');

    final draft = container.read(employeeComplianceDocumentDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);

    final recordsNotifier = container.read(
      employeeComplianceRecordsProvider('1').notifier,
    );
    final record = recordsNotifier.addDraft(draft);

    expect(record.id, 'ECD-1-004');
    expect(record.status, EmployeeComplianceDocumentStatus.pending);

    recordsNotifier.verify(record.id);
    final updated = container
        .read(employeeComplianceRecordsProvider('1'))
        .singleWhere((item) => item.id == record.id);

    expect(updated.status, EmployeeComplianceDocumentStatus.verified);
  });

  test('employee compliance renewal clears expiring soon attention', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final summary = container.read(employeeComplianceSummaryProvider('2'));
    expect(summary.expiringSoonCount, 1);

    final record = container
        .read(employeeComplianceRecordsProvider('2'))
        .singleWhere((item) => item.id == '2-work-permit');

    container
        .read(employeeComplianceRecordsProvider('2').notifier)
        .renew(record.id, DateTime(2027, 5, 30));

    final renewedSummary = container.read(
      employeeComplianceSummaryProvider('2'),
    );
    final renewedRecord = container
        .read(employeeComplianceRecordsProvider('2'))
        .singleWhere((item) => item.id == '2-work-permit');

    expect(renewedRecord.status, EmployeeComplianceDocumentStatus.verified);
    expect(renewedRecord.expiresAt, DateTime(2027, 5, 30));
    expect(renewedSummary.expiringSoonCount, 0);
  });
}
