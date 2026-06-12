import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/payroal/models/payroll_management_models.dart';
import 'package:kaysir/features/hris/payroal/states/payroll_provider.dart';

void main() {
  test('payroll summary aggregates payroll totals and payment progress', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(payrollSummaryProvider);

    expect(summary.employeeCount, 3);
    expect(summary.paidCount, 0);
    expect(summary.pendingCount, 3);
    expect(summary.totalGross, 25500);
    expect(summary.totalNet, closeTo(16424.25, 0.01));
    expect(summary.totalDeductions, closeTo(9075.75, 0.01));

    container.read(paymentStatusProvider.notifier).state = {
      ...container.read(paymentStatusProvider),
      2: true,
    };

    final updated = container.read(payrollSummaryProvider);
    expect(updated.paidCount, 1);
    expect(updated.pendingCount, 2);
    expect(updated.completionRate, closeTo(1 / 3, 0.0001));
  });

  test('payroll details follow selected payroll employee', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(payrollDetailsProvider), isNull);

    final employees = container.read(employeesProvider2);
    container.read(selectedEmployeeProvider3.notifier).state = employees.first;

    final details = container.read(payrollDetailsProvider);
    expect(details, isNotNull);
    expect(details!.grossSalary, 8500);
    expect(details.netSalary, closeTo(5474.75, 0.01));
  });

  test('payroll input changes track approval and application readiness', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var inputs = container.read(payrollInputChangeSummaryProvider);

    expect(inputs.lines.length, 4);
    expect(inputs.status, PayrollInputChangeStatus.blocked);
    expect(inputs.blockedCount, 1);
    expect(inputs.pendingCount, 3);
    expect(inputs.approvedCount, 0);
    expect(inputs.grossImpact, 1520);
    expect(inputs.nextAction, 'Resolve 1 payroll input blockers.');

    final unpaidLeave = inputs.lines.firstWhere(
      (line) => line.id == 'PIC-1003',
    );
    expect(unpaidLeave.status, PayrollInputChangeStatus.blocked);
    expect(unpaidLeave.payrollImpact, -480);
    expect(unpaidLeave.nextAction, 'Missing supporting document');

    container.read(selectedEmployeeProvider3.notifier).state = container
        .read(employeesProvider2)
        .firstWhere((employee) => employee.id == 2);
    inputs = container.read(payrollInputChangeSummaryProvider);
    expect(inputs.visibleLines.length, 2);
    expect(
      inputs.visibleLines.map((line) => line.request.type),
      containsAll([
        PayrollInputChangeType.bonus,
        PayrollInputChangeType.retroAdjustment,
      ]),
    );

    container.read(payrollApprovedInputChangeIdsProvider.notifier).state = {
      for (final line in inputs.lines.where((line) => line.canApprove)) line.id,
    };
    inputs = container.read(payrollInputChangeSummaryProvider);
    expect(inputs.approvedCount, 3);
    expect(inputs.pendingCount, 0);
    expect(inputs.canApply, isTrue);

    container.read(payrollAppliedInputChangeIdsProvider.notifier).state = {
      for (final line in inputs.lines.where((line) => line.canApply)) line.id,
    };
    inputs = container.read(payrollInputChangeSummaryProvider);
    expect(inputs.appliedCount, 3);
    expect(inputs.appliedImpact, 2000);
    expect(inputs.status, PayrollInputChangeStatus.blocked);
  });

  test('payroll data import previews row validation errors', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      payrollDataImportDraftProvider.notifier,
    );
    draftNotifier.setCsvText(
      'employee_id,amount,effective_date,reason,current_amount\n'
      '99,0,2026-06-05,Bad,0\n',
    );

    final preview = container.read(payrollDataImportPreviewProvider);

    expect(preview.canImport, isFalse);
    expect(preview.errorCount, 1);
    expect(preview.lines.single.errors, contains('Employee 99 is unavailable'));
    expect(
      preview.lines.single.errors,
      contains('Amount must be greater than 0'),
    );
    expect(preview.nextAction, 'Fix 1 import row errors.');
  });

  test('payroll data import feeds validated rows into input changes', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      payrollDataImportDraftProvider.notifier,
    );
    draftNotifier.setType(PayrollDataImportType.salaryChange);
    draftNotifier.setSourceLabel('Comp import');
    draftNotifier.setCsvText(
      'employee_id,amount,effective_date,reason,current_amount\n'
      '1,9000,2026-06-05,Annual salary calibration,8500\n',
    );
    final preview = container.read(payrollDataImportPreviewProvider);

    final batch = container
        .read(payrollDataImportBatchesProvider.notifier)
        .applyPreview(preview);
    final inputChanges = container.read(payrollInputChangeSummaryProvider);
    final imported = inputChanges.lines.firstWhere(
      (line) => line.id == '${batch.id}-2',
    );

    expect(batch.validCount, 1);
    expect(inputChanges.lines.length, 5);
    expect(imported.request.sourceLabel, 'Comp import');
    expect(imported.payrollImpact, 500);
    expect(imported.status, PayrollInputChangeStatus.pending);
  });

  test('payroll attendance bridge tracks payroll-ready time impacts', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var bridge = container.read(payrollAttendanceBridgeProvider);

    expect(bridge.lines.length, 4);
    expect(bridge.status, PayrollAttendanceBridgeStatus.blocked);
    expect(bridge.blockedCount, 1);
    expect(bridge.pendingCount, 3);
    expect(bridge.totalImpact, closeTo(-11, 0.01));
    expect(bridge.nextAction, 'Resolve 1 attendance payroll blockers.');

    final lateDeduction = bridge.lines.firstWhere(
      (line) => line.id == 'PAS-1003',
    );
    expect(lateDeduction.status, PayrollAttendanceBridgeStatus.blocked);
    expect(lateDeduction.amount, -63);
    expect(lateDeduction.nextAction, 'Missing manager approval');

    container.read(selectedEmployeeProvider3.notifier).state = container
        .read(employeesProvider2)
        .firstWhere((employee) => employee.id == 2);
    bridge = container.read(payrollAttendanceBridgeProvider);
    expect(bridge.visibleLines.length, 2);
    expect(
      bridge.visibleLines.map((line) => line.signal.type),
      containsAll([
        PayrollAttendanceSignalType.shiftPremium,
        PayrollAttendanceSignalType.unpaidAbsence,
      ]),
    );

    container
        .read(payrollApprovedAttendanceSignalIdsProvider.notifier)
        .state = {
      for (final line in bridge.lines.where((line) => line.canApprove)) line.id,
    };
    bridge = container.read(payrollAttendanceBridgeProvider);
    expect(bridge.approvedCount, 3);
    expect(bridge.canApply, isTrue);

    container.read(payrollAppliedAttendanceSignalIdsProvider.notifier).state = {
      for (final line in bridge.lines.where((line) => line.canApply)) line.id,
    };
    bridge = container.read(payrollAttendanceBridgeProvider);
    expect(bridge.appliedCount, 3);
    expect(bridge.appliedImpact, closeTo(52, 0.01));
    expect(bridge.status, PayrollAttendanceBridgeStatus.blocked);
  });

  test('payroll loan repayments apply ready deductions with caps', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var loans = container.read(payrollLoanRepaymentProvider);

    expect(loans.lines.length, 4);
    expect(loans.status, PayrollLoanRepaymentStatus.blocked);
    expect(loans.readyCount, 2);
    expect(loans.blockedCount, 1);
    expect(loans.pausedCount, 1);
    expect(loans.outstandingBalance, 7500);
    expect(loans.scheduledRepayment, 1254);
    expect(loans.nextAction, 'Resolve 1 loan repayment blockers.');

    final cappedLoan = loans.lines.firstWhere((line) => line.id == 'LON-1002');
    expect(cappedLoan.isCapped, isTrue);
    expect(cappedLoan.repaymentAmount, closeTo(504, 0.01));
    expect(cappedLoan.nextAction, 'Apply capped repayment deduction.');

    final blockedLoan = loans.lines.firstWhere((line) => line.id == 'LON-1003');
    expect(blockedLoan.status, PayrollLoanRepaymentStatus.blocked);
    expect(blockedLoan.nextAction, 'Missing signed agreement');

    container.read(selectedEmployeeProvider3.notifier).state = container
        .read(employeesProvider2)
        .firstWhere((employee) => employee.id == 2);
    loans = container.read(payrollLoanRepaymentProvider);
    expect(loans.visibleLines.length, 2);
    expect(
      loans.visibleLines.map((line) => line.status),
      containsAll([
        PayrollLoanRepaymentStatus.ready,
        PayrollLoanRepaymentStatus.paused,
      ]),
    );

    container.read(payrollAppliedLoanRepaymentIdsProvider.notifier).state = {
      for (final line in loans.lines.where((line) => line.canApply)) line.id,
    };
    loans = container.read(payrollLoanRepaymentProvider);
    expect(loans.appliedCount, 2);
    expect(loans.appliedRepayment, closeTo(804, 0.01));
    expect(loans.status, PayrollLoanRepaymentStatus.blocked);
  });

  test('payroll GL mapping flags unmapped finance categories', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mapping = container.read(payrollGlMappingProvider);

    expect(mapping.status, PayrollGlMappingStatus.blocked);
    expect(mapping.unmappedCount, 1);
    expect(mapping.mappedCount, mapping.lines.length - 1);
    expect(mapping.unmappedAmount, closeTo(1254, 0.01));
    expect(
      mapping.nextAction,
      'Map 1 payroll GL categories before journal posting.',
    );

    final loanMapping = mapping.lines.firstWhere(
      (line) => line.category == PayrollGlMappingCategory.loanRepayment,
    );
    expect(loanMapping.isMapped, isFalse);
    expect(loanMapping.accountLabel, 'Unmapped');
  });

  test('payroll GL mapping can reach ready coverage', () {
    final baseContainer = ProviderContainer();
    addTearDown(baseContainer.dispose);

    final completeMappings = [
      ...baseContainer
          .read(payrollGlAccountMappingsProvider)
          .where(
            (mapping) =>
                mapping.category != PayrollGlMappingCategory.loanRepayment,
          ),
      const PayrollGlAccountMapping(
        category: PayrollGlMappingCategory.loanRepayment,
        sourceLabel: '*',
        accountCode: '1325',
        accountName: 'Employee loan receivable',
        isRequired: true,
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        payrollGlAccountMappingsProvider.overrideWithValue(completeMappings),
      ],
    );
    addTearDown(container.dispose);

    final mapping = container.read(payrollGlMappingProvider);

    expect(mapping.status, PayrollGlMappingStatus.ready);
    expect(mapping.unmappedCount, 0);
    expect(mapping.readinessRate, 1);
    expect(
      mapping.nextAction,
      'Payroll GL mappings are ready for finance posting.',
    );
  });

  test('payroll exception resolution prioritizes cross-module blockers', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final resolution = container.read(payrollExceptionResolutionProvider);

    expect(resolution.status, PayrollExceptionResolutionStatus.blocked);
    expect(resolution.lines, isNotEmpty);
    expect(resolution.criticalCount, greaterThan(0));
    expect(resolution.warningCount, greaterThan(0));
    expect(resolution.lines.first.severity, PayrollExceptionSeverity.critical);
    expect(resolution.nextAction, startsWith('Resolve '));
    expect(
      resolution.lines.map((line) => line.source),
      containsAll([
        PayrollExceptionResolutionSource.inputChanges,
        PayrollExceptionResolutionSource.attendance,
        PayrollExceptionResolutionSource.loans,
        PayrollExceptionResolutionSource.glMapping,
      ]),
    );
  });

  test('payroll exception SLA board combines queue and blocker aging', () {
    final asOfDate = DateTime(2026, 6, 2);
    final container = ProviderContainer(
      overrides: [payrollAsOfDateProvider.overrideWithValue(asOfDate)],
    );
    addTearDown(container.dispose);

    final resolution = container.read(payrollExceptionResolutionProvider);
    final sla = container.read(payrollExceptionSlaProvider);

    expect(sla.items.length, greaterThan(resolution.lines.length));
    expect(sla.breachedCount, 0);
    expect(sla.dueTodayCount, greaterThan(0));
    expect(sla.criticalCount, greaterThan(0));
    expect(sla.amountAtRisk, closeTo(resolution.financialExposure, 0.01));
    expect(sla.items.map((item) => item.id), contains('PE-1001'));
    expect(
      sla.items.first.statusOn(asOfDate),
      PayrollExceptionSlaStatus.dueToday,
    );
    expect(sla.ownerLoads.first.totalCount, greaterThan(0));
    expect(sla.nextAction, startsWith('Clear '));
  });

  test('payroll exception SLA board escalates breached due dates first', () {
    final asOfDate = DateTime(2026, 6, 2);
    final sla = PayrollExceptionSlaSummary.fromRun(
      asOfDate: asOfDate,
      exceptions: [
        PayrollExceptionItem(
          id: 'PE-OVERDUE',
          title: 'Missing bank confirmation',
          employeeName: 'Aisha Rahman',
          owner: 'Payroll Ops',
          dueDate: asOfDate.subtract(const Duration(days: 1)),
          severity: PayrollExceptionSeverity.critical,
          status: PayrollExceptionStatus.open,
          action: 'Confirm bank confirmation evidence.',
        ),
      ],
      resolution: const PayrollExceptionResolutionSummary(lines: []),
    );

    expect(sla.breachedCount, 1);
    expect(sla.dueTodayCount, 0);
    expect(sla.items.first.id, 'PE-OVERDUE');
    expect(
      sla.items.first.statusOn(asOfDate),
      PayrollExceptionSlaStatus.breached,
    );
    expect(sla.nextAction, 'Escalate 1 breached payroll SLA items.');
  });

  test('payroll exception resolution clears when upstream blockers close', () {
    final asOfDate = DateTime(2026, 6, 2);
    final baseContainer = ProviderContainer();
    addTearDown(baseContainer.dispose);
    final completeMappings = [
      ...baseContainer
          .read(payrollGlAccountMappingsProvider)
          .where(
            (mapping) =>
                mapping.category != PayrollGlMappingCategory.loanRepayment,
          ),
      const PayrollGlAccountMapping(
        category: PayrollGlMappingCategory.loanRepayment,
        sourceLabel: '*',
        accountCode: '1325',
        accountName: 'Employee loan receivable',
        isRequired: true,
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(asOfDate),
        payrollTaxProfilesProvider.overrideWithValue(
          _completePayrollTaxProfiles(),
        ),
        payrollInputChangeRequestsProvider.overrideWithValue([
          PayrollInputChangeRequest(
            id: 'PIC-CLEAR-1',
            employeeId: 1,
            type: PayrollInputChangeType.bonus,
            currentAmount: 0,
            proposedAmount: 100,
            effectiveDate: asOfDate.add(const Duration(days: 2)),
            sourceLabel: 'Clean input',
            reason: 'Clean exception resolution input',
            hasApprovalOwner: true,
            hasSupportingDocument: true,
          ),
        ]),
        payrollAttendanceSignalsProvider.overrideWithValue([
          PayrollAttendanceSignal(
            id: 'PAS-CLEAR-1',
            employeeId: 1,
            type: PayrollAttendanceSignalType.overtime,
            workDate: asOfDate.subtract(const Duration(days: 1)),
            units: 1,
            rate: 30,
            sourceLabel: 'Clean attendance',
            hasManagerApproval: true,
            hasPayrollEvidence: true,
          ),
        ]),
        payrollLoanAccountsProvider.overrideWithValue([
          const PayrollLoanAccount(
            id: 'LON-CLEAR-1',
            employeeId: 1,
            type: PayrollLoanType.salaryAdvance,
            principalAmount: 300,
            outstandingBalance: 200,
            scheduledInstallment: 50,
            deductionCapRatio: 0.05,
            remainingInstallments: 4,
            isPaused: false,
            hasSignedAgreement: true,
            hasFinanceApproval: true,
          ),
        ]),
        payrollGlAccountMappingsProvider.overrideWithValue(completeMappings),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);
    container.read(payrollApprovalRecordsProvider.notifier).state = {
      'hr-review': _approvalRecord('hr-review'),
      'finance-review': _approvalRecord('finance-review'),
      'payroll-manager': _approvalRecord('payroll-manager'),
      'final-release': _approvalRecord('final-release'),
    };

    final resolution = container.read(payrollExceptionResolutionProvider);

    expect(resolution.status, PayrollExceptionResolutionStatus.clear);
    expect(resolution.lines, isEmpty);
    expect(resolution.nextAction, 'No payroll exception blockers remain.');
  });

  test('payroll operations center highlights the current blocked stage', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final operations = container.read(payrollOperationsCenterProvider);

    expect(operations.periodLabel, isNotEmpty);
    expect(operations.stages.length, 9);
    expect(operations.currentStage?.id, 'run-plan');
    expect(
      operations.currentStage?.status,
      PayrollOperationsStageStatus.blocked,
    );
    expect(operations.blockedCount, greaterThan(0));
    expect(operations.blockerCount, greaterThan(0));
    expect(operations.amountAtRisk, greaterThan(0));
    expect(operations.nextAction, startsWith('Activate'));
  });

  test(
    'payroll operations center completes after release and close evidence',
    () {
      final asOfDate = DateTime(2026, 6, 2);
      final baseContainer = ProviderContainer();
      addTearDown(baseContainer.dispose);
      final completeMappings = [
        ...baseContainer
            .read(payrollGlAccountMappingsProvider)
            .where(
              (mapping) =>
                  mapping.category != PayrollGlMappingCategory.loanRepayment,
            ),
        const PayrollGlAccountMapping(
          category: PayrollGlMappingCategory.loanRepayment,
          sourceLabel: '*',
          accountCode: '1325',
          accountName: 'Employee loan receivable',
          isRequired: true,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(asOfDate),
          payrollTaxProfilesProvider.overrideWithValue(
            _completePayrollTaxProfiles(),
          ),
          payrollInputChangeRequestsProvider.overrideWithValue([
            PayrollInputChangeRequest(
              id: 'PIC-OPS-1',
              employeeId: 1,
              type: PayrollInputChangeType.bonus,
              currentAmount: 0,
              proposedAmount: 100,
              effectiveDate: asOfDate.add(const Duration(days: 2)),
              sourceLabel: 'Operations input',
              reason: 'Clean operations center input',
              hasApprovalOwner: true,
              hasSupportingDocument: true,
            ),
          ]),
          payrollAttendanceSignalsProvider.overrideWithValue([
            PayrollAttendanceSignal(
              id: 'PAS-OPS-1',
              employeeId: 1,
              type: PayrollAttendanceSignalType.overtime,
              workDate: asOfDate.subtract(const Duration(days: 1)),
              units: 1,
              rate: 30,
              sourceLabel: 'Operations attendance',
              hasManagerApproval: true,
              hasPayrollEvidence: true,
            ),
          ]),
          payrollLoanAccountsProvider.overrideWithValue([
            const PayrollLoanAccount(
              id: 'LON-OPS-1',
              employeeId: 1,
              type: PayrollLoanType.salaryAdvance,
              principalAmount: 300,
              outstandingBalance: 200,
              scheduledInstallment: 50,
              deductionCapRatio: 0.05,
              remainingInstallments: 4,
              isPaused: false,
              hasSignedAgreement: true,
              hasFinanceApproval: true,
            ),
          ]),
          payrollGlAccountMappingsProvider.overrideWithValue(completeMappings),
        ],
      );
      addTearDown(container.dispose);

      _closePayrollRun(container);
      container.read(payrollApprovalRecordsProvider.notifier).state = {
        'hr-review': _approvalRecord('hr-review'),
        'finance-review': _approvalRecord('finance-review'),
        'payroll-manager': _approvalRecord('payroll-manager'),
        'final-release': _approvalRecord('final-release'),
      };
      final distribution = container.read(payrollPayslipDistributionProvider);
      container.read(payrollPayslipDeliveryReceiptsProvider.notifier).state = {
        for (final line in distribution.lines)
          line.payslip.employeeId: PayrollPayslipDeliveryReceipt(
            employeeId: line.payslip.employeeId,
            sentAt: asOfDate.add(const Duration(hours: 2)),
            acknowledgedAt: asOfDate.add(const Duration(hours: 4)),
          ),
      };

      final operations = container.read(payrollOperationsCenterProvider);

      expect(operations.completeCount, operations.stages.length);
      expect(operations.currentStage, isNull);
      expect(operations.blockedCount, 0);
      expect(operations.progress, 1);
      expect(operations.nextAction, 'Payroll operations are complete.');
    },
  );

  test('payroll off-cycle run draft validates required payroll evidence', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var draft = container.read(payrollOffCycleRunDraftProvider);

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, contains('Select an employee'));

    final notifier = container.read(payrollOffCycleRunDraftProvider.notifier);
    notifier.setEmployeeId(container.read(employeesProvider2).first.id);
    notifier.setType(PayrollOffCycleRunType.termination);
    notifier.setGrossAmount('2500');
    notifier.setPayDate(DateTime(2026, 6, 5));
    notifier.setEvidenceReference('TERM-2026-044');
    notifier.setReason('Final settlement payout approved');

    draft = container.read(payrollOffCycleRunDraftProvider);

    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);
  });

  test('payroll off-cycle run requests approve and release independently', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      payrollOffCycleRunDraftProvider.notifier,
    );
    draftNotifier.setEmployeeId(container.read(employeesProvider2).first.id);
    draftNotifier.setType(PayrollOffCycleRunType.bonus);
    draftNotifier.setGrossAmount('1000');
    draftNotifier.setPayDate(DateTime(2026, 6, 6));
    draftNotifier.setEvidenceReference('BONUS-Q2');
    draftNotifier.setReason('Approved spot bonus payout');

    final request = container
        .read(payrollOffCycleRunRequestsProvider.notifier)
        .submit(
          draft: container.read(payrollOffCycleRunDraftProvider),
          employees: container.read(employeesProvider2),
        );

    var summary = container.read(payrollOffCycleRunSummaryProvider);
    expect(request.id, 'OC-1001');
    expect(summary.submittedCount, 1);
    expect(summary.pendingGrossAmount, 1000);
    expect(summary.nextAction, 'Approve 1 off-cycle requests.');

    container
        .read(payrollOffCycleRunRequestsProvider.notifier)
        .approve(request.id);
    summary = container.read(payrollOffCycleRunSummaryProvider);
    expect(summary.approvedCount, 1);
    expect(summary.nextAction, 'Release 1 approved off-cycle runs.');

    container
        .read(payrollOffCycleRunRequestsProvider.notifier)
        .release(request.id);
    summary = container.read(payrollOffCycleRunSummaryProvider);
    expect(summary.releasedCount, 1);
    expect(summary.releasedNetAmount, closeTo(780, 0.01));
    expect(summary.nextAction, 'No off-cycle payroll action is pending.');
  });

  test('payroll employee ledger waits for selected employee', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final ledger = container.read(payrollEmployeeLedgerProvider);

    expect(ledger.employee, isNull);
    expect(ledger.entries, isEmpty);
    expect(ledger.nextAction, 'Select an employee to review payroll ledger.');
  });

  test('payroll employee ledger combines selected employee activity', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final employee = container.read(employeesProvider2).first;
    container.read(selectedEmployeeProvider3.notifier).state = employee;

    final importDraft = container.read(payrollDataImportDraftProvider.notifier);
    importDraft.setCsvText(
      'employee_id,amount,effective_date,reason,current_amount\n'
      '${employee.id},9000,2026-06-05,Ledger salary calibration,8500\n',
    );
    container
        .read(payrollDataImportBatchesProvider.notifier)
        .applyPreview(container.read(payrollDataImportPreviewProvider));

    final offCycleDraft = container.read(
      payrollOffCycleRunDraftProvider.notifier,
    );
    offCycleDraft.setEmployeeId(employee.id);
    offCycleDraft.setType(PayrollOffCycleRunType.bonus);
    offCycleDraft.setGrossAmount('1000');
    offCycleDraft.setPayDate(DateTime(2026, 6, 7));
    offCycleDraft.setEvidenceReference('LEDGER-BONUS');
    offCycleDraft.setReason('Ledger spot bonus payout');
    final offCycle = container
        .read(payrollOffCycleRunRequestsProvider.notifier)
        .submit(
          draft: container.read(payrollOffCycleRunDraftProvider),
          employees: container.read(employeesProvider2),
        );
    container
        .read(payrollOffCycleRunRequestsProvider.notifier)
        .approve(offCycle.id);
    container
        .read(payrollOffCycleRunRequestsProvider.notifier)
        .release(offCycle.id);

    final ledger = container.read(payrollEmployeeLedgerProvider);

    expect(ledger.employee?.id, employee.id);
    expect(
      ledger.entries.map((entry) => entry.type),
      containsAll([
        PayrollEmployeeLedgerEntryType.regularPayroll,
        PayrollEmployeeLedgerEntryType.inputChange,
        PayrollEmployeeLedgerEntryType.offCycle,
        PayrollEmployeeLedgerEntryType.payment,
        PayrollEmployeeLedgerEntryType.payslip,
      ]),
    );
    expect(ledger.credits, greaterThan(0));
    expect(ledger.attentionCount, greaterThan(0));
  });

  test('payroll dispute draft validates intake requirements', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var draft = container.read(payrollDisputeDraftProvider);
    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, contains('Select an employee'));

    final notifier = container.read(payrollDisputeDraftProvider.notifier);
    notifier.setEmployeeId(container.read(employeesProvider2).first.id);
    notifier.setType(PayrollDisputeType.incorrectDeduction);
    notifier.setClaimAmount('220');
    notifier.setEvidenceReference('DSP-2026-01');
    notifier.setDescription('Incorrect deduction on current payslip');

    draft = container.read(payrollDisputeDraftProvider);
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);
  });

  test('payroll disputes move through review and correction close', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(payrollDisputeDraftProvider.notifier);
    notifier.setEmployeeId(container.read(employeesProvider2).first.id);
    notifier.setType(PayrollDisputeType.missingPay);
    notifier.setClaimAmount('320');
    notifier.setEvidenceReference('MISSPAY-1');
    notifier.setDescription('Missing approved overtime payout');

    final dispute = container
        .read(payrollDisputeCasesProvider.notifier)
        .submit(
          draft: container.read(payrollDisputeDraftProvider),
          employees: container.read(employeesProvider2),
        );

    var summary = container.read(payrollDisputeSummaryProvider);
    expect(dispute.id, 'DIS-1001');
    expect(summary.submittedCount, 1);
    expect(summary.openExposure, 320);
    expect(summary.nextAction, 'Start review for 1 disputes.');

    container
        .read(payrollDisputeCasesProvider.notifier)
        .startReview(dispute.id);
    summary = container.read(payrollDisputeSummaryProvider);
    expect(summary.inReviewCount, 1);
    expect(summary.nextAction, 'Resolve 1 disputes in review.');

    container
        .read(payrollDisputeCasesProvider.notifier)
        .approveCorrection(dispute.id);
    summary = container.read(payrollDisputeSummaryProvider);
    expect(summary.correctionApprovedCount, 1);
    expect(summary.approvedCorrectionAmount, 320);

    container.read(payrollDisputeCasesProvider.notifier).close(dispute.id);
    summary = container.read(payrollDisputeSummaryProvider);
    expect(summary.resolvedCount, 1);
    expect(summary.openCount, 0);
    expect(summary.nextAction, 'No payroll disputes need action.');
  });

  test('payroll simulation summarizes upstream payroll impact', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final simulation = container.read(payrollSimulationProvider);

    expect(simulation.status, PayrollSimulationStatus.blocked);
    expect(simulation.blockerCount, 3);
    expect(simulation.grossDelta, 2052);
    expect(simulation.loanRepaymentImpact, closeTo(804, 0.01));
    expect(simulation.netDelta, closeTo(517.64, 0.05));
    expect(simulation.projectedGross, 27552);
    expect(simulation.nextAction, 'Resolve 3 upstream simulation blockers.');
  });

  test('payroll simulation can be reviewed and applied when clean', () {
    final asOfDate = DateTime(2026, 6, 2);
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(asOfDate),
        payrollInputChangeRequestsProvider.overrideWithValue([
          PayrollInputChangeRequest(
            id: 'PIC-CLEAN-1',
            employeeId: 1,
            type: PayrollInputChangeType.salaryChange,
            currentAmount: 8500,
            proposedAmount: 8700,
            effectiveDate: asOfDate.add(const Duration(days: 3)),
            sourceLabel: 'Clean compensation change',
            reason: 'Simulation ready salary change',
            hasApprovalOwner: true,
            hasSupportingDocument: true,
          ),
        ]),
        payrollAttendanceSignalsProvider.overrideWithValue([
          PayrollAttendanceSignal(
            id: 'PAS-CLEAN-1',
            employeeId: 1,
            type: PayrollAttendanceSignalType.overtime,
            workDate: asOfDate.subtract(const Duration(days: 1)),
            units: 2,
            rate: 30,
            sourceLabel: 'Clean overtime',
            hasManagerApproval: true,
            hasPayrollEvidence: true,
          ),
        ]),
        payrollLoanAccountsProvider.overrideWithValue([
          const PayrollLoanAccount(
            id: 'LON-CLEAN-1',
            employeeId: 1,
            type: PayrollLoanType.salaryAdvance,
            principalAmount: 500,
            outstandingBalance: 300,
            scheduledInstallment: 100,
            deductionCapRatio: 0.05,
            remainingInstallments: 3,
            isPaused: false,
            hasSignedAgreement: true,
            hasFinanceApproval: true,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    var simulation = container.read(payrollSimulationProvider);
    expect(simulation.status, PayrollSimulationStatus.draft);
    expect(simulation.canReview, isTrue);
    expect(simulation.grossDelta, 260);
    expect(simulation.netDelta, closeTo(67.43, 0.05));

    container.read(payrollSimulationReviewedProvider.notifier).state = true;
    simulation = container.read(payrollSimulationProvider);
    expect(simulation.status, PayrollSimulationStatus.reviewed);
    expect(simulation.canApply, isTrue);

    container.read(payrollSimulationAppliedProvider.notifier).state = true;
    simulation = container.read(payrollSimulationProvider);
    expect(simulation.status, PayrollSimulationStatus.applied);
    expect(
      simulation.nextAction,
      'Payroll simulation is applied to the run preview.',
    );
  });

  test('payroll scenario library blocks saving dirty simulations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container
          .read(payrollScenarioRecordsProvider.notifier)
          .save(
            simulation: container.read(payrollSimulationProvider),
            label: 'Blocked scenario',
            notes: 'Should not save',
            createdAt: DateTime(2026, 6, 2),
          ),
      throwsStateError,
    );

    final library = container.read(payrollScenarioLibrarySummaryProvider);
    expect(library.scenarios, isEmpty);
    expect(library.nextAction, 'Save the current simulation as a scenario.');
  });

  test(
    'payroll scenario library converts approved scenario to input changes',
    () {
      final asOfDate = DateTime(2026, 6, 2);
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(asOfDate),
          payrollInputChangeRequestsProvider.overrideWithValue([
            PayrollInputChangeRequest(
              id: 'PIC-SCN-1',
              employeeId: 1,
              type: PayrollInputChangeType.salaryChange,
              currentAmount: 8500,
              proposedAmount: 8900,
              effectiveDate: asOfDate.add(const Duration(days: 3)),
              sourceLabel: 'Scenario seed',
              reason: 'Scenario salary calibration',
              hasApprovalOwner: true,
              hasSupportingDocument: true,
            ),
          ]),
          payrollAttendanceSignalsProvider.overrideWithValue([
            PayrollAttendanceSignal(
              id: 'PAS-SCN-1',
              employeeId: 1,
              type: PayrollAttendanceSignalType.overtime,
              workDate: asOfDate.subtract(const Duration(days: 1)),
              units: 1,
              rate: 30,
              sourceLabel: 'Scenario attendance',
              hasManagerApproval: true,
              hasPayrollEvidence: true,
            ),
          ]),
          payrollLoanAccountsProvider.overrideWithValue([
            const PayrollLoanAccount(
              id: 'LON-SCN-1',
              employeeId: 1,
              type: PayrollLoanType.salaryAdvance,
              principalAmount: 300,
              outstandingBalance: 200,
              scheduledInstallment: 50,
              deductionCapRatio: 0.05,
              remainingInstallments: 4,
              isPaused: false,
              hasSignedAgreement: true,
              hasFinanceApproval: true,
            ),
          ]),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(payrollApprovedDeductionAuthorizationIdsProvider.notifier)
          .state = {
        for (final line
            in container.read(payrollDeductionAuthorizationProvider).lines)
          line.id,
      };

      final scenario = container
          .read(payrollScenarioRecordsProvider.notifier)
          .save(
            simulation: container.read(payrollSimulationProvider),
            label: 'Merit increase scenario',
            notes: 'Convert approved merit proposal',
            createdAt: asOfDate,
          );
      container
          .read(payrollScenarioRecordsProvider.notifier)
          .approve(scenario.id);
      container
          .read(payrollScenarioRecordsProvider.notifier)
          .convert(scenario.id);

      final library = container.read(payrollScenarioLibrarySummaryProvider);
      final scenarioInputs = container.read(
        payrollScenarioInputChangeRequestsProvider,
      );

      expect(library.convertedCount, 1);
      expect(scenarioInputs.length, 1);
      expect(scenarioInputs.single.id, '${scenario.id}-PIC-SCN-1');
      expect(scenarioInputs.single.sourceLabel, 'Merit increase scenario');
    },
  );

  test('payroll employee profiles summarize setup readiness', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var profiles = container.read(payrollEmployeeProfileSummaryProvider);

    expect(profiles.profiles.length, 3);
    expect(profiles.readyCount, 2);
    expect(profiles.incompleteCount, 1);
    expect(profiles.suspendedCount, 0);
    expect(profiles.readinessRate, closeTo(2 / 3, 0.0001));

    final alex = profiles.profiles.firstWhere(
      (profile) => profile.employee.id == 1,
    );
    expect(alex.status, PayrollEmployeeProfileStatus.ready);
    expect(alex.canIncludeInRun, isTrue);
    expect(alex.recurringEarningTotal, 250);
    expect(alex.recurringDeductionTotal, 425);
    expect(alex.employeeBenefitContribution, 610);
    expect(alex.employerBenefitContribution, 675);
    expect(alex.nextAction, 'Payroll profile is ready for the next run.');

    final michael = profiles.profiles.firstWhere(
      (profile) => profile.employee.id == 3,
    );
    expect(michael.status, PayrollEmployeeProfileStatus.incomplete);
    expect(michael.blockers, ['Incomplete tax profile']);
    expect(michael.canIncludeInRun, isFalse);

    final employees = container.read(employeesProvider2);
    container.read(selectedEmployeeProvider3.notifier).state = employees[2];
    profiles = container.read(payrollEmployeeProfileSummaryProvider);
    expect(profiles.selectedProfile?.employeeName, 'Michael Chen');
    expect(profiles.nextAction, 'Incomplete tax profile');
  });

  test('payroll deduction authorizations track approval readiness', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var authorizations = container.read(payrollDeductionAuthorizationProvider);

    expect(authorizations.lines.length, 6);
    expect(authorizations.status, PayrollDeductionAuthorizationStatus.pending);
    expect(authorizations.pendingCount, 6);
    expect(authorizations.approvedCount, 0);
    expect(authorizations.blockedCount, 0);
    expect(authorizations.canApprove, isTrue);
    expect(authorizations.totalAuthorizedAmount, 1545);
    expect(authorizations.nextAction, 'Approve 6 deduction authorizations.');

    final retirement = authorizations.lines.firstWhere(
      (line) => line.id == 'RR-1002',
    );
    expect(
      retirement.type,
      PayrollDeductionAuthorizationType.recurringDeduction,
    );
    expect(retirement.canApprove, isTrue);

    container.read(selectedEmployeeProvider3.notifier).state = container
        .read(employeesProvider2)
        .firstWhere((employee) => employee.id == 3);
    authorizations = container.read(payrollDeductionAuthorizationProvider);
    expect(authorizations.visibleLines.length, 2);
    expect(
      authorizations.visibleLines.last.type,
      PayrollDeductionAuthorizationType.taxableBenefit,
    );

    container
        .read(payrollApprovedDeductionAuthorizationIdsProvider.notifier)
        .state = {for (final line in authorizations.lines) line.id};
    authorizations = container.read(payrollDeductionAuthorizationProvider);
    expect(authorizations.status, PayrollDeductionAuthorizationStatus.approved);
    expect(authorizations.pendingCount, 0);
    expect(authorizations.approvedCount, 6);
    expect(authorizations.approvedAmount, 1545);
    expect(
      authorizations.nextAction,
      'All deduction authorizations are approved.',
    );
  });

  test('payroll employee profiles respect suspension state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(payrollSuspendedEmployeeIdsProvider.notifier).state = {2};

    final profiles = container.read(payrollEmployeeProfileSummaryProvider);
    final sarah = profiles.profiles.firstWhere(
      (profile) => profile.employee.id == 2,
    );

    expect(profiles.readyCount, 1);
    expect(profiles.incompleteCount, 1);
    expect(profiles.suspendedCount, 1);
    expect(sarah.status, PayrollEmployeeProfileStatus.suspended);
    expect(sarah.blockers.first, 'Employee is suspended from payroll');
    expect(sarah.canIncludeInRun, isFalse);
  });

  test('payroll configuration summarizes policy readiness', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final configuration = container.read(payrollConfigurationSummaryProvider);

    expect(configuration.period.label, 'June 2026 Payroll');
    expect(configuration.status, PayrollConfigurationStatus.blocked);
    expect(configuration.readyControlCount, 4);
    expect(configuration.blockedControlCount, 1);
    expect(configuration.readinessRate, 0.8);
    expect(configuration.warnings, [
      'Approval lead time is tight for exception handling',
      'Funding reserve is below the preferred 10%',
    ]);
    expect(
      configuration.nextAction,
      '1 employee payroll profiles are incomplete',
    );
  });

  test('payroll configuration can reach ready state', () {
    final container = ProviderContainer(
      overrides: [
        payrollTaxProfilesProvider.overrideWithValue([
          const PayrollTaxProfile(
            employeeId: 1,
            taxIdLast4: '1932',
            filingStatus: PayrollTaxFilingStatus.single,
            allowanceCount: 1,
            hasWithholdingCertificate: true,
          ),
          const PayrollTaxProfile(
            employeeId: 2,
            taxIdLast4: '2044',
            filingStatus: PayrollTaxFilingStatus.married,
            allowanceCount: 2,
            hasWithholdingCertificate: true,
          ),
          const PayrollTaxProfile(
            employeeId: 3,
            taxIdLast4: '5590',
            filingStatus: PayrollTaxFilingStatus.headOfHousehold,
            allowanceCount: 1,
            hasWithholdingCertificate: true,
          ),
        ]),
        payrollSchedulePolicyProvider.overrideWithValue(
          const PayrollSchedulePolicy(
            frequency: PayrollPayFrequency.monthly,
            cutoffDay: 18,
            payDay: 25,
            approvalLeadDays: 5,
            timezoneLabel: 'Asia/Jakarta',
          ),
        ),
        payrollFundingPolicyProvider.overrideWithValue(
          const PayrollFundingPolicy(
            defaultFundingAccount: 'Main payroll account',
            reserveRatio: 0.12,
            authorizationLimit: 30000,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final configuration = container.read(payrollConfigurationSummaryProvider);

    expect(configuration.status, PayrollConfigurationStatus.ready);
    expect(configuration.readyControlCount, 5);
    expect(configuration.blockedControlCount, 0);
    expect(configuration.warnings, isEmpty);
    expect(
      configuration.nextAction,
      'Payroll configuration is ready for June 2026 Payroll.',
    );
  });

  test('payroll configuration flags invalid schedule policy', () {
    final container = ProviderContainer(
      overrides: [
        payrollSchedulePolicyProvider.overrideWithValue(
          const PayrollSchedulePolicy(
            frequency: PayrollPayFrequency.monthly,
            cutoffDay: 26,
            payDay: 25,
            approvalLeadDays: 1,
            timezoneLabel: '',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final configuration = container.read(payrollConfigurationSummaryProvider);

    expect(configuration.status, PayrollConfigurationStatus.blocked);
    expect(configuration.schedulePolicy.blockers, [
      'Pay day must be after cut-off day',
      'Approval lead time is below two days',
      'Payroll timezone is missing',
    ]);
    expect(configuration.nextAction, 'Pay day must be after cut-off day');
  });

  test('payroll approval workflow gates staged release approvals', () {
    final container = ProviderContainer(
      overrides: [
        payrollTaxProfilesProvider.overrideWithValue(
          _completePayrollTaxProfiles(),
        ),
      ],
    );
    addTearDown(container.dispose);

    var workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.approvedCount, 0);
    expect(workflow.readyCount, 0);
    expect(workflow.blockedCount, 4);
    expect(workflow.canReleasePayments, isFalse);
    expect(workflow.nextStage?.id, 'hr-review');
    expect(workflow.nextAction, contains('Activate a payroll run plan'));

    _prepareApprovalPrerequisites(container);

    workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.readyCount, 1);
    expect(workflow.blockedCount, 3);
    expect(workflow.nextStage?.id, 'hr-review');
    expect(workflow.nextAction, 'Approve HR review.');

    container.read(payrollApprovalRecordsProvider.notifier).state = {
      'hr-review': _approvalRecord('hr-review'),
    };
    workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.approvedCount, 1);
    expect(workflow.nextStage?.id, 'finance-review');
    expect(workflow.nextAction, 'Approve Finance review.');

    container.read(payrollApprovalRecordsProvider.notifier).state = {
      ...container.read(payrollApprovalRecordsProvider),
      'finance-review': _approvalRecord('finance-review'),
    };
    workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.nextStage?.id, 'payroll-manager');
    expect(workflow.nextAction, 'Approve Payroll manager approval.');

    container.read(payrollApprovalRecordsProvider.notifier).state = {
      ...container.read(payrollApprovalRecordsProvider),
      'payroll-manager': _approvalRecord('payroll-manager'),
    };
    workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.nextStage?.id, 'final-release');
    expect(workflow.nextAction, 'Approve Final release authorization.');

    container.read(payrollApprovalRecordsProvider.notifier).state = {
      ...container.read(payrollApprovalRecordsProvider),
      'final-release': _approvalRecord('final-release'),
    };
    workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.isFullyApproved, isTrue);
    expect(workflow.canReleasePayments, isTrue);
    expect(workflow.nextAction, 'Payroll approvals are complete.');
  });

  test(
    'payroll approval delegation tracks coverage and delegated readiness',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollTaxProfilesProvider.overrideWithValue(
            _completePayrollTaxProfiles(),
          ),
        ],
      );
      addTearDown(container.dispose);

      var delegation = container.read(payrollApprovalDelegationProvider);
      expect(delegation.coveredCount, 4);
      expect(delegation.hasFullCoverage, isTrue);
      expect(delegation.blockedCount, 4);
      expect(delegation.delegatedCount, 0);
      expect(delegation.nextAction, 'Resolve 4 delegated approval blockers.');

      _prepareApprovalPrerequisites(container);

      delegation = container.read(payrollApprovalDelegationProvider);
      expect(delegation.blockedCount, 3);
      expect(delegation.delegatedCount, 1);
      expect(delegation.lines.first.activeOwner, 'People Operations Partner');
      expect(delegation.nextAction, 'Resolve 3 delegated approval blockers.');
    },
  );

  test('payroll approval delegation flags missing backup coverage', () {
    final container = ProviderContainer(
      overrides: [
        payrollApprovalDelegationPoliciesProvider.overrideWithValue([
          const PayrollApprovalDelegationPolicy(
            stageId: 'hr-review',
            primaryOwner: 'HR Operations Lead',
            delegateOwner: 'People Operations Partner',
            backupOwner: 'Unassigned backup',
            escalationOwner: 'Head of People',
            delegateEnabled: true,
            backupEnabled: false,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final delegation = container.read(payrollApprovalDelegationProvider);

    expect(delegation.coveredCount, 0);
    expect(delegation.hasFullCoverage, isFalse);
    expect(delegation.blockedCount, 4);
    expect(
      delegation.nextAction,
      'Complete delegation coverage for 4 approval stages.',
    );
  });

  test('payroll approval workflow reblocks downstream approvals', () {
    final container = ProviderContainer(
      overrides: [
        payrollTaxProfilesProvider.overrideWithValue(
          _completePayrollTaxProfiles(),
        ),
      ],
    );
    addTearDown(container.dispose);

    _prepareApprovalPrerequisites(container);
    container.read(payrollApprovalRecordsProvider.notifier).state = {
      'hr-review': _approvalRecord('hr-review'),
      'finance-review': _approvalRecord('finance-review'),
      'payroll-manager': _approvalRecord('payroll-manager'),
      'final-release': _approvalRecord('final-release'),
    };

    var workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.canReleasePayments, isTrue);

    container.read(payrollApprovalRecordsProvider.notifier).state = {
      'hr-review': _approvalRecord('hr-review'),
    };

    workflow = container.read(payrollApprovalWorkflowProvider);
    expect(workflow.approvedCount, 1);
    expect(workflow.canReleasePayments, isFalse);
    expect(workflow.nextStage?.id, 'finance-review');
    expect(workflow.stages.last.status, PayrollApprovalStageStatus.blocked);
  });

  test('payroll evidence center summarizes blocked evidence', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final evidence = container.read(payrollEvidenceCenterProvider);

    expect(evidence.periodLabel, 'June 2026 Payroll');
    expect(evidence.status, PayrollEvidenceStatus.blocked);
    expect(evidence.items.length, 9);
    expect(evidence.capturedCount, 0);
    expect(evidence.blockedCount, 9);
    expect(evidence.readyCount, 0);
    expect(evidence.nextAction, '1 employee payroll profiles are incomplete');

    final approvals = evidence.items.firstWhere(
      (item) => item.id == 'approvals',
    );
    expect(approvals.category, PayrollEvidenceCategory.approval);
    expect(approvals.blockers.first, contains('Activate a payroll run plan'));
  });

  test(
    'payroll evidence center completes after close evidence is captured',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollTaxProfilesProvider.overrideWithValue(
            _completePayrollTaxProfiles(),
          ),
          payrollSchedulePolicyProvider.overrideWithValue(
            const PayrollSchedulePolicy(
              frequency: PayrollPayFrequency.monthly,
              cutoffDay: 18,
              payDay: 25,
              approvalLeadDays: 5,
              timezoneLabel: 'Asia/Jakarta',
            ),
          ),
          payrollFundingPolicyProvider.overrideWithValue(
            const PayrollFundingPolicy(
              defaultFundingAccount: 'Main payroll account',
              reserveRatio: 0.12,
              authorizationLimit: 30000,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      _prepareApprovalPrerequisites(container);
      container.read(payrollApprovalRecordsProvider.notifier).state = {
        'hr-review': _approvalRecord('hr-review'),
        'finance-review': _approvalRecord('finance-review'),
        'payroll-manager': _approvalRecord('payroll-manager'),
        'final-release': _approvalRecord('final-release'),
      };

      final batch = container.read(payrollPaymentBatchProvider);
      container.read(paymentStatusProvider.notifier).state = {
        for (final line in batch.lines) line.employeeId: true,
      };

      final package = container.read(payrollPayslipPackageProvider);
      container
          .read(payrollPublishedPayslipEmployeeIdsProvider.notifier)
          .state = {for (final line in package.lines) line.employeeId};

      final liabilities = container.read(payrollLiabilitySummaryProvider);
      container.read(payrollRemittedLiabilityIdsProvider.notifier).state = {
        for (final line in liabilities.lines) line.id,
      };

      final journal = container.read(payrollJournalPostingProvider);
      container.read(payrollPostedJournalIdsProvider.notifier).state = {
        journal.journalId,
      };

      final varianceReport = container.read(payrollVarianceReportProvider);
      container
          .read(payrollExportedVarianceReportIdsProvider.notifier)
          .state = {varianceReport.reportId};
      final costCenterReport = container.read(payrollCostCenterReportProvider);
      container
          .read(payrollExportedCostCenterReportIdsProvider.notifier)
          .state = {costCenterReport.reportId};
      final registerReport = container.read(payrollRegisterReportProvider);
      container
          .read(payrollExportedRegisterReportIdsProvider.notifier)
          .state = {registerReport.reportId};

      final archive = container.read(payrollArchivePackageProvider);
      container.read(payrollArchivedRunPackageIdsProvider.notifier).state = {
        archive.packageId,
      };

      final evidence = container.read(payrollEvidenceCenterProvider);
      expect(evidence.status, PayrollEvidenceStatus.captured);
      expect(evidence.capturedCount, 9);
      expect(evidence.blockedCount, 0);
      expect(evidence.readyCount, 0);
      expect(evidence.captureRate, 1);
      expect(evidence.nextAction, 'Payroll evidence center is complete.');
    },
  );

  test('payroll risk summary highlights pending payments and deductions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final risks = container.read(payrollRiskSummaryProvider);

    expect(risks.pendingPayments, 3);
    expect(risks.highDeductionEmployees, 3);
    expect(risks.unpaidGross, 25500);
    expect(risks.unpaidNet, closeTo(16424.25, 0.01));
    expect(risks.averageDeductionRate, closeTo(0.356, 0.001));
    expect(risks.totalRisks, 6);
  });

  test('payroll cost centers summarize allocation and operational risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final costCenters = container.read(payrollCostCenterSummaryProvider);

    expect(costCenters.periodLabel, 'June 2026 Payroll');
    expect(costCenters.totalEmployeeCount, 3);
    expect(costCenters.totalRiskCount, 4);
    expect(costCenters.totalGrossPayroll, 25950);
    expect(costCenters.lines.map((line) => line.id), [
      'operations',
      'engineering',
      'design',
    ]);

    final engineering = costCenters.lines.firstWhere(
      (line) => line.id == 'engineering',
    );
    expect(engineering.employeeCount, 1);
    expect(engineering.pendingPaymentCount, 1);
    expect(engineering.pendingAdjustmentCount, 1);
    expect(engineering.riskCount, 2);
    expect(costCenters.nextAction, 'Engineering has 2 payroll items to clear.');

    container.read(paymentStatusProvider.notifier).state = {
      ...container.read(paymentStatusProvider),
      1: true,
    };

    final updated = container.read(payrollCostCenterSummaryProvider);
    final updatedEngineering = updated.lines.firstWhere(
      (line) => line.id == 'engineering',
    );
    expect(updatedEngineering.paidCount, 1);
    expect(updatedEngineering.pendingPaymentCount, 0);
    expect(updatedEngineering.riskCount, 1);
  });

  test('payroll cost center budgets flag variance and owner readiness', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final budgets = container.read(payrollCostCenterBudgetSummaryProvider);

    expect(budgets.periodLabel, 'June 2026 Payroll');
    expect(budgets.totalBudget, 26600);
    expect(budgets.totalGrossPayroll, 25950);
    expect(budgets.totalRemainingBudget, 650);
    expect(budgets.overBudgetCount, 1);
    expect(budgets.watchCount, 2);
    expect(budgets.pendingApprovalCount, 3);
    expect(budgets.approvedReleaseCount, 0);
    expect(budgets.readyEvidenceCount, 3);
    expect(budgets.requiredEvidenceCount, 9);
    expect(budgets.incompleteEvidenceCount, 6);
    expect(budgets.evidenceCompletionRate, closeTo(1 / 3, 0.0001));
    expect(budgets.lines.map((line) => line.id), [
      'operations',
      'design',
      'engineering',
    ]);

    final operations = budgets.lines.first;
    expect(operations.status, PayrollCostCenterBudgetStatus.overBudget);
    expect(operations.remainingBudget, -200);
    expect(operations.readyEvidenceCount, 1);
    expect(operations.requiredEvidenceCount, 3);
    expect(operations.evidenceItems.map((item) => item.id), [
      'operations-register',
      'operations-variance',
      'operations-risk',
    ]);
    expect(
      budgets.nextAction,
      'Operations needs budget approval before payroll release.',
    );

    container
        .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
        .state = {'operations'};

    final approved = container.read(payrollCostCenterBudgetSummaryProvider);
    final approvedOperations = approved.lines.firstWhere(
      (line) => line.id == 'operations',
    );
    expect(approvedOperations.status, PayrollCostCenterBudgetStatus.overBudget);
    expect(approvedOperations.isApprovedForRelease, isTrue);
    expect(approvedOperations.needsReleaseApproval, isFalse);
    expect(approvedOperations.readyEvidenceCount, 3);
    expect(approvedOperations.evidenceCompletionRate, 1);
    expect(approved.pendingApprovalCount, 2);
    expect(approved.approvedReleaseCount, 1);
    expect(approved.readyEvidenceCount, 5);
    expect(approved.requiredEvidenceCount, 9);
    expect(
      approved.nextAction,
      'Design needs owner confirmation before release.',
    );

    final relaxed = ProviderContainer(
      overrides: [
        payrollCostCenterBudgetPlansProvider.overrideWithValue([
          const PayrollCostCenterBudgetPlan(
            costCenterId: 'engineering',
            owner: 'Engineering Finance Partner',
            budget: 9200,
            reserve: 900,
          ),
          const PayrollCostCenterBudgetPlan(
            costCenterId: 'design',
            owner: 'Design Operations Lead',
            budget: 7800,
            reserve: 600,
          ),
          const PayrollCostCenterBudgetPlan(
            costCenterId: 'operations',
            owner: 'Operations Controller',
            budget: 10500,
            reserve: 800,
          ),
        ]),
      ],
    );
    addTearDown(relaxed.dispose);

    final updated = relaxed.read(payrollCostCenterBudgetSummaryProvider);
    expect(updated.overBudgetCount, 0);
    expect(
      updated.nextAction,
      'Design needs owner confirmation before release.',
    );
  });

  test(
    'payroll employer cost insights allocate liabilities by cost center',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final employerCost = container.read(payrollEmployerCostProvider);

      expect(employerCost.periodLabel, 'June 2026 Payroll');
      expect(employerCost.employeeCount, 3);
      expect(employerCost.totalGrossPayroll, 25950);
      expect(employerCost.totalLiabilityAllocation, closeTo(9075.75, 0.01));
      expect(employerCost.totalEmployerCost, closeTo(35025.75, 0.01));
      expect(employerCost.overBudgetCount, 3);
      expect(employerCost.watchCount, 0);
      expect(employerCost.totalBudget, 26600);
      expect(employerCost.totalBudgetVariance, closeTo(-8425.75, 0.01));
      expect(
        employerCost.nextAction,
        'Operations is over employer cost budget.',
      );

      final operations = employerCost.lines.first;
      expect(operations.id, 'operations');
      expect(operations.status, PayrollEmployerCostStatus.overBudget);
      expect(operations.liabilityAllocation, closeTo(3427.45, 0.01));
      expect(operations.totalEmployerCost, closeTo(13227.45, 0.01));
      expect(operations.utilization, greaterThan(1));
    },
  );

  test('payroll cost center report tracks finance export readiness', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var report = container.read(payrollCostCenterReportProvider);

    expect(report.reportId, 'CC-JUNE-2026-PAYROLL');
    expect(report.status, PayrollCostCenterReportStatus.blocked);
    expect(report.canExport, isFalse);
    expect(report.costCenterCount, 3);
    expect(report.approvedCount, 0);
    expect(report.blockedCount, 3);
    expect(report.totalBudget, 26600);
    expect(report.totalGrossPayroll, 25950);
    expect(
      report.nextAction,
      '3 cost center report lines need approval or risk clearance',
    );

    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    container.read(paymentStatusProvider.notifier).state = {
      for (final employee in container.read(employeesProvider2))
        employee.id: true,
    };
    container
        .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
        .state = {
      for (final line
          in container.read(payrollCostCenterBudgetSummaryProvider).lines)
        line.id,
    };

    report = container.read(payrollCostCenterReportProvider);
    expect(report.status, PayrollCostCenterReportStatus.ready);
    expect(report.canExport, isTrue);
    expect(report.approvedCount, 3);
    expect(report.blockedCount, 0);
    expect(report.totalGrossPayroll, 27150);
    expect(
      report.nextAction,
      'Export cost center payroll report for finance review.',
    );

    container
        .read(payrollExportedCostCenterReportIdsProvider.notifier)
        .state = {report.reportId};

    report = container.read(payrollCostCenterReportProvider);
    expect(report.status, PayrollCostCenterReportStatus.exported);
    expect(report.canExport, isFalse);
    expect(report.nextAction, 'Cost center payroll report is exported.');
  });

  test('payroll payment status seeds from employee ids', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final employees = container.read(employeesProvider2);
    final status = container.read(paymentStatusProvider);

    expect(status.keys, employees.map((employee) => employee.id));
    expect(status.values.every((isPaid) => !isPaid), isTrue);
  });

  test('payroll period selection drives run as-of date', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedPayrollRunPeriodProvider).id, '202606');
    expect(container.read(payrollAsOfDateProvider), DateTime(2026, 6, 2));
    expect(
      container.read(payrollRunDashboardProvider).periodLabel,
      'June 2026 Payroll',
    );

    container.read(selectedPayrollRunPeriodIdProvider.notifier).state =
        '202607';

    expect(container.read(selectedPayrollRunPeriodProvider).id, '202607');
    expect(container.read(payrollAsOfDateProvider), DateTime(2026, 7, 2));
    expect(
      container.read(payrollRunDashboardProvider).periodLabel,
      'July 2026 Payroll',
    );
  });

  test('payroll run builder prepares and submits run plans', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var draft = container.read(payrollRunBuilderDraftProvider);
    expect(draft.periodId, '202606');
    expect(draft.label, 'June 2026 Payroll');
    expect(draft.periodStart, DateTime(2026, 6));
    expect(draft.periodEnd, DateTime(2026, 6, 24));
    expect(draft.payDate, DateTime(2026, 6, 25));
    expect(draft.scope, PayrollRunScope.allEmployees);
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    var preview = container.read(payrollRunBuilderPreviewProvider);
    expect(preview.includedEmployeeCount, 3);
    expect(preview.excludedEmployeeCount, 0);
    expect(preview.estimatedGross, 25500);
    expect(preview.estimatedNet, closeTo(16424.25, 0.01));
    expect(preview.estimatedDeductions, closeTo(9075.75, 0.01));
    expect(preview.canCreateRun, isTrue);
    expect(preview.nextAction, 'Create run plan for 3 employees.');
    expect(preview.readyChecklistCount, 4);
    expect(preview.blockerCount, 0);
    expect(preview.readinessItems.map((item) => item.id), [
      'salary',
      'cost-center',
      'payment-profile',
      'active-employee',
    ]);

    var activePlan = container.read(payrollActiveRunPlanSummaryProvider);
    expect(activePlan.hasActivePlan, isFalse);
    expect(activePlan.periodLabel, 'June 2026 Payroll');
    expect(activePlan.readyArtifactCount, 0);
    expect(activePlan.artifactCount, 0);
    expect(
      activePlan.nextAction,
      'Activate a payroll run plan for June 2026 Payroll before final payroll preparation.',
    );

    final draftNotifier = container.read(
      payrollRunBuilderDraftProvider.notifier,
    );
    draftNotifier.setLabel('');
    draftNotifier.setPayDate(DateTime(2026, 6, 1));

    draft = container.read(payrollRunBuilderDraftProvider);
    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a payroll run label',
      'Pay date must be on or after the period end',
    ]);
    preview = container.read(payrollRunBuilderPreviewProvider);
    expect(preview.canCreateRun, isFalse);
    expect(preview.nextAction, 'Please enter a payroll run label');

    draftNotifier.setLabel('July 2026 Payroll');
    draftNotifier.setPeriodStart(DateTime(2026, 7));
    draftNotifier.setPeriodEnd(DateTime(2026, 7, 24));
    draftNotifier.setPayDate(DateTime(2026, 7, 25));
    draftNotifier.setScope(PayrollRunScope.salariedOnly);
    draftNotifier.setNotes('Prepare salaried payroll run for July close.');

    preview = container.read(payrollRunBuilderPreviewProvider);
    expect(preview.includedEmployeeCount, 3);
    expect(preview.excludedEmployeeCount, 0);
    expect(preview.nextAction, 'Create run plan for 3 employees.');

    final request = container
        .read(payrollRunBuildRequestsProvider.notifier)
        .submitPreview(preview);

    expect(request.id, 'PR-1001');
    expect(request.periodId, '202606');
    expect(request.label, 'July 2026 Payroll');
    expect(request.scope, PayrollRunScope.salariedOnly);
    expect(request.createdAt, DateTime(2026, 7, 18));
    expect(request.artifacts.map((artifact) => artifact.id), [
      'employee-register',
      'payment-profile-review',
      'cost-center-allocation',
      'approval-checklist',
    ]);
    expect(request.artifacts.every((artifact) => artifact.isReady), isTrue);
    expect(request.status, PayrollRunBuildStatus.draft);
    expect(request.isReadyForApproval, isTrue);
    expect(container.read(payrollRunBuildRequestsProvider), [request]);

    final requests = container.read(payrollRunBuildRequestsProvider.notifier);
    requests.approve(request.id);
    var updatedRequest = container.read(payrollRunBuildRequestsProvider).first;
    expect(updatedRequest.status, PayrollRunBuildStatus.approved);
    expect(updatedRequest.canActivate, isTrue);

    requests.reopen(request.id);
    updatedRequest = container.read(payrollRunBuildRequestsProvider).first;
    expect(updatedRequest.status, PayrollRunBuildStatus.draft);

    requests.approve(request.id);
    requests.activate(request.id);
    updatedRequest = container.read(payrollRunBuildRequestsProvider).first;
    expect(updatedRequest.status, PayrollRunBuildStatus.activated);
    activePlan = container.read(payrollActiveRunPlanSummaryProvider);
    expect(activePlan.hasActivePlan, isTrue);
    expect(activePlan.periodLabel, 'June 2026 Payroll');
    expect(activePlan.request?.id, 'PR-1001');

    container.read(selectedPayrollRunPeriodIdProvider.notifier).state =
        '202607';

    activePlan = container.read(payrollActiveRunPlanSummaryProvider);
    expect(activePlan.hasActivePlan, isFalse);
    expect(activePlan.periodLabel, 'July 2026 Payroll');
    expect(
      activePlan.nextAction,
      'Activate a payroll run plan for July 2026 Payroll before final payroll preparation.',
    );
    expect(() => requests.reopen(request.id), throwsA(isA<StateError>()));

    final incompleteProfiles = ProviderContainer(
      overrides: [
        payrollPaymentProfilesProvider.overrideWithValue(
          container.read(payrollPaymentProfilesProvider).take(2).toList(),
        ),
      ],
    );
    addTearDown(incompleteProfiles.dispose);

    final blockedPreview = incompleteProfiles.read(
      payrollRunBuilderPreviewProvider,
    );
    expect(blockedPreview.canCreateRun, isFalse);
    expect(blockedPreview.blockerCount, 1);
    expect(
      blockedPreview.nextAction,
      '1 employees missing payment destination',
    );
  });

  test('payroll run activation keeps one active plan per period', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final preview = container.read(payrollRunBuilderPreviewProvider);
    final requests = container.read(payrollRunBuildRequestsProvider.notifier);

    final first = requests.submitPreview(preview);
    expect(first.periodId, '202606');
    requests.approve(first.id);
    requests.activate(first.id);

    final draft = container.read(payrollRunBuilderDraftProvider.notifier);
    draft.setLabel('June 2026 Payroll rerun');
    draft.setNotes('Prepare replacement payroll run for June close.');

    final second = requests.submitPreview(
      container.read(payrollRunBuilderPreviewProvider),
    );
    expect(second.periodId, '202606');
    requests.approve(second.id);
    requests.activate(second.id);

    var plansById = {
      for (final request in container.read(payrollRunBuildRequestsProvider))
        request.id: request,
    };
    expect(plansById[first.id]!.status, PayrollRunBuildStatus.approved);
    expect(plansById[second.id]!.status, PayrollRunBuildStatus.activated);

    var activePlan = container.read(payrollActiveRunPlanSummaryProvider);
    expect(activePlan.request?.id, second.id);
    expect(activePlan.request?.label, 'June 2026 Payroll rerun');

    requests.activate(first.id);

    plansById = {
      for (final request in container.read(payrollRunBuildRequestsProvider))
        request.id: request,
    };
    expect(plansById[first.id]!.status, PayrollRunBuildStatus.activated);
    expect(plansById[second.id]!.status, PayrollRunBuildStatus.approved);
    expect(
      container.read(payrollActiveRunPlanSummaryProvider).request?.id,
      first.id,
    );
  });

  test('payroll run dashboard summarizes payroll operations', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final dashboard = container.read(payrollRunDashboardProvider);

    expect(dashboard.periodLabel, 'June 2026 Payroll');
    expect(dashboard.payDate, DateTime(2026, 6, 25));
    expect(dashboard.status, PayrollRunStatus.needsReview);
    expect(dashboard.grossPayroll, 25950);
    expect(dashboard.netPayroll, closeTo(16874.25, 0.01));
    expect(dashboard.deductions, closeTo(9075.75, 0.01));
    expect(dashboard.approvedAdjustmentTotal, 450);
    expect(dashboard.employeeCount, 3);
    expect(dashboard.pendingPaymentCount, 3);
    expect(dashboard.pendingAdjustmentCount, 1);
    expect(dashboard.approvedAdjustmentCount, 1);
    expect(dashboard.openExceptionCount, 2);
    expect(dashboard.criticalExceptionCount, 1);
    expect(dashboard.readinessScore, 40);
    expect(
      dashboard.nextAction,
      'Resolve critical payroll exceptions before approval.',
    );
  });

  test('payroll run comparison highlights period movement', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final comparison = container.read(payrollRunComparisonProvider);

    expect(comparison.periodLabel, 'June 2026 Payroll');
    expect(comparison.baselinePeriodLabel, 'May 2026 Payroll');
    expect(comparison.signal, PayrollRunComparisonSignal.review);
    expect(comparison.reviewCount, 1);
    expect(comparison.watchCount, 4);
    expect(
      comparison.nextAction,
      'Review approved adjustments change before close sign-off.',
    );

    final gross = comparison.metrics.firstWhere(
      (metric) => metric.id == 'gross-payroll',
    );
    expect(gross.currentValue, 25950);
    expect(gross.baselineValue, 25250);
    expect(gross.delta, 700);
    expect(gross.signal, PayrollRunComparisonSignal.watch);

    final adjustments = comparison.metrics.firstWhere(
      (metric) => metric.id == 'adjustments',
    );
    expect(adjustments.currentValue, 450);
    expect(adjustments.baselineValue, 300);
    expect(adjustments.signal, PayrollRunComparisonSignal.review);

    final operations = comparison.costCenters.firstWhere(
      (line) => line.id == 'operations',
    );
    expect(operations.grossDelta, 150);
    expect(operations.signal, PayrollRunComparisonSignal.stable);

    final drilldown = container.read(payrollVarianceDrilldownProvider);
    expect(drilldown.periodLabel, 'June 2026 Payroll');
    expect(drilldown.baselinePeriodLabel, 'May 2026 Payroll');
    expect(drilldown.lines.length, 5);
    expect(drilldown.reviewCount, 1);
    expect(drilldown.watchCount, 4);
    expect(drilldown.totalAbsoluteVariance, closeTo(1605.75, 0.01));
    expect(
      drilldown.nextAction,
      'Investigate 1 payroll variance drilldowns before sign-off.',
    );

    final topLine = drilldown.lines.first;
    expect(topLine.id, 'metric-adjustments');
    expect(topLine.scope, PayrollVarianceDrilldownScope.run);
    expect(topLine.owner, 'Payroll Manager');
    expect(topLine.needsReview, isTrue);
  });

  test(
    'payroll run comparison can settle when baseline matches current run',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
          payrollRunComparisonBaselineProvider.overrideWithValue(
            const PayrollRunComparisonBaseline(
              periodLabel: 'May 2026 Payroll',
              employeeCount: 3,
              grossPayroll: 25950,
              netPayroll: 16874.25,
              deductions: 9075.75,
              approvedAdjustmentTotal: 450,
              costCenters: [
                PayrollRunComparisonCostCenterBaseline(
                  id: 'operations',
                  label: 'Operations',
                  employeeCount: 1,
                  grossPayroll: 9800,
                ),
                PayrollRunComparisonCostCenterBaseline(
                  id: 'engineering',
                  label: 'Engineering',
                  employeeCount: 1,
                  grossPayroll: 8500,
                ),
                PayrollRunComparisonCostCenterBaseline(
                  id: 'design',
                  label: 'Design',
                  employeeCount: 1,
                  grossPayroll: 7650,
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final comparison = container.read(payrollRunComparisonProvider);
      final drilldown = container.read(payrollVarianceDrilldownProvider);

      expect(comparison.signal, PayrollRunComparisonSignal.stable);
      expect(comparison.reviewCount, 0);
      expect(comparison.watchCount, 0);
      expect(
        comparison.nextAction,
        'Payroll run is aligned with the prior period.',
      );
      expect(drilldown.lines, isEmpty);
      expect(
        drilldown.nextAction,
        'No material payroll variance drilldowns remain.',
      );
    },
  );

  test('payroll adjustment draft validates and submits requests', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final empty = container.read(payrollAdjustmentDraftProvider);
    expect(empty.isReadyToSubmit, isFalse);
    expect(empty.validationErrors, [
      'Please select an employee',
      'Please enter an amount',
      'Please select an effective date',
      'Please enter a cost center',
      'Please enter a reason',
    ]);

    final draft = container.read(payrollAdjustmentDraftProvider.notifier);
    draft.setEmployeeId(1);
    draft.setType(PayrollAdjustmentType.overtime);
    draft.setAmount('775');
    draft.setEffectiveDate(DateTime(2026, 6, 10));
    draft.setCostCenter('ENG-DELIVERY');
    draft.setReason('Approved release overtime for payroll close.');

    final request = container
        .read(payrollAdjustmentsProvider.notifier)
        .submitDraft(
          draft: container.read(payrollAdjustmentDraftProvider),
          employees: container.read(employeesProvider2),
        );

    expect(request.id, 'PA-1004');
    expect(request.employeeName, 'Alex Johnson');
    expect(request.type, PayrollAdjustmentType.overtime);
    expect(request.amount, 775);
    expect(request.status, PayrollAdjustmentStatus.submitted);
    expect(
      container.read(payrollRunDashboardProvider).pendingAdjustmentCount,
      2,
    );
    expect(container.read(payrollRunDashboardProvider).readinessScore, 32);
  });

  test('payroll approval and exception queues update run readiness', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final adjustments = container.read(payrollAdjustmentsProvider.notifier);
    adjustments.approve('PA-1001');

    var dashboard = container.read(payrollRunDashboardProvider);
    expect(dashboard.pendingAdjustmentCount, 0);
    expect(dashboard.approvedAdjustmentTotal, 1650);
    expect(dashboard.readinessScore, 48);

    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');

    dashboard = container.read(payrollRunDashboardProvider);
    expect(dashboard.openExceptionCount, 1);
    expect(dashboard.criticalExceptionCount, 0);
    expect(dashboard.readinessScore, 72);
    expect(
      dashboard.nextAction,
      'Clear payroll warnings before locking the run.',
    );
  });

  test('payroll reconciliation highlights blockers and variance', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final reconciliation = container.read(payrollReconciliationSummaryProvider);

    expect(reconciliation.periodLabel, 'June 2026 Payroll');
    expect(reconciliation.baselinePeriodLabel, 'May 2026 Payroll');
    expect(reconciliation.status, PayrollReconciliationStatus.blocked);
    expect(reconciliation.blockerCount, 3);
    expect(reconciliation.materialVarianceCount, 0);
    expect(reconciliation.fundingGap, 0);
    expect(reconciliation.fundingBuffer, closeTo(1625.75, 0.01));
    expect(reconciliation.canReview, isFalse);
    expect(reconciliation.isReviewed, isFalse);
    expect(reconciliation.largestVariance.id, 'gross');
    expect(
      reconciliation.nextAction,
      'Clear 3 payroll blockers before reconciliation sign-off.',
    );

    final linesById = {
      for (final line in reconciliation.varianceLines) line.id: line,
    };
    expect(linesById['gross']!.status, PayrollVarianceStatus.stable);
    expect(linesById['net']!.status, PayrollVarianceStatus.stable);
    expect(linesById['deductions']!.status, PayrollVarianceStatus.stable);

    final varianceReport = container.read(payrollVarianceReportProvider);
    expect(varianceReport.reportId, 'VAR-JUNE-2026-PAYROLL');
    expect(varianceReport.status, PayrollVarianceReportStatus.blocked);
    expect(varianceReport.canExport, isFalse);
    expect(varianceReport.materialVarianceCount, 0);
    expect(varianceReport.largestVariance.id, 'gross');
    expect(varianceReport.nextAction, 'Reconciliation is not reviewed');
  });

  test(
    'payroll reconciliation can be reviewed after pre-close blockers clear',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
        ],
      );
      addTearDown(container.dispose);

      container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
      final exceptions = container.read(payrollExceptionsProvider.notifier);
      exceptions.resolve('PE-1001');
      exceptions.resolve('PE-1002');

      var reconciliation = container.read(payrollReconciliationSummaryProvider);
      expect(reconciliation.status, PayrollReconciliationStatus.watch);
      expect(reconciliation.canReview, isTrue);
      expect(reconciliation.isReviewed, isFalse);
      expect(reconciliation.materialVarianceCount, 2);
      expect(
        reconciliation.nextAction,
        'Document payroll variance and collect finance sign-off.',
      );

      container
          .read(payrollReconciliationReviewSignatureProvider.notifier)
          .state = reconciliation.reviewSignature;

      reconciliation = container.read(payrollReconciliationSummaryProvider);
      expect(reconciliation.isReviewed, isTrue);

      var varianceReport = container.read(payrollVarianceReportProvider);
      expect(varianceReport.status, PayrollVarianceReportStatus.ready);
      expect(varianceReport.canExport, isTrue);
      expect(varianceReport.materialVarianceCount, 2);
      expect(varianceReport.reviewVarianceCount, 0);
      expect(
        varianceReport.nextAction,
        'Export variance report for finance review.',
      );

      container
          .read(payrollExportedVarianceReportIdsProvider.notifier)
          .state = {varianceReport.reportId};

      varianceReport = container.read(payrollVarianceReportProvider);
      expect(varianceReport.status, PayrollVarianceReportStatus.exported);
      expect(varianceReport.canExport, isFalse);
      expect(varianceReport.nextAction, 'Payroll variance report is exported.');
    },
  );

  test('payroll payment batch prepares recipient release lines', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final batch = container.read(payrollPaymentBatchProvider);

    expect(batch.batchId, 'PB-202606');
    expect(batch.status, PayrollPaymentBatchStatus.blocked);
    expect(batch.canRelease, isFalse);
    expect(batch.hasActiveRunPlan, isFalse);
    expect(batch.activeRunPlanLabel, 'No active run plan');
    expect(batch.reconciliationReviewed, isFalse);
    expect(batch.isRunLocked, isFalse);
    expect(batch.pendingCount, 3);
    expect(batch.readyRecipientCount, 3);
    expect(batch.blockedRecipientCount, 0);
    expect(batch.totalNet, closeTo(16874.25, 0.01));
    expect(batch.pendingNet, closeTo(16874.25, 0.01));
    expect(batch.adjustmentTotal, 450);
    expect(batch.lines[1].destinationLabel, 'Mandiri **** 2044');
    expect(
      batch.nextAction,
      'Activate a payroll run plan before payment release.',
    );
  });

  test('payroll payment batch releases after reconciliation and lock', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _activatePayrollRunPlan(container);
    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');

    container
        .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
        .state = {
      for (final line
          in container.read(payrollCostCenterBudgetSummaryProvider).lines)
        line.id,
    };

    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;
    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    _authorizeFundingAccounts(container);

    var batch = container.read(payrollPaymentBatchProvider);
    expect(batch.status, PayrollPaymentBatchStatus.ready);
    expect(batch.canRelease, isTrue);
    expect(batch.hasActiveRunPlan, isTrue);
    expect(batch.activeRunPlanLabel, 'June 2026 Payroll');
    expect(batch.totalNet, closeTo(18074.25, 0.01));
    expect(batch.adjustmentTotal, 1650);
    expect(batch.lines.first.adjustmentAmount, 1200);
    expect(
      batch.nextAction,
      'Release 3 scheduled payments from payroll funding.',
    );

    container.read(paymentStatusProvider.notifier).state = {
      for (final line in batch.lines) line.employeeId: true,
    };

    batch = container.read(payrollPaymentBatchProvider);
    expect(batch.status, PayrollPaymentBatchStatus.released);
    expect(batch.pendingCount, 0);
    expect(batch.paidCount, 3);
    expect(batch.releasedNet, closeTo(18074.25, 0.01));
    expect(batch.nextAction, 'Payment batch is fully released.');

    final plan = container.read(payrollRunClosePlanProvider);
    expect(plan.nextStep?.id, 'publish-payslips');
  });

  test('payroll bank transfer file previews release recipients', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var file = container.read(payrollBankTransferFileProvider);
    expect(file.fileId, 'BANK-202606');
    expect(file.status, PayrollBankTransferFileStatus.blocked);
    expect(file.canExport, isFalse);
    expect(file.recipientCount, 2);
    expect(file.nonBankRecipientCount, 1);
    expect(file.totalAmount, closeTo(10523.95, 0.01));
    expect(file.lines.first.referenceCode, 'PAY-202606-0001');
    expect(file.nextAction, 'Payroll run plan is not active');

    _activatePayrollRunPlan(container);
    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');
    container
        .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
        .state = {
      for (final line
          in container.read(payrollCostCenterBudgetSummaryProvider).lines)
        line.id,
    };
    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;
    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    file = container.read(payrollBankTransferFileProvider);
    expect(file.status, PayrollBankTransferFileStatus.ready);
    expect(file.canExport, isTrue);
    expect(file.totalAmount, closeTo(11723.95, 0.01));
    expect(file.nextAction, 'Export bank transfer file for payment release.');

    container
        .read(payrollExportedBankTransferFileIdsProvider.notifier)
        .state = {file.fileId};

    file = container.read(payrollBankTransferFileProvider);
    expect(file.status, PayrollBankTransferFileStatus.exported);
    expect(file.canExport, isFalse);
    expect(file.nextAction, 'Bank transfer file is exported.');
  });

  test('payroll funding authorization gates payment release accounts', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var authorization = container.read(payrollFundingAuthorizationProvider);
    expect(authorization.lines.length, 2);
    expect(authorization.blockedCount, 2);
    expect(authorization.readyCount, 0);
    expect(authorization.authorizedCount, 0);
    expect(authorization.isAuthorizedForRelease, isFalse);
    expect(
      authorization.nextAction,
      'Resolve 2 funding authorization blockers.',
    );

    _activatePayrollRunPlan(container);
    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');
    container
        .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
        .state = {
      for (final line
          in container.read(payrollCostCenterBudgetSummaryProvider).lines)
        line.id,
    };
    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;
    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    authorization = container.read(payrollFundingAuthorizationProvider);
    expect(authorization.blockedCount, 0);
    expect(authorization.readyCount, 2);
    expect(authorization.nextAction, 'Authorize 2 payroll funding accounts.');

    final draftNotifier = container.read(
      payrollFundingAuthorizationDraftProvider.notifier,
    );
    draftNotifier.selectAccount(authorization.lines.first.accountLabel);
    var draft = container.read(payrollFundingAuthorizationDraftProvider);
    expect(draft.accountLabel, authorization.lines.first.accountLabel);
    expect(draft.authorizedBy, 'Payroll Controller');
    expect(draft.referenceCode, startsWith('AUTH-'));
    expect(draft.isReadyToSubmit, isTrue);

    draftNotifier.setNotes('');
    draft = container.read(payrollFundingAuthorizationDraftProvider);
    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, ['Enter authorization notes']);
    draftNotifier.setNotes(
      'Payroll funding authorization reviewed and approved.',
    );

    container
        .read(payrollFundingAuthorizationRecordsProvider.notifier)
        .state = {
      for (final line in authorization.lines)
        line.accountLabel: _fundingAuthorizationRecord(line.accountLabel),
    };

    authorization = container.read(payrollFundingAuthorizationProvider);
    expect(authorization.authorizedCount, 2);
    expect(authorization.pendingCount, 0);
    expect(authorization.isAuthorizedForRelease, isTrue);
    expect(authorization.lines.first.authorization?.authorizedBy, 'Aisha CFO');
    expect(
      authorization.lines.first.authorization?.referenceCode,
      startsWith('AUTH-'),
    );
    expect(
      authorization.nextAction,
      'All payroll funding accounts are authorized.',
    );
  });

  test('payroll funding forecast combines payments and liabilities', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final forecast = container.read(payrollFundingForecastProvider);

    expect(forecast.periodLabel, 'June 2026 Payroll');
    expect(forecast.accountLabel, '2 payroll funding accounts');
    expect(forecast.status, PayrollFundingStatus.shortfall);
    expect(forecast.availableFunding, 18500);
    expect(forecast.totalRequiredFunding, closeTo(25950, 0.01));
    expect(forecast.shortfall, closeTo(7450, 0.01));
    expect(forecast.buffer, 0);
    expect(forecast.pendingObligationCount, 2);
    expect(forecast.obligations.map((obligation) => obligation.id), [
      'employee-net-pay',
      'payroll-liabilities',
    ]);
    expect(
      forecast.nextAction,
      'Top up payroll funding before release and remittance.',
    );
  });

  test('payroll funding forecast settles after payments and remittances', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final forecast = container.read(payrollFundingForecastProvider);

    expect(forecast.status, PayrollFundingStatus.settled);
    expect(forecast.totalRequiredFunding, 0);
    expect(forecast.shortfall, 0);
    expect(forecast.buffer, closeTo(18500, 0.01));
    expect(forecast.utilizationRatio, 0);
    expect(forecast.settledObligationCount, 2);
    expect(
      forecast.nextAction,
      'Payroll cash obligations are settled for this run.',
    );
  });

  test('payroll compliance calendar tracks dated close milestones', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final calendar = container.read(payrollComplianceCalendarProvider);

    expect(calendar.periodLabel, 'June 2026 Payroll');
    expect(calendar.asOfDate, DateTime(2026, 6, 2));
    expect(calendar.milestones.map((milestone) => milestone.id), [
      'reconciliation-signoff',
      'funding-readiness',
      'payment-release',
      'payslip-publishing',
      'journal-posting',
      'liability-remittance',
      'archive-package',
      'control-review',
    ]);
    expect(calendar.completedCount, 0);
    expect(calendar.blockedCount, 8);
    expect(calendar.dueSoonCount, 0);
    expect(calendar.overdueCount, 0);
    expect(
      calendar.milestones.first.status,
      PayrollComplianceMilestoneStatus.blocked,
    );
    expect(
      calendar.nextAction,
      'Clear 3 payroll blockers before reconciliation sign-off.',
    );
  });

  test('payroll compliance calendar completes with closed payroll run', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final calendar = container.read(payrollComplianceCalendarProvider);

    expect(calendar.completedCount, 8);
    expect(calendar.blockedCount, 0);
    expect(calendar.overdueCount, 0);
    expect(
      calendar.milestones.every(
        (milestone) =>
            milestone.status == PayrollComplianceMilestoneStatus.complete,
      ),
      isTrue,
    );
    expect(calendar.nextAction, 'Payroll compliance calendar is complete.');
  });

  test('payroll cutoff calendar tracks pre-close operating windows', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final calendar = container.read(payrollCutoffCalendarProvider);

    expect(calendar.periodLabel, 'June 2026 Payroll');
    expect(calendar.payDate, DateTime(2026, 6, 25));
    expect(calendar.rules.map((rule) => rule.id), [
      'data-import',
      'input-changes',
      'attendance',
      'approvals',
      'payments',
      'payslips',
      'liabilities',
      'statutory',
      'archive',
    ]);
    expect(calendar.completeCount, 0);
    expect(calendar.blockedCount, 7);
    expect(calendar.dueSoonCount, 0);
    expect(calendar.missedCount, 0);

    final dataImport = calendar.rules.first;
    expect(
      dataImport.statusOn(calendar.asOfDate),
      PayrollCutoffRuleStatus.open,
    );
    expect(dataImport.cutoffAt, DateTime(2026, 6, 10));
    expect(calendar.nextAction, startsWith('Resolve '));
  });

  test(
    'payroll cutoff calendar marks missed windows after cutoff dates pass',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 20)),
        ],
      );
      addTearDown(container.dispose);

      final calendar = container.read(payrollCutoffCalendarProvider);

      expect(calendar.missedCount, 3);
      expect(calendar.rules.first.id, 'data-import');
      expect(
        calendar.rules.first.statusOn(calendar.asOfDate),
        PayrollCutoffRuleStatus.missed,
      );
      expect(
        calendar.nextAction,
        'Import payroll changes before review starts.',
      );
    },
  );

  test('payroll risk register prioritizes active close risks', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final riskRegister = container.read(payrollRiskRegisterProvider);

    expect(riskRegister.periodLabel, 'June 2026 Payroll');
    expect(riskRegister.asOfDate, DateTime(2026, 6, 2));
    expect(riskRegister.items.map((item) => item.id), [
      'PE-1001',
      'funding-shortfall',
      'PE-1002',
      'PA-1001',
    ]);
    expect(riskRegister.criticalCount, 2);
    expect(riskRegister.highCount, 2);
    expect(riskRegister.dueTodayCount, 0);
    expect(riskRegister.items.first.category, PayrollRiskCategory.exception);
    expect(riskRegister.items.first.severity, PayrollRiskSeverity.critical);
    expect(
      riskRegister.nextAction,
      'Confirm bank account before direct deposit approval.',
    );
  });

  test('payroll risk register clears after payroll close', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final riskRegister = container.read(payrollRiskRegisterProvider);

    expect(riskRegister.items, isEmpty);
    expect(riskRegister.criticalCount, 0);
    expect(riskRegister.highCount, 0);
    expect(riskRegister.nextAction, 'No active payroll close risks.');
  });

  test('payroll audit trail records run evidence and attention items', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final auditTrail = container.read(payrollAuditTrailProvider);

    expect(auditTrail.periodLabel, 'June 2026 Payroll');
    expect(auditTrail.events.map((event) => event.id), contains('PE-1001'));
    expect(auditTrail.events.map((event) => event.id), contains('PA-1001'));
    expect(
      auditTrail.events.map((event) => event.id),
      contains('payment-release'),
    );
    expect(auditTrail.attentionCount, greaterThan(0));
    expect(auditTrail.completedCount, 1);
    expect(auditTrail.latestEvent?.id, 'close-period');
    expect(
      auditTrail.nextAction,
      'Confirm bank account before direct deposit approval.',
    );
  });

  test('payroll audit trail completes after payroll close', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final auditTrail = container.read(payrollAuditTrailProvider);

    expect(auditTrail.attentionCount, 0);
    expect(auditTrail.nextAction, 'Payroll audit trail is current.');
    expect(
      auditTrail.events
          .firstWhere((event) => event.id == 'close-period')
          .status,
      PayrollAuditEventStatus.complete,
    );
    expect(
      auditTrail.events
          .firstWhere((event) => event.id == 'control-review')
          .status,
      PayrollAuditEventStatus.complete,
    );
  });

  test('payroll audit trail includes report delivery receipts', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final varianceReport = container.read(payrollVarianceReportProvider);
    container.read(payrollExportedVarianceReportIdsProvider.notifier).state = {
      varianceReport.reportId,
    };

    final costCenterReport = container.read(payrollCostCenterReportProvider);
    container
        .read(payrollExportedCostCenterReportIdsProvider.notifier)
        .state = {costCenterReport.reportId};

    final bankFile = container.read(payrollBankTransferFileProvider);
    container
        .read(payrollExportedBankTransferFileIdsProvider.notifier)
        .state = {bankFile.fileId};

    final registerReport = container.read(payrollRegisterReportProvider);
    container.read(payrollExportedRegisterReportIdsProvider.notifier).state = {
      registerReport.reportId,
    };

    final statutoryReport = container.read(payrollStatutoryReportProvider);
    container.read(payrollExportedStatutoryFilingIdsProvider.notifier).state = {
      for (final line in statutoryReport.lines) line.id,
    };

    final distribution = container.read(payrollReportDistributionProvider);
    container
        .read(payrollReportDeliveryReceiptsProvider.notifier)
        .deliverReady(
          summary: distribution,
          deliveredBy: 'Payroll Controller',
          deliveredAt: DateTime(2026, 6, 28, 10),
        );

    final auditTrail = container.read(payrollAuditTrailProvider);
    final deliveryEvent = auditTrail.events.firstWhere(
      (event) => event.id == 'distribution-${varianceReport.reportId}',
    );

    expect(deliveryEvent.type, PayrollAuditEventType.distribution);
    expect(deliveryEvent.actor, 'Payroll Controller');
    expect(deliveryEvent.status, PayrollAuditEventStatus.complete);
    expect(deliveryEvent.detail, contains('Finance workspace'));
    expect(deliveryEvent.detail, contains('Finance Controller'));
  });

  test('payroll payslip package waits for released payments', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final package = container.read(payrollPayslipPackageProvider);

    expect(package.packageId, 'PS-202606');
    expect(package.status, PayrollPayslipPackageStatus.blocked);
    expect(package.canPublish, isFalse);
    expect(package.publishedCount, 0);
    expect(package.pendingCount, 3);
    expect(package.readyCount, 0);
    expect(package.blockedCount, 3);
    expect(package.lines.first.statementId, 'PS-202606-0001');
    expect(package.lines[1].channel, PayrollPayslipDeliveryChannel.email);
    expect(package.nextAction, 'Resolve 3 payslip publishing blockers.');

    final detail = container.read(payrollPayslipDetailProvider);
    expect(detail.packageId, 'PS-202606');
    expect(detail.line?.employeeId, package.lines.first.employeeId);
    expect(detail.statusLabel, 'Blocked');
    expect(detail.grossAmount, 8500);
    expect(detail.netAmount, closeTo(5474.75, 0.01));
    expect(detail.nextAction, 'Payment is not released');

    final template = container.read(payrollPayslipTemplateSummaryProvider);
    expect(template.status, PayrollPayslipTemplateStatus.blocked);
    expect(template.enabledSectionCount, template.sections.length);
    expect(template.previewLine?.employeeId, package.lines.first.employeeId);
    expect(template.nextAction, 'Resolve 3 package blockers');
    expect(
      template.sections
          .firstWhere(
            (section) =>
                section.type == PayrollPayslipTemplateSectionType.payment,
          )
          .statusLabel,
      'Visible',
    );

    final distribution = container.read(payrollPayslipDistributionProvider);
    expect(
      distribution.status,
      PayrollPayslipDistributionStatus.waitingForPublish,
    );
    expect(distribution.canDispatch, isFalse);
    expect(distribution.waitingCount, 3);
    expect(
      distribution.nextAction,
      'Publish payslips before dispatching statements.',
    );
  });

  test('payroll payslip template detects setup gaps', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
        payrollPayslipTemplateProfileProvider.overrideWithValue(
          const PayrollPayslipTemplateProfile(
            templateId: 'PST-DRAFT',
            brandName: '',
            logoLabel: '',
            primaryColorHex: '',
            includeEarnings: true,
            includeDeductions: false,
            includeBenefits: false,
            includeEmployerContributions: false,
            includePaymentReference: true,
            includeLeaveBalance: false,
            employeeMessage: '',
            preparedBy: 'Payroll operations',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final template = container.read(payrollPayslipTemplateSummaryProvider);

    expect(template.status, PayrollPayslipTemplateStatus.needsSetup);
    expect(template.nextAction, 'Complete payslip branding');
    expect(template.blockers, contains('Add employee delivery message'));
    expect(
      template.sections
          .firstWhere(
            (section) =>
                section.type == PayrollPayslipTemplateSectionType.deductions,
          )
          .statusLabel,
      'Required',
    );
  });

  test('payroll payslip package publishes after payment release', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');

    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;
    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    final batch = container.read(payrollPaymentBatchProvider);
    container.read(paymentStatusProvider.notifier).state = {
      for (final line in batch.lines) line.employeeId: true,
    };

    var package = container.read(payrollPayslipPackageProvider);
    expect(package.status, PayrollPayslipPackageStatus.ready);
    expect(package.canPublish, isTrue);
    expect(package.readyCount, 3);
    expect(package.totalNet, closeTo(18074.25, 0.01));
    expect(
      package.nextAction,
      'Publish 3 employee payslips to configured channels.',
    );

    container
        .read(payrollPublishedPayslipEmployeeIdsProvider.notifier)
        .state = {package.lines.first.employeeId};

    package = container.read(payrollPayslipPackageProvider);
    expect(package.status, PayrollPayslipPackageStatus.publishing);
    expect(package.publishedCount, 1);
    expect(package.readyCount, 2);

    container.read(selectedPayrollPayslipEmployeeIdProvider.notifier).state =
        package.lines[1].employeeId;
    var detail = container.read(payrollPayslipDetailProvider);
    expect(detail.line?.employeeName, package.lines[1].employeeName);
    expect(detail.statusLabel, 'Ready');
    expect(
      detail.nextAction,
      '${package.lines[1].employeeName} payslip is ready to publish.',
    );

    container
        .read(payrollPublishedPayslipEmployeeIdsProvider.notifier)
        .state = {for (final line in package.lines) line.employeeId};

    package = container.read(payrollPayslipPackageProvider);
    expect(package.status, PayrollPayslipPackageStatus.published);
    expect(package.pendingCount, 0);
    expect(package.publishedNet, closeTo(18074.25, 0.01));
    expect(package.nextAction, 'Payslip package is fully published.');

    detail = container.read(payrollPayslipDetailProvider);
    expect(detail.statusLabel, 'Published');
    expect(
      detail.nextAction,
      '${package.lines[1].employeeName} payslip is published.',
    );

    final template = container.read(payrollPayslipTemplateSummaryProvider);
    expect(template.status, PayrollPayslipTemplateStatus.published);
    expect(
      template.nextAction,
      'Template and payslip delivery package are fully published.',
    );

    var distribution = container.read(payrollPayslipDistributionProvider);
    expect(distribution.status, PayrollPayslipDistributionStatus.ready);
    expect(distribution.canDispatch, isTrue);
    expect(distribution.readyToSendCount, 3);

    final sentAt = package.payDate.add(const Duration(hours: 2));
    container.read(payrollPayslipDeliveryReceiptsProvider.notifier).state = {
      package.lines[0].employeeId: PayrollPayslipDeliveryReceipt(
        employeeId: package.lines[0].employeeId,
        sentAt: sentAt,
        acknowledgedAt: sentAt.add(const Duration(hours: 1)),
      ),
      package.lines[1].employeeId: PayrollPayslipDeliveryReceipt(
        employeeId: package.lines[1].employeeId,
        sentAt: sentAt,
      ),
      package.lines[2].employeeId: PayrollPayslipDeliveryReceipt(
        employeeId: package.lines[2].employeeId,
        sentAt: sentAt,
        failureReason: 'Email relay bounced',
      ),
    };

    distribution = container.read(payrollPayslipDistributionProvider);
    expect(
      distribution.status,
      PayrollPayslipDistributionStatus.needsAttention,
    );
    expect(distribution.acknowledgedCount, 1);
    expect(distribution.sentCount, 1);
    expect(distribution.failedCount, 1);
    expect(distribution.canDispatch, isTrue);
    expect(distribution.nextAction, 'Retry 1 failed payslip deliveries.');
  });

  test('payroll liability summary waits for released payments', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final liabilities = container.read(payrollLiabilitySummaryProvider);

    expect(liabilities.remittanceId, 'LR-202606');
    expect(liabilities.status, PayrollLiabilityRemittanceStatus.blocked);
    expect(liabilities.canRemit, isFalse);
    expect(liabilities.remittedCount, 0);
    expect(liabilities.pendingCount, 6);
    expect(liabilities.readyCount, 0);
    expect(liabilities.blockedCount, 6);
    expect(liabilities.totalAmount, closeTo(9075.75, 0.01));
    expect(liabilities.lines.first.id, 'federal-tax');
    expect(liabilities.lines.first.amount, 3825);
    expect(liabilities.nextAction, 'Resolve 6 liability remittance blockers.');
  });

  test('payroll liability summary remits after payment release', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');

    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;
    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    final batch = container.read(payrollPaymentBatchProvider);
    container.read(paymentStatusProvider.notifier).state = {
      for (final line in batch.lines) line.employeeId: true,
    };

    var liabilities = container.read(payrollLiabilitySummaryProvider);
    expect(liabilities.status, PayrollLiabilityRemittanceStatus.ready);
    expect(liabilities.canRemit, isTrue);
    expect(liabilities.readyCount, 6);
    expect(liabilities.pendingAmount, closeTo(9075.75, 0.01));
    expect(liabilities.nextDueLine?.id, 'retirement-401k');
    expect(
      liabilities.nextAction,
      'Remit 6 payroll liabilities before closing the period.',
    );

    container.read(payrollRemittedLiabilityIdsProvider.notifier).state = {
      for (final line in liabilities.lines) line.id,
    };

    liabilities = container.read(payrollLiabilitySummaryProvider);
    expect(liabilities.status, PayrollLiabilityRemittanceStatus.remitted);
    expect(liabilities.pendingCount, 0);
    expect(liabilities.remittedAmount, closeTo(9075.75, 0.01));
    expect(liabilities.nextAction, 'Payroll liabilities are fully remitted.');
  });

  test('payroll register report summarizes export blockers and totals', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final report = container.read(payrollRegisterReportProvider);

    expect(report.reportId, 'REG-202606');
    expect(report.status, PayrollRegisterReportStatus.blocked);
    expect(report.canExport, isFalse);
    expect(report.employeeCount, 3);
    expect(report.releasedPaymentCount, 0);
    expect(report.publishedPayslipCount, 0);
    expect(report.completeLineCount, 0);
    expect(report.totalGross, 25950);
    expect(report.totalNet, closeTo(16874.25, 0.01));
    expect(report.liabilityAmount, closeTo(9075.75, 0.01));
    expect(report.lines.first.statementId, 'PS-202606-0001');
    expect(report.nextAction, '3 payment releases pending');
  });

  test('payroll register report exports after close evidence completes', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    var report = container.read(payrollRegisterReportProvider);
    expect(report.status, PayrollRegisterReportStatus.ready);
    expect(report.canExport, isTrue);
    expect(report.releasedPaymentCount, 3);
    expect(report.publishedPayslipCount, 3);
    expect(report.completeLineCount, 3);
    expect(report.liabilitiesRemitted, isTrue);
    expect(report.journalPosted, isTrue);
    expect(report.nextAction, 'Export payroll register for finance review.');

    container.read(payrollExportedRegisterReportIdsProvider.notifier).state = {
      report.reportId,
    };

    report = container.read(payrollRegisterReportProvider);
    expect(report.status, PayrollRegisterReportStatus.exported);
    expect(report.canExport, isFalse);
    expect(report.nextAction, 'Payroll register report is exported.');
  });

  test(
    'payroll statutory report blocks until close artifacts are complete',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
        ],
      );
      addTearDown(container.dispose);

      final report = container.read(payrollStatutoryReportProvider);

      expect(report.packId, 'STAT-202606');
      expect(report.status, PayrollStatutoryFilingStatus.blocked);
      expect(report.canExport, isFalse);
      expect(report.lines.length, 7);
      expect(report.readyCount, 0);
      expect(report.exportedCount, 0);
      expect(report.blockedCount, 7);
      expect(report.totalAmount, closeTo(25950, 0.01));
      expect(
        report.lines.first.type,
        PayrollStatutoryFilingType.taxWithholding,
      );
      expect(report.nextAction, 'Resolve 7 statutory filing blockers.');
    },
  );

  test(
    'payroll statutory report exports after register and archive are ready',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
        ],
      );
      addTearDown(container.dispose);

      _closePayrollRun(container);

      final register = container.read(payrollRegisterReportProvider);
      container
          .read(payrollExportedRegisterReportIdsProvider.notifier)
          .state = {register.reportId};

      var report = container.read(payrollStatutoryReportProvider);
      expect(report.status, PayrollStatutoryFilingStatus.ready);
      expect(report.canExport, isTrue);
      expect(report.readyCount, 7);
      expect(report.blockedCount, 0);
      expect(report.nextAction, 'Export 7 statutory filing packages.');

      container
          .read(payrollExportedStatutoryFilingIdsProvider.notifier)
          .state = {for (final line in report.lines) line.id};

      report = container.read(payrollStatutoryReportProvider);
      expect(report.status, PayrollStatutoryFilingStatus.exported);
      expect(report.canExport, isFalse);
      expect(report.exportedCount, 7);
      expect(report.nextAction, 'Statutory reporting pack is exported.');
    },
  );

  test('payroll reports hub summarizes blocked report artifacts', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final hub = container.read(payrollReportsHubProvider);

    expect(hub.periodLabel, 'June 2026 Payroll');
    expect(hub.items.length, 7);
    expect(hub.blockedCount, 7);
    expect(hub.readyCount, 0);
    expect(hub.completeCount, 0);
    expect(hub.items.map((item) => item.id), contains('REG-202606'));
    expect(
      hub.items.map((item) => item.category),
      containsAll([
        PayrollReportHubCategory.finance,
        PayrollReportHubCategory.payments,
        PayrollReportHubCategory.compliance,
        PayrollReportHubCategory.audit,
      ]),
    );
    expect(hub.nextAction, 'Resolve 7 payroll report blockers.');
  });

  test('payroll reports hub completes after close exports are retained', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final varianceReport = container.read(payrollVarianceReportProvider);
    container.read(payrollExportedVarianceReportIdsProvider.notifier).state = {
      varianceReport.reportId,
    };

    final costCenterReport = container.read(payrollCostCenterReportProvider);
    container
        .read(payrollExportedCostCenterReportIdsProvider.notifier)
        .state = {costCenterReport.reportId};

    final bankFile = container.read(payrollBankTransferFileProvider);
    container
        .read(payrollExportedBankTransferFileIdsProvider.notifier)
        .state = {bankFile.fileId};

    final registerReport = container.read(payrollRegisterReportProvider);
    container.read(payrollExportedRegisterReportIdsProvider.notifier).state = {
      registerReport.reportId,
    };

    final statutoryReport = container.read(payrollStatutoryReportProvider);
    container.read(payrollExportedStatutoryFilingIdsProvider.notifier).state = {
      for (final line in statutoryReport.lines) line.id,
    };

    final hub = container.read(payrollReportsHubProvider);

    expect(hub.blockedCount, 0);
    expect(hub.readyCount, 0);
    expect(hub.completeCount, 7);
    expect(hub.nextAction, 'Payroll report hub is complete for this period.');
  });

  test('payroll report distribution blocks until reports are complete', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final distribution = container.read(payrollReportDistributionProvider);

    expect(distribution.periodLabel, 'June 2026 Payroll');
    expect(distribution.lines.length, 7);
    expect(distribution.status, PayrollReportDistributionStatus.blocked);
    expect(distribution.blockedCount, 7);
    expect(distribution.readyCount, 0);
    expect(distribution.deliveredCount, 0);
    expect(distribution.lines.first.channel.label, isNotEmpty);
    expect(distribution.nextAction, 'Resolve 7 report distribution blockers.');
  });

  test('payroll report distribution tracks delivery completion', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final varianceReport = container.read(payrollVarianceReportProvider);
    container.read(payrollExportedVarianceReportIdsProvider.notifier).state = {
      varianceReport.reportId,
    };

    final costCenterReport = container.read(payrollCostCenterReportProvider);
    container
        .read(payrollExportedCostCenterReportIdsProvider.notifier)
        .state = {costCenterReport.reportId};

    final bankFile = container.read(payrollBankTransferFileProvider);
    container
        .read(payrollExportedBankTransferFileIdsProvider.notifier)
        .state = {bankFile.fileId};

    final registerReport = container.read(payrollRegisterReportProvider);
    container.read(payrollExportedRegisterReportIdsProvider.notifier).state = {
      registerReport.reportId,
    };

    final statutoryReport = container.read(payrollStatutoryReportProvider);
    container.read(payrollExportedStatutoryFilingIdsProvider.notifier).state = {
      for (final line in statutoryReport.lines) line.id,
    };

    var distribution = container.read(payrollReportDistributionProvider);
    expect(distribution.status, PayrollReportDistributionStatus.ready);
    expect(distribution.blockedCount, 0);
    expect(distribution.readyCount, 7);
    expect(distribution.deliveredCount, 0);
    expect(distribution.nextAction, 'Deliver 7 payroll report packages.');

    container
        .read(payrollReportDeliveryReceiptsProvider.notifier)
        .deliverReady(
          summary: distribution,
          deliveredBy: 'Payroll Controller',
          deliveredAt: DateTime(2026, 6, 25, 15),
        );

    distribution = container.read(payrollReportDistributionProvider);
    expect(distribution.status, PayrollReportDistributionStatus.delivered);
    expect(distribution.readyCount, 0);
    expect(distribution.deliveredCount, 7);
    expect(distribution.deliveryRate, 1);
    expect(distribution.nextAction, 'Payroll report distribution is complete.');
    expect(distribution.lines.first.receipt?.deliveredBy, 'Payroll Controller');
    expect(distribution.lines.first.receipt?.deliveredAt.hour, 15);
    expect(
      distribution.lines.first.receipt?.recipients,
      distribution.lines.first.recipients,
    );

    container
        .read(payrollReportDeliveryReceiptsProvider.notifier)
        .reopen(distribution.lines.first.report.id);

    distribution = container.read(payrollReportDistributionProvider);
    expect(distribution.status, PayrollReportDistributionStatus.ready);
    expect(distribution.readyCount, 1);
    expect(distribution.deliveredCount, 6);
    expect(distribution.lines.first.receipt, isNull);
  });

  test('payroll audit pack review summarizes blocked reviewer readiness', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final review = container.read(payrollAuditPackReviewProvider);

    expect(review.reviewId, 'APR-202606');
    expect(review.status, PayrollAuditPackReviewStatus.blocked);
    expect(review.checkpoints.length, 5);
    expect(review.blockedCount, 5);
    expect(review.retainedCount, 0);
    expect(review.readyCount, 0);
    expect(review.nextAction, 'Resolve 5 audit pack review blockers.');
  });

  test(
    'payroll audit pack review is retained after close evidence completes',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
          payrollTaxProfilesProvider.overrideWithValue(
            _completePayrollTaxProfiles(),
          ),
        ],
      );
      addTearDown(container.dispose);

      _closePayrollRun(container);

      container.read(payrollApprovalRecordsProvider.notifier).state = {
        'hr-review': _approvalRecord('hr-review'),
        'finance-review': _approvalRecord('finance-review'),
        'payroll-manager': _approvalRecord('payroll-manager'),
        'final-release': _approvalRecord('final-release'),
      };

      final varianceReport = container.read(payrollVarianceReportProvider);
      container
          .read(payrollExportedVarianceReportIdsProvider.notifier)
          .state = {varianceReport.reportId};

      final costCenterReport = container.read(payrollCostCenterReportProvider);
      container
          .read(payrollExportedCostCenterReportIdsProvider.notifier)
          .state = {costCenterReport.reportId};

      final bankFile = container.read(payrollBankTransferFileProvider);
      container
          .read(payrollExportedBankTransferFileIdsProvider.notifier)
          .state = {bankFile.fileId};

      final registerReport = container.read(payrollRegisterReportProvider);
      container
          .read(payrollExportedRegisterReportIdsProvider.notifier)
          .state = {registerReport.reportId};

      final statutoryReport = container.read(payrollStatutoryReportProvider);
      container
          .read(payrollExportedStatutoryFilingIdsProvider.notifier)
          .state = {for (final line in statutoryReport.lines) line.id};

      final distribution = container.read(payrollReportDistributionProvider);
      container
          .read(payrollReportDeliveryReceiptsProvider.notifier)
          .deliverReady(
            summary: distribution,
            deliveredBy: 'Payroll Controller',
            deliveredAt: DateTime(2026, 6, 28, 10),
          );

      final review = container.read(payrollAuditPackReviewProvider);

      expect(review.status, PayrollAuditPackReviewStatus.retained);
      expect(review.blockedCount, 0);
      expect(review.readyCount, 0);
      expect(review.retainedCount, 5);
      expect(review.readinessRate, 1);
      expect(
        review.nextAction,
        'Payroll audit pack is retained and reviewer-ready.',
      );
    },
  );

  test('audit pack findings track remediation and closure', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var findings = container.read(auditPackFindingsProvider);

    expect(findings.findings.length, 5);
    expect(findings.openCount, 5);
    expect(findings.remediatedCount, 0);
    expect(findings.closedCount, 0);
    expect(findings.criticalCount, 2);
    expect(findings.nextAction, 'Remediate 5 audit pack findings.');
    var worklist = container.read(auditOwnerWorklistProvider);
    expect(worklist.periodLabel, 'June 2026 Payroll');
    expect(worklist.ownerCount, greaterThan(3));
    expect(worklist.blockedCount, greaterThan(0));
    expect(worklist.actionCount, 5);
    expect(worklist.nextAction, startsWith('Resolve'));
    expect(
      worklist.groups.map((group) => group.owner),
      contains('Payroll Controller'),
    );
    var signoff = container.read(auditCloseSignoffProvider);
    expect(signoff.periodLabel, 'June 2026 Payroll');
    expect(signoff.gates.length, 6);
    expect(signoff.canSignOff, isFalse);
    expect(signoff.blockedCount, greaterThan(0));
    expect(signoff.nextAction, startsWith('Resolve'));
    expect(
      signoff.gates.map((gate) => gate.id),
      containsAll(['owner-actions', 'finding-closure', 'audit-trail']),
    );
    var attestation = container.read(auditCloseAttestationProvider);
    expect(attestation.canSign, isFalse);
    expect(attestation.isSigned, isFalse);
    expect(attestation.statusLabel, 'Blocked');
    expect(attestation.nextAction, signoff.nextAction);
    var handoff = container.read(auditHandoffPackageProvider);
    expect(handoff.periodLabel, 'June 2026 Payroll');
    expect(handoff.packageId, 'AHP-JUNE-2026-PAYROLL');
    expect(handoff.canHandoff, isFalse);
    expect(handoff.blockedCount, greaterThan(0));
    expect(handoff.nextAction, startsWith('Resolve'));
    expect(
      handoff.lines.map((line) => line.id),
      containsAll(['signoff-gates', 'final-attestation', 'reviewer-route']),
    );
    var delivery = container.read(auditHandoffDeliveryProvider);
    expect(delivery.canRoute, isFalse);
    expect(delivery.isDelivered, isFalse);
    expect(delivery.statusLabel, 'Blocked');
    expect(delivery.nextAction, handoff.nextAction);
    var receipt = container.read(auditReviewerReceiptProvider);
    expect(receipt.canRecord, isFalse);
    expect(receipt.isRecorded, isFalse);
    expect(receipt.statusLabel, 'Blocked');
    expect(receipt.nextAction, delivery.nextAction);

    container
        .read(auditPackFindingRecordsProvider.notifier)
        .remediate(
          checkpointId: 'archive-retention',
          remediatedAt: DateTime(2026, 6, 3),
        );

    findings = container.read(auditPackFindingsProvider);
    expect(findings.openCount, 4);
    expect(findings.remediatedCount, 1);
    worklist = container.read(auditOwnerWorklistProvider);
    expect(worklist.readyReviewCount, 1);
    signoff = container.read(auditCloseSignoffProvider);
    expect(signoff.canSignOff, isFalse);
    expect(
      findings.findings
          .firstWhere((finding) => finding.id == 'archive-retention')
          .resolutionNote,
      'Remediation evidence attached.',
    );
    var auditTrail = container.read(payrollAuditTrailProvider);
    final remediationEvent = auditTrail.events.firstWhere(
      (event) => event.id == 'finding-remediated-archive-retention',
    );
    expect(remediationEvent.type, PayrollAuditEventType.finding);
    expect(remediationEvent.status, PayrollAuditEventStatus.recorded);
    expect(remediationEvent.detail, contains('archive-retention'));

    container
        .read(auditPackFindingRecordsProvider.notifier)
        .close(
          checkpointId: 'archive-retention',
          closedAt: DateTime(2026, 6, 4),
        );

    findings = container.read(auditPackFindingsProvider);
    expect(findings.closedCount, 1);
    expect(findings.closureRate, closeTo(0.2, 0.001));
    worklist = container.read(auditOwnerWorklistProvider);
    expect(worklist.actionCount, 4);
    signoff = container.read(auditCloseSignoffProvider);
    expect(signoff.canSignOff, isFalse);
    auditTrail = container.read(payrollAuditTrailProvider);
    final closureEvent = auditTrail.events.firstWhere(
      (event) => event.id == 'finding-closed-archive-retention',
    );
    expect(closureEvent.type, PayrollAuditEventType.finding);
    expect(closureEvent.status, PayrollAuditEventStatus.complete);

    container
        .read(auditPackFindingRecordsProvider.notifier)
        .reopen('archive-retention');

    findings = container.read(auditPackFindingsProvider);
    expect(findings.openCount, 5);
    expect(findings.closedCount, 0);
    worklist = container.read(auditOwnerWorklistProvider);
    expect(worklist.actionCount, 5);
    auditTrail = container.read(payrollAuditTrailProvider);
    expect(
      auditTrail.events.any(
        (event) => event.id == 'finding-remediated-archive-retention',
      ),
      isFalse,
    );
  });

  test('audit pack findings clear when review package is retained', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
        payrollTaxProfilesProvider.overrideWithValue(
          _completePayrollTaxProfiles(),
        ),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    container.read(payrollApprovalRecordsProvider.notifier).state = {
      'hr-review': _approvalRecord('hr-review'),
      'finance-review': _approvalRecord('finance-review'),
      'payroll-manager': _approvalRecord('payroll-manager'),
      'final-release': _approvalRecord('final-release'),
    };

    final varianceReport = container.read(payrollVarianceReportProvider);
    container.read(payrollExportedVarianceReportIdsProvider.notifier).state = {
      varianceReport.reportId,
    };

    final costCenterReport = container.read(payrollCostCenterReportProvider);
    container
        .read(payrollExportedCostCenterReportIdsProvider.notifier)
        .state = {costCenterReport.reportId};

    final bankFile = container.read(payrollBankTransferFileProvider);
    container
        .read(payrollExportedBankTransferFileIdsProvider.notifier)
        .state = {bankFile.fileId};

    final registerReport = container.read(payrollRegisterReportProvider);
    container.read(payrollExportedRegisterReportIdsProvider.notifier).state = {
      registerReport.reportId,
    };

    final statutoryReport = container.read(payrollStatutoryReportProvider);
    container.read(payrollExportedStatutoryFilingIdsProvider.notifier).state = {
      for (final line in statutoryReport.lines) line.id,
    };

    final distribution = container.read(payrollReportDistributionProvider);
    container
        .read(payrollReportDeliveryReceiptsProvider.notifier)
        .deliverReady(
          summary: distribution,
          deliveredBy: 'Payroll Controller',
          deliveredAt: DateTime(2026, 6, 28, 10),
        );

    final findings = container.read(auditPackFindingsProvider);
    final worklist = container.read(auditOwnerWorklistProvider);

    expect(findings.findings, isEmpty);
    expect(findings.closureRate, 1);
    expect(findings.nextAction, 'Audit pack findings are closed.');
    expect(worklist.isClear, isTrue);
    expect(worklist.nextAction, 'No owner actions remain for audit close.');
    final signoff = container.read(auditCloseSignoffProvider);
    expect(signoff.canSignOff, isTrue);
    expect(signoff.blockedCount, 0);
    expect(signoff.actionCount, 0);
    expect(signoff.readyCount, 6);
    expect(signoff.readinessRate, 1);
    expect(
      signoff.nextAction,
      'Payroll audit close is ready for final sign-off.',
    );
    var attestation = container.read(auditCloseAttestationProvider);
    expect(attestation.canSign, isTrue);
    expect(attestation.isSigned, isFalse);
    expect(attestation.statusLabel, 'Ready');
    expect(attestation.nextAction, 'Capture final audit close attestation.');
    var handoff = container.read(auditHandoffPackageProvider);
    expect(handoff.canHandoff, isFalse);
    expect(handoff.blockedCount, 0);
    expect(handoff.pendingCount, 2);
    expect(handoff.nextAction, 'Complete 2 handoff items.');

    container
        .read(auditCloseAttestationDraftProvider.notifier)
        .setSignedBy('Aisha Rahman');
    container
        .read(auditCloseAttestationDraftProvider.notifier)
        .setRole('Internal Audit Lead');
    container
        .read(auditCloseAttestationDraftProvider.notifier)
        .setNote('Final payroll audit close evidence reviewed and retained.');
    final draft = container.read(auditCloseAttestationDraftProvider);
    expect(draft.isReadyToSubmit, isTrue);
    container.read(auditCloseAttestationRecordProvider.notifier).state =
        draft.toRecord();

    attestation = container.read(auditCloseAttestationProvider);
    expect(attestation.isSigned, isTrue);
    expect(attestation.canSign, isFalse);
    expect(attestation.canReopen, isTrue);
    expect(attestation.statusLabel, 'Signed');
    expect(attestation.nextAction, contains('Aisha Rahman'));
    handoff = container.read(auditHandoffPackageProvider);
    expect(handoff.canHandoff, isTrue);
    expect(handoff.readyCount, handoff.lines.length);
    expect(handoff.readinessRate, 1);
    expect(
      handoff.nextAction,
      'Audit handoff package is ready for reviewer routing.',
    );
    expect(handoff.recipientLabel, contains('Internal Audit'));
    var delivery = container.read(auditHandoffDeliveryProvider);
    expect(delivery.canRoute, isTrue);
    expect(delivery.isDelivered, isFalse);
    expect(delivery.statusLabel, 'Ready');
    expect(delivery.nextAction, 'Route audit handoff package to reviewers.');

    container
        .read(auditHandoffDeliveryDraftProvider.notifier)
        .setRoutedBy('Payroll Controller');
    container
        .read(auditHandoffDeliveryDraftProvider.notifier)
        .setChannel(AuditHandoffDeliveryChannel.governancePortal);
    container
        .read(auditHandoffDeliveryDraftProvider.notifier)
        .setNote('Reviewer package routed through governance portal.');
    final deliveryDraft = container.read(auditHandoffDeliveryDraftProvider);
    expect(deliveryDraft.isReadyToSubmit, isTrue);
    container
        .read(auditHandoffDeliveryRecordProvider.notifier)
        .state = deliveryDraft.toRecord(
      packageId: handoff.packageId,
      recipients: handoff.recipients,
    );

    delivery = container.read(auditHandoffDeliveryProvider);
    expect(delivery.isDelivered, isTrue);
    expect(delivery.canRoute, isFalse);
    expect(delivery.canReopen, isTrue);
    expect(delivery.statusLabel, 'Delivered');
    expect(delivery.nextAction, contains('Governance portal'));
    var receipt = container.read(auditReviewerReceiptProvider);
    expect(receipt.canRecord, isTrue);
    expect(receipt.isRecorded, isFalse);
    expect(receipt.statusLabel, 'Ready');
    expect(
      receipt.nextAction,
      'Capture reviewer receipt for delivered audit package.',
    );

    container
        .read(auditReviewerReceiptDraftProvider.notifier)
        .setReviewer('Internal Audit');
    container
        .read(auditReviewerReceiptDraftProvider.notifier)
        .setReviewerRole('Audit Reviewer');
    container
        .read(auditReviewerReceiptDraftProvider.notifier)
        .setDecision(AuditReviewerReceiptDecision.accepted);
    container
        .read(auditReviewerReceiptDraftProvider.notifier)
        .setNote('Reviewer accepted the delivered audit handoff package.');
    final receiptDraft = container.read(auditReviewerReceiptDraftProvider);
    expect(receiptDraft.isReadyToSubmit, isTrue);
    container
        .read(auditReviewerReceiptRecordProvider.notifier)
        .state = receiptDraft.toRecord(packageId: handoff.packageId);

    receipt = container.read(auditReviewerReceiptProvider);
    expect(receipt.isRecorded, isTrue);
    expect(receipt.canRecord, isFalse);
    expect(receipt.canReopen, isTrue);
    expect(receipt.statusLabel, 'Accepted');
    expect(receipt.nextAction, contains('accepted'));
  });

  test('payroll controls evidence matrix tracks blocked controls', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final matrix = container.read(payrollControlsEvidenceMatrixProvider);

    expect(matrix.periodLabel, 'June 2026 Payroll');
    expect(matrix.lines.length, 9);
    expect(matrix.coverageRate, 1);
    expect(matrix.missingCount, 0);
    expect(matrix.blockedCount, 9);
    expect(matrix.completeCount, 0);
    expect(matrix.lines.first.control.id, 'exception-clearance');
    expect(matrix.lines.first.evidence?.id, 'exception-clearance');
    expect(matrix.nextAction, 'Resolve 9 control evidence blockers.');
  });

  test(
    'payroll controls evidence matrix completes after retained evidence',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
          payrollTaxProfilesProvider.overrideWithValue(
            _completePayrollTaxProfiles(),
          ),
        ],
      );
      addTearDown(container.dispose);

      _closePayrollRun(container);

      container.read(payrollApprovalRecordsProvider.notifier).state = {
        'hr-review': _approvalRecord('hr-review'),
        'finance-review': _approvalRecord('finance-review'),
        'payroll-manager': _approvalRecord('payroll-manager'),
        'final-release': _approvalRecord('final-release'),
      };

      final costCenterReport = container.read(payrollCostCenterReportProvider);
      container
          .read(payrollExportedCostCenterReportIdsProvider.notifier)
          .state = {costCenterReport.reportId};

      final registerReport = container.read(payrollRegisterReportProvider);
      container
          .read(payrollExportedRegisterReportIdsProvider.notifier)
          .state = {registerReport.reportId};

      final matrix = container.read(payrollControlsEvidenceMatrixProvider);

      expect(matrix.status, PayrollControlsEvidenceMatrixStatus.complete);
      expect(matrix.completeCount, 9);
      expect(matrix.readyCount, 0);
      expect(matrix.blockedCount, 0);
      expect(matrix.missingCount, 0);
      expect(
        matrix.nextAction,
        'Payroll controls evidence matrix is complete.',
      );
    },
  );

  test('payroll journal posting balances finance export lines', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var journal = container.read(payrollJournalPostingProvider);
    expect(journal.journalId, 'JE-202606');
    expect(journal.status, PayrollJournalPostingStatus.blocked);
    expect(journal.canPost, isFalse);
    expect(journal.blockers.length, 5);
    expect(journal.totalDebits, closeTo(journal.totalCredits, 0.01));

    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');

    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;
    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    final batch = container.read(payrollPaymentBatchProvider);
    container.read(paymentStatusProvider.notifier).state = {
      for (final line in batch.lines) line.employeeId: true,
    };

    final package = container.read(payrollPayslipPackageProvider);
    container
        .read(payrollPublishedPayslipEmployeeIdsProvider.notifier)
        .state = {for (final line in package.lines) line.employeeId};

    final liabilities = container.read(payrollLiabilitySummaryProvider);
    container.read(payrollRemittedLiabilityIdsProvider.notifier).state = {
      for (final line in liabilities.lines) line.id,
    };

    journal = container.read(payrollJournalPostingProvider);
    expect(journal.status, PayrollJournalPostingStatus.ready);
    expect(journal.canPost, isTrue);
    expect(journal.lines.length, 3);
    expect(journal.totalDebits, closeTo(27150, 0.01));
    expect(journal.totalCredits, closeTo(27150, 0.01));
    expect(journal.balanceVariance, closeTo(0, 0.01));
    expect(journal.nextAction, 'Post balanced payroll journal to finance.');

    container.read(payrollPostedJournalIdsProvider.notifier).state = {
      journal.journalId,
    };

    journal = container.read(payrollJournalPostingProvider);
    expect(journal.status, PayrollJournalPostingStatus.posted);
    expect(journal.nextAction, 'Payroll journal is posted to finance.');
  });

  test(
    'payroll archive package captures close evidence after journal posting',
    () {
      final container = ProviderContainer(
        overrides: [
          payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
        ],
      );
      addTearDown(container.dispose);

      var archive = container.read(payrollArchivePackageProvider);
      expect(archive.packageId, 'AR-202606');
      expect(archive.status, PayrollArchivePackageStatus.blocked);
      expect(archive.canArchive, isFalse);
      expect(archive.evidenceItems.length, 7);
      expect(archive.readyCount, 1);
      expect(archive.blockedCount, 6);
      expect(archive.retentionUntil, DateTime(2033, 6, 25));
      expect(archive.nextAction, 'Resolve 6 archive evidence blockers.');

      container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
      final exceptions = container.read(payrollExceptionsProvider.notifier);
      exceptions.resolve('PE-1001');
      exceptions.resolve('PE-1002');

      container
          .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
          .state = {
        for (final line
            in container.read(payrollCostCenterBudgetSummaryProvider).lines)
          line.id,
      };

      final reconciliation = container.read(
        payrollReconciliationSummaryProvider,
      );
      container
          .read(payrollReconciliationReviewSignatureProvider.notifier)
          .state = reconciliation.reviewSignature;
      container
          .read(payrollRunCloseProgressProvider.notifier)
          .complete('lock-payroll');

      final batch = container.read(payrollPaymentBatchProvider);
      container.read(paymentStatusProvider.notifier).state = {
        for (final line in batch.lines) line.employeeId: true,
      };

      final package = container.read(payrollPayslipPackageProvider);
      container
          .read(payrollPublishedPayslipEmployeeIdsProvider.notifier)
          .state = {for (final line in package.lines) line.employeeId};

      final liabilities = container.read(payrollLiabilitySummaryProvider);
      container.read(payrollRemittedLiabilityIdsProvider.notifier).state = {
        for (final line in liabilities.lines) line.id,
      };

      final journal = container.read(payrollJournalPostingProvider);
      container.read(payrollPostedJournalIdsProvider.notifier).state = {
        journal.journalId,
      };

      archive = container.read(payrollArchivePackageProvider);
      expect(archive.status, PayrollArchivePackageStatus.ready);
      expect(archive.canArchive, isTrue);
      expect(archive.readyCount, 7);
      expect(archive.blockedCount, 0);
      expect(
        archive.nextAction,
        'Archive payroll evidence package before final close.',
      );

      container.read(payrollArchivedRunPackageIdsProvider.notifier).state = {
        archive.packageId,
      };

      archive = container.read(payrollArchivePackageProvider);
      expect(archive.status, PayrollArchivePackageStatus.archived);
      expect(archive.capturedCount, 7);
      expect(
        archive.nextAction,
        'Payroll run package is archived for audit retention.',
      );
    },
  );

  test('payroll control review signs off close controls after archive', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    var review = container.read(payrollControlReviewProvider);
    expect(review.reviewId, 'CR-202606');
    expect(review.status, PayrollControlReviewStatus.blocked);
    expect(review.canReview, isFalse);
    expect(review.items.length, 9);
    expect(review.readyCount, 0);
    expect(review.blockedCount, 9);
    expect(review.criticalBlockedCount, 7);
    expect(review.nextAction, 'Resolve 9 payroll control blockers.');

    container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');
    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');

    container
        .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
        .state = {
      for (final line
          in container.read(payrollCostCenterBudgetSummaryProvider).lines)
        line.id,
    };

    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;
    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    final batch = container.read(payrollPaymentBatchProvider);
    container.read(paymentStatusProvider.notifier).state = {
      for (final line in batch.lines) line.employeeId: true,
    };

    final package = container.read(payrollPayslipPackageProvider);
    container
        .read(payrollPublishedPayslipEmployeeIdsProvider.notifier)
        .state = {for (final line in package.lines) line.employeeId};

    final liabilities = container.read(payrollLiabilitySummaryProvider);
    container.read(payrollRemittedLiabilityIdsProvider.notifier).state = {
      for (final line in liabilities.lines) line.id,
    };

    final journal = container.read(payrollJournalPostingProvider);
    container.read(payrollPostedJournalIdsProvider.notifier).state = {
      journal.journalId,
    };

    final archive = container.read(payrollArchivePackageProvider);
    container.read(payrollArchivedRunPackageIdsProvider.notifier).state = {
      archive.packageId,
    };

    review = container.read(payrollControlReviewProvider);
    expect(review.status, PayrollControlReviewStatus.ready);
    expect(review.canReview, isTrue);
    expect(review.reviewedCount, 0);
    expect(review.readyCount, 9);
    expect(review.blockedCount, 0);
    expect(
      review.nextAction,
      'Sign off 9 payroll controls before final close.',
    );

    container.read(payrollReviewedControlIdsProvider.notifier).state = {
      for (final item in review.items) item.id,
    };

    review = container.read(payrollControlReviewProvider);
    expect(review.status, PayrollControlReviewStatus.reviewed);
    expect(review.reviewedCount, 9);
    expect(review.pendingCount, 0);
    expect(review.nextAction, 'Payroll control review is signed off.');
  });

  test('payroll close plan blocks until exceptions and approvals clear', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final plan = container.read(payrollRunClosePlanProvider);

    expect(plan.steps.map((step) => step.id), [
      'activate-run-plan',
      'clear-exceptions',
      'approve-adjustments',
      'approve-cost-centers',
      'review-reconciliation',
      'lock-payroll',
      'disburse-payments',
      'publish-payslips',
      'remit-liabilities',
      'post-journal',
      'archive-run',
      'review-controls',
      'close-period',
    ]);
    expect(plan.completedCount, 0);
    expect(plan.readyCount, 0);
    expect(plan.blockedCount, 13);
    expect(plan.progressRatio, 0);
    expect(plan.nextStep?.id, 'activate-run-plan');
    expect(
      plan.nextAction,
      'Activate a payroll run plan for June 2026 Payroll before final payroll preparation.',
    );
    expect(plan.steps.first.status, PayrollRunCloseStepStatus.blocked);
  });

  test('payroll analytics summarizes close readiness and blockers', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    final analytics = container.read(payrollAnalyticsSummaryProvider);

    expect(analytics.periodLabel, 'June 2026 Payroll');
    expect(analytics.readinessScore, 40);
    expect(analytics.closeProgress, 0);
    expect(analytics.varianceRiskCount, 0);
    expect(analytics.blockedStageCount, 8);
    expect(analytics.completeStageCount, 0);
    expect(
      analytics.nextAction,
      'Activate a payroll run plan for June 2026 Payroll before final payroll preparation.',
    );
    expect(analytics.metrics.map((metric) => metric.id), [
      'readiness',
      'close',
      'variance',
      'release',
    ]);
    expect(analytics.stages.map((stage) => stage.id), [
      'budgets',
      'reconciliation',
      'payments',
      'payslips',
      'liabilities',
      'journal',
      'archive',
      'controls',
    ]);
    expect(analytics.stages.first.status, PayrollAnalyticsStatus.blocked);
  });

  test('payroll analytics tracks a fully closed run', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _closePayrollRun(container);

    final analytics = container.read(payrollAnalyticsSummaryProvider);

    expect(analytics.closeProgress, 1);
    expect(analytics.blockedStageCount, 0);
    expect(analytics.completeStageCount, 8);
    expect(analytics.nextAction, 'Payroll run is closed.');
    expect(
      analytics.stages.every(
        (stage) => stage.status == PayrollAnalyticsStatus.complete,
      ),
      isTrue,
    );

    final releaseMetric = analytics.metrics.firstWhere(
      (metric) => metric.id == 'release',
    );
    expect(releaseMetric.value, '8/8');
    expect(releaseMetric.status, PayrollAnalyticsStatus.complete);
  });

  test('payroll close plan progresses through lock disbursement and close', () {
    final container = ProviderContainer(
      overrides: [
        payrollAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 2)),
      ],
    );
    addTearDown(container.dispose);

    _activatePayrollRunPlan(container);
    final adjustments = container.read(payrollAdjustmentsProvider.notifier);
    adjustments.approve('PA-1001');

    final exceptions = container.read(payrollExceptionsProvider.notifier);
    exceptions.resolve('PE-1001');
    exceptions.resolve('PE-1002');

    var plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 3);
    expect(plan.readyCount, 0);
    expect(plan.blockedCount, 10);
    expect(plan.nextStep?.id, 'approve-cost-centers');
    expect(
      plan.nextAction,
      'Engineering needs budget approval before payroll release.',
    );

    container
        .read(payrollApprovedCostCenterBudgetIdsProvider.notifier)
        .state = {
      for (final line
          in container.read(payrollCostCenterBudgetSummaryProvider).lines)
        line.id,
    };

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 4);
    expect(plan.readyCount, 1);
    expect(plan.blockedCount, 8);
    expect(plan.nextStep?.id, 'review-reconciliation');
    expect(plan.nextAction, 'Mark payroll reconciliation reviewed.');

    final reconciliation = container.read(payrollReconciliationSummaryProvider);
    container
        .read(payrollReconciliationReviewSignatureProvider.notifier)
        .state = reconciliation.reviewSignature;

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 5);
    expect(plan.readyCount, 1);
    expect(plan.nextStep?.id, 'lock-payroll');

    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('lock-payroll');

    _authorizeFundingAccounts(container);

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 6);
    expect(plan.readyCount, 1);
    expect(plan.nextStep?.id, 'disburse-payments');

    final employees = container.read(employeesProvider2);
    container.read(paymentStatusProvider.notifier).state = {
      for (final employee in employees) employee.id: true,
    };

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 7);
    expect(plan.readyCount, 1);
    expect(plan.blockedCount, 5);
    expect(plan.nextStep?.id, 'publish-payslips');

    container
        .read(payrollPublishedPayslipEmployeeIdsProvider.notifier)
        .state = {for (final employee in employees) employee.id};

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 8);
    expect(plan.readyCount, 1);
    expect(plan.blockedCount, 4);
    expect(plan.nextStep?.id, 'remit-liabilities');

    final liabilities = container.read(payrollLiabilitySummaryProvider);
    container.read(payrollRemittedLiabilityIdsProvider.notifier).state = {
      for (final line in liabilities.lines) line.id,
    };

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 9);
    expect(plan.readyCount, 1);
    expect(plan.blockedCount, 3);
    expect(plan.nextStep?.id, 'post-journal');

    final journal = container.read(payrollJournalPostingProvider);
    container.read(payrollPostedJournalIdsProvider.notifier).state = {
      journal.journalId,
    };

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 10);
    expect(plan.readyCount, 1);
    expect(plan.blockedCount, 2);
    expect(plan.nextStep?.id, 'archive-run');

    final archive = container.read(payrollArchivePackageProvider);
    container.read(payrollArchivedRunPackageIdsProvider.notifier).state = {
      archive.packageId,
    };

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 11);
    expect(plan.readyCount, 1);
    expect(plan.blockedCount, 1);
    expect(plan.nextStep?.id, 'review-controls');

    final controlReview = container.read(payrollControlReviewProvider);
    container.read(payrollReviewedControlIdsProvider.notifier).state = {
      for (final item in controlReview.items) item.id,
    };

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 12);
    expect(plan.readyCount, 1);
    expect(plan.blockedCount, 0);
    expect(plan.nextStep?.id, 'close-period');

    container
        .read(payrollRunCloseProgressProvider.notifier)
        .complete('close-period');

    plan = container.read(payrollRunClosePlanProvider);
    expect(plan.completedCount, 13);
    expect(plan.isClosed, isTrue);
    expect(plan.nextAction, 'Payroll run is closed.');
  });
}

