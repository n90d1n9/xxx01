import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../employee/models/employee.dart';
import '../data/payroll_management_seed_data.dart';
import '../data/payroll_seed_data.dart';
import '../models/payroll_detail.dart';
import '../models/payroll_management_models.dart';

final payrollRunPeriodsProvider = Provider<List<PayrollRunPeriod>>((ref) {
  return buildPayrollRunPeriods();
});

final selectedPayrollRunPeriodIdProvider = StateProvider<String>((ref) {
  final currentPeriod = ref
      .watch(payrollRunPeriodsProvider)
      .firstWhere((period) => period.isCurrent);
  return currentPeriod.id;
});

final selectedPayrollRunPeriodProvider = Provider<PayrollRunPeriod>((ref) {
  final periods = ref.watch(payrollRunPeriodsProvider);
  final selectedId = ref.watch(selectedPayrollRunPeriodIdProvider);
  return periods.firstWhere(
    (period) => period.id == selectedId,
    orElse: () => periods.firstWhere((period) => period.isCurrent),
  );
});

final payrollAsOfDateProvider = Provider<DateTime>((ref) {
  return ref.watch(selectedPayrollRunPeriodProvider).asOfDate;
});

final payrollRunBuilderDraftProvider = StateNotifierProvider<
  PayrollRunBuilderDraftNotifier,
  PayrollRunBuilderDraft
>((ref) {
  return PayrollRunBuilderDraftNotifier(
    PayrollRunBuilderDraft.fromPeriod(
      ref.watch(selectedPayrollRunPeriodProvider),
    ),
  );
});

