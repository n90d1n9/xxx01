import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import '../states/payroll_provider.dart';
import '../widgets/payroll_adjustment_form_panel.dart';
import '../widgets/payroll_active_run_plan_panel.dart';
import '../widgets/payroll_approval_delegation_panel.dart';
import '../widgets/payroll_approval_workflow_panel.dart';
import '../widgets/payroll_approval_queue_panel.dart';
import '../widgets/payroll_archive_package_panel.dart';
import '../widgets/payroll_analytics_panel.dart';
import '../widgets/payroll_attendance_bridge_panel.dart';
import '../widgets/payroll_audit_pack_review_panel.dart';
import '../widgets/payroll_audit_trail_panel.dart';
import '../widgets/payroll_bank_transfer_file_panel.dart';
import '../widgets/payroll_compliance_calendar_panel.dart';
import '../widgets/payroll_configuration_panel.dart';
import '../widgets/payroll_control_review_panel.dart';
import '../widgets/payroll_cost_center_budget_panel.dart';
import '../widgets/payroll_cost_center_panel.dart';
import '../widgets/payroll_cost_center_report_panel.dart';
import '../widgets/payroll_controls_evidence_matrix_panel.dart';
import '../widgets/payroll_cutoff_calendar_panel.dart';
import '../widgets/payroll_data_import_panel.dart';
import '../widgets/payroll_deduction_authorization_panel.dart';
import '../widgets/payroll_detail_panel.dart';
import '../widgets/payroll_dispute_center_panel.dart';
import '../widgets/payroll_employee_ledger_panel.dart';
import '../widgets/payroll_employee_profile_panel.dart';
import '../widgets/payroll_employee_selector.dart';
import '../widgets/payroll_employer_cost_panel.dart';
import '../widgets/payroll_evidence_center_panel.dart';
import '../widgets/payroll_exception_resolution_panel.dart';
import '../widgets/payroll_exception_sla_panel.dart';
import '../widgets/payroll_funding_authorization_panel.dart';
import '../widgets/payroll_funding_forecast_panel.dart';
import '../widgets/payroll_gl_mapping_panel.dart';
import '../widgets/payroll_input_change_panel.dart';
import '../widgets/payroll_journal_posting_panel.dart';
import '../widgets/payroll_liability_panel.dart';
import '../widgets/payroll_loan_repayment_panel.dart';
import '../widgets/payroll_off_cycle_run_panel.dart';
import '../widgets/payroll_operations_center_panel.dart';
import '../widgets/payroll_payment_batch_panel.dart';
import '../widgets/payroll_period_selector.dart';
import '../widgets/payroll_payslip_detail_panel.dart';
import '../widgets/payroll_payslip_distribution_panel.dart';
import '../widgets/payroll_payslip_package_panel.dart';
import '../widgets/payroll_payslip_template_panel.dart';
import '../widgets/payroll_register_report_panel.dart';
import '../widgets/payroll_report_distribution_panel.dart';
import '../widgets/payroll_reconciliation_panel.dart';
import '../widgets/payroll_reports_hub_panel.dart';
import '../widgets/payroll_risk_register_panel.dart';
import '../widgets/payroll_run_builder_panel.dart';
import '../widgets/payroll_run_dashboard_panel.dart';
import '../widgets/payroll_run_close_panel.dart';
import '../widgets/payroll_run_comparison_panel.dart';
import '../widgets/payroll_scenario_library_panel.dart';
import '../widgets/payroll_simulation_panel.dart';
import '../widgets/payroll_statutory_report_panel.dart';
import '../widgets/payroll_summary_panel.dart';
import '../widgets/payroll_variance_drilldown_panel.dart';
import '../widgets/payroll_variance_report_panel.dart';
import '../widgets/payroll_workspace_tabs.dart';
import '../widgets/audit_close_attestation_panel.dart';
import '../widgets/audit_close_signoff_panel.dart';
import '../widgets/audit_pack_findings_panel.dart';
import '../widgets/audit_handoff_delivery_panel.dart';
import '../widgets/audit_handoff_package_panel.dart';
import '../widgets/audit_owner_worklist_panel.dart';
import '../widgets/audit_reviewer_receipt_panel.dart';