void _closePayrollRun(ProviderContainer container) {
  _activatePayrollRunPlan(container);

  container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');

  final exceptions = container.read(payrollExceptionsProvider.notifier);
  exceptions.resolve('PE-1001');
  exceptions.resolve('PE-1002');

  container.read(payrollApprovedCostCenterBudgetIdsProvider.notifier).state = {
    for (final line
        in container.read(payrollCostCenterBudgetSummaryProvider).lines)
      line.id,
  };

  final reconciliation = container.read(payrollReconciliationSummaryProvider);
  container.read(payrollReconciliationReviewSignatureProvider.notifier).state =
      reconciliation.reviewSignature;

  container
      .read(payrollRunCloseProgressProvider.notifier)
      .complete('lock-payroll');

  _authorizeFundingAccounts(container);

  final batch = container.read(payrollPaymentBatchProvider);
  container.read(paymentStatusProvider.notifier).state = {
    for (final line in batch.lines) line.employeeId: true,
  };

  final package = container.read(payrollPayslipPackageProvider);
  container.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state = {
    for (final line in package.lines) line.employeeId,
  };

  final liabilities = container.read(payrollLiabilitySummaryProvider);
  container.read(payrollRemittedLiabilityIdsProvider.notifier).state = {
    for (final line in liabilities.lines) line.id,
  };

  final journal = container.read(payrollJournalPostingProvider);
  container.read(payrollPostedJournalIdsProvider.notifier).state = {
    journal.journalId,
  };

  final archive = container.read(payrollArchivePackageProvider);
  container.read(payrollArchivedRunPackageIdsProvider.notifier).state = {
    archive.packageId,
  };

  final controlReview = container.read(payrollControlReviewProvider);
  container.read(payrollReviewedControlIdsProvider.notifier).state = {
    for (final item in controlReview.items) item.id,
  };

  container
      .read(payrollRunCloseProgressProvider.notifier)
      .complete('close-period');
}