class PayrollRunBuilderDraftNotifier
    extends StateNotifier<PayrollRunBuilderDraft> {
  PayrollRunBuilderDraftNotifier(super.state);

  void setLabel(String value) {
    state = state.copyWith(label: value);
  }

  void setPeriodStart(DateTime value) {
    state = state.copyWith(periodStart: value);
  }

  void setPeriodEnd(DateTime value) {
    state = state.copyWith(periodEnd: value);
  }

  void setPayDate(DateTime value) {
    state = state.copyWith(payDate: value);
  }

  void setScope(PayrollRunScope value) {
    state = state.copyWith(scope: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void reset(PayrollRunPeriod period) {
    state = PayrollRunBuilderDraft.fromPeriod(period);
  }
}

final payrollRunBuildRequestsProvider = StateNotifierProvider<
  PayrollRunBuildRequestsNotifier,
  List<PayrollRunBuildRequest>
>((ref) {
  return PayrollRunBuildRequestsNotifier();
});

class PayrollRunBuildRequestsNotifier
    extends StateNotifier<List<PayrollRunBuildRequest>> {
  PayrollRunBuildRequestsNotifier() : super(const []);

  PayrollRunBuildRequest submitPreview(PayrollRunBuilderPreview preview) {
    if (!preview.canCreateRun) {
      throw StateError(preview.nextAction);
    }
    final draft = preview.draft;
    final request = draft.toRequest(
      id: _nextRequestId(),
      createdAt: draft.payDate.subtract(const Duration(days: 7)),
      artifacts: preview.buildArtifacts(),
    );
    state = [request, ...state];
    return request;
  }

  void approve(String id) {
    _update(id, (request) {
      if (!request.isReadyForApproval) {
        throw StateError('Run plan artifacts must be ready before approval');
      }
      return request.copyWith(status: PayrollRunBuildStatus.approved);
    });
  }

  void activate(String id) {
    PayrollRunBuildRequest? target;
    for (final request in state) {
      if (request.id == id) {
        target = request;
        break;
      }
    }
    if (target == null) {
      throw StateError('Payroll run plan is unavailable');
    }
    if (!target.canActivate) {
      throw StateError('Approve the run plan before activation');
    }

    state =
        state.map((request) {
          if (request.id == id) {
            return request.copyWith(status: PayrollRunBuildStatus.activated);
          }
          if (request.status == PayrollRunBuildStatus.activated &&
              request.periodId == target!.periodId) {
            return request.copyWith(status: PayrollRunBuildStatus.approved);
          }
          return request;
        }).toList();
  }

  void reopen(String id) {
    _update(id, (request) {
      if (request.status == PayrollRunBuildStatus.activated) {
        throw StateError('Activated run plans cannot be reopened');
      }
      return request.copyWith(status: PayrollRunBuildStatus.draft);
    });
  }

  void _update(
    String id,
    PayrollRunBuildRequest Function(PayrollRunBuildRequest request) update,
  ) {
    var found = false;
    state =
        state.map((request) {
          if (request.id != id) return request;
          found = true;
          return update(request);
        }).toList();
    if (!found) throw StateError('Payroll run plan is unavailable');
  }

  String _nextRequestId() {
    final sequence =
        state
            .map((request) => int.tryParse(request.id.replaceAll('PR-', '')))
            .whereType<int>()
            .fold<int>(1000, (max, value) => value > max ? value : max) +
        1;
    return 'PR-$sequence';
  }
}

final employeesProvider2 = StateProvider<List<Employee>>((ref) {
  return buildPayrollEmployees();
});

final payrollRunBuilderPreviewProvider = Provider<PayrollRunBuilderPreview>((
  ref,
) {
  return PayrollRunBuilderPreview.fromDraft(
    draft: ref.watch(payrollRunBuilderDraftProvider),
    employees: ref.watch(employeesProvider2),
    paymentProfiles: ref.watch(payrollPaymentProfilesProvider),
  );
});

final payrollActiveRunPlanSummaryProvider =
    Provider<PayrollActiveRunPlanSummary>((ref) {
      return PayrollActiveRunPlanSummary.fromPeriod(
        period: ref.watch(selectedPayrollRunPeriodProvider),
        requests: ref.watch(payrollRunBuildRequestsProvider),
      );
    });

final selectedEmployeeProvider3 = StateProvider<Employee?>((ref) => null);

final payrollDetailsProvider = Provider<PayrollDetails?>((ref) {
  final selectedEmployee = ref.watch(selectedEmployeeProvider3);
  final salary = selectedEmployee?.salary;
  return salary == null ? null : PayrollDetails.fromSalary(salary);
});

final paymentStatusProvider = StateProvider<Map<int, bool>>((ref) {
  return buildPayrollPaymentStatus(ref.watch(employeesProvider2));
});

final payrollSummaryProvider = Provider<PayrollSummary>((ref) {
  return PayrollSummary.fromEmployees(
    employees: ref.watch(employeesProvider2),
    paymentStatus: ref.watch(paymentStatusProvider),
  );
});

final payrollEmployeeLedgerProvider = Provider<PayrollEmployeeLedgerSummary>((
  ref,
) {
  final selectedEmployee = ref.watch(selectedEmployeeProvider3);
  return PayrollEmployeeLedgerSummary.fromRun(
    employee: selectedEmployee,
    period: ref.watch(selectedPayrollRunPeriodProvider),
    details: ref.watch(payrollDetailsProvider),
    isPaid:
        selectedEmployee == null
            ? false
            : ref.watch(paymentStatusProvider)[selectedEmployee.id] ?? false,
    inputChanges: ref.watch(payrollInputChangeSummaryProvider),
    attendanceBridge: ref.watch(payrollAttendanceBridgeProvider),
    loanRepayments: ref.watch(payrollLoanRepaymentProvider),
    deductionAuthorizations: ref.watch(payrollDeductionAuthorizationProvider),
    offCycleRuns: ref.watch(payrollOffCycleRunSummaryProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
  );
});

final payrollRiskSummaryProvider = Provider<PayrollRiskSummary>((ref) {
  return PayrollRiskSummary.fromEmployees(
    employees: ref.watch(employeesProvider2),
    paymentStatus: ref.watch(paymentStatusProvider),
  );
});

final payrollCostCenterSummaryProvider = Provider<PayrollCostCenterSummary>((
  ref,
) {
  return PayrollCostCenterSummary.fromRun(
    periodLabel: ref.watch(payrollRunDashboardProvider).periodLabel,
    employees: ref.watch(employeesProvider2),
    paymentStatus: ref.watch(paymentStatusProvider),
    adjustments: ref.watch(payrollAdjustmentsProvider),
  );
});

final payrollCostCenterBudgetPlansProvider =
    Provider<List<PayrollCostCenterBudgetPlan>>((ref) {
      return buildPayrollCostCenterBudgetPlans();
    });

final payrollApprovedCostCenterBudgetIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollCostCenterBudgetSummaryProvider =
    Provider<PayrollCostCenterBudgetSummary>((ref) {
      return PayrollCostCenterBudgetSummary.fromCostCenters(
        costCenters: ref.watch(payrollCostCenterSummaryProvider),
        plans: ref.watch(payrollCostCenterBudgetPlansProvider),
        approvedCostCenterIds: ref.watch(
          payrollApprovedCostCenterBudgetIdsProvider,
        ),
      );
    });

final payrollCostCenterReportProvider =
    Provider<PayrollCostCenterReportSummary>((ref) {
      return PayrollCostCenterReportSummary.fromCostCenters(
        costCenters: ref.watch(payrollCostCenterSummaryProvider),
        budgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
        exportedReportIds: ref.watch(
          payrollExportedCostCenterReportIdsProvider,
        ),
      );
    });

final payrollEmployerCostProvider = Provider<PayrollEmployerCostSummary>((ref) {
  return PayrollEmployerCostSummary.fromRun(
    costCenters: ref.watch(payrollCostCenterSummaryProvider),
    budgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
  );
});

final payrollPaymentProfilesProvider = Provider<List<PayrollPaymentProfile>>((
  ref,
) {
  return buildPayrollPaymentProfiles();
});

final payrollSchedulePolicyProvider = Provider<PayrollSchedulePolicy>((ref) {
  return buildPayrollSchedulePolicy();
});

final payrollTaxPolicyProvider = Provider<PayrollTaxPolicy>((ref) {
  return buildPayrollTaxPolicy();
});

final payrollBenefitPolicyProvider = Provider<PayrollBenefitPolicy>((ref) {
  return buildPayrollBenefitPolicy();
});

final payrollFundingPolicyProvider = Provider<PayrollFundingPolicy>((ref) {
  return buildPayrollFundingPolicy();
});

final payrollPayslipDeliveryProfilesProvider =
    Provider<List<PayrollPayslipDeliveryProfile>>((ref) {
      return buildPayrollPayslipDeliveryProfiles();
    });

final payrollTaxProfilesProvider = Provider<List<PayrollTaxProfile>>((ref) {
  return buildPayrollTaxProfiles();
});

final payrollBenefitElectionsProvider = Provider<List<PayrollBenefitElection>>((
  ref,
) {
  return buildPayrollBenefitElections();
});

final payrollRecurringRulesProvider = Provider<List<PayrollRecurringRule>>((
  ref,
) {
  return buildPayrollRecurringRules();
});

final payrollDataImportDraftProvider = StateNotifierProvider<
  PayrollDataImportDraftNotifier,
  PayrollDataImportDraft
>((ref) {
  return PayrollDataImportDraftNotifier(
    PayrollDataImportDraft.empty(ref.watch(payrollAsOfDateProvider)),
  );
});

class PayrollDataImportDraftNotifier
    extends StateNotifier<PayrollDataImportDraft> {
  PayrollDataImportDraftNotifier(super.state);

  void setType(PayrollDataImportType value) {
    state = state.copyWith(type: value);
  }

  void setSourceLabel(String value) {
    state = state.copyWith(sourceLabel: value);
  }

  void setCsvText(String value) {
    state = state.copyWith(csvText: value);
  }

  void loadSample() {
    state = state.copyWith(
      csvText:
          'employee_id,amount,effective_date,reason,current_amount\n'
          '1,9000,${_isoDate(state.asOfDate.add(const Duration(days: 3)))},Annual salary calibration,8500\n'
          '2,450,${_isoDate(state.asOfDate.add(const Duration(days: 4)))},Quarterly payroll bonus,\n',
    );
  }

  void clear() {
    state = PayrollDataImportDraft.empty(state.asOfDate);
  }
}

final payrollDataImportPreviewProvider = Provider<PayrollDataImportPreview>((
  ref,
) {
  return PayrollDataImportPreview.fromDraft(
    draft: ref.watch(payrollDataImportDraftProvider),
    employees: ref.watch(employeesProvider2),
  );
});

final payrollDataImportBatchesProvider = StateNotifierProvider<
  PayrollDataImportBatchesNotifier,
  List<PayrollDataImportBatch>
>((ref) {
  return PayrollDataImportBatchesNotifier();
});

class PayrollDataImportBatchesNotifier
    extends StateNotifier<List<PayrollDataImportBatch>> {
  PayrollDataImportBatchesNotifier() : super(const []);

  PayrollDataImportBatch applyPreview(PayrollDataImportPreview preview) {
    if (!preview.canImport) {
      throw StateError(preview.nextAction);
    }
    final batch = preview.toBatch(id: _nextBatchId());
    state = [batch, ...state];
    return batch;
  }

  void remove(String id) {
    state = state.where((batch) => batch.id != id).toList();
  }

  void clear() {
    state = const [];
  }

  String _nextBatchId() {
    final sequence =
        state
            .map((batch) => int.tryParse(batch.id.replaceAll('IMP-', '')))
            .whereType<int>()
            .fold<int>(1000, (max, value) => value > max ? value : max) +
        1;
    return 'IMP-$sequence';
  }
}

final payrollImportedInputChangeRequestsProvider =
    Provider<List<PayrollInputChangeRequest>>((ref) {
      return ref
          .watch(payrollDataImportBatchesProvider)
          .expand((batch) => batch.toInputChanges())
          .toList();
    });

final payrollScenarioDraftLabelProvider = StateProvider<String>(
  (ref) => 'Payroll optimization scenario',
);

final payrollScenarioDraftNotesProvider = StateProvider<String>(
  (ref) => 'Review projected payroll impact before conversion.',
);

final payrollScenarioRecordsProvider = StateNotifierProvider<
  PayrollScenarioRecordsNotifier,
  List<PayrollScenarioRecord>
>((ref) {
  return PayrollScenarioRecordsNotifier();
});

class PayrollScenarioRecordsNotifier
    extends StateNotifier<List<PayrollScenarioRecord>> {
  PayrollScenarioRecordsNotifier() : super(const []);

  PayrollScenarioRecord save({
    required PayrollSimulationSummary simulation,
    required String label,
    required String notes,
    required DateTime createdAt,
  }) {
    if (simulation.blockerCount > 0) {
      throw StateError(simulation.nextAction);
    }
    final scenario = PayrollScenarioRecord.fromSimulation(
      id: _nextScenarioId(),
      label: label,
      notes: notes,
      createdAt: createdAt,
      simulation: simulation,
    );
    state = [scenario, ...state];
    return scenario;
  }

  void approve(String id) {
    _update(id, (scenario) {
      if (!scenario.canApprove) {
        throw StateError('Only saved scenarios can be approved');
      }
      return scenario.copyWith(status: PayrollScenarioStatus.approved);
    });
  }

  void convert(String id) {
    _update(id, (scenario) {
      if (!scenario.canConvert) {
        throw StateError('Approve the payroll scenario before conversion');
      }
      return scenario.copyWith(status: PayrollScenarioStatus.converted);
    });
  }

  void remove(String id) {
    state = state.where((scenario) => scenario.id != id).toList();
  }

  void clear() {
    state = const [];
  }

  void _update(
    String id,
    PayrollScenarioRecord Function(PayrollScenarioRecord scenario) update,
  ) {
    var found = false;
    state =
        state.map((scenario) {
          if (scenario.id != id) return scenario;
          found = true;
          return update(scenario);
        }).toList();
    if (!found) throw StateError('Payroll scenario is unavailable');
  }

  String _nextScenarioId() {
    final sequence =
        state
            .map((scenario) => int.tryParse(scenario.id.replaceAll('SCN-', '')))
            .whereType<int>()
            .fold<int>(1000, (max, value) => value > max ? value : max) +
        1;
    return 'SCN-$sequence';
  }
}

final payrollScenarioInputChangeRequestsProvider =
    Provider<List<PayrollInputChangeRequest>>((ref) {
      return ref
          .watch(payrollScenarioRecordsProvider)
          .where(
            (scenario) => scenario.status == PayrollScenarioStatus.converted,
          )
          .expand((scenario) => scenario.toInputChanges())
          .toList();
    });

final payrollScenarioLibrarySummaryProvider =
    Provider<PayrollScenarioLibrarySummary>((ref) {
      return PayrollScenarioLibrarySummary(
        scenarios: ref.watch(payrollScenarioRecordsProvider),
        draftLabel: ref.watch(payrollScenarioDraftLabelProvider),
        draftNotes: ref.watch(payrollScenarioDraftNotesProvider),
      );
    });

final payrollInputChangeRequestsProvider =
    Provider<List<PayrollInputChangeRequest>>((ref) {
      return [
        ...buildPayrollInputChangeRequests(ref.watch(payrollAsOfDateProvider)),
        ...ref.watch(payrollImportedInputChangeRequestsProvider),
        ...ref.watch(payrollScenarioInputChangeRequestsProvider),
      ];
    });

final payrollApprovedInputChangeIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollAppliedInputChangeIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollInputChangeSummaryProvider = Provider<PayrollInputChangeSummary>((
  ref,
) {
  return PayrollInputChangeSummary.fromRequests(
    requests: ref.watch(payrollInputChangeRequestsProvider),
    employees: ref.watch(employeesProvider2),
    approvedChangeIds: ref.watch(payrollApprovedInputChangeIdsProvider),
    appliedChangeIds: ref.watch(payrollAppliedInputChangeIdsProvider),
    asOfDate: ref.watch(payrollAsOfDateProvider),
    selectedEmployeeId: ref.watch(selectedEmployeeProvider3)?.id,
  );
});

final payrollAttendanceSignalsProvider =
    Provider<List<PayrollAttendanceSignal>>((ref) {
      return buildPayrollAttendanceSignals(ref.watch(payrollAsOfDateProvider));
    });

final payrollApprovedAttendanceSignalIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollAppliedAttendanceSignalIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollAttendanceBridgeProvider =
    Provider<PayrollAttendanceBridgeSummary>((ref) {
      return PayrollAttendanceBridgeSummary.fromSignals(
        signals: ref.watch(payrollAttendanceSignalsProvider),
        employees: ref.watch(employeesProvider2),
        approvedSignalIds: ref.watch(
          payrollApprovedAttendanceSignalIdsProvider,
        ),
        appliedSignalIds: ref.watch(payrollAppliedAttendanceSignalIdsProvider),
        selectedEmployeeId: ref.watch(selectedEmployeeProvider3)?.id,
      );
    });

final payrollLoanAccountsProvider = Provider<List<PayrollLoanAccount>>((ref) {
  return buildPayrollLoanAccounts();
});

final payrollAppliedLoanRepaymentIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollLoanRepaymentProvider = Provider<PayrollLoanRepaymentSummary>((
  ref,
) {
  return PayrollLoanRepaymentSummary.fromAccounts(
    accounts: ref.watch(payrollLoanAccountsProvider),
    employees: ref.watch(employeesProvider2),
    appliedLoanIds: ref.watch(payrollAppliedLoanRepaymentIdsProvider),
    selectedEmployeeId: ref.watch(selectedEmployeeProvider3)?.id,
  );
});

final payrollGlAccountMappingsProvider =
    Provider<List<PayrollGlAccountMapping>>((ref) {
      return buildPayrollGlAccountMappings();
    });

final payrollGlMappingProvider = Provider<PayrollGlMappingSummary>((ref) {
  return PayrollGlMappingSummary.fromPayrollRun(
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    loanRepayments: ref.watch(payrollLoanRepaymentProvider),
    attendanceBridge: ref.watch(payrollAttendanceBridgeProvider),
    costCenters: ref.watch(payrollCostCenterSummaryProvider),
    mappings: ref.watch(payrollGlAccountMappingsProvider),
  );
});

final payrollSimulationReviewedProvider = StateProvider<bool>((ref) => false);

final payrollSimulationAppliedProvider = StateProvider<bool>((ref) => false);

final payrollSimulationProvider = Provider<PayrollSimulationSummary>((ref) {
  return PayrollSimulationSummary(
    baseSummary: ref.watch(payrollSummaryProvider),
    inputChanges: ref.watch(payrollInputChangeSummaryProvider),
    attendanceBridge: ref.watch(payrollAttendanceBridgeProvider),
    loanRepayments: ref.watch(payrollLoanRepaymentProvider),
    deductionAuthorizations: ref.watch(payrollDeductionAuthorizationProvider),
    isReviewed: ref.watch(payrollSimulationReviewedProvider),
    isApplied: ref.watch(payrollSimulationAppliedProvider),
  );
});

final payrollSuspendedEmployeeIdsProvider = StateProvider<Set<int>>(
  (ref) => <int>{},
);

final payrollApprovedDeductionAuthorizationIdsProvider =
    StateProvider<Set<String>>((ref) => <String>{});

final payrollEmployeeProfileSummaryProvider =
    Provider<PayrollEmployeeProfileSummary>((ref) {
      return PayrollEmployeeProfileSummary.fromEmployees(
        employees: ref.watch(employeesProvider2),
        paymentProfiles: ref.watch(payrollPaymentProfilesProvider),
        payslipDeliveryProfiles: ref.watch(
          payrollPayslipDeliveryProfilesProvider,
        ),
        taxProfiles: ref.watch(payrollTaxProfilesProvider),
        benefitElections: ref.watch(payrollBenefitElectionsProvider),
        recurringRules: ref.watch(payrollRecurringRulesProvider),
        selectedEmployeeId: ref.watch(selectedEmployeeProvider3)?.id,
        suspendedEmployeeIds: ref.watch(payrollSuspendedEmployeeIdsProvider),
      );
    });

final payrollDeductionAuthorizationProvider =
    Provider<PayrollDeductionAuthorizationSummary>((ref) {
      return PayrollDeductionAuthorizationSummary.fromProfiles(
        employeeProfiles: ref.watch(payrollEmployeeProfileSummaryProvider),
        approvedAuthorizationIds: ref.watch(
          payrollApprovedDeductionAuthorizationIdsProvider,
        ),
      );
    });

final payrollConfigurationSummaryProvider =
    Provider<PayrollConfigurationSummary>((ref) {
      return PayrollConfigurationSummary(
        period: ref.watch(selectedPayrollRunPeriodProvider),
        schedulePolicy: ref.watch(payrollSchedulePolicyProvider),
        taxPolicy: ref.watch(payrollTaxPolicyProvider),
        benefitPolicy: ref.watch(payrollBenefitPolicyProvider),
        fundingPolicy: ref.watch(payrollFundingPolicyProvider),
        employeeProfiles: ref.watch(payrollEmployeeProfileSummaryProvider),
      );
    });

final payrollLiabilityProfilesProvider =
    Provider<List<PayrollLiabilityProfile>>((ref) {
      return buildPayrollLiabilityProfiles();
    });

final payrollPublishedPayslipEmployeeIdsProvider = StateProvider<Set<int>>(
  (ref) => <int>{},
);

final payrollPayslipDeliveryReceiptsProvider =
    StateProvider<Map<int, PayrollPayslipDeliveryReceipt>>(
      (ref) => <int, PayrollPayslipDeliveryReceipt>{},
    );

final payrollRemittedLiabilityIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollPostedJournalIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollArchivedRunPackageIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollReviewedControlIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollExportedRegisterReportIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollExportedBankTransferFileIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollExportedVarianceReportIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollExportedCostCenterReportIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollExportedStatutoryFilingIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final payrollReportDeliveryReceiptsProvider = StateNotifierProvider<
  PayrollReportDeliveryReceiptsNotifier,
  Map<String, PayrollReportDeliveryReceipt>
>((ref) => PayrollReportDeliveryReceiptsNotifier());

class PayrollReportDeliveryReceiptsNotifier
    extends StateNotifier<Map<String, PayrollReportDeliveryReceipt>> {
  PayrollReportDeliveryReceiptsNotifier()
    : super(<String, PayrollReportDeliveryReceipt>{});

  void deliver({
    required PayrollReportDistributionLine line,
    required String deliveredBy,
    required DateTime deliveredAt,
  }) {
    state = {
      ...state,
      line.report.id: PayrollReportDeliveryReceipt(
        reportId: line.report.id,
        channel: line.channel,
        recipients: line.recipients,
        deliveredBy: deliveredBy,
        deliveredAt: deliveredAt,
      ),
    };
  }

  void deliverReady({
    required PayrollReportDistributionSummary summary,
    required String deliveredBy,
    required DateTime deliveredAt,
  }) {
    state = {
      ...state,
      for (final line in summary.readyLines)
        line.report.id: PayrollReportDeliveryReceipt(
          reportId: line.report.id,
          channel: line.channel,
          recipients: line.recipients,
          deliveredBy: deliveredBy,
          deliveredAt: deliveredAt,
        ),
    };
  }

  void reopen(String reportId) {
    state = {...state}..remove(reportId);
  }

  void reset() {
    state = <String, PayrollReportDeliveryReceipt>{};
  }
}

final auditPackFindingRecordsProvider = StateNotifierProvider<
  AuditPackFindingRecordsNotifier,
  Map<String, AuditPackFindingRecord>
>((ref) => AuditPackFindingRecordsNotifier());

class AuditPackFindingRecordsNotifier
    extends StateNotifier<Map<String, AuditPackFindingRecord>> {
  AuditPackFindingRecordsNotifier() : super(<String, AuditPackFindingRecord>{});

  void remediate({
    required String checkpointId,
    required DateTime remediatedAt,
    String resolutionNote = 'Remediation evidence attached.',
  }) {
    state = {
      ...state,
      checkpointId: AuditPackFindingRecord(
        checkpointId: checkpointId,
        status: AuditPackFindingStatus.remediated,
        resolutionNote: resolutionNote,
        remediatedAt: remediatedAt,
      ),
    };
  }

  void close({required String checkpointId, required DateTime closedAt}) {
    final record = state[checkpointId];
    if (record == null || record.status != AuditPackFindingStatus.remediated) {
      throw StateError('Remediate the finding before closing it');
    }
    state = {
      ...state,
      checkpointId: record.copyWith(
        status: AuditPackFindingStatus.closed,
        closedAt: closedAt,
      ),
    };
  }

  void reopen(String checkpointId) {
    state = {...state}..remove(checkpointId);
  }

  void reset() {
    state = <String, AuditPackFindingRecord>{};
  }
}

final payrollFundingAuthorizationRecordsProvider =
    StateProvider<Map<String, PayrollFundingAuthorizationRecord>>(
      (ref) => <String, PayrollFundingAuthorizationRecord>{},
    );

final payrollApprovalRecordsProvider =
    StateProvider<Map<String, PayrollApprovalRecord>>(
      (ref) => <String, PayrollApprovalRecord>{},
    );

final payrollApprovalDelegationPoliciesProvider =
    Provider<List<PayrollApprovalDelegationPolicy>>((ref) {
      return const [
        PayrollApprovalDelegationPolicy(
          stageId: 'hr-review',
          primaryOwner: 'HR Operations Lead',
          delegateOwner: 'People Operations Partner',
          backupOwner: 'HR Business Partner',
          escalationOwner: 'Head of People',
          delegateEnabled: true,
          backupEnabled: true,
        ),
        PayrollApprovalDelegationPolicy(
          stageId: 'finance-review',
          primaryOwner: 'Finance Partner',
          delegateOwner: 'Senior Finance Analyst',
          backupOwner: 'Finance Controller',
          escalationOwner: 'Finance Director',
          delegateEnabled: true,
          backupEnabled: true,
        ),
        PayrollApprovalDelegationPolicy(
          stageId: 'payroll-manager',
          primaryOwner: 'Payroll Manager',
          delegateOwner: 'Senior Payroll Specialist',
          backupOwner: 'Payroll Operations Lead',
          escalationOwner: 'Payroll Controller',
          delegateEnabled: true,
          backupEnabled: true,
        ),
        PayrollApprovalDelegationPolicy(
          stageId: 'final-release',
          primaryOwner: 'Payroll Controller',
          delegateOwner: 'Finance Controller',
          backupOwner: 'CFO Delegate',
          escalationOwner: 'CFO',
          delegateEnabled: true,
          backupEnabled: true,
        ),
      ];
    });

final payrollFundingAuthorizationDraftProvider = StateNotifierProvider<
  PayrollFundingAuthorizationDraftNotifier,
  PayrollFundingAuthorizationDraft
>((ref) {
  return PayrollFundingAuthorizationDraftNotifier(
    ref.watch(payrollAsOfDateProvider),
  );
});

class PayrollFundingAuthorizationDraftNotifier
    extends StateNotifier<PayrollFundingAuthorizationDraft> {
  PayrollFundingAuthorizationDraftNotifier(DateTime authorizedAt)
    : _authorizedAt = authorizedAt,
      super(PayrollFundingAuthorizationDraft.empty(authorizedAt));

  final DateTime _authorizedAt;

  void selectAccount(String accountLabel) {
    state = PayrollFundingAuthorizationDraft.forAccount(
      accountLabel: accountLabel,
      authorizedAt: _authorizedAt,
    );
  }

  void setAuthorizedBy(String value) {
    state = state.copyWith(authorizedBy: value);
  }

  void setReferenceCode(String value) {
    state = state.copyWith(referenceCode: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void clear() {
    state = PayrollFundingAuthorizationDraft.empty(_authorizedAt);
  }
}

final payrollAdjustmentDraftProvider = StateNotifierProvider<
  PayrollAdjustmentDraftNotifier,
  PayrollAdjustmentDraft
>((ref) {
  return PayrollAdjustmentDraftNotifier(ref.watch(payrollAsOfDateProvider));
});

class PayrollAdjustmentDraftNotifier
    extends StateNotifier<PayrollAdjustmentDraft> {
  PayrollAdjustmentDraftNotifier(DateTime asOfDate)
    : super(PayrollAdjustmentDraft.empty(asOfDate));

  void setEmployeeId(int value) {
    state = state.copyWith(employeeId: value);
  }

  void setType(PayrollAdjustmentType value) {
    state = state.copyWith(type: value);
  }

  void setAmount(String value) {
    state = state.copyWith(amount: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state.copyWith(effectiveDate: value);
  }

  void setCostCenter(String value) {
    state = state.copyWith(costCenter: value);
  }

  void setReason(String value) {
    state = state.copyWith(reason: value);
  }

  void clear() {
    state = PayrollAdjustmentDraft.empty(state.asOfDate);
  }
}

final payrollOffCycleRunDraftProvider = StateNotifierProvider<
  PayrollOffCycleRunDraftNotifier,
  PayrollOffCycleRunDraft
>((ref) {
  return PayrollOffCycleRunDraftNotifier(
    PayrollOffCycleRunDraft.empty(ref.watch(payrollAsOfDateProvider)),
  );
});

class PayrollOffCycleRunDraftNotifier
    extends StateNotifier<PayrollOffCycleRunDraft> {
  PayrollOffCycleRunDraftNotifier(super.state);

  void setEmployeeId(int? value) {
    state = state.copyWith(employeeId: value, clearEmployee: value == null);
  }

  void setType(PayrollOffCycleRunType value) {
    state = state.copyWith(type: value);
  }

  void setGrossAmount(String value) {
    state = state.copyWith(grossAmount: value);
  }

  void setPayDate(DateTime value) {
    state = state.copyWith(payDate: value);
  }

  void setReason(String value) {
    state = state.copyWith(reason: value);
  }

  void setEvidenceReference(String value) {
    state = state.copyWith(evidenceReference: value);
  }

  void setGrossUp(bool value) {
    state = state.copyWith(grossUp: value);
  }

  void clear() {
    state = PayrollOffCycleRunDraft.empty(state.asOfDate);
  }
}

final payrollOffCycleRunRequestsProvider = StateNotifierProvider<
  PayrollOffCycleRunRequestsNotifier,
  List<PayrollOffCycleRunRequest>
>((ref) {
  return PayrollOffCycleRunRequestsNotifier();
});

class PayrollOffCycleRunRequestsNotifier
    extends StateNotifier<List<PayrollOffCycleRunRequest>> {
  PayrollOffCycleRunRequestsNotifier() : super(const []);

  PayrollOffCycleRunRequest submit({
    required PayrollOffCycleRunDraft draft,
    required List<Employee> employees,
  }) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    final employee = employees.firstWhere(
      (item) => item.id == draft.employeeId,
      orElse: () => throw StateError('Selected employee is unavailable'),
    );
    final request = draft.toRequest(
      id: _nextRequestId(),
      employee: employee,
      submittedAt: draft.asOfDate,
    );
    state = [request, ...state];
    return request;
  }

  void approve(String id) {
    _update(id, (request) {
      if (!request.isSubmitted) {
        throw StateError('Only submitted off-cycle requests can be approved');
      }
      return request.copyWith(status: PayrollOffCycleRunStatus.approved);
    });
  }

  void reject(String id) {
    _update(id, (request) {
      if (request.isReleased) {
        throw StateError('Released off-cycle runs cannot be rejected');
      }
      return request.copyWith(status: PayrollOffCycleRunStatus.rejected);
    });
  }

  void release(String id) {
    _update(id, (request) {
      if (!request.isApproved) {
        throw StateError('Approve the off-cycle request before release');
      }
      return request.copyWith(status: PayrollOffCycleRunStatus.released);
    });
  }

  void reopen(String id) {
    _update(id, (request) {
      if (request.isReleased) {
        throw StateError('Released off-cycle runs cannot be reopened');
      }
      return request.copyWith(status: PayrollOffCycleRunStatus.submitted);
    });
  }

  void _update(
    String id,
    PayrollOffCycleRunRequest Function(PayrollOffCycleRunRequest request)
    update,
  ) {
    var found = false;
    state =
        state.map((request) {
          if (request.id != id) return request;
          found = true;
          return update(request);
        }).toList();
    if (!found) throw StateError('Off-cycle payroll request is unavailable');
  }

  String _nextRequestId() {
    final sequence =
        state
            .map((request) => int.tryParse(request.id.replaceAll('OC-', '')))
            .whereType<int>()
            .fold<int>(1000, (max, value) => value > max ? value : max) +
        1;
    return 'OC-$sequence';
  }
}

final payrollOffCycleRunSummaryProvider = Provider<PayrollOffCycleRunSummary>((
  ref,
) {
  return PayrollOffCycleRunSummary(
    requests: ref.watch(payrollOffCycleRunRequestsProvider),
  );
});

final payrollDisputeDraftProvider =
    StateNotifierProvider<PayrollDisputeDraftNotifier, PayrollDisputeDraft>((
      ref,
    ) {
      return PayrollDisputeDraftNotifier(
        PayrollDisputeDraft.empty(ref.watch(payrollAsOfDateProvider)),
      );
    });

class PayrollDisputeDraftNotifier extends StateNotifier<PayrollDisputeDraft> {
  PayrollDisputeDraftNotifier(super.state);

  void setEmployeeId(int? value) {
    state = state.copyWith(employeeId: value, clearEmployee: value == null);
  }

  void setType(PayrollDisputeType value) {
    state = state.copyWith(type: value);
  }

  void setClaimAmount(String value) {
    state = state.copyWith(claimAmount: value);
  }

  void setEvidenceReference(String value) {
    state = state.copyWith(evidenceReference: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void clear() {
    state = PayrollDisputeDraft.empty(state.asOfDate);
  }
}

final payrollDisputeCasesProvider = StateNotifierProvider<
  PayrollDisputeCasesNotifier,
  List<PayrollDisputeCase>
>((ref) => PayrollDisputeCasesNotifier());

class PayrollDisputeCasesNotifier
    extends StateNotifier<List<PayrollDisputeCase>> {
  PayrollDisputeCasesNotifier() : super(const []);

  PayrollDisputeCase submit({
    required PayrollDisputeDraft draft,
    required List<Employee> employees,
  }) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    final employee = employees.firstWhere(
      (item) => item.id == draft.employeeId,
      orElse: () => throw StateError('Selected employee is unavailable'),
    );
    final dispute = draft.toCase(id: _nextDisputeId(), employee: employee);
    state = [dispute, ...state];
    return dispute;
  }

  void startReview(String id) {
    _update(id, (item) {
      if (!item.canReview) {
        throw StateError('Only submitted disputes can start review');
      }
      return item.copyWith(status: PayrollDisputeStatus.inReview);
    });
  }

  void approveCorrection(String id) {
    _update(id, (item) {
      if (!item.canApproveCorrection) {
        throw StateError('Move the dispute into review before correction');
      }
      return item.copyWith(
        status: PayrollDisputeStatus.correctionApproved,
        resolutionAmount: item.claimAmount,
        resolutionNotes: 'Correction approved for payroll adjustment.',
      );
    });
  }

  void reject(String id) {
    _update(id, (item) {
      if (!item.canReject) {
        throw StateError(
          'Only submitted or in-review disputes can be rejected',
        );
      }
      return item.copyWith(
        status: PayrollDisputeStatus.rejected,
        resolutionNotes: 'Dispute rejected after payroll review.',
      );
    });
  }

  void close(String id) {
    _update(id, (item) {
      if (!item.canClose) {
        throw StateError('Approve a correction before closing the dispute');
      }
      return item.copyWith(status: PayrollDisputeStatus.resolved);
    });
  }

  void clear() {
    state = const [];
  }

  void _update(
    String id,
    PayrollDisputeCase Function(PayrollDisputeCase item) update,
  ) {
    var found = false;
    state =
        state.map((item) {
          if (item.id != id) return item;
          found = true;
          return update(item);
        }).toList();
    if (!found) throw StateError('Payroll dispute is unavailable');
  }

  String _nextDisputeId() {
    final sequence =
        state
            .map((item) => int.tryParse(item.id.replaceAll('DIS-', '')))
            .whereType<int>()
            .fold<int>(1000, (max, value) => value > max ? value : max) +
        1;
    return 'DIS-$sequence';
  }
}

final payrollDisputeSummaryProvider = Provider<PayrollDisputeSummary>((ref) {
  return PayrollDisputeSummary(
    draft: ref.watch(payrollDisputeDraftProvider),
    cases: ref.watch(payrollDisputeCasesProvider),
    selectedEmployeeId: ref.watch(selectedEmployeeProvider3)?.id,
  );
});

final payrollAdjustmentsProvider = StateNotifierProvider<
  PayrollAdjustmentNotifier,
  List<PayrollAdjustmentRequest>
>((ref) {
  return PayrollAdjustmentNotifier(
    buildPayrollAdjustments(ref.watch(payrollAsOfDateProvider)),
  );
});

class PayrollAdjustmentNotifier
    extends StateNotifier<List<PayrollAdjustmentRequest>> {
  PayrollAdjustmentNotifier(super.state);

  PayrollAdjustmentRequest submitDraft({
    required PayrollAdjustmentDraft draft,
    required List<Employee> employees,
  }) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final employee = employees.firstWhere(
      (item) => item.id == draft.employeeId,
      orElse: () => throw StateError('Selected employee is unavailable'),
    );
    final request = draft.toRequest(
      id: _nextAdjustmentId(),
      employee: employee,
      submittedAt: draft.asOfDate,
    );
    state = [request, ...state];
    return request;
  }

  void approve(String id) {
    _setStatus(id, PayrollAdjustmentStatus.approved);
  }

  void reject(String id) {
    _setStatus(id, PayrollAdjustmentStatus.rejected);
  }

  void _setStatus(String id, PayrollAdjustmentStatus status) {
    state =
        state.map((request) {
          if (request.id != id) return request;
          return request.copyWith(status: status);
        }).toList();
  }

  String _nextAdjustmentId() {
    final sequence =
        state
            .map((request) => int.tryParse(request.id.replaceAll('PA-', '')))
            .whereType<int>()
            .fold<int>(1000, (max, value) => value > max ? value : max) +
        1;
    return 'PA-$sequence';
  }
}

final payrollExceptionsProvider =
    StateNotifierProvider<PayrollExceptionNotifier, List<PayrollExceptionItem>>(
      (ref) {
        return PayrollExceptionNotifier(
          buildPayrollExceptions(ref.watch(payrollAsOfDateProvider)),
        );
      },
    );

class PayrollExceptionNotifier
    extends StateNotifier<List<PayrollExceptionItem>> {
  PayrollExceptionNotifier(super.state);

  void resolve(String id) {
    _setStatus(id, PayrollExceptionStatus.resolved);
  }

  void reopen(String id) {
    _setStatus(id, PayrollExceptionStatus.open);
  }

  void _setStatus(String id, PayrollExceptionStatus status) {
    state =
        state.map((exception) {
          if (exception.id != id) return exception;
          return exception.copyWith(status: status);
        }).toList();
  }
}

final payrollRunDashboardProvider = Provider<PayrollRunDashboard>((ref) {
  return PayrollRunDashboard.fromSignals(
    summary: ref.watch(payrollSummaryProvider),
    adjustments: ref.watch(payrollAdjustmentsProvider),
    exceptions: ref.watch(payrollExceptionsProvider),
    asOfDate: ref.watch(payrollAsOfDateProvider),
  );
});

final payrollReconciliationBaselineProvider =
    Provider<PayrollReconciliationBaseline>((ref) {
      return buildPayrollReconciliationBaseline(
        ref.watch(payrollAsOfDateProvider),
      );
    });

final payrollRunComparisonBaselineProvider =
    Provider<PayrollRunComparisonBaseline>((ref) {
      return buildPayrollRunComparisonBaseline(
        ref.watch(payrollAsOfDateProvider),
      );
    });

final payrollReconciliationReviewSignatureProvider = StateProvider<String?>(
  (ref) => null,
);

final payrollReconciliationSummaryProvider =
    Provider<PayrollReconciliationSummary>((ref) {
      return PayrollReconciliationSummary.fromRun(
        dashboard: ref.watch(payrollRunDashboardProvider),
        baseline: ref.watch(payrollReconciliationBaselineProvider),
        reviewedSignature: ref.watch(
          payrollReconciliationReviewSignatureProvider,
        ),
      );
    });

final payrollVarianceReportProvider = Provider<PayrollVarianceReportSummary>((
  ref,
) {
  return PayrollVarianceReportSummary.fromReconciliation(
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    exportedReportIds: ref.watch(payrollExportedVarianceReportIdsProvider),
  );
});

final payrollRunComparisonProvider = Provider<PayrollRunComparisonSummary>((
  ref,
) {
  return PayrollRunComparisonSummary.fromRun(
    dashboard: ref.watch(payrollRunDashboardProvider),
    costCenters: ref.watch(payrollCostCenterSummaryProvider),
    baseline: ref.watch(payrollRunComparisonBaselineProvider),
  );
});

final payrollVarianceDrilldownProvider =
    Provider<PayrollVarianceDrilldownSummary>((ref) {
      return PayrollVarianceDrilldownSummary.fromRun(
        reconciliation: ref.watch(payrollReconciliationSummaryProvider),
        comparison: ref.watch(payrollRunComparisonProvider),
      );
    });

final payrollRunCloseProgressProvider =
    StateNotifierProvider<PayrollRunCloseProgressNotifier, Set<String>>((ref) {
      return PayrollRunCloseProgressNotifier();
    });

class PayrollRunCloseProgressNotifier extends StateNotifier<Set<String>> {
  PayrollRunCloseProgressNotifier() : super(<String>{});

  void complete(String stepId) {
    state = {...state, stepId};
  }

  void reopen(String stepId) {
    state = {...state}..remove(stepId);
  }

  void reset() {
    state = <String>{};
  }
}

final payrollPaymentBatchProvider = Provider<PayrollPaymentBatchSummary>((ref) {
  return PayrollPaymentBatchSummary.fromRun(
    dashboard: ref.watch(payrollRunDashboardProvider),
    employees: ref.watch(employeesProvider2),
    paymentStatus: ref.watch(paymentStatusProvider),
    profiles: ref.watch(payrollPaymentProfilesProvider),
    adjustments: ref.watch(payrollAdjustmentsProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    activeRunPlan: ref.watch(payrollActiveRunPlanSummaryProvider),
    completedStepIds: ref.watch(payrollRunCloseProgressProvider),
  );
});

final payrollBankTransferFileProvider =
    Provider<PayrollBankTransferFileSummary>((ref) {
      return PayrollBankTransferFileSummary.fromPaymentBatch(
        paymentBatch: ref.watch(payrollPaymentBatchProvider),
        exportedFileIds: ref.watch(payrollExportedBankTransferFileIdsProvider),
      );
    });

final payrollPayslipPackageProvider = Provider<PayrollPayslipPackageSummary>((
  ref,
) {
  return PayrollPayslipPackageSummary.fromPaymentBatch(
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    deliveryProfiles: ref.watch(payrollPayslipDeliveryProfilesProvider),
    publishedEmployeeIds: ref.watch(payrollPublishedPayslipEmployeeIdsProvider),
  );
});

final selectedPayrollPayslipEmployeeIdProvider = StateProvider<int?>(
  (ref) => null,
);

final payrollPayslipDetailProvider = Provider<PayrollPayslipDetail>((ref) {
  return PayrollPayslipDetail.fromPackage(
    package: ref.watch(payrollPayslipPackageProvider),
    selectedEmployeeId: ref.watch(selectedPayrollPayslipEmployeeIdProvider),
  );
});

final payrollPayslipTemplateProfileProvider =
    Provider<PayrollPayslipTemplateProfile>((ref) {
      return buildPayrollPayslipTemplateProfile();
    });

final payrollPayslipTemplateSummaryProvider =
    Provider<PayrollPayslipTemplateSummary>((ref) {
      return PayrollPayslipTemplateSummary.fromPackage(
        profile: ref.watch(payrollPayslipTemplateProfileProvider),
        package: ref.watch(payrollPayslipPackageProvider),
        detail: ref.watch(payrollPayslipDetailProvider),
      );
    });

final payrollPayslipDistributionProvider =
    Provider<PayrollPayslipDistributionSummary>((ref) {
      return PayrollPayslipDistributionSummary.fromPackage(
        package: ref.watch(payrollPayslipPackageProvider),
        receipts: ref.watch(payrollPayslipDeliveryReceiptsProvider),
      );
    });

final payrollLiabilitySummaryProvider = Provider<PayrollLiabilitySummary>((
  ref,
) {
  return PayrollLiabilitySummary.fromPaymentBatch(
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    profiles: ref.watch(payrollLiabilityProfilesProvider),
    remittedLiabilityIds: ref.watch(payrollRemittedLiabilityIdsProvider),
  );
});

final payrollJournalPostingProvider = Provider<PayrollJournalPostingSummary>((
  ref,
) {
  return PayrollJournalPostingSummary.fromPayrollRun(
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    postedJournalIds: ref.watch(payrollPostedJournalIdsProvider),
  );
});

final payrollRegisterReportProvider = Provider<PayrollRegisterReportSummary>((
  ref,
) {
  return PayrollRegisterReportSummary.fromRun(
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    journalPosted: ref.watch(payrollJournalPostingProvider).isPosted,
    exportedReportIds: ref.watch(payrollExportedRegisterReportIdsProvider),
  );
});

final payrollFundingForecastProvider = Provider<PayrollFundingForecastSummary>((
  ref,
) {
  return PayrollFundingForecastSummary.fromRun(
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
  );
});

final payrollFundingAuthorizationProvider =
    Provider<PayrollFundingAuthorizationSummary>((ref) {
      return PayrollFundingAuthorizationSummary.fromRun(
        paymentBatch: ref.watch(payrollPaymentBatchProvider),
        fundingForecast: ref.watch(payrollFundingForecastProvider),
        costCenterBudgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
        authorizationRecords: ref.watch(
          payrollFundingAuthorizationRecordsProvider,
        ),
      );
    });

final payrollApprovalWorkflowProvider =
    Provider<PayrollApprovalWorkflowSummary>((ref) {
      return PayrollApprovalWorkflowSummary.fromRun(
        dashboard: ref.watch(payrollRunDashboardProvider),
        activeRunPlan: ref.watch(payrollActiveRunPlanSummaryProvider),
        configuration: ref.watch(payrollConfigurationSummaryProvider),
        costCenterBudgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
        reconciliation: ref.watch(payrollReconciliationSummaryProvider),
        fundingAuthorization: ref.watch(payrollFundingAuthorizationProvider),
        approvals: ref.watch(payrollApprovalRecordsProvider),
      );
    });

final payrollApprovalDelegationProvider =
    Provider<PayrollApprovalDelegationSummary>((ref) {
      return PayrollApprovalDelegationSummary.fromWorkflow(
        workflow: ref.watch(payrollApprovalWorkflowProvider),
        policies: ref.watch(payrollApprovalDelegationPoliciesProvider),
      );
    });

final payrollArchivePackageProvider = Provider<PayrollArchivePackageSummary>((
  ref,
) {
  return PayrollArchivePackageSummary.fromRun(
    dashboard: ref.watch(payrollRunDashboardProvider),
    costCenterBudgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    journalPosting: ref.watch(payrollJournalPostingProvider),
    archivedPackageIds: ref.watch(payrollArchivedRunPackageIdsProvider),
  );
});

final payrollControlReviewProvider = Provider<PayrollControlReviewSummary>((
  ref,
) {
  return PayrollControlReviewSummary.fromRun(
    dashboard: ref.watch(payrollRunDashboardProvider),
    costCenterBudgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    journalPosting: ref.watch(payrollJournalPostingProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
    reviewedControlIds: ref.watch(payrollReviewedControlIdsProvider),
  );
});

final payrollEvidenceCenterProvider = Provider<PayrollEvidenceCenterSummary>((
  ref,
) {
  return PayrollEvidenceCenterSummary.fromRun(
    dashboard: ref.watch(payrollRunDashboardProvider),
    configuration: ref.watch(payrollConfigurationSummaryProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    approvals: ref.watch(payrollApprovalWorkflowProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    varianceReport: ref.watch(payrollVarianceReportProvider),
    costCenterReport: ref.watch(payrollCostCenterReportProvider),
    registerReport: ref.watch(payrollRegisterReportProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
  );
});

final payrollControlsEvidenceMatrixProvider =
    Provider<PayrollControlsEvidenceMatrixSummary>((ref) {
      return PayrollControlsEvidenceMatrixSummary.fromRun(
        controlReview: ref.watch(payrollControlReviewProvider),
        evidenceCenter: ref.watch(payrollEvidenceCenterProvider),
      );
    });

final payrollExceptionResolutionProvider =
    Provider<PayrollExceptionResolutionSummary>((ref) {
      return PayrollExceptionResolutionSummary.fromRun(
        inputChanges: ref.watch(payrollInputChangeSummaryProvider),
        attendanceBridge: ref.watch(payrollAttendanceBridgeProvider),
        loanRepayments: ref.watch(payrollLoanRepaymentProvider),
        glMapping: ref.watch(payrollGlMappingProvider),
        approvalWorkflow: ref.watch(payrollApprovalWorkflowProvider),
        paymentBatch: ref.watch(payrollPaymentBatchProvider),
        payslipPackage: ref.watch(payrollPayslipPackageProvider),
        liabilities: ref.watch(payrollLiabilitySummaryProvider),
        journalPosting: ref.watch(payrollJournalPostingProvider),
      );
    });

final payrollExceptionSlaProvider = Provider<PayrollExceptionSlaSummary>((ref) {
  return PayrollExceptionSlaSummary.fromRun(
    asOfDate: ref.watch(payrollAsOfDateProvider),
    exceptions: ref.watch(payrollExceptionsProvider),
    resolution: ref.watch(payrollExceptionResolutionProvider),
  );
});

final payrollRunClosePlanProvider = Provider<PayrollRunClosePlan>((ref) {
  return PayrollRunClosePlan.fromDashboard(
    dashboard: ref.watch(payrollRunDashboardProvider),
    activeRunPlan: ref.watch(payrollActiveRunPlanSummaryProvider),
    costCenterBudgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    fundingAuthorization: ref.watch(payrollFundingAuthorizationProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    journalPosting: ref.watch(payrollJournalPostingProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
    controlReview: ref.watch(payrollControlReviewProvider),
    completedStepIds: ref.watch(payrollRunCloseProgressProvider),
  );
});

final payrollOperationsCenterProvider =
    Provider<PayrollOperationsCenterSummary>((ref) {
      return PayrollOperationsCenterSummary.fromRun(
        dashboard: ref.watch(payrollRunDashboardProvider),
        activeRunPlan: ref.watch(payrollActiveRunPlanSummaryProvider),
        exceptionResolution: ref.watch(payrollExceptionResolutionProvider),
        approvalWorkflow: ref.watch(payrollApprovalWorkflowProvider),
        fundingAuthorization: ref.watch(payrollFundingAuthorizationProvider),
        paymentBatch: ref.watch(payrollPaymentBatchProvider),
        payslipDistribution: ref.watch(payrollPayslipDistributionProvider),
        liabilities: ref.watch(payrollLiabilitySummaryProvider),
        journalPosting: ref.watch(payrollJournalPostingProvider),
        closePlan: ref.watch(payrollRunClosePlanProvider),
      );
    });

final payrollAnalyticsSummaryProvider = Provider<PayrollAnalyticsSummary>((
  ref,
) {
  return PayrollAnalyticsSummary.fromRun(
    dashboard: ref.watch(payrollRunDashboardProvider),
    costCenterBudgets: ref.watch(payrollCostCenterBudgetSummaryProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    journalPosting: ref.watch(payrollJournalPostingProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
    controlReview: ref.watch(payrollControlReviewProvider),
    closePlan: ref.watch(payrollRunClosePlanProvider),
  );
});

final payrollComplianceCalendarProvider =
    Provider<PayrollComplianceCalendarSummary>((ref) {
      return PayrollComplianceCalendarSummary.fromRun(
        asOfDate: ref.watch(payrollAsOfDateProvider),
        reconciliation: ref.watch(payrollReconciliationSummaryProvider),
        fundingForecast: ref.watch(payrollFundingForecastProvider),
        paymentBatch: ref.watch(payrollPaymentBatchProvider),
        payslipPackage: ref.watch(payrollPayslipPackageProvider),
        liabilities: ref.watch(payrollLiabilitySummaryProvider),
        journalPosting: ref.watch(payrollJournalPostingProvider),
        archivePackage: ref.watch(payrollArchivePackageProvider),
        controlReview: ref.watch(payrollControlReviewProvider),
      );
    });

final payrollCutoffCalendarProvider = Provider<PayrollCutoffCalendarSummary>((
  ref,
) {
  return PayrollCutoffCalendarSummary.fromRun(
    asOfDate: ref.watch(payrollAsOfDateProvider),
    dashboard: ref.watch(payrollRunDashboardProvider),
    importBatches: ref.watch(payrollDataImportBatchesProvider),
    inputChanges: ref.watch(payrollInputChangeSummaryProvider),
    attendanceBridge: ref.watch(payrollAttendanceBridgeProvider),
    approvalWorkflow: ref.watch(payrollApprovalWorkflowProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    statutoryReport: ref.watch(payrollStatutoryReportProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
  );
});

final payrollStatutoryReportProvider = Provider<PayrollStatutoryReportSummary>((
  ref,
) {
  return PayrollStatutoryReportSummary.fromRun(
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    registerReport: ref.watch(payrollRegisterReportProvider),
    journalPosting: ref.watch(payrollJournalPostingProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
    exportedFilingIds: ref.watch(payrollExportedStatutoryFilingIdsProvider),
  );
});

final payrollReportsHubProvider = Provider<PayrollReportsHubSummary>((ref) {
  return PayrollReportsHubSummary.fromRun(
    asOfDate: ref.watch(payrollAsOfDateProvider),
    varianceReport: ref.watch(payrollVarianceReportProvider),
    costCenterReport: ref.watch(payrollCostCenterReportProvider),
    bankTransferFile: ref.watch(payrollBankTransferFileProvider),
    registerReport: ref.watch(payrollRegisterReportProvider),
    statutoryReport: ref.watch(payrollStatutoryReportProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
    controlReview: ref.watch(payrollControlReviewProvider),
  );
});

final payrollReportDistributionProvider =
    Provider<PayrollReportDistributionSummary>((ref) {
      return PayrollReportDistributionSummary.fromReportsHub(
        reportsHub: ref.watch(payrollReportsHubProvider),
        deliveryReceipts: ref.watch(payrollReportDeliveryReceiptsProvider),
      );
    });

final payrollAuditPackReviewProvider = Provider<PayrollAuditPackReviewSummary>((
  ref,
) {
  return PayrollAuditPackReviewSummary.fromAuditSignals(
    archivePackage: ref.watch(payrollArchivePackageProvider),
    reportsHub: ref.watch(payrollReportsHubProvider),
    reportDistribution: ref.watch(payrollReportDistributionProvider),
    controlsMatrix: ref.watch(payrollControlsEvidenceMatrixProvider),
    auditTrail: ref.watch(payrollAuditTrailProvider),
  );
});

final auditPackFindingsProvider = Provider<AuditPackFindingsSummary>((ref) {
  return AuditPackFindingsSummary.fromReview(
    review: ref.watch(payrollAuditPackReviewProvider),
    asOfDate: ref.watch(payrollAsOfDateProvider),
    records: ref.watch(auditPackFindingRecordsProvider),
  );
});

final auditOwnerWorklistProvider = Provider<AuditOwnerWorklistSummary>((ref) {
  return AuditOwnerWorklistSummary.fromAuditSignals(
    periodLabel: ref.watch(selectedPayrollRunPeriodProvider).label,
    findings: ref.watch(auditPackFindingsProvider),
    auditPackReview: ref.watch(payrollAuditPackReviewProvider),
    controlsMatrix: ref.watch(payrollControlsEvidenceMatrixProvider),
    reportDistribution: ref.watch(payrollReportDistributionProvider),
  );
});

final auditCloseSignoffProvider = Provider<AuditCloseSignoffSummary>((ref) {
  return AuditCloseSignoffSummary.fromAuditReadiness(
    periodLabel: ref.watch(selectedPayrollRunPeriodProvider).label,
    ownerWorklist: ref.watch(auditOwnerWorklistProvider),
    findings: ref.watch(auditPackFindingsProvider),
    auditPackReview: ref.watch(payrollAuditPackReviewProvider),
    controlsMatrix: ref.watch(payrollControlsEvidenceMatrixProvider),
    reportDistribution: ref.watch(payrollReportDistributionProvider),
    auditTrail: ref.watch(payrollAuditTrailProvider),
  );
});

final auditCloseAttestationDraftProvider = StateNotifierProvider<
  AuditCloseAttestationDraftNotifier,
  AuditCloseAttestationDraft
>((ref) {
  return AuditCloseAttestationDraftNotifier(ref.watch(payrollAsOfDateProvider));
});

/// Manages editable signer input for final payroll audit attestation.
class AuditCloseAttestationDraftNotifier
    extends StateNotifier<AuditCloseAttestationDraft> {
  AuditCloseAttestationDraftNotifier(DateTime signedAt)
    : _signedAt = signedAt,
      super(AuditCloseAttestationDraft.empty(signedAt));

  final DateTime _signedAt;

  void setSignedBy(String value) {
    state = state.copyWith(signedBy: value);
  }

  void setRole(String value) {
    state = state.copyWith(role: value);
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
  }

  void clear() {
    state = AuditCloseAttestationDraft.empty(_signedAt);
  }
}

final auditCloseAttestationRecordProvider =
    StateProvider<AuditCloseAttestationRecord?>((ref) => null);

final auditCloseAttestationProvider = Provider<AuditCloseAttestationSummary>((
  ref,
) {
  return AuditCloseAttestationSummary(
    periodLabel: ref.watch(selectedPayrollRunPeriodProvider).label,
    signoff: ref.watch(auditCloseSignoffProvider),
    draft: ref.watch(auditCloseAttestationDraftProvider),
    record: ref.watch(auditCloseAttestationRecordProvider),
  );
});

final auditHandoffPackageProvider = Provider<AuditHandoffPackageSummary>((ref) {
  return AuditHandoffPackageSummary.fromAuditClose(
    periodLabel: ref.watch(selectedPayrollRunPeriodProvider).label,
    attestation: ref.watch(auditCloseAttestationProvider),
    ownerWorklist: ref.watch(auditOwnerWorklistProvider),
  );
});

final auditHandoffDeliveryDraftProvider = StateNotifierProvider<
  AuditHandoffDeliveryDraftNotifier,
  AuditHandoffDeliveryDraft
>((ref) {
  return AuditHandoffDeliveryDraftNotifier(ref.watch(payrollAsOfDateProvider));
});

/// Manages editable routing input for audit handoff package delivery.
class AuditHandoffDeliveryDraftNotifier
    extends StateNotifier<AuditHandoffDeliveryDraft> {
  AuditHandoffDeliveryDraftNotifier(DateTime routedAt)
    : _routedAt = routedAt,
      super(AuditHandoffDeliveryDraft.empty(routedAt));

  final DateTime _routedAt;

  void setRoutedBy(String value) {
    state = state.copyWith(routedBy: value);
  }

  void setChannel(AuditHandoffDeliveryChannel value) {
    state = state.copyWith(channel: value);
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
  }

  void clear() {
    state = AuditHandoffDeliveryDraft.empty(_routedAt);
  }
}

final auditHandoffDeliveryRecordProvider =
    StateProvider<AuditHandoffDeliveryRecord?>((ref) => null);

final auditHandoffDeliveryProvider = Provider<AuditHandoffDeliverySummary>((
  ref,
) {
  return AuditHandoffDeliverySummary(
    package: ref.watch(auditHandoffPackageProvider),
    draft: ref.watch(auditHandoffDeliveryDraftProvider),
    record: ref.watch(auditHandoffDeliveryRecordProvider),
  );
});

final auditReviewerReceiptDraftProvider = StateNotifierProvider<
  AuditReviewerReceiptDraftNotifier,
  AuditReviewerReceiptDraft
>((ref) {
  return AuditReviewerReceiptDraftNotifier(ref.watch(payrollAsOfDateProvider));
});

/// Manages editable reviewer input for audit handoff receipt.
class AuditReviewerReceiptDraftNotifier
    extends StateNotifier<AuditReviewerReceiptDraft> {
  AuditReviewerReceiptDraftNotifier(DateTime reviewedAt)
    : _reviewedAt = reviewedAt,
      super(AuditReviewerReceiptDraft.empty(reviewedAt));

  final DateTime _reviewedAt;

  void setReviewer(String value) {
    state = state.copyWith(reviewer: value);
  }

  void setReviewerRole(String value) {
    state = state.copyWith(reviewerRole: value);
  }

  void setDecision(AuditReviewerReceiptDecision value) {
    state = state.copyWith(decision: value);
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
  }

  void clear() {
    state = AuditReviewerReceiptDraft.empty(_reviewedAt);
  }
}

final auditReviewerReceiptRecordProvider =
    StateProvider<AuditReviewerReceiptRecord?>((ref) => null);

final auditReviewerReceiptProvider = Provider<AuditReviewerReceiptSummary>((
  ref,
) {
  return AuditReviewerReceiptSummary(
    delivery: ref.watch(auditHandoffDeliveryProvider),
    draft: ref.watch(auditReviewerReceiptDraftProvider),
    record: ref.watch(auditReviewerReceiptRecordProvider),
  );
});

final payrollRiskRegisterProvider = Provider<PayrollRiskRegisterSummary>((ref) {
  return PayrollRiskRegisterSummary.fromRun(
    asOfDate: ref.watch(payrollAsOfDateProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    fundingForecast: ref.watch(payrollFundingForecastProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    complianceCalendar: ref.watch(payrollComplianceCalendarProvider),
    exceptions: ref.watch(payrollExceptionsProvider),
    adjustments: ref.watch(payrollAdjustmentsProvider),
  );
});

final payrollAuditTrailProvider = Provider<PayrollAuditTrailSummary>((ref) {
  return PayrollAuditTrailSummary.fromRun(
    asOfDate: ref.watch(payrollAsOfDateProvider),
    dashboard: ref.watch(payrollRunDashboardProvider),
    adjustments: ref.watch(payrollAdjustmentsProvider),
    exceptions: ref.watch(payrollExceptionsProvider),
    reconciliation: ref.watch(payrollReconciliationSummaryProvider),
    paymentBatch: ref.watch(payrollPaymentBatchProvider),
    payslipPackage: ref.watch(payrollPayslipPackageProvider),
    liabilities: ref.watch(payrollLiabilitySummaryProvider),
    journalPosting: ref.watch(payrollJournalPostingProvider),
    archivePackage: ref.watch(payrollArchivePackageProvider),
    controlReview: ref.watch(payrollControlReviewProvider),
    closePlan: ref.watch(payrollRunClosePlanProvider),
    reportDistribution: ref.watch(payrollReportDistributionProvider),
    auditFindingRecords: ref.watch(auditPackFindingRecordsProvider),
  );
});

String _isoDate(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