enum _RunBuilderDateField { periodStart, periodEnd, payDate }

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider2);
    final periods = ref.watch(payrollRunPeriodsProvider);
    final selectedPeriod = ref.watch(selectedPayrollRunPeriodProvider);
    final selectedEmployee = ref.watch(selectedEmployeeProvider3);
    final runBuilderDraft = ref.watch(payrollRunBuilderDraftProvider);
    final runBuilderPreview = ref.watch(payrollRunBuilderPreviewProvider);
    final runBuildRequests = ref.watch(payrollRunBuildRequestsProvider);
    final activeRunPlan = ref.watch(payrollActiveRunPlanSummaryProvider);
    final payrollDetails = ref.watch(payrollDetailsProvider);
    final employeeLedger = ref.watch(payrollEmployeeLedgerProvider);
    final employeeProfiles = ref.watch(payrollEmployeeProfileSummaryProvider);
    final deductionAuthorizations = ref.watch(
      payrollDeductionAuthorizationProvider,
    );
    final dataImportDraft = ref.watch(payrollDataImportDraftProvider);
    final dataImportPreview = ref.watch(payrollDataImportPreviewProvider);
    final dataImportBatches = ref.watch(payrollDataImportBatchesProvider);
    final inputChanges = ref.watch(payrollInputChangeSummaryProvider);
    final attendanceBridge = ref.watch(payrollAttendanceBridgeProvider);
    final loanRepayments = ref.watch(payrollLoanRepaymentProvider);
    final simulation = ref.watch(payrollSimulationProvider);
    final scenarioLibrary = ref.watch(payrollScenarioLibrarySummaryProvider);
    final offCycleDraft = ref.watch(payrollOffCycleRunDraftProvider);
    final offCycleRuns = ref.watch(payrollOffCycleRunSummaryProvider);
    final disputeSummary = ref.watch(payrollDisputeSummaryProvider);
    final paymentStatus = ref.watch(paymentStatusProvider);
    final summary = ref.watch(payrollSummaryProvider);
    final costCenters = ref.watch(payrollCostCenterSummaryProvider);
    final costCenterBudgets = ref.watch(payrollCostCenterBudgetSummaryProvider);
    final costCenterReport = ref.watch(payrollCostCenterReportProvider);
    final employerCost = ref.watch(payrollEmployerCostProvider);
    final runDashboard = ref.watch(payrollRunDashboardProvider);
    final reconciliation = ref.watch(payrollReconciliationSummaryProvider);
    final paymentBatch = ref.watch(payrollPaymentBatchProvider);
    final bankTransferFile = ref.watch(payrollBankTransferFileProvider);
    final fundingAuthorization = ref.watch(payrollFundingAuthorizationProvider);
    final fundingAuthorizationDraft = ref.watch(
      payrollFundingAuthorizationDraftProvider,
    );
    final payslipPackage = ref.watch(payrollPayslipPackageProvider);
    final payslipDetail = ref.watch(payrollPayslipDetailProvider);
    final payslipTemplate = ref.watch(payrollPayslipTemplateSummaryProvider);
    final payslipDistribution = ref.watch(payrollPayslipDistributionProvider);
    final liabilities = ref.watch(payrollLiabilitySummaryProvider);
    final glMapping = ref.watch(payrollGlMappingProvider);
    final journalPosting = ref.watch(payrollJournalPostingProvider);
    final registerReport = ref.watch(payrollRegisterReportProvider);
    final archivePackage = ref.watch(payrollArchivePackageProvider);
    final controlReview = ref.watch(payrollControlReviewProvider);
    final closePlan = ref.watch(payrollRunClosePlanProvider);
    final approvalWorkflow = ref.watch(payrollApprovalWorkflowProvider);
    final approvalDelegation = ref.watch(payrollApprovalDelegationProvider);
    final analytics = ref.watch(payrollAnalyticsSummaryProvider);
    final runComparison = ref.watch(payrollRunComparisonProvider);
    final fundingForecast = ref.watch(payrollFundingForecastProvider);
    final varianceReport = ref.watch(payrollVarianceReportProvider);
    final varianceDrilldown = ref.watch(payrollVarianceDrilldownProvider);
    final complianceCalendar = ref.watch(payrollComplianceCalendarProvider);
    final cutoffCalendar = ref.watch(payrollCutoffCalendarProvider);
    final statutoryReport = ref.watch(payrollStatutoryReportProvider);
    final configuration = ref.watch(payrollConfigurationSummaryProvider);
    final evidenceCenter = ref.watch(payrollEvidenceCenterProvider);
    final controlsEvidenceMatrix = ref.watch(
      payrollControlsEvidenceMatrixProvider,
    );
    final exceptionResolution = ref.watch(payrollExceptionResolutionProvider);
    final exceptionSla = ref.watch(payrollExceptionSlaProvider);
    final operationsCenter = ref.watch(payrollOperationsCenterProvider);
    final riskRegister = ref.watch(payrollRiskRegisterProvider);
    final auditTrail = ref.watch(payrollAuditTrailProvider);
    final reportsHub = ref.watch(payrollReportsHubProvider);
    final reportDistribution = ref.watch(payrollReportDistributionProvider);
    final auditPackReview = ref.watch(payrollAuditPackReviewProvider);
    final auditPackFindings = ref.watch(auditPackFindingsProvider);
    final auditOwnerWorklist = ref.watch(auditOwnerWorklistProvider);
    final auditCloseSignoff = ref.watch(auditCloseSignoffProvider);
    final auditCloseAttestation = ref.watch(auditCloseAttestationProvider);
    final auditHandoffPackage = ref.watch(auditHandoffPackageProvider);
    final auditHandoffDelivery = ref.watch(auditHandoffDeliveryProvider);
    final auditReviewerReceipt = ref.watch(auditReviewerReceiptProvider);
    final adjustmentDraft = ref.watch(payrollAdjustmentDraftProvider);
    final adjustments = ref.watch(payrollAdjustmentsProvider);
    final exceptions = ref.watch(payrollExceptionsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Payroll Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Payroll calendar',
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payroll calendar opened')),
              );
            },
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${runDashboard.openExceptionCount} payroll alerts need review',
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            PayrollPeriodSelector(
              periods: periods,
              selectedPeriod: selectedPeriod,
              onPeriodChanged:
                  (periodId) => _selectPayrollPeriod(ref, periodId),
            ),
            Expanded(
              child: PayrollWorkspaceTabs(
                tabs: [
                  PayrollWorkspaceTabSpec(
                    label: 'Overview',
                    icon: Icons.insights_outlined,
                    child: PayrollWorkspaceSection(
                      children: [
                        PayrollRunDashboardPanel(dashboard: runDashboard),
                        PayrollOperationsCenterPanel(summary: operationsCenter),
                        PayrollActiveRunPlanPanel(summary: activeRunPlan),
                        PayrollRunBuilderPanel(
                          draft: runBuilderDraft,
                          preview: runBuilderPreview,
                          requests: runBuildRequests,
                          onLabelChanged:
                              ref
                                  .read(payrollRunBuilderDraftProvider.notifier)
                                  .setLabel,
                          onSelectPeriodStart:
                              () => _selectRunBuilderDate(
                                context,
                                ref,
                                _RunBuilderDateField.periodStart,
                              ),
                          onSelectPeriodEnd:
                              () => _selectRunBuilderDate(
                                context,
                                ref,
                                _RunBuilderDateField.periodEnd,
                              ),
                          onSelectPayDate:
                              () => _selectRunBuilderDate(
                                context,
                                ref,
                                _RunBuilderDateField.payDate,
                              ),
                          onScopeChanged:
                              ref
                                  .read(payrollRunBuilderDraftProvider.notifier)
                                  .setScope,
                          onNotesChanged:
                              ref
                                  .read(payrollRunBuilderDraftProvider.notifier)
                                  .setNotes,
                          onSubmit: () => _submitRunBuilder(context, ref),
                          onReset: () => _resetRunBuilder(ref),
                          onApproveRequest:
                              (requestId) => _approveRunBuildRequest(
                                context,
                                ref,
                                requestId,
                              ),
                          onActivateRequest:
                              (requestId) => _activateRunBuildRequest(
                                context,
                                ref,
                                requestId,
                              ),
                          onReopenRequest:
                              (requestId) => _reopenRunBuildRequest(
                                context,
                                ref,
                                requestId,
                              ),
                        ),
                        PayrollAnalyticsPanel(summary: analytics),
                        PayrollRunComparisonPanel(summary: runComparison),
                        PayrollCostCenterPanel(summary: costCenters),
                        PayrollEmployerCostPanel(summary: employerCost),
                        PayrollCostCenterBudgetPanel(
                          summary: costCenterBudgets,
                          onApproveCostCenter:
                              (costCenterId) => _approveCostCenterBudget(
                                context,
                                ref,
                                costCenterId,
                              ),
                          onReopenCostCenter:
                              (costCenterId) => _reopenCostCenterBudget(
                                context,
                                ref,
                                costCenterId,
                              ),
                        ),
                        PayrollCostCenterReportPanel(
                          summary: costCenterReport,
                          onExportReport:
                              () => _exportCostCenterReport(context, ref),
                          onReopenReport:
                              () => _reopenCostCenterReport(context, ref),
                        ),
                        PayrollRiskRegisterPanel(summary: riskRegister),
                      ],
                    ),
                  ),
                  PayrollWorkspaceTabSpec(
                    label: 'Close',
                    icon: Icons.fact_check_outlined,
                    child: PayrollWorkspaceSection(
                      children: [
                        PayrollReconciliationPanel(
                          summary: reconciliation,
                          onMarkReviewed:
                              () => _markReconciliationReviewed(context, ref),
                          onReopenReview:
                              () => _reopenReconciliationReview(context, ref),
                        ),
                        PayrollApprovalWorkflowPanel(
                          summary: approvalWorkflow,
                          onApproveStage:
                              (stageId) =>
                                  _approvePayrollStage(context, ref, stageId),
                          onReopenStage:
                              (stageId) =>
                                  _reopenPayrollStage(context, ref, stageId),
                        ),
                        PayrollApprovalDelegationPanel(
                          summary: approvalDelegation,
                        ),
                        PayrollVarianceReportPanel(
                          summary: varianceReport,
                          onExportReport:
                              () => _exportVarianceReport(context, ref),
                          onReopenReport:
                              () => _reopenVarianceReport(context, ref),
                        ),
                        PayrollVarianceDrilldownPanel(
                          summary: varianceDrilldown,
                        ),
                        PayrollFundingForecastPanel(summary: fundingForecast),
                        PayrollRunClosePanel(
                          plan: closePlan,
                          onCompleteStep:
                              (stepId) =>
                                  _completeCloseStep(context, ref, stepId),
                          onReopenStep:
                              (stepId) =>
                                  _reopenCloseStep(context, ref, stepId),
                        ),
                      ],
                    ),
                  ),
                  PayrollWorkspaceTabSpec(
                    label: 'Payments',
                    icon: Icons.payments_outlined,
                    child: PayrollWorkspaceSection(
                      children: [
                        PayrollFundingAuthorizationPanel(
                          summary: fundingAuthorization,
                          draft: fundingAuthorizationDraft,
                          onSelectAccount:
                              (accountLabel) =>
                                  _selectFundingAuthorizationAccount(
                                    context,
                                    ref,
                                    accountLabel,
                                  ),
                          onAuthorizedByChanged:
                              ref
                                  .read(
                                    payrollFundingAuthorizationDraftProvider
                                        .notifier,
                                  )
                                  .setAuthorizedBy,
                          onReferenceCodeChanged:
                              ref
                                  .read(
                                    payrollFundingAuthorizationDraftProvider
                                        .notifier,
                                  )
                                  .setReferenceCode,
                          onNotesChanged:
                              ref
                                  .read(
                                    payrollFundingAuthorizationDraftProvider
                                        .notifier,
                                  )
                                  .setNotes,
                          onSubmitAuthorization:
                              () => _authorizeFundingAccount(context, ref),
                          onCancelAuthorization:
                              ref
                                  .read(
                                    payrollFundingAuthorizationDraftProvider
                                        .notifier,
                                  )
                                  .clear,
                          onReopenAccount:
                              (accountLabel) => _reopenFundingAccount(
                                context,
                                ref,
                                accountLabel,
                              ),
                        ),
                        PayrollBankTransferFilePanel(
                          summary: bankTransferFile,
                          onExportFile:
                              () => _exportBankTransferFile(context, ref),
                          onReopenFile:
                              () => _reopenBankTransferFile(context, ref),
                        ),
                        PayrollPaymentBatchPanel(
                          batch: paymentBatch,
                          onReleaseBatch:
                              () => _releasePaymentBatch(context, ref),
                        ),
                        PayrollPayslipPackagePanel(
                          summary: payslipPackage,
                          onPublishPayslips:
                              () => _publishPayslips(context, ref),
                          onReopenPublishing:
                              () => _reopenPayslipPublishing(context, ref),
                        ),
                        PayrollPayslipTemplatePanel(summary: payslipTemplate),
                        PayrollPayslipDistributionPanel(
                          summary: payslipDistribution,
                          onDispatchStatements:
                              () => _dispatchPayslipStatements(context, ref),
                          onResetDelivery:
                              () => _resetPayslipDelivery(context, ref),
                        ),
                        PayrollPayslipDetailPanel(detail: payslipDetail),
                        PayrollLiabilityPanel(
                          summary: liabilities,
                          onRemitLiabilities:
                              () => _remitLiabilities(context, ref),
                          onReopenRemittance:
                              () => _reopenLiabilityRemittance(context, ref),
                        ),
                        PayrollGlMappingPanel(summary: glMapping),
                        PayrollJournalPostingPanel(
                          summary: journalPosting,
                          onPostJournal:
                              () => _postPayrollJournal(context, ref),
                          onReopenPosting:
                              () => _reopenJournalPosting(context, ref),
                        ),
                        PayrollRegisterReportPanel(
                          summary: registerReport,
                          onExportReport:
                              () => _exportRegisterReport(context, ref),
                          onReopenReport:
                              () => _reopenRegisterReport(context, ref),
                        ),
                      ],
                    ),
                  ),
                  PayrollWorkspaceTabSpec(
                    label: 'Compliance',
                    icon: Icons.policy_outlined,
                    child: PayrollWorkspaceSection(
                      children: [
                        PayrollConfigurationPanel(summary: configuration),
                        PayrollCutoffCalendarPanel(summary: cutoffCalendar),
                        PayrollComplianceCalendarPanel(
                          summary: complianceCalendar,
                        ),
                        PayrollStatutoryReportPanel(
                          summary: statutoryReport,
                          onExportPack:
                              () => _exportStatutoryReport(context, ref),
                          onReopenPack:
                              () => _reopenStatutoryReport(context, ref),
                        ),
                        PayrollEvidenceCenterPanel(summary: evidenceCenter),
                        PayrollArchivePackagePanel(
                          summary: archivePackage,
                          onArchivePackage:
                              () => _archiveRunPackage(context, ref),
                          onReopenArchive:
                              () => _reopenRunArchive(context, ref),
                        ),
                        PayrollControlReviewPanel(
                          summary: controlReview,
                          onReviewControls:
                              () => _reviewPayrollControls(context, ref),
                          onReopenReview:
                              () => _reopenControlReview(context, ref),
                        ),
                      ],
                    ),
                  ),
                  PayrollWorkspaceTabSpec(
                    label: 'Audit',
                    icon: Icons.history_outlined,
                    child: PayrollWorkspaceSection(
                      children: [
                        PayrollReportsHubPanel(summary: reportsHub),
                        PayrollReportDistributionPanel(
                          summary: reportDistribution,
                          onDeliverReady:
                              () => _deliverReadyReports(context, ref),
                          onReopenReport:
                              (reportId) =>
                                  _reopenReportDelivery(context, ref, reportId),
                        ),
                        PayrollControlsEvidenceMatrixPanel(
                          summary: controlsEvidenceMatrix,
                        ),
                        AuditCloseSignoffPanel(summary: auditCloseSignoff),
                        AuditCloseAttestationPanel(
                          summary: auditCloseAttestation,
                          onSignedByChanged:
                              ref
                                  .read(
                                    auditCloseAttestationDraftProvider.notifier,
                                  )
                                  .setSignedBy,
                          onRoleChanged:
                              ref
                                  .read(
                                    auditCloseAttestationDraftProvider.notifier,
                                  )
                                  .setRole,
                          onNoteChanged:
                              ref
                                  .read(
                                    auditCloseAttestationDraftProvider.notifier,
                                  )
                                  .setNote,
                          onSubmit: () => _signAuditClose(context, ref),
                          onReopen:
                              () => _reopenAuditCloseAttestation(context, ref),
                        ),
                        AuditHandoffPackagePanel(summary: auditHandoffPackage),
                        AuditHandoffDeliveryPanel(
                          summary: auditHandoffDelivery,
                          onRoutedByChanged:
                              ref
                                  .read(
                                    auditHandoffDeliveryDraftProvider.notifier,
                                  )
                                  .setRoutedBy,
                          onChannelChanged:
                              ref
                                  .read(
                                    auditHandoffDeliveryDraftProvider.notifier,
                                  )
                                  .setChannel,
                          onNoteChanged:
                              ref
                                  .read(
                                    auditHandoffDeliveryDraftProvider.notifier,
                                  )
                                  .setNote,
                          onSubmit: () => _routeAuditHandoff(context, ref),
                          onReopen:
                              () => _reopenAuditHandoffDelivery(context, ref),
                        ),
                        AuditReviewerReceiptPanel(
                          summary: auditReviewerReceipt,
                          onReviewerChanged:
                              ref
                                  .read(
                                    auditReviewerReceiptDraftProvider.notifier,
                                  )
                                  .setReviewer,
                          onReviewerRoleChanged:
                              ref
                                  .read(
                                    auditReviewerReceiptDraftProvider.notifier,
                                  )
                                  .setReviewerRole,
                          onDecisionChanged:
                              ref
                                  .read(
                                    auditReviewerReceiptDraftProvider.notifier,
                                  )
                                  .setDecision,
                          onNoteChanged:
                              ref
                                  .read(
                                    auditReviewerReceiptDraftProvider.notifier,
                                  )
                                  .setNote,
                          onSubmit:
                              () => _recordAuditReviewerReceipt(context, ref),
                          onReopen:
                              () => _reopenAuditReviewerReceipt(context, ref),
                        ),
                        PayrollAuditPackReviewPanel(summary: auditPackReview),
                        AuditOwnerWorklistPanel(summary: auditOwnerWorklist),
                        AuditPackFindingsPanel(
                          summary: auditPackFindings,
                          onRemediateFinding:
                              (findingId) => _remediateAuditPackFinding(
                                context,
                                ref,
                                findingId,
                              ),
                          onCloseFinding:
                              (findingId) => _closeAuditPackFinding(
                                context,
                                ref,
                                findingId,
                              ),
                          onReopenFinding:
                              (findingId) => _reopenAuditPackFinding(
                                context,
                                ref,
                                findingId,
                              ),
                        ),
                        PayrollAuditTrailPanel(summary: auditTrail),
                      ],
                    ),
                  ),
                  PayrollWorkspaceTabSpec(
                    label: 'Employees',
                    icon: Icons.groups_outlined,
                    child: PayrollWorkspaceSection(
                      children: [
                        PayrollExceptionResolutionPanel(
                          summary: exceptionResolution,
                        ),
                        PayrollExceptionSlaPanel(summary: exceptionSla),
                        PayrollDataImportPanel(
                          draft: dataImportDraft,
                          preview: dataImportPreview,
                          batches: dataImportBatches,
                          onTypeChanged:
                              ref
                                  .read(payrollDataImportDraftProvider.notifier)
                                  .setType,
                          onSourceLabelChanged:
                              ref
                                  .read(payrollDataImportDraftProvider.notifier)
                                  .setSourceLabel,
                          onCsvTextChanged:
                              ref
                                  .read(payrollDataImportDraftProvider.notifier)
                                  .setCsvText,
                          onLoadSample:
                              ref
                                  .read(payrollDataImportDraftProvider.notifier)
                                  .loadSample,
                          onApplyPreview:
                              () => _applyPayrollDataImport(context, ref),
                          onClear:
                              ref
                                  .read(payrollDataImportDraftProvider.notifier)
                                  .clear,
                          onRemoveBatch:
                              (batchId) => _removePayrollDataImport(
                                context,
                                ref,
                                batchId,
                              ),
                        ),
                        PayrollInputChangePanel(
                          summary: inputChanges,
                          onApproveReady:
                              () => _approvePayrollInputChanges(context, ref),
                          onApplyApproved:
                              () => _applyPayrollInputChanges(context, ref),
                          onReopen: () => _reopenPayrollInputChanges(ref),
                        ),
                        PayrollAttendanceBridgePanel(
                          summary: attendanceBridge,
                          onApproveReady:
                              () => _approveAttendanceBridge(context, ref),
                          onApplyApproved:
                              () => _applyAttendanceBridge(context, ref),
                          onReopen: () => _reopenAttendanceBridge(ref),
                        ),
                        PayrollLoanRepaymentPanel(
                          summary: loanRepayments,
                          onApplyReady:
                              () => _applyLoanRepayments(context, ref),
                          onReopen: () => _reopenLoanRepayments(ref),
                        ),
                        PayrollSimulationPanel(
                          summary: simulation,
                          onReview:
                              () => _reviewPayrollSimulation(context, ref),
                          onApply: () => _applyPayrollSimulation(context, ref),
                          onReopen: () => _reopenPayrollSimulation(ref),
                        ),
                        PayrollScenarioLibraryPanel(
                          summary: scenarioLibrary,
                          simulation: simulation,
                          onLabelChanged:
                              (value) =>
                                  ref
                                      .read(
                                        payrollScenarioDraftLabelProvider
                                            .notifier,
                                      )
                                      .state = value,
                          onNotesChanged:
                              (value) =>
                                  ref
                                      .read(
                                        payrollScenarioDraftNotesProvider
                                            .notifier,
                                      )
                                      .state = value,
                          onSaveScenario:
                              () => _savePayrollScenario(context, ref),
                          onApproveScenario:
                              (scenarioId) => _approvePayrollScenario(
                                context,
                                ref,
                                scenarioId,
                              ),
                          onConvertScenario:
                              (scenarioId) => _convertPayrollScenario(
                                context,
                                ref,
                                scenarioId,
                              ),
                          onRemoveScenario:
                              (scenarioId) => _removePayrollScenario(
                                context,
                                ref,
                                scenarioId,
                              ),
                        ),
                        PayrollOffCycleRunPanel(
                          draft: offCycleDraft,
                          summary: offCycleRuns,
                          employees: employees,
                          onEmployeeChanged:
                              ref
                                  .read(
                                    payrollOffCycleRunDraftProvider.notifier,
                                  )
                                  .setEmployeeId,
                          onTypeChanged:
                              ref
                                  .read(
                                    payrollOffCycleRunDraftProvider.notifier,
                                  )
                                  .setType,
                          onGrossAmountChanged:
                              ref
                                  .read(
                                    payrollOffCycleRunDraftProvider.notifier,
                                  )
                                  .setGrossAmount,
                          onSelectPayDate:
                              () => _selectOffCyclePayDate(context, ref),
                          onReasonChanged:
                              ref
                                  .read(
                                    payrollOffCycleRunDraftProvider.notifier,
                                  )
                                  .setReason,
                          onEvidenceReferenceChanged:
                              ref
                                  .read(
                                    payrollOffCycleRunDraftProvider.notifier,
                                  )
                                  .setEvidenceReference,
                          onGrossUpChanged:
                              ref
                                  .read(
                                    payrollOffCycleRunDraftProvider.notifier,
                                  )
                                  .setGrossUp,
                          onSubmit: () => _submitOffCycleRun(context, ref),
                          onClear:
                              ref
                                  .read(
                                    payrollOffCycleRunDraftProvider.notifier,
                                  )
                                  .clear,
                          onApprove:
                              (requestId) =>
                                  _approveOffCycleRun(context, ref, requestId),
                          onReject:
                              (requestId) =>
                                  _rejectOffCycleRun(context, ref, requestId),
                          onRelease:
                              (requestId) =>
                                  _releaseOffCycleRun(context, ref, requestId),
                          onReopen:
                              (requestId) =>
                                  _reopenOffCycleRun(context, ref, requestId),
                        ),
                        HrisResponsivePanelGrid(
                          breakpoint: 940,
                          panels: [
                            PayrollAdjustmentFormPanel(
                              draft: adjustmentDraft,
                              employees: employees,
                              onEmployeeChanged:
                                  ref
                                      .read(
                                        payrollAdjustmentDraftProvider.notifier,
                                      )
                                      .setEmployeeId,
                              onTypeChanged:
                                  ref
                                      .read(
                                        payrollAdjustmentDraftProvider.notifier,
                                      )
                                      .setType,
                              onAmountChanged:
                                  ref
                                      .read(
                                        payrollAdjustmentDraftProvider.notifier,
                                      )
                                      .setAmount,
                              onSelectEffectiveDate:
                                  () => _selectAdjustmentDate(context, ref),
                              onCostCenterChanged:
                                  ref
                                      .read(
                                        payrollAdjustmentDraftProvider.notifier,
                                      )
                                      .setCostCenter,
                              onReasonChanged:
                                  ref
                                      .read(
                                        payrollAdjustmentDraftProvider.notifier,
                                      )
                                      .setReason,
                              onSubmit: () => _submitAdjustment(context, ref),
                              onClear:
                                  ref
                                      .read(
                                        payrollAdjustmentDraftProvider.notifier,
                                      )
                                      .clear,
                            ),
                            PayrollApprovalQueuePanel(
                              adjustments: adjustments,
                              exceptions: exceptions,
                              onApproveAdjustment:
                                  ref
                                      .read(payrollAdjustmentsProvider.notifier)
                                      .approve,
                              onRejectAdjustment:
                                  ref
                                      .read(payrollAdjustmentsProvider.notifier)
                                      .reject,
                              onResolveException:
                                  ref
                                      .read(payrollExceptionsProvider.notifier)
                                      .resolve,
                              onReopenException:
                                  ref
                                      .read(payrollExceptionsProvider.notifier)
                                      .reopen,
                            ),
                          ],
                        ),
                        PayrollSummaryPanel(summary: summary),
                        PayrollEmployeeSelector(
                          employees: employees,
                          selectedEmployee: selectedEmployee,
                          paymentStatus: paymentStatus,
                          onSelected: (employee) {
                            ref.read(selectedEmployeeProvider3.notifier).state =
                                employee;
                            ref
                                .read(
                                  selectedPayrollPayslipEmployeeIdProvider
                                      .notifier,
                                )
                                .state = employee.id;
                          },
                        ),
                        PayrollEmployeeProfilePanel(summary: employeeProfiles),
                        PayrollEmployeeLedgerPanel(summary: employeeLedger),
                        PayrollDisputeCenterPanel(
                          summary: disputeSummary,
                          employees: employees,
                          onEmployeeChanged:
                              ref
                                  .read(payrollDisputeDraftProvider.notifier)
                                  .setEmployeeId,
                          onTypeChanged:
                              ref
                                  .read(payrollDisputeDraftProvider.notifier)
                                  .setType,
                          onClaimAmountChanged:
                              ref
                                  .read(payrollDisputeDraftProvider.notifier)
                                  .setClaimAmount,
                          onEvidenceReferenceChanged:
                              ref
                                  .read(payrollDisputeDraftProvider.notifier)
                                  .setEvidenceReference,
                          onDescriptionChanged:
                              ref
                                  .read(payrollDisputeDraftProvider.notifier)
                                  .setDescription,
                          onSubmit: () => _submitPayrollDispute(context, ref),
                          onClear:
                              ref
                                  .read(payrollDisputeDraftProvider.notifier)
                                  .clear,
                          onStartReview:
                              (caseId) => _startPayrollDisputeReview(
                                context,
                                ref,
                                caseId,
                              ),
                          onApproveCorrection:
                              (caseId) => _approvePayrollDisputeCorrection(
                                context,
                                ref,
                                caseId,
                              ),
                          onReject:
                              (caseId) =>
                                  _rejectPayrollDispute(context, ref, caseId),
                          onClose:
                              (caseId) =>
                                  _closePayrollDispute(context, ref, caseId),
                        ),
                        PayrollDeductionAuthorizationPanel(
                          summary: deductionAuthorizations,
                          onApproveReady:
                              () =>
                                  _approveDeductionAuthorizations(context, ref),
                          onReopenApprovals:
                              () =>
                                  _reopenDeductionAuthorizations(context, ref),
                        ),
                        PayrollDetailPanel(
                          employee: selectedEmployee,
                          details: payrollDetails,
                          isPaid:
                              selectedEmployee == null
                                  ? false
                                  : paymentStatus[selectedEmployee.id] ?? false,
                          onProcessPayment:
                              selectedEmployee == null
                                  ? null
                                  : () => _processPayment(
                                    context: context,
                                    ref: ref,
                                    employeeId: selectedEmployee.id,
                                    employeeName: selectedEmployee.name,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPayrollPeriod(WidgetRef ref, String periodId) {
    ref.read(selectedPayrollRunPeriodIdProvider.notifier).state = periodId;
    _resetRunBuilder(ref);
    ref.read(selectedEmployeeProvider3.notifier).state = null;
    ref.read(selectedPayrollPayslipEmployeeIdProvider.notifier).state = null;
    ref.read(payrollAdjustmentDraftProvider.notifier).clear();
    ref.read(payrollFundingAuthorizationDraftProvider.notifier).clear();
    ref.read(payrollApprovedInputChangeIdsProvider.notifier).state = <String>{};
    ref.read(payrollAppliedInputChangeIdsProvider.notifier).state = <String>{};
    ref.read(payrollDataImportDraftProvider.notifier).clear();
    ref.read(payrollDataImportBatchesProvider.notifier).clear();
    ref.read(payrollScenarioRecordsProvider.notifier).clear();
    ref.read(payrollScenarioDraftLabelProvider.notifier).state =
        'Payroll optimization scenario';
    ref.read(payrollScenarioDraftNotesProvider.notifier).state =
        'Review projected payroll impact before conversion.';
    ref.read(payrollDisputeDraftProvider.notifier).clear();
    ref.read(payrollDisputeCasesProvider.notifier).clear();
    ref.read(payrollApprovedAttendanceSignalIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollAppliedAttendanceSignalIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollAppliedLoanRepaymentIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollSimulationReviewedProvider.notifier).state = false;
    ref.read(payrollSimulationAppliedProvider.notifier).state = false;
    ref.read(payrollApprovedDeductionAuthorizationIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollReconciliationReviewSignatureProvider.notifier).state =
        null;
    ref.read(payrollRunCloseProgressProvider.notifier).reset();
    ref.read(paymentStatusProvider.notifier).state = {
      for (final employee in ref.read(employeesProvider2)) employee.id: false,
    };
    ref.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state =
        <int>{};
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state =
        <int, PayrollPayslipDeliveryReceipt>{};
    ref.read(payrollFundingAuthorizationRecordsProvider.notifier).state =
        <String, PayrollFundingAuthorizationRecord>{};
    ref.read(payrollApprovalRecordsProvider.notifier).state =
        <String, PayrollApprovalRecord>{};
    ref.read(payrollRemittedLiabilityIdsProvider.notifier).state = <String>{};
    ref.read(payrollPostedJournalIdsProvider.notifier).state = <String>{};
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    _clearPayrollExports(ref);
    ref.read(payrollApprovedCostCenterBudgetIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollFundingAuthorizationRecordsProvider.notifier).state =
        <String, PayrollFundingAuthorizationRecord>{};
    ref.read(payrollApprovalRecordsProvider.notifier).state =
        <String, PayrollApprovalRecord>{};
  }

  void _processPayment({
    required BuildContext context,
    required WidgetRef ref,
    required int employeeId,
    required String employeeName,
  }) {
    final updatedStatus = Map<int, bool>.from(ref.read(paymentStatusProvider));
    updatedStatus[employeeId] = true;
    ref.read(paymentStatusProvider.notifier).state = updatedStatus;

    _showMessage(context, 'Payment to $employeeName processed');
  }

  Future<void> _selectRunBuilderDate(
    BuildContext context,
    WidgetRef ref,
    _RunBuilderDateField field,
  ) async {
    final draft = ref.read(payrollRunBuilderDraftProvider);
    final initialDate = switch (field) {
      _RunBuilderDateField.periodStart => draft.periodStart,
      _RunBuilderDateField.periodEnd => draft.periodEnd,
      _RunBuilderDateField.payDate => draft.payDate,
    };
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 1),
      lastDate: DateTime(initialDate.year + 2),
    );
    if (picked == null) return;
    final notifier = ref.read(payrollRunBuilderDraftProvider.notifier);
    switch (field) {
      case _RunBuilderDateField.periodStart:
        notifier.setPeriodStart(picked);
        return;
      case _RunBuilderDateField.periodEnd:
        notifier.setPeriodEnd(picked);
        return;
      case _RunBuilderDateField.payDate:
        notifier.setPayDate(picked);
        return;
    }
  }

  Future<void> _selectOffCyclePayDate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final draft = ref.read(payrollOffCycleRunDraftProvider);
    final initialDate =
        draft.payDate ??
        ref.read(payrollAsOfDateProvider).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: ref.read(payrollAsOfDateProvider),
      lastDate: initialDate.add(const Duration(days: 90)),
    );
    if (picked == null) return;
    ref.read(payrollOffCycleRunDraftProvider.notifier).setPayDate(picked);
  }

  void _submitOffCycleRun(BuildContext context, WidgetRef ref) {
    final draft = ref.read(payrollOffCycleRunDraftProvider);
    if (!draft.isReadyToSubmit) {
      _showMessage(context, draft.validationErrors.first);
      return;
    }

    try {
      final request = ref
          .read(payrollOffCycleRunRequestsProvider.notifier)
          .submit(draft: draft, employees: ref.read(employeesProvider2));
      ref.read(payrollOffCycleRunDraftProvider.notifier).clear();
      _showMessage(
        context,
        '${request.id} submitted for ${request.employeeName}',
      );
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _applyPayrollDataImport(BuildContext context, WidgetRef ref) {
    final preview = ref.read(payrollDataImportPreviewProvider);
    if (!preview.canImport) {
      _showMessage(context, preview.nextAction);
      return;
    }

    try {
      final batch = ref
          .read(payrollDataImportBatchesProvider.notifier)
          .applyPreview(preview);
      ref.read(payrollDataImportDraftProvider.notifier).clear();
      _showMessage(context, '${batch.id} imported ${batch.validCount} rows');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _removePayrollDataImport(
    BuildContext context,
    WidgetRef ref,
    String batchId,
  ) {
    ref.read(payrollDataImportBatchesProvider.notifier).remove(batchId);
    ref.read(payrollApprovedInputChangeIdsProvider.notifier).state = {
      ...ref.read(payrollApprovedInputChangeIdsProvider),
    }..removeWhere((id) => id.startsWith('$batchId-'));
    ref.read(payrollAppliedInputChangeIdsProvider.notifier).state = {
      ...ref.read(payrollAppliedInputChangeIdsProvider),
    }..removeWhere((id) => id.startsWith('$batchId-'));
    _showMessage(context, '$batchId import removed');
  }

  void _savePayrollScenario(BuildContext context, WidgetRef ref) {
    final simulation = ref.read(payrollSimulationProvider);
    try {
      final scenario = ref
          .read(payrollScenarioRecordsProvider.notifier)
          .save(
            simulation: simulation,
            label: ref.read(payrollScenarioDraftLabelProvider),
            notes: ref.read(payrollScenarioDraftNotesProvider),
            createdAt: ref.read(payrollAsOfDateProvider),
          );
      _showMessage(context, '${scenario.id} saved for review');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _approvePayrollScenario(
    BuildContext context,
    WidgetRef ref,
    String scenarioId,
  ) {
    try {
      ref.read(payrollScenarioRecordsProvider.notifier).approve(scenarioId);
      _showMessage(context, '$scenarioId approved');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _convertPayrollScenario(
    BuildContext context,
    WidgetRef ref,
    String scenarioId,
  ) {
    try {
      ref.read(payrollScenarioRecordsProvider.notifier).convert(scenarioId);
      _showMessage(context, '$scenarioId converted into payroll inputs');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _removePayrollScenario(
    BuildContext context,
    WidgetRef ref,
    String scenarioId,
  ) {
    ref.read(payrollScenarioRecordsProvider.notifier).remove(scenarioId);
    ref.read(payrollApprovedInputChangeIdsProvider.notifier).state = {
      ...ref.read(payrollApprovedInputChangeIdsProvider),
    }..removeWhere((id) => id.startsWith('$scenarioId-'));
    ref.read(payrollAppliedInputChangeIdsProvider.notifier).state = {
      ...ref.read(payrollAppliedInputChangeIdsProvider),
    }..removeWhere((id) => id.startsWith('$scenarioId-'));
    _showMessage(context, '$scenarioId removed');
  }

  void _submitPayrollDispute(BuildContext context, WidgetRef ref) {
    final draft = ref.read(payrollDisputeDraftProvider);
    if (!draft.isReadyToSubmit) {
      _showMessage(context, draft.validationErrors.first);
      return;
    }

    try {
      final dispute = ref
          .read(payrollDisputeCasesProvider.notifier)
          .submit(draft: draft, employees: ref.read(employeesProvider2));
      ref.read(payrollDisputeDraftProvider.notifier).clear();
      _showMessage(context, '${dispute.id} submitted for payroll review');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _startPayrollDisputeReview(
    BuildContext context,
    WidgetRef ref,
    String caseId,
  ) {
    try {
      ref.read(payrollDisputeCasesProvider.notifier).startReview(caseId);
      _showMessage(context, '$caseId moved into review');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _approvePayrollDisputeCorrection(
    BuildContext context,
    WidgetRef ref,
    String caseId,
  ) {
    try {
      ref.read(payrollDisputeCasesProvider.notifier).approveCorrection(caseId);
      _showMessage(context, '$caseId correction approved');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _rejectPayrollDispute(
    BuildContext context,
    WidgetRef ref,
    String caseId,
  ) {
    try {
      ref.read(payrollDisputeCasesProvider.notifier).reject(caseId);
      _showMessage(context, '$caseId rejected');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _closePayrollDispute(
    BuildContext context,
    WidgetRef ref,
    String caseId,
  ) {
    try {
      ref.read(payrollDisputeCasesProvider.notifier).close(caseId);
      _showMessage(context, '$caseId closed');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _approveOffCycleRun(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    try {
      ref.read(payrollOffCycleRunRequestsProvider.notifier).approve(requestId);
      _showMessage(context, '$requestId approved for off-cycle release');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _rejectOffCycleRun(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    try {
      ref.read(payrollOffCycleRunRequestsProvider.notifier).reject(requestId);
      _showMessage(context, '$requestId rejected');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _releaseOffCycleRun(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    try {
      ref.read(payrollOffCycleRunRequestsProvider.notifier).release(requestId);
      _showMessage(context, '$requestId released');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _reopenOffCycleRun(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    try {
      ref.read(payrollOffCycleRunRequestsProvider.notifier).reopen(requestId);
      _showMessage(context, '$requestId reopened');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitRunBuilder(BuildContext context, WidgetRef ref) {
    final preview = ref.read(payrollRunBuilderPreviewProvider);
    if (!preview.canCreateRun) {
      _showMessage(context, preview.nextAction);
      return;
    }
    try {
      final request = ref
          .read(payrollRunBuildRequestsProvider.notifier)
          .submitPreview(preview);
      _showMessage(context, '${request.id} created for ${request.label}');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _approveRunBuildRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    try {
      ref.read(payrollRunBuildRequestsProvider.notifier).approve(requestId);
      _showMessage(context, '$requestId approved for activation');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _activateRunBuildRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    try {
      ref.read(payrollRunBuildRequestsProvider.notifier).activate(requestId);
      _showMessage(context, '$requestId activated');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _reopenRunBuildRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    try {
      ref.read(payrollRunBuildRequestsProvider.notifier).reopen(requestId);
      _showMessage(context, '$requestId reopened');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _resetRunBuilder(WidgetRef ref) {
    ref
        .read(payrollRunBuilderDraftProvider.notifier)
        .reset(ref.read(selectedPayrollRunPeriodProvider));
  }

  void _completeCloseStep(BuildContext context, WidgetRef ref, String stepId) {
    switch (stepId) {
      case 'review-reconciliation':
        _markReconciliationReviewed(context, ref);
        return;
      case 'lock-payroll':
        ref.read(payrollRunCloseProgressProvider.notifier).complete(stepId);
        _showMessage(context, 'Payroll run locked');
        return;
      case 'disburse-payments':
        _releasePaymentBatch(context, ref);
        return;
      case 'publish-payslips':
        _publishPayslips(context, ref);
        return;
      case 'remit-liabilities':
        _remitLiabilities(context, ref);
        return;
      case 'post-journal':
        _postPayrollJournal(context, ref);
        return;
      case 'archive-run':
        _archiveRunPackage(context, ref);
        return;
      case 'review-controls':
        _reviewPayrollControls(context, ref);
        return;
      case 'close-period':
        ref.read(payrollRunCloseProgressProvider.notifier).complete(stepId);
        _showMessage(context, 'Payroll period closed');
        return;
      default:
        ref.read(payrollRunCloseProgressProvider.notifier).complete(stepId);
        _showMessage(context, 'Payroll close step completed');
    }
  }

  void _reopenCloseStep(BuildContext context, WidgetRef ref, String stepId) {
    if (stepId == 'review-reconciliation') {
      _reopenReconciliationReview(context, ref);
      return;
    }
    if (stepId == 'publish-payslips') {
      _reopenPayslipPublishing(context, ref);
      return;
    }
    if (stepId == 'remit-liabilities') {
      _reopenLiabilityRemittance(context, ref);
      return;
    }
    if (stepId == 'post-journal') {
      _reopenJournalPosting(context, ref);
      return;
    }
    if (stepId == 'archive-run') {
      _reopenRunArchive(context, ref);
      return;
    }
    if (stepId == 'review-controls') {
      _reopenControlReview(context, ref);
      return;
    }
    if (stepId == 'lock-payroll') {
      ref.read(payrollRunCloseProgressProvider.notifier).reopen(stepId);
      ref.read(payrollFundingAuthorizationRecordsProvider.notifier).state =
          <String, PayrollFundingAuthorizationRecord>{};
      _clearPayrollApprovals(ref);
      ref.read(paymentStatusProvider.notifier).state = {
        for (final employee in ref.read(employeesProvider2)) employee.id: false,
      };
      _reopenPayslipPublishing(context, ref, showMessage: false);
      _showMessage(context, 'Payroll close step reopened');
      return;
    }

    ref.read(payrollRunCloseProgressProvider.notifier).reopen(stepId);
    _showMessage(context, 'Payroll close step reopened');
  }

  void _markReconciliationReviewed(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.read(payrollReconciliationSummaryProvider);
    ref.read(payrollReconciliationReviewSignatureProvider.notifier).state =
        reconciliation.reviewSignature;
    _showMessage(context, 'Payroll reconciliation reviewed');
  }

  void _exportVarianceReport(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollVarianceReportProvider);
    if (!summary.canExport) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollExportedVarianceReportIdsProvider.notifier).state = {
      ...ref.read(payrollExportedVarianceReportIdsProvider),
      summary.reportId,
    };

    _showMessage(context, '${summary.reportId} exported for finance review');
  }

  void _reopenVarianceReport(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollVarianceReportProvider);
    ref.read(payrollExportedVarianceReportIdsProvider.notifier).state = {
      ...ref.read(payrollExportedVarianceReportIdsProvider),
    }..remove(summary.reportId);
    _showMessage(context, '${summary.reportId} export reopened');
  }

  void _reopenReconciliationReview(BuildContext context, WidgetRef ref) {
    ref.read(payrollReconciliationReviewSignatureProvider.notifier).state =
        null;
    ref.read(payrollExportedVarianceReportIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state =
        <int>{};
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state =
        <int, PayrollPayslipDeliveryReceipt>{};
    ref.read(payrollRemittedLiabilityIdsProvider.notifier).state = <String>{};
    ref.read(payrollPostedJournalIdsProvider.notifier).state = <String>{};
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    _clearPayrollApprovals(ref);
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('lock-payroll');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('publish-payslips');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('remit-liabilities');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('post-journal');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('archive-run');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    _showMessage(context, 'Payroll reconciliation reopened');
  }

  void _releasePaymentBatch(BuildContext context, WidgetRef ref) {
    final batch = ref.read(payrollPaymentBatchProvider);
    if (!batch.canRelease) {
      _showMessage(context, batch.nextAction);
      return;
    }
    final approvalWorkflow = ref.read(payrollApprovalWorkflowProvider);
    if (!approvalWorkflow.canReleasePayments) {
      _showMessage(context, approvalWorkflow.nextAction);
      return;
    }
    final fundingAuthorization = ref.read(payrollFundingAuthorizationProvider);
    if (!fundingAuthorization.isAuthorizedForRelease) {
      _showMessage(context, fundingAuthorization.nextAction);
      return;
    }

    final updatedStatus = Map<int, bool>.from(ref.read(paymentStatusProvider));
    for (final line in batch.lines.where((line) => line.canRelease)) {
      updatedStatus[line.employeeId] = true;
    }
    ref.read(paymentStatusProvider.notifier).state = updatedStatus;
    _clearPayrollExports(ref);

    _showMessage(context, '${batch.pendingCount} payments released');
  }

  void _approvePayrollStage(
    BuildContext context,
    WidgetRef ref,
    String stageId,
  ) {
    final workflow = ref.read(payrollApprovalWorkflowProvider);
    final stage = workflow.stages.firstWhere((item) => item.id == stageId);
    if (!stage.canApprove) {
      _showMessage(context, stage.nextAction);
      return;
    }

    ref.read(payrollApprovalRecordsProvider.notifier).state = {
      ...ref.read(payrollApprovalRecordsProvider),
      stageId: PayrollApprovalRecord(
        stageId: stageId,
        approvedBy: _approvalOwnerName(stageId),
        approvedAt: ref.read(payrollAsOfDateProvider),
        note: '${stage.title} approved for ${workflow.periodLabel}',
      ),
    };

    _showMessage(context, '${stage.title} approved');
  }

  void _reopenPayrollStage(
    BuildContext context,
    WidgetRef ref,
    String stageId,
  ) {
    final workflow = ref.read(payrollApprovalWorkflowProvider);
    final stage = workflow.stages.firstWhere((item) => item.id == stageId);
    final records = {...ref.read(payrollApprovalRecordsProvider)};
    final stageOrder = workflow.stages.map((item) => item.id).toList();
    final startIndex = stageOrder.indexOf(stageId);
    for (var index = startIndex; index < stageOrder.length; index++) {
      records.remove(stageOrder[index]);
    }

    ref.read(payrollApprovalRecordsProvider.notifier).state = records;
    ref.read(paymentStatusProvider.notifier).state = {
      for (final employee in ref.read(employeesProvider2)) employee.id: false,
    };
    ref.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state =
        <int>{};
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state =
        <int, PayrollPayslipDeliveryReceipt>{};
    _clearPayrollExports(ref);

    _showMessage(context, '${stage.title} approval reopened');
  }

  void _authorizeFundingAccount(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollFundingAuthorizationProvider);
    final draft = ref.read(payrollFundingAuthorizationDraftProvider);
    if (!draft.isReadyToSubmit) {
      _showMessage(context, draft.validationErrors.first);
      return;
    }
    final line = summary.lines.firstWhere(
      (item) => item.accountLabel == draft.accountLabel,
      orElse: () => throw StateError('Funding account is unavailable'),
    );
    if (!line.canAuthorize) {
      _showMessage(
        context,
        line.blockers.isEmpty ? summary.nextAction : line.blockers.first,
      );
      return;
    }
    final existing = ref.read(payrollFundingAuthorizationRecordsProvider);
    ref.read(payrollFundingAuthorizationRecordsProvider.notifier).state = {
      ...existing,
      draft.accountLabel: draft.toRecord(),
    };
    ref.read(payrollFundingAuthorizationDraftProvider.notifier).clear();
    _showMessage(context, '${draft.accountLabel} funding authorized');
  }

  void _selectFundingAuthorizationAccount(
    BuildContext context,
    WidgetRef ref,
    String accountLabel,
  ) {
    final summary = ref.read(payrollFundingAuthorizationProvider);
    final line = summary.lines.firstWhere(
      (item) => item.accountLabel == accountLabel,
    );
    if (!line.canAuthorize) {
      _showMessage(
        context,
        line.blockers.isEmpty ? summary.nextAction : line.blockers.first,
      );
      return;
    }
    ref
        .read(payrollFundingAuthorizationDraftProvider.notifier)
        .selectAccount(accountLabel);
  }

  void _reopenFundingAccount(
    BuildContext context,
    WidgetRef ref,
    String accountLabel,
  ) {
    ref.read(payrollFundingAuthorizationRecordsProvider.notifier).state = {
      ...ref.read(payrollFundingAuthorizationRecordsProvider),
    }..remove(accountLabel);
    ref.read(payrollFundingAuthorizationDraftProvider.notifier).clear();
    ref.read(paymentStatusProvider.notifier).state = {
      for (final employee in ref.read(employeesProvider2)) employee.id: false,
    };
    ref.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state =
        <int>{};
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state =
        <int, PayrollPayslipDeliveryReceipt>{};
    ref.read(payrollRemittedLiabilityIdsProvider.notifier).state = <String>{};
    ref.read(payrollPostedJournalIdsProvider.notifier).state = <String>{};
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    _clearPayrollApprovals(ref);
    _clearPayrollExports(ref);
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('publish-payslips');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('remit-liabilities');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('post-journal');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('archive-run');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    _showMessage(context, '$accountLabel funding authorization reopened');
  }

  void _publishPayslips(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollPayslipPackageProvider);
    if (!summary.canPublish) {
      _showMessage(context, summary.nextAction);
      return;
    }

    final publishedIds = {
      ...ref.read(payrollPublishedPayslipEmployeeIdsProvider),
    };
    for (final line in summary.lines.where((line) => line.canPublish)) {
      publishedIds.add(line.employeeId);
    }
    ref.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state =
        publishedIds;

    _showMessage(context, '${summary.readyCount} payslips published');
  }

  void _dispatchPayslipStatements(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollPayslipDistributionProvider);
    if (!summary.canDispatch) {
      _showMessage(context, summary.nextAction);
      return;
    }

    final dispatchedAt = summary.package.payDate.add(const Duration(hours: 2));
    final receipts = {...ref.read(payrollPayslipDeliveryReceiptsProvider)};
    for (final line in summary.lines.where((line) => line.canDispatch)) {
      receipts[line.payslip.employeeId] = PayrollPayslipDeliveryReceipt(
        employeeId: line.payslip.employeeId,
        sentAt: dispatchedAt,
      );
    }
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state = receipts;

    _showMessage(
      context,
      '${summary.readyToSendCount + summary.failedCount} payslip statements dispatched',
    );
  }

  void _resetPayslipDelivery(BuildContext context, WidgetRef ref) {
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state =
        <int, PayrollPayslipDeliveryReceipt>{};
    _showMessage(context, 'Payslip delivery receipts reset');
  }

  void _remitLiabilities(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollLiabilitySummaryProvider);
    if (!summary.canRemit) {
      _showMessage(context, summary.nextAction);
      return;
    }

    final remittedIds = {...ref.read(payrollRemittedLiabilityIdsProvider)};
    for (final line in summary.lines.where((line) => line.canRemit)) {
      remittedIds.add(line.id);
    }
    ref.read(payrollRemittedLiabilityIdsProvider.notifier).state = remittedIds;

    _showMessage(context, '${summary.readyCount} liabilities remitted');
  }

  void _postPayrollJournal(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollJournalPostingProvider);
    if (!summary.canPost) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollPostedJournalIdsProvider.notifier).state = {
      ...ref.read(payrollPostedJournalIdsProvider),
      summary.journalId,
    };

    _showMessage(context, '${summary.journalId} posted to finance');
  }

  void _exportRegisterReport(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollRegisterReportProvider);
    if (!summary.canExport) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollExportedRegisterReportIdsProvider.notifier).state = {
      ...ref.read(payrollExportedRegisterReportIdsProvider),
      summary.reportId,
    };

    _showMessage(context, '${summary.reportId} exported for finance review');
  }

  void _reopenRegisterReport(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollRegisterReportProvider);
    ref.read(payrollExportedRegisterReportIdsProvider.notifier).state = {
      ...ref.read(payrollExportedRegisterReportIdsProvider),
    }..remove(summary.reportId);
    ref.read(payrollExportedStatutoryFilingIdsProvider.notifier).state =
        <String>{};
    _showMessage(context, '${summary.reportId} export reopened');
  }

  void _exportBankTransferFile(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollBankTransferFileProvider);
    if (!summary.canExport) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollExportedBankTransferFileIdsProvider.notifier).state = {
      ...ref.read(payrollExportedBankTransferFileIdsProvider),
      summary.fileId,
    };

    _showMessage(context, '${summary.fileId} exported for bank transfer');
  }

  void _reopenBankTransferFile(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollBankTransferFileProvider);
    ref.read(payrollExportedBankTransferFileIdsProvider.notifier).state = {
      ...ref.read(payrollExportedBankTransferFileIdsProvider),
    }..remove(summary.fileId);
    _showMessage(context, '${summary.fileId} export reopened');
  }

  void _exportCostCenterReport(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollCostCenterReportProvider);
    if (!summary.canExport) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollExportedCostCenterReportIdsProvider.notifier).state = {
      ...ref.read(payrollExportedCostCenterReportIdsProvider),
      summary.reportId,
    };

    _showMessage(context, '${summary.reportId} exported for finance review');
  }

  void _reopenCostCenterReport(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollCostCenterReportProvider);
    ref.read(payrollExportedCostCenterReportIdsProvider.notifier).state = {
      ...ref.read(payrollExportedCostCenterReportIdsProvider),
    }..remove(summary.reportId);
    _showMessage(context, '${summary.reportId} export reopened');
  }

  void _exportStatutoryReport(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollStatutoryReportProvider);
    if (!summary.canExport) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollExportedStatutoryFilingIdsProvider.notifier).state = {
      ...ref.read(payrollExportedStatutoryFilingIdsProvider),
      for (final line in summary.lines.where((line) => line.canExport)) line.id,
    };

    _showMessage(context, '${summary.readyCount} statutory filings exported');
  }

  void _reopenStatutoryReport(BuildContext context, WidgetRef ref) {
    ref.read(payrollExportedStatutoryFilingIdsProvider.notifier).state =
        <String>{};
    _showMessage(context, 'Statutory reporting pack reopened');
  }

  void _deliverReadyReports(BuildContext context, WidgetRef ref) {
    final distribution = ref.read(payrollReportDistributionProvider);
    if (distribution.readyCount == 0) {
      _showMessage(context, distribution.nextAction);
      return;
    }

    ref
        .read(payrollReportDeliveryReceiptsProvider.notifier)
        .deliverReady(
          summary: distribution,
          deliveredBy: 'Payroll Controller',
          deliveredAt: ref.read(payrollAsOfDateProvider),
        );
    _showMessage(
      context,
      '${distribution.readyCount} payroll reports delivered',
    );
  }

  void _reopenReportDelivery(
    BuildContext context,
    WidgetRef ref,
    String reportId,
  ) {
    ref.read(payrollReportDeliveryReceiptsProvider.notifier).reopen(reportId);
    ref.read(auditCloseAttestationRecordProvider.notifier).state = null;
    ref.read(auditHandoffDeliveryRecordProvider.notifier).state = null;
    ref.read(auditReviewerReceiptRecordProvider.notifier).state = null;
    _showMessage(context, '$reportId delivery reopened');
  }

  void _signAuditClose(BuildContext context, WidgetRef ref) {
    final summary = ref.read(auditCloseAttestationProvider);
    if (!summary.canSign) {
      _showMessage(context, summary.nextAction);
      return;
    }
    final draft = ref.read(auditCloseAttestationDraftProvider);
    if (!draft.isReadyToSubmit) {
      _showMessage(context, draft.validationErrors.first);
      return;
    }

    ref.read(auditCloseAttestationRecordProvider.notifier).state =
        draft.toRecord();
    ref.read(auditCloseAttestationDraftProvider.notifier).clear();
    _showMessage(context, 'Payroll audit close signed');
  }

  void _reopenAuditCloseAttestation(BuildContext context, WidgetRef ref) {
    ref.read(auditCloseAttestationRecordProvider.notifier).state = null;
    ref.read(auditCloseAttestationDraftProvider.notifier).clear();
    ref.read(auditHandoffDeliveryRecordProvider.notifier).state = null;
    ref.read(auditHandoffDeliveryDraftProvider.notifier).clear();
    ref.read(auditReviewerReceiptRecordProvider.notifier).state = null;
    ref.read(auditReviewerReceiptDraftProvider.notifier).clear();
    _showMessage(context, 'Payroll audit close attestation reopened');
  }

  void _routeAuditHandoff(BuildContext context, WidgetRef ref) {
    final summary = ref.read(auditHandoffDeliveryProvider);
    if (!summary.canRoute) {
      _showMessage(context, summary.nextAction);
      return;
    }
    final draft = ref.read(auditHandoffDeliveryDraftProvider);
    if (!draft.isReadyToSubmit) {
      _showMessage(context, draft.validationErrors.first);
      return;
    }

    ref.read(auditHandoffDeliveryRecordProvider.notifier).state = draft
        .toRecord(
          packageId: summary.package.packageId,
          recipients: summary.package.recipients,
        );
    ref.read(auditHandoffDeliveryDraftProvider.notifier).clear();
    _showMessage(context, '${summary.package.packageId} routed to reviewers');
  }

  void _reopenAuditHandoffDelivery(BuildContext context, WidgetRef ref) {
    ref.read(auditHandoffDeliveryRecordProvider.notifier).state = null;
    ref.read(auditHandoffDeliveryDraftProvider.notifier).clear();
    ref.read(auditReviewerReceiptRecordProvider.notifier).state = null;
    ref.read(auditReviewerReceiptDraftProvider.notifier).clear();
    _showMessage(context, 'Audit handoff delivery reopened');
  }

  void _recordAuditReviewerReceipt(BuildContext context, WidgetRef ref) {
    final summary = ref.read(auditReviewerReceiptProvider);
    if (!summary.canRecord) {
      _showMessage(context, summary.nextAction);
      return;
    }
    final draft = ref.read(auditReviewerReceiptDraftProvider);
    if (!draft.isReadyToSubmit) {
      _showMessage(context, draft.validationErrors.first);
      return;
    }

    ref.read(auditReviewerReceiptRecordProvider.notifier).state = draft
        .toRecord(packageId: summary.delivery.package.packageId);
    ref.read(auditReviewerReceiptDraftProvider.notifier).clear();
    _showMessage(context, 'Audit reviewer receipt recorded');
  }

  void _reopenAuditReviewerReceipt(BuildContext context, WidgetRef ref) {
    ref.read(auditReviewerReceiptRecordProvider.notifier).state = null;
    ref.read(auditReviewerReceiptDraftProvider.notifier).clear();
    _showMessage(context, 'Audit reviewer receipt reopened');
  }

  void _remediateAuditPackFinding(
    BuildContext context,
    WidgetRef ref,
    String findingId,
  ) {
    ref
        .read(auditPackFindingRecordsProvider.notifier)
        .remediate(
          checkpointId: findingId,
          remediatedAt: ref.read(payrollAsOfDateProvider),
        );
    _showMessage(context, '$findingId finding remediated');
  }

  void _closeAuditPackFinding(
    BuildContext context,
    WidgetRef ref,
    String findingId,
  ) {
    try {
      ref
          .read(auditPackFindingRecordsProvider.notifier)
          .close(
            checkpointId: findingId,
            closedAt: ref.read(payrollAsOfDateProvider),
          );
      _showMessage(context, '$findingId finding closed');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _reopenAuditPackFinding(
    BuildContext context,
    WidgetRef ref,
    String findingId,
  ) {
    ref.read(auditPackFindingRecordsProvider.notifier).reopen(findingId);
    ref.read(auditCloseAttestationRecordProvider.notifier).state = null;
    ref.read(auditHandoffDeliveryRecordProvider.notifier).state = null;
    ref.read(auditReviewerReceiptRecordProvider.notifier).state = null;
    _showMessage(context, '$findingId finding reopened');
  }

  void _approveCostCenterBudget(
    BuildContext context,
    WidgetRef ref,
    String costCenterId,
  ) {
    final summary = ref.read(payrollCostCenterBudgetSummaryProvider);
    final line = summary.lines.firstWhere((item) => item.id == costCenterId);
    ref.read(payrollApprovedCostCenterBudgetIdsProvider.notifier).state = {
      ...ref.read(payrollApprovedCostCenterBudgetIdsProvider),
      costCenterId,
    };
    _showMessage(context, '${line.label} budget release approved');
  }

  void _reopenCostCenterBudget(
    BuildContext context,
    WidgetRef ref,
    String costCenterId,
  ) {
    final summary = ref.read(payrollCostCenterBudgetSummaryProvider);
    final line = summary.lines.firstWhere((item) => item.id == costCenterId);
    ref.read(payrollApprovedCostCenterBudgetIdsProvider.notifier).state = {
      ...ref.read(payrollApprovedCostCenterBudgetIdsProvider),
    }..remove(costCenterId);
    ref.read(payrollFundingAuthorizationRecordsProvider.notifier).state =
        <String, PayrollFundingAuthorizationRecord>{};
    _clearPayrollApprovals(ref);
    ref.read(payrollFundingAuthorizationDraftProvider.notifier).clear();
    ref.read(paymentStatusProvider.notifier).state = {
      for (final employee in ref.read(employeesProvider2)) employee.id: false,
    };
    ref.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state =
        <int>{};
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state =
        <int, PayrollPayslipDeliveryReceipt>{};
    ref.read(payrollRemittedLiabilityIdsProvider.notifier).state = <String>{};
    ref.read(payrollPostedJournalIdsProvider.notifier).state = <String>{};
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    _clearPayrollExports(ref);
    ref.read(payrollReconciliationReviewSignatureProvider.notifier).state =
        null;
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('lock-payroll');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('publish-payslips');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('remit-liabilities');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('post-journal');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('archive-run');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    _showMessage(context, '${line.label} budget approval reopened');
  }

  void _archiveRunPackage(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollArchivePackageProvider);
    if (!summary.canArchive) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = {
      ...ref.read(payrollArchivedRunPackageIdsProvider),
      summary.packageId,
    };

    _showMessage(context, '${summary.packageId} archived for audit retention');
  }

  void _reviewPayrollControls(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollControlReviewProvider);
    if (!summary.canReview) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollReviewedControlIdsProvider.notifier).state = {
      ...ref.read(payrollReviewedControlIdsProvider),
      for (final item in summary.items.where((item) => item.isReady)) item.id,
    };

    _showMessage(context, '${summary.readyCount} payroll controls signed off');
  }

  void _reopenPayslipPublishing(
    BuildContext context,
    WidgetRef ref, {
    bool showMessage = true,
  }) {
    ref.read(payrollPublishedPayslipEmployeeIdsProvider.notifier).state =
        <int>{};
    ref.read(payrollPayslipDeliveryReceiptsProvider.notifier).state =
        <int, PayrollPayslipDeliveryReceipt>{};
    ref.read(payrollRemittedLiabilityIdsProvider.notifier).state = <String>{};
    ref.read(payrollPostedJournalIdsProvider.notifier).state = <String>{};
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    _clearPayrollExports(ref);
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('remit-liabilities');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('post-journal');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('archive-run');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    if (showMessage) {
      _showMessage(context, 'Payslip publishing reopened');
    }
  }

  void _reopenLiabilityRemittance(
    BuildContext context,
    WidgetRef ref, {
    bool showMessage = true,
  }) {
    ref.read(payrollRemittedLiabilityIdsProvider.notifier).state = <String>{};
    ref.read(payrollPostedJournalIdsProvider.notifier).state = <String>{};
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    _clearPayrollExports(ref);
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('remit-liabilities');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('post-journal');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('archive-run');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    if (showMessage) {
      _showMessage(context, 'Liability remittance reopened');
    }
  }

  void _reopenJournalPosting(
    BuildContext context,
    WidgetRef ref, {
    bool showMessage = true,
  }) {
    ref.read(payrollPostedJournalIdsProvider.notifier).state = <String>{};
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    _clearPayrollExports(ref);
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('post-journal');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('archive-run');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    if (showMessage) {
      _showMessage(context, 'Payroll journal posting reopened');
    }
  }

  void _reopenRunArchive(
    BuildContext context,
    WidgetRef ref, {
    bool showMessage = true,
  }) {
    ref.read(payrollArchivedRunPackageIdsProvider.notifier).state = <String>{};
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    ref.read(payrollExportedStatutoryFilingIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('archive-run');
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    if (showMessage) {
      _showMessage(context, 'Payroll audit archive reopened');
    }
  }

  void _reopenControlReview(
    BuildContext context,
    WidgetRef ref, {
    bool showMessage = true,
  }) {
    ref.read(payrollReviewedControlIdsProvider.notifier).state = <String>{};
    ref
        .read(payrollRunCloseProgressProvider.notifier)
        .reopen('review-controls');
    ref.read(payrollRunCloseProgressProvider.notifier).reopen('close-period');
    if (showMessage) {
      _showMessage(context, 'Payroll control review reopened');
    }
  }

  void _clearExportedRegisterReports(WidgetRef ref) {
    ref.read(payrollExportedRegisterReportIdsProvider.notifier).state =
        <String>{};
  }

  void _clearExportedBankTransferFiles(WidgetRef ref) {
    ref.read(payrollExportedBankTransferFileIdsProvider.notifier).state =
        <String>{};
  }

  void _clearExportedCostCenterReports(WidgetRef ref) {
    ref.read(payrollExportedCostCenterReportIdsProvider.notifier).state =
        <String>{};
  }

  void _clearExportedStatutoryFilings(WidgetRef ref) {
    ref.read(payrollExportedStatutoryFilingIdsProvider.notifier).state =
        <String>{};
  }

  void _clearPayrollExports(WidgetRef ref) {
    _clearExportedRegisterReports(ref);
    _clearExportedBankTransferFiles(ref);
    _clearExportedCostCenterReports(ref);
    _clearExportedStatutoryFilings(ref);
  }

  void _clearPayrollApprovals(WidgetRef ref) {
    ref.read(payrollApprovalRecordsProvider.notifier).state =
        <String, PayrollApprovalRecord>{};
  }

  String _approvalOwnerName(String stageId) {
    return switch (stageId) {
      'hr-review' => 'HR Operations Lead',
      'finance-review' => 'Finance Partner',
      'payroll-manager' => 'Payroll Manager',
      'final-release' => 'Payroll Controller',
      _ => 'Payroll Approver',
    };
  }

  Future<void> _selectAdjustmentDate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final draft = ref.read(payrollAdjustmentDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.effectiveDate ?? draft.asOfDate.add(const Duration(days: 3)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref.read(payrollAdjustmentDraftProvider.notifier).setEffectiveDate(picked);
  }

  void _submitAdjustment(BuildContext context, WidgetRef ref) {
    try {
      final request = ref
          .read(payrollAdjustmentsProvider.notifier)
          .submitDraft(
            draft: ref.read(payrollAdjustmentDraftProvider),
            employees: ref.read(employeesProvider2),
          );
      ref.read(payrollAdjustmentDraftProvider.notifier).clear();
      _showMessage(
        context,
        '${request.id} submitted for ${request.employeeName}',
      );
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _approvePayrollInputChanges(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollInputChangeSummaryProvider);
    if (!summary.canApprove) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollApprovedInputChangeIdsProvider.notifier).state = {
      ...ref.read(payrollApprovedInputChangeIdsProvider),
      for (final line in summary.lines.where((line) => line.canApprove))
        line.id,
    };

    _showMessage(context, '${summary.pendingCount} payroll inputs approved');
  }

  void _applyPayrollInputChanges(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollInputChangeSummaryProvider);
    if (!summary.canApply) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollAppliedInputChangeIdsProvider.notifier).state = {
      ...ref.read(payrollAppliedInputChangeIdsProvider),
      for (final line in summary.lines.where((line) => line.canApply)) line.id,
    };

    _showMessage(context, '${summary.approvedCount} payroll inputs applied');
  }

  void _reopenPayrollInputChanges(WidgetRef ref) {
    ref.read(payrollApprovedInputChangeIdsProvider.notifier).state = <String>{};
    ref.read(payrollAppliedInputChangeIdsProvider.notifier).state = <String>{};
  }

  void _approveAttendanceBridge(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollAttendanceBridgeProvider);
    if (!summary.canApprove) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollApprovedAttendanceSignalIdsProvider.notifier).state = {
      ...ref.read(payrollApprovedAttendanceSignalIdsProvider),
      for (final line in summary.lines.where((line) => line.canApprove))
        line.id,
    };

    _showMessage(
      context,
      '${summary.pendingCount} attendance payroll impacts approved',
    );
  }

  void _applyAttendanceBridge(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollAttendanceBridgeProvider);
    if (!summary.canApply) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollAppliedAttendanceSignalIdsProvider.notifier).state = {
      ...ref.read(payrollAppliedAttendanceSignalIdsProvider),
      for (final line in summary.lines.where((line) => line.canApply)) line.id,
    };

    _showMessage(
      context,
      '${summary.approvedCount} attendance payroll impacts applied',
    );
  }

  void _reopenAttendanceBridge(WidgetRef ref) {
    ref.read(payrollApprovedAttendanceSignalIdsProvider.notifier).state =
        <String>{};
    ref.read(payrollAppliedAttendanceSignalIdsProvider.notifier).state =
        <String>{};
  }

  void _applyLoanRepayments(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollLoanRepaymentProvider);
    if (!summary.canApply) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollAppliedLoanRepaymentIdsProvider.notifier).state = {
      ...ref.read(payrollAppliedLoanRepaymentIdsProvider),
      for (final line in summary.lines.where((line) => line.canApply)) line.id,
    };

    _showMessage(context, '${summary.readyCount} loan repayments applied');
  }

  void _reopenLoanRepayments(WidgetRef ref) {
    ref.read(payrollAppliedLoanRepaymentIdsProvider.notifier).state =
        <String>{};
  }

  void _reviewPayrollSimulation(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollSimulationProvider);
    if (!summary.canReview) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollSimulationReviewedProvider.notifier).state = true;
    ref.read(payrollSimulationAppliedProvider.notifier).state = false;
    _showMessage(context, 'Payroll simulation reviewed');
  }

  void _applyPayrollSimulation(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollSimulationProvider);
    if (!summary.canApply) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref.read(payrollSimulationAppliedProvider.notifier).state = true;
    _showMessage(context, 'Payroll simulation applied to run preview');
  }

  void _reopenPayrollSimulation(WidgetRef ref) {
    ref.read(payrollSimulationReviewedProvider.notifier).state = false;
    ref.read(payrollSimulationAppliedProvider.notifier).state = false;
  }

  void _approveDeductionAuthorizations(BuildContext context, WidgetRef ref) {
    final summary = ref.read(payrollDeductionAuthorizationProvider);
    if (!summary.canApprove) {
      _showMessage(context, summary.nextAction);
      return;
    }

    ref
        .read(payrollApprovedDeductionAuthorizationIdsProvider.notifier)
        .state = {
      ...ref.read(payrollApprovedDeductionAuthorizationIdsProvider),
      for (final line in summary.lines.where((line) => line.canApprove))
        line.id,
    };

    _showMessage(
      context,
      '${summary.pendingCount} deduction authorizations approved',
    );
  }

  void _reopenDeductionAuthorizations(BuildContext context, WidgetRef ref) {
    ref.read(payrollApprovedDeductionAuthorizationIdsProvider.notifier).state =
        <String>{};
    _showMessage(context, 'Deduction authorizations reopened');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