void _activatePayrollRunPlan(ProviderContainer container) {
  final preview = container.read(payrollRunBuilderPreviewProvider);
  final request = container
      .read(payrollRunBuildRequestsProvider.notifier)
      .submitPreview(preview);
  final requests = container.read(payrollRunBuildRequestsProvider.notifier);
  requests.approve(request.id);
  requests.activate(request.id);
}

void _prepareApprovalPrerequisites(ProviderContainer container) {
  _activatePayrollRunPlan(container);
  container.read(payrollAdjustmentsProvider.notifier).approve('PA-1001');

  final exceptions = container.read(payrollExceptionsProvider.notifier);
  exceptions.resolve('PE-1001');
  exceptions.resolve('PE-1002');

  container.read(payrollApprovedCostCenterBudgetIdsProvider.notifier).state = {
    for (final line
        in container.read(payrollCostCenterBudgetSummaryProvider).lines)
      line.id,
  };

  final reconciliation = container.read(payrollReconciliationSummaryProvider);
  container.read(payrollReconciliationReviewSignatureProvider.notifier).state =
      reconciliation.reviewSignature;
  container
      .read(payrollRunCloseProgressProvider.notifier)
      .complete('lock-payroll');

  _authorizeFundingAccounts(container);
}

void _authorizeFundingAccounts(ProviderContainer container) {
  final authorization = container.read(payrollFundingAuthorizationProvider);
  container.read(payrollFundingAuthorizationRecordsProvider.notifier).state = {
    for (final line in authorization.lines)
      line.accountLabel: _fundingAuthorizationRecord(line.accountLabel),
  };
}

