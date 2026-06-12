import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_request_coverage_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_request_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_vault_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_request_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_vault_coverage_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_vault_provider.dart';

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

  test('employee document request profile highlights overdue fulfilment', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeDocumentRequestProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.requestedCount, 0);
    expect(profile.reviewingCount, 1);
    expect(profile.issuedPendingAckCount, 1);
    expect(profile.overdueCount, 1);
    expect(profile.attentionCount, 3);
    expect(profile.nextAction, 'Resolve 1 overdue document request.');
  });

  test('employee document request draft validates and submits', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeDocumentRequestDraftProvider('3').notifier,
    );
    draftNotifier
      ..setType(EmployeeDocumentRequestType.salaryCertificate)
      ..setTitle('Salary certificate for visa')
      ..setPurpose('Prepare salary certificate for visa appointment.');

    final draft = container.read(employeeDocumentRequestDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);

    final profileNotifier = container.read(
      employeeDocumentRequestProfileProvider('3').notifier,
    );
    final request = profileNotifier.submitDraft(draft);
    final profile =
        container.read(employeeDocumentRequestProfileProvider('3'))!;

    expect(request.id, 'EDR-3-001');
    expect(request.status, EmployeeDocumentRequestStatus.requested);
    expect(profile.requestedCount, 1);
  });

  test('employee document request creates linked vault coverage request', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final coverage =
        container.read(employeeDocumentVaultCoverageProvider('4'))!;
    final payrollGap = coverage.items.singleWhere(
      (item) => item.category == EmployeeDocumentVaultCategory.payrollTax,
    );

    final notifier = container.read(
      employeeDocumentRequestProfileProvider('4').notifier,
    );
    final request = notifier.submitCoverageRequest(payrollGap);

    expect(request.id, 'EDR-4-003');
    expect(request.type, EmployeeDocumentRequestType.custom);
    expect(request.title, 'Payroll and tax evidence request');
    expect(request.owner, 'Payroll Operations');
    expect(request.dueDate, DateTime(2026, 6, 4));
    expect(request.status, EmployeeDocumentRequestStatus.requested);
    expect(
      request.correlationId,
      EmployeeDocumentCoverageRequestFactory.correlationIdFor(payrollGap),
    );

    final profile =
        container.read(employeeDocumentRequestProfileProvider('4'))!;
    expect(profile.requestedCount, 1);
    expect(() => notifier.submitCoverageRequest(payrollGap), throwsStateError);
  });

  test(
    'employee document request fulfillment updates linked vault evidence',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final coverage =
          container.read(employeeDocumentVaultCoverageProvider('4'))!;
      final requestNotifier = container.read(
        employeeDocumentRequestProfileProvider('4').notifier,
      );
      final vaultNotifier = container.read(
        employeeDocumentVaultProfileProvider('4').notifier,
      );

      final payrollGap = coverage.items.singleWhere(
        (item) => item.category == EmployeeDocumentVaultCategory.payrollTax,
      );
      final payrollRequest = requestNotifier.submitCoverageRequest(payrollGap);
      requestNotifier.issueRequest(payrollRequest.id);
      final issuedPayroll = container
          .read(employeeDocumentRequestProfileProvider('4'))!
          .requests
          .singleWhere((request) => request.id == payrollRequest.id);
      final payrollRecord = vaultNotifier.fulfillCoverageRequest(issuedPayroll);

      expect(payrollRecord.id, 'EDV-4-004');
      expect(payrollRecord.category, EmployeeDocumentVaultCategory.payrollTax);
      expect(payrollRecord.status, EmployeeDocumentVaultStatus.verified);
      expect(payrollRecord.source, 'Document request EDR-4-003');

      var vault = container.read(employeeDocumentVaultProfileProvider('4'))!;
      expect(vault.records.length, 4);
      var refreshedCoverage =
          container.read(employeeDocumentVaultCoverageProvider('4'))!;
      expect(refreshedCoverage.completeCount, 3);
      expect(refreshedCoverage.missingCount, 1);

      final workAuthorizationGap = refreshedCoverage.items.singleWhere(
        (item) =>
            item.category == EmployeeDocumentVaultCategory.workAuthorization,
      );
      final workAuthorizationRequest = requestNotifier.submitCoverageRequest(
        workAuthorizationGap,
      );
      requestNotifier.issueRequest(workAuthorizationRequest.id);
      final issuedWorkAuthorization = container
          .read(employeeDocumentRequestProfileProvider('4'))!
          .requests
          .singleWhere((request) => request.id == workAuthorizationRequest.id);
      final workAuthorizationRecord = vaultNotifier.fulfillCoverageRequest(
        issuedWorkAuthorization,
      );

      expect(workAuthorizationRecord.id, 'EDV-4-003');
      expect(
        workAuthorizationRecord.category,
        EmployeeDocumentVaultCategory.workAuthorization,
      );
      expect(
        workAuthorizationRecord.status,
        EmployeeDocumentVaultStatus.verified,
      );
      expect(workAuthorizationRecord.expiresAt, DateTime(2027, 5, 30));
      expect(workAuthorizationRecord.source, 'Document request EDR-4-004');

      vault = container.read(employeeDocumentVaultProfileProvider('4'))!;
      expect(vault.records.length, 4);
      refreshedCoverage =
          container.read(employeeDocumentVaultCoverageProvider('4'))!;
      expect(refreshedCoverage.completeCount, 4);
      expect(refreshedCoverage.expiringCount, 0);
    },
  );

  test('employee document request actions review issue and acknowledge', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final onboardingNotifier = container.read(
      employeeDocumentRequestProfileProvider('5').notifier,
    );
    onboardingNotifier.markReviewing('EDR-5-001');
    var onboarding =
        container.read(employeeDocumentRequestProfileProvider('5'))!;
    expect(onboarding.requestedCount, 0);
    expect(onboarding.reviewingCount, 1);

    onboardingNotifier.issueRequest('EDR-5-001');
    onboarding = container.read(employeeDocumentRequestProfileProvider('5'))!;
    expect(onboarding.reviewingCount, 0);
    expect(onboarding.attentionCount, 0);

    final watchlistNotifier = container.read(
      employeeDocumentRequestProfileProvider('4').notifier,
    );
    watchlistNotifier.acknowledgeRequest('EDR-4-001');
    final watchlist =
        container.read(employeeDocumentRequestProfileProvider('4'))!;
    final acknowledged = watchlist.requests.singleWhere(
      (request) => request.id == 'EDR-4-001',
    );

    expect(acknowledged.status, EmployeeDocumentRequestStatus.acknowledged);
    expect(watchlist.overdueCount, 0);
    expect(watchlist.issuedPendingAckCount, 0);
    expect(watchlist.nextAction, 'Issue 1 document request under review.');
  });
}