PayrollFundingAuthorizationRecord _fundingAuthorizationRecord(
  String accountLabel,
) {
  return PayrollFundingAuthorizationRecord(
    accountLabel: accountLabel,
    authorizedBy: 'Aisha CFO',
    authorizedAt: DateTime(2026, 6, 20, 10),
    referenceCode: 'AUTH-${accountLabel.hashCode.abs()}',
    notes: 'Payroll funding authorization reviewed and approved.',
  );
}

List<PayrollTaxProfile> _completePayrollTaxProfiles() {
  return const [
    PayrollTaxProfile(
      employeeId: 1,
      taxIdLast4: '1932',
      filingStatus: PayrollTaxFilingStatus.single,
      allowanceCount: 1,
      hasWithholdingCertificate: true,
    ),
    PayrollTaxProfile(
      employeeId: 2,
      taxIdLast4: '2044',
      filingStatus: PayrollTaxFilingStatus.married,
      allowanceCount: 2,
      hasWithholdingCertificate: true,
    ),
    PayrollTaxProfile(
      employeeId: 3,
      taxIdLast4: '5590',
      filingStatus: PayrollTaxFilingStatus.headOfHousehold,
      allowanceCount: 1,
      hasWithholdingCertificate: true,
    ),
  ];
}

PayrollApprovalRecord _approvalRecord(String stageId) {
  return PayrollApprovalRecord(
    stageId: stageId,
    approvedBy: 'Test Approver',
    approvedAt: DateTime(2026, 6, 20, 11),
    note: '$stageId approved in test.',
  );
}
