import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/hris_ui.dart';
import '../models/employee_directory_action_models.dart';
import '../models/employee_directory_bulk_profile_update_models.dart';
import '../models/employee_directory_bulk_profile_update_preview_models.dart';
import '../models/employee_directory_import_models.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_directory_intake_draft.dart';
import '../models/employee_directory_quality_fix_models.dart';
import '../models/employee_directory_quality_signoff_models.dart';
import '../models/employee_directory_quality_models.dart';
import '../models/employee_directory_roster_handoff_models.dart';
import '../models/employee_directory_roster_payroll_import_models.dart';
import '../models/employee_directory_roster_payroll_run_kickoff_models.dart';
import '../models/employee_directory_roster_payroll_sync_models.dart';
import '../models/employee_directory_roster_payroll_validation_models.dart';
import '../models/employee_directory_roster_publish_models.dart';
import '../models/employee_directory_saved_view_models.dart';
import '../models/employee_directory_table_layout_models.dart';
import '../models/employee_directory_table_models.dart';
import '../models/employee_payroll_run_console_command_models.dart';
import '../states/employee_directory_action_provider.dart';
import '../states/employee_directory_activity_provider.dart';
import '../states/employee_directory_bulk_profile_update_provider.dart';
import '../states/employee_directory_bulk_profile_update_preview_provider.dart';
import '../states/employee_directory_import_provider.dart';
import '../states/employee_directory_insights_provider.dart';
import '../states/employee_directory_provider.dart';
import '../states/employee_directory_quality_fix_provider.dart';
import '../states/employee_directory_quality_gate_provider.dart';
import '../states/employee_directory_quality_plan_provider.dart';
import '../states/employee_directory_quality_provider.dart';
import '../states/employee_directory_quality_signoff_provider.dart';
import '../states/employee_directory_roster_handoff_provider.dart';
import '../states/employee_directory_roster_diff_provider.dart';
import '../states/employee_directory_roster_payroll_import_provider.dart';
import '../states/employee_directory_roster_payroll_run_kickoff_provider.dart';
import '../states/employee_directory_roster_payroll_sync_provider.dart';
import '../states/employee_directory_roster_payroll_validation_provider.dart';
import '../states/employee_directory_roster_publish_provider.dart';
import '../states/employee_directory_saved_view_provider.dart';
import '../states/employee_directory_selection_review_provider.dart';
import '../states/employee_directory_table_layout_provider.dart';
import '../states/employee_directory_table_provider.dart';
import '../states/employee_directory_view_review_provider.dart';
import '../states/employee_payroll_run_console_audit_provider.dart';
import '../states/employee_payroll_run_console_command_provider.dart';
import '../states/employee_payroll_run_console_provider.dart';
import '../widgets/directory/employee_directory_action_queue_panel.dart';
import '../widgets/directory/employee_directory_activity_panel.dart';
import '../widgets/directory/employee_directory_bulk_action_bar.dart';
import '../widgets/directory/employee_directory_bulk_profile_update_panel.dart';
import '../widgets/directory/employee_directory_bulk_profile_update_preview_panel.dart';
import '../widgets/directory/employee_directory_detail_sheet.dart';
import '../widgets/directory/employee_directory_import_panel.dart';
import '../widgets/directory/employee_directory_insights_panel.dart';
import '../widgets/directory/employee_directory_intake_sheet.dart';
import '../widgets/directory/employee_directory_quality_panel.dart';
import '../widgets/directory/employee_directory_quality_fix_panel.dart';
import '../widgets/directory/employee_directory_quality_gate_panel.dart';
import '../widgets/directory/employee_directory_quality_plan_panel.dart';
import '../widgets/directory/employee_directory_quality_signoff_panel.dart';
import '../widgets/directory/employee_directory_roster_diff_panel.dart';
import '../widgets/directory/employee_directory_roster_handoff_panel.dart';
import '../widgets/directory/employee_directory_roster_payroll_import_panel.dart';
import '../widgets/directory/employee_directory_roster_payroll_run_kickoff_panel.dart';
import '../widgets/directory/employee_directory_roster_payroll_sync_panel.dart';
import '../widgets/directory/employee_directory_roster_payroll_validation_panel.dart';
import '../widgets/directory/employee_directory_roster_publish_panel.dart';
import '../widgets/directory/employee_directory_saved_views_panel.dart';
import '../widgets/directory/employee_directory_selection_review_panel.dart';
import '../widgets/directory/employee_directory_summary_grid.dart';
import '../widgets/directory/employee_directory_table_controls.dart';
import '../widgets/directory/employee_directory_table_layout_panel.dart';
import '../widgets/directory/employee_directory_table_panel.dart';
import '../widgets/directory/employee_directory_table_preset_strip.dart';
import '../widgets/directory/employee_directory_view_review_panel.dart';
import '../widgets/directory/employee_payroll_run_console_panel.dart';

class EmployeeDirectoryTableScreen extends ConsumerWidget {
  const EmployeeDirectoryTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(employeeDirectoryDepartmentsProvider);
    final selectedDepartment = ref.watch(
      employeeDirectorySelectedDepartmentProvider,
    );
    final highPerformerOnly = ref.watch(
      employeeDirectoryHighPerformerOnlyProvider,
    );
    final query = ref.watch(employeeDirectorySearchQueryProvider);
    final summary = ref.watch(employeeDirectorySummaryProvider);
    final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
    final tableView = ref.watch(employeeDirectoryTableViewProvider);
    final tableLayout = ref.watch(employeeDirectoryTableLayoutProvider);
    final presets = ref.watch(employeeDirectoryTablePresetsProvider);
    final activePresetId = ref.watch(
      employeeDirectoryTableActivePresetProvider,
    );
    final viewReview = ref.watch(employeeDirectoryViewReviewProvider);
    final savedViews = ref.watch(employeeDirectorySavedViewsProvider);
    final savedViewDraft = ref.watch(employeeDirectorySavedViewDraftProvider);
    final activeSavedView = ref.watch(employeeDirectoryActiveSavedViewProvider);
    final selectedEmployeeIds = ref.watch(
      employeeDirectoryTableSelectedIdsProvider,
    );
    final selectedEmployees = ref.watch(
      employeeDirectoryTableSelectedRowsProvider,
    );
    final selectionReview = ref.watch(employeeDirectorySelectionReviewProvider);
    final bulkProfileUpdateDraft = ref.watch(
      employeeDirectoryBulkProfileUpdateDraftProvider,
    );
    final bulkProfileUpdatePreview = ref.watch(
      employeeDirectoryBulkProfileUpdatePreviewProvider,
    );
    final workforceInsights = ref.watch(employeeDirectoryInsightsProvider);
    final qualityReport = ref.watch(employeeDirectoryQualityReportProvider);
    final qualityFilter = ref.watch(employeeDirectoryQualityFilterProvider);
    final qualityGate = ref.watch(employeeDirectoryQualityGateProvider);
    final qualityFixPlan = ref.watch(employeeDirectoryQualityFixPlanProvider);
    final qualityFixReview = ref.watch(
      employeeDirectoryQualityFixReviewProvider,
    );
    final qualitySignoffReview = ref.watch(
      employeeDirectoryQualityGateSignoffReviewProvider,
    );
    final rosterPublishReview = ref.watch(
      employeeDirectoryRosterPublishReviewProvider,
    );
    final rosterDiffReview = ref.watch(
      employeeDirectoryRosterDiffReviewProvider,
    );
    final rosterHandoffReview = ref.watch(
      employeeDirectoryRosterHandoffReviewProvider,
    );
    final rosterPayrollSyncReview = ref.watch(
      employeeDirectoryRosterPayrollSyncReviewProvider,
    );
    final rosterPayrollImportReview = ref.watch(
      employeeDirectoryRosterPayrollImportReviewProvider,
    );
    final rosterPayrollValidationReview = ref.watch(
      employeeDirectoryRosterPayrollValidationReviewProvider,
    );
    final rosterPayrollRunKickoffReview = ref.watch(
      employeeDirectoryRosterPayrollRunKickoffReviewProvider,
    );
    final payrollRunConsoleReview = ref.watch(
      employeePayrollRunConsoleProvider,
    );
    final payrollRunConsoleCommandResult = ref.watch(
      employeePayrollRunConsoleCommandResultProvider,
    );
    final payrollRunConsoleAuditEvents = ref.watch(
      employeePayrollRunConsoleAuditProvider,
    );
    final actionQueue = ref.watch(employeeDirectoryActionQueueProvider);
    final actionQueueSummary = ref.watch(
      employeeDirectoryActionQueueSummaryProvider,
    );
    final importCsv = ref.watch(employeeDirectoryImportCsvProvider);
    final importPreview = ref.watch(employeeDirectoryImportPreviewProvider);
    final activitySummary = ref.watch(employeeDirectoryActivitySummaryProvider);
    final recentActivity = ref.watch(employeeDirectoryRecentActivityProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Employee Directory'),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: () => _clearFilters(ref),
          ),
          IconButton(
            tooltip: 'Export table',
            icon: const Icon(Icons.file_download_outlined),
            onPressed:
                () => _exportEmployees(context, ref, tableView.rows, asOfDate),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisCommandHeader(
                title: 'Employee Directory',
                subtitle: 'Search, segment, and govern employee records',
                icon: Icons.badge_outlined,
                departments: departments,
                departmentLabel: 'Department',
                selectedDepartment: selectedDepartment,
                attentionOnly: highPerformerOnly,
                attentionLabel: 'High performers',
                onDepartmentChanged: (value) {
                  if (value == null) return;
                  _markManualTableChange(ref);
                  ref
                      .read(
                        employeeDirectorySelectedDepartmentProvider.notifier,
                      )
                      .state = value;
                },
                onAttentionChanged: (value) {
                  _markManualTableChange(ref);
                  ref
                      .read(employeeDirectoryHighPerformerOnlyProvider.notifier)
                      .state = value;
                },
              ),
              const SizedBox(height: 16),
              EmployeeDirectorySummaryGrid(summary: summary),
              const SizedBox(height: 16),
              EmployeeDirectoryInsightsPanel(insights: workforceInsights),
              const SizedBox(height: 16),
              EmployeeDirectoryQualityPanel(
                report: qualityReport,
                activeFilter: qualityFilter,
                onFilterSelected: (filter) => _applyQualityFilter(ref, filter),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryQualityGatePanel(
                gate: qualityGate,
                onIssueSelected:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .selectIssue,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryQualityPlanPanel(
                plan: qualityFixPlan,
                onIssueSelected:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .selectIssue,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryQualityFixPanel(
                review: qualityFixReview,
                onIssueSelected:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .selectIssue,
                onEmailChanged:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .setEmail,
                onPhoneChanged:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .setPhone,
                onManagerChanged:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .setManager,
                onDepartmentChanged:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .setDepartment,
                onLocationChanged:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .setLocation,
                onJoiningDateChanged:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .setJoiningDate,
                onAuditNoteChanged:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .setAuditNote,
                onSubmit:
                    () => _applyQualityFix(context, ref, qualityFixReview),
                onClear:
                    ref
                        .read(employeeDirectoryQualityFixDraftProvider.notifier)
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryQualitySignoffPanel(
                review: qualitySignoffReview,
                onReviewerChanged:
                    ref
                        .read(
                          employeeDirectoryQualityGateSignoffDraftProvider
                              .notifier,
                        )
                        .setReviewer,
                onNoteChanged:
                    ref
                        .read(
                          employeeDirectoryQualityGateSignoffDraftProvider
                              .notifier,
                        )
                        .setNote,
                onAcceptReviewItemsChanged:
                    ref
                        .read(
                          employeeDirectoryQualityGateSignoffDraftProvider
                              .notifier,
                        )
                        .setAcceptReviewItems,
                onSubmit:
                    () => _submitQualityGateSignoff(
                      context,
                      ref,
                      qualitySignoffReview,
                      asOfDate,
                    ),
                onClear:
                    ref
                        .read(
                          employeeDirectoryQualityGateSignoffDraftProvider
                              .notifier,
                        )
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryRosterPublishPanel(
                review: rosterPublishReview,
                onPreparedByChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPublishDraftProvider.notifier,
                        )
                        .setPreparedBy,
                onReleaseNoteChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPublishDraftProvider.notifier,
                        )
                        .setReleaseNote,
                onConfirmPayrollHandoffChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPublishDraftProvider.notifier,
                        )
                        .setConfirmPayrollHandoff,
                onSubmit:
                    () => _publishRosterRelease(
                      context,
                      ref,
                      rosterPublishReview,
                      asOfDate,
                    ),
                onClear:
                    ref
                        .read(
                          employeeDirectoryRosterPublishDraftProvider.notifier,
                        )
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryRosterDiffPanel(review: rosterDiffReview),
              const SizedBox(height: 16),
              EmployeeDirectoryRosterHandoffPanel(
                review: rosterHandoffReview,
                onAcknowledge:
                    (recipient) => _acknowledgeRosterHandoff(
                      context,
                      ref,
                      rosterHandoffReview,
                      recipient,
                      asOfDate,
                    ),
                onResend:
                    (recipient) => _resendRosterHandoff(
                      context,
                      ref,
                      rosterHandoffReview,
                      recipient,
                      asOfDate,
                    ),
                onEscalate:
                    (recipient) => _escalateRosterHandoff(
                      context,
                      ref,
                      rosterHandoffReview,
                      recipient,
                      asOfDate,
                    ),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryRosterPayrollSyncPanel(
                review: rosterPayrollSyncReview,
                onSyncedByChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollSyncDraftProvider
                              .notifier,
                        )
                        .setSyncedBy,
                onSyncNoteChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollSyncDraftProvider
                              .notifier,
                        )
                        .setSyncNote,
                onPayrollImpactReviewChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollSyncDraftProvider
                              .notifier,
                        )
                        .setConfirmPayrollImpactReview,
                onControlTotalsChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollSyncDraftProvider
                              .notifier,
                        )
                        .setConfirmControlTotals,
                onSubmit:
                    () => _syncRosterPayroll(
                      context,
                      ref,
                      rosterPayrollSyncReview,
                      asOfDate,
                    ),
                onClear:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollSyncDraftProvider
                              .notifier,
                        )
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryRosterPayrollImportPanel(
                review: rosterPayrollImportReview,
                onBatchLabelChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollImportDraftProvider
                              .notifier,
                        )
                        .setBatchLabel,
                onPreparedByChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollImportDraftProvider
                              .notifier,
                        )
                        .setPreparedBy,
                onImportNoteChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollImportDraftProvider
                              .notifier,
                        )
                        .setImportNote,
                onColumnMappingChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollImportDraftProvider
                              .notifier,
                        )
                        .setConfirmColumnMapping,
                onAttentionProfilesChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollImportDraftProvider
                              .notifier,
                        )
                        .setConfirmAttentionProfiles,
                onPreviewControlsChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollImportDraftProvider
                              .notifier,
                        )
                        .setConfirmPreviewControls,
                onSubmit:
                    () => _stageRosterPayrollImport(
                      context,
                      ref,
                      rosterPayrollImportReview,
                      asOfDate,
                    ),
                onClear:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollImportDraftProvider
                              .notifier,
                        )
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryRosterPayrollValidationPanel(
                review: rosterPayrollValidationReview,
                onValidatedByChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollValidationDraftProvider
                              .notifier,
                        )
                        .setValidatedBy,
                onValidationNoteChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollValidationDraftProvider
                              .notifier,
                        )
                        .setValidationNote,
                onFileLoadedChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollValidationDraftProvider
                              .notifier,
                        )
                        .setConfirmFileLoaded,
                onValidationItemsChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollValidationDraftProvider
                              .notifier,
                        )
                        .setConfirmValidationItems,
                onPayrollRunControlsChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollValidationDraftProvider
                              .notifier,
                        )
                        .setConfirmPayrollRunControls,
                onSubmit:
                    () => _validateRosterPayrollImport(
                      context,
                      ref,
                      rosterPayrollValidationReview,
                      asOfDate,
                    ),
                onClear:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollValidationDraftProvider
                              .notifier,
                        )
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryRosterPayrollRunKickoffPanel(
                review: rosterPayrollRunKickoffReview,
                onRunReferenceChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollRunKickoffDraftProvider
                              .notifier,
                        )
                        .setRunReference,
                onRunOwnerChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollRunKickoffDraftProvider
                              .notifier,
                        )
                        .setRunOwner,
                onKickoffNoteChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollRunKickoffDraftProvider
                              .notifier,
                        )
                        .setKickoffNote,
                onFundingWindowChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollRunKickoffDraftProvider
                              .notifier,
                        )
                        .setConfirmFundingWindow,
                onPayslipHoldChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollRunKickoffDraftProvider
                              .notifier,
                        )
                        .setConfirmPayslipHold,
                onAuditArchiveChanged:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollRunKickoffDraftProvider
                              .notifier,
                        )
                        .setConfirmAuditArchive,
                onSubmit:
                    () => _launchRosterPayrollRun(
                      context,
                      ref,
                      rosterPayrollRunKickoffReview,
                      asOfDate,
                    ),
                onClear:
                    ref
                        .read(
                          employeeDirectoryRosterPayrollRunKickoffDraftProvider
                              .notifier,
                        )
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeePayrollRunConsolePanel(
                review: payrollRunConsoleReview,
                targetEmployeeIds: selectedEmployeeIds,
                auditEvents: payrollRunConsoleAuditEvents,
                lastCommandResult: payrollRunConsoleCommandResult,
                onRunCommand:
                    (type) => _runPayrollRunConsoleCommand(
                      context,
                      ref,
                      type,
                      selectedEmployeeIds,
                    ),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryActionQueuePanel(
                summary: actionQueueSummary,
                actions: actionQueue,
                onAssign: (action) => _assignAction(context, ref, action),
                onStart: (action) => _startAction(context, ref, action),
                onResolve: (action) => _resolveAction(context, ref, action),
                onSnooze: (action) => _snoozeAction(context, ref, action),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryImportPanel(
                csvInput: importCsv,
                preview: importPreview,
                onCsvChanged:
                    (value) =>
                        ref
                            .read(employeeDirectoryImportCsvProvider.notifier)
                            .state = value,
                onLoadTemplate:
                    () =>
                        ref
                            .read(employeeDirectoryImportCsvProvider.notifier)
                            .state = employeeDirectoryImportTemplateCsv,
                onClear:
                    () =>
                        ref
                            .read(employeeDirectoryImportCsvProvider.notifier)
                            .state = '',
                onImportValid:
                    () => _importEmployees(context, ref, importPreview),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryTablePresetStrip(
                presets: presets,
                activePresetId: activePresetId,
                visibleCount: tableView.visibleCount,
                onPresetSelected: (preset) => _applyTablePreset(ref, preset),
              ),
              const SizedBox(height: 16),
              EmployeeDirectorySavedViewsPanel(
                savedViews: savedViews,
                draft: savedViewDraft,
                activeView: activeSavedView,
                allDepartmentsLabel: employeeDirectoryAllDepartments,
                currentFilterCount: viewReview.activeFilterCount,
                currentColumnCount: tableLayout.visibleColumnCount,
                currentDensityLabel: tableLayout.density.label,
                onNameChanged:
                    ref
                        .read(employeeDirectorySavedViewDraftProvider.notifier)
                        .setName,
                onDescriptionChanged:
                    ref
                        .read(employeeDirectorySavedViewDraftProvider.notifier)
                        .setDescription,
                onPinnedChanged:
                    ref
                        .read(employeeDirectorySavedViewDraftProvider.notifier)
                        .setPinned,
                onSave: () => _saveCustomSavedView(context, ref),
                onClearDraft:
                    ref
                        .read(employeeDirectorySavedViewDraftProvider.notifier)
                        .clear,
                onApply: (view) => _applyCustomSavedView(context, ref, view),
                onDelete: (view) => _deleteCustomSavedView(context, ref, view),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryViewReviewPanel(review: viewReview),
              const SizedBox(height: 16),
              EmployeeDirectoryTableLayoutPanel(
                layout: tableLayout,
                onColumnToggled: (column) => _toggleTableColumn(ref, column),
                onDensityChanged: (density) => _setTableDensity(ref, density),
                onReset: () => _resetTableLayout(ref),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryTableControls(
                query: query,
                visibleCount: tableView.visibleCount,
                candidateCount: tableView.candidateCount,
                statusFilter: tableView.statusFilter,
                onSearchChanged: (value) {
                  _markManualTableChange(ref);
                  ref
                      .read(employeeDirectorySearchQueryProvider.notifier)
                      .state = value;
                },
                onStatusChanged: (value) {
                  if (value == null) return;
                  _markManualTableChange(ref);
                  ref
                      .read(employeeDirectoryTableStatusFilterProvider.notifier)
                      .state = value;
                },
                onAddEmployee: () => _addEmployee(context, ref),
                onClearFilters: () => _clearFilters(ref),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryBulkActionBar(
                selectedCount: selectedEmployees.length,
                visibleCount: tableView.visibleCount,
                onSelectVisible:
                    () => ref
                        .read(
                          employeeDirectoryTableSelectedIdsProvider.notifier,
                        )
                        .selectMany(
                          tableView.rows.map((employee) => employee.id),
                        ),
                onClearSelection:
                    ref
                        .read(
                          employeeDirectoryTableSelectedIdsProvider.notifier,
                        )
                        .clear,
                onExportSelected:
                    () => _exportEmployees(
                      context,
                      ref,
                      selectedEmployees,
                      asOfDate,
                    ),
                onStatusChanged:
                    (status) => _updateSelectedStatus(
                      context,
                      ref,
                      selectedEmployees,
                      status,
                    ),
                onRemoveSelected:
                    () => _confirmDeleteEmployees(
                      context,
                      ref,
                      selectedEmployees,
                    ),
              ),
              const SizedBox(height: 16),
              EmployeeDirectorySelectionReviewPanel(review: selectionReview),
              const SizedBox(height: 16),
              EmployeeDirectoryBulkProfileUpdatePanel(
                selectedCount: selectedEmployees.length,
                draft: bulkProfileUpdateDraft,
                onManagerChanged:
                    ref
                        .read(
                          employeeDirectoryBulkProfileUpdateDraftProvider
                              .notifier,
                        )
                        .setManager,
                onDepartmentChanged:
                    ref
                        .read(
                          employeeDirectoryBulkProfileUpdateDraftProvider
                              .notifier,
                        )
                        .setDepartment,
                onLocationChanged:
                    ref
                        .read(
                          employeeDirectoryBulkProfileUpdateDraftProvider
                              .notifier,
                        )
                        .setLocation,
                onAuditNoteChanged:
                    ref
                        .read(
                          employeeDirectoryBulkProfileUpdateDraftProvider
                              .notifier,
                        )
                        .setAuditNote,
                canSubmit: bulkProfileUpdatePreview.canApply,
                onSubmit:
                    () => _applyBulkProfileUpdate(
                      context,
                      ref,
                      bulkProfileUpdateDraft,
                      bulkProfileUpdatePreview,
                    ),
                onClear:
                    ref
                        .read(
                          employeeDirectoryBulkProfileUpdateDraftProvider
                              .notifier,
                        )
                        .clear,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryBulkProfileUpdatePreviewPanel(
                preview: bulkProfileUpdatePreview,
                onApprovalChanged:
                    (approved) => ref
                        .read(
                          employeeDirectoryBulkProfileUpdateDraftProvider
                              .notifier,
                        )
                        .setPreviewApproved(
                          approved,
                          approvalSignature: bulkProfileUpdatePreview.signature,
                        ),
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryActivityPanel(
                summary: activitySummary,
                events: recentActivity,
              ),
              const SizedBox(height: 16),
              EmployeeDirectoryTablePanel(
                view: tableView,
                layout: tableLayout,
                selectedEmployeeIds: selectedEmployeeIds,
                asOfDate: asOfDate,
                onSort: (field) {
                  _markManualTableChange(ref);
                  ref
                      .read(employeeDirectoryTableSortProvider.notifier)
                      .state = ref
                      .read(employeeDirectoryTableSortProvider)
                      .toggled(field);
                },
                onSelectionChanged:
                    (employee, selected) => ref
                        .read(
                          employeeDirectoryTableSelectedIdsProvider.notifier,
                        )
                        .setSelected(employee.id, selected),
                onOpenProfile:
                    (employee) =>
                        _showEmployeeDetails(context, ref, employee, asOfDate),
                onEdit: (employee) => _editEmployee(context, ref, employee),
                onMessage:
                    (employee) =>
                        _showMessage(context, 'Message ${employee.name}'),
                onSchedule:
                    (employee) =>
                        _showMessage(context, 'Schedule ${employee.name}'),
                onRemove:
                    (employee) =>
                        _confirmDeleteEmployee(context, ref, employee),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEmployee(context, ref),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add employee'),
      ),
    );
  }

  void _showEmployeeDetails(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryMember employee,
    DateTime asOfDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder:
          (sheetContext) => EmployeeDirectoryDetailSheet(
            employee: employee,
            asOfDate: asOfDate,
            onMessage: () {
              Navigator.pop(sheetContext);
              _showMessage(context, 'Message ${employee.name}');
            },
            onEdit: () {
              Navigator.pop(sheetContext);
              _editEmployee(context, ref, employee);
            },
            onSchedule: () {
              Navigator.pop(sheetContext);
              _showMessage(context, 'Schedule ${employee.name}');
            },
          ),
    );
  }

  void _confirmDeleteEmployee(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryMember employee,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove employee'),
            content: Text(
              'Remove ${employee.name} from this directory workspace?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  ref
                      .read(employeeDirectoryMembersProvider.notifier)
                      .removeMember(employee.id);
                  ref
                      .read(employeeDirectoryActivityProvider.notifier)
                      .recordRemoved(employee);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteEmployees(
    BuildContext context,
    WidgetRef ref,
    List<EmployeeDirectoryMember> employees,
  ) {
    if (employees.isEmpty) {
      _showMessage(context, 'Select employees before removing');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove selected employees'),
            content: Text(
              'Remove ${employees.length} selected employees from this directory workspace?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  final ids = employees.map((employee) => employee.id).toList();
                  final directory = ref.read(
                    employeeDirectoryMembersProvider.notifier,
                  );
                  for (final id in ids) {
                    directory.removeMember(id);
                  }
                  ref
                      .read(employeeDirectoryActivityProvider.notifier)
                      .recordRemovedMany(employees);
                  ref
                      .read(employeeDirectoryTableSelectedIdsProvider.notifier)
                      .removeMany(ids);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _updateSelectedStatus(
    BuildContext context,
    WidgetRef ref,
    List<EmployeeDirectoryMember> employees,
    EmployeeDirectoryStatus status,
  ) {
    if (employees.isEmpty) {
      _showMessage(context, 'Select employees before updating status');
      return;
    }

    final directory = ref.read(employeeDirectoryMembersProvider.notifier);
    for (final employee in employees) {
      directory.updateMember(employee.copyWith(status: status));
    }
    ref
        .read(employeeDirectoryActivityProvider.notifier)
        .recordBulkStatusChanged(members: employees, status: status);
    ref.read(employeeDirectoryTableSelectedIdsProvider.notifier).clear();
    _showMessage(
      context,
      '${employees.length} employees marked ${status.label}',
    );
  }

  void _applyBulkProfileUpdate(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryBulkProfileUpdateDraft draft,
    EmployeeDirectoryBulkProfileUpdatePreview preview,
  ) {
    if (!preview.canApply) {
      _showMessage(context, preview.applyBlockerMessage);
      return;
    }

    final directory = ref.read(employeeDirectoryMembersProvider.notifier);
    final changedEmployees = preview.rows.map((row) => row.member).toList();
    for (final employee in changedEmployees) {
      directory.updateMember(draft.applyTo(employee));
    }
    ref
        .read(employeeDirectoryActivityProvider.notifier)
        .recordBulkProfileUpdated(
          members: changedEmployees,
          changedFields: draft.changedFieldLabels,
          auditNote: draft.auditNote,
        );
    ref.read(employeeDirectoryTableSelectedIdsProvider.notifier).clear();
    ref.read(employeeDirectoryBulkProfileUpdateDraftProvider.notifier).clear();
    _showMessage(context, '${_profiles(changedEmployees.length)} updated');
  }

  void _exportEmployees(
    BuildContext context,
    WidgetRef ref,
    List<EmployeeDirectoryMember> employees,
    DateTime asOfDate,
  ) {
    if (employees.isEmpty) {
      _showMessage(context, 'No employee rows available to export');
      return;
    }

    final export = EmployeeDirectoryTableCsvExport.fromMembers(
      members: employees,
      asOfDate: asOfDate,
    );
    ref.read(employeeDirectoryTableLastCsvExportProvider.notifier).state =
        export;
    ref
        .read(employeeDirectoryActivityProvider.notifier)
        .recordExported(export.rowCount);
    _showMessage(context, '${export.rowCount} employee rows prepared as CSV');
  }

  void _addEmployee(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder:
          (sheetContext) => EmployeeDirectoryIntakeSheet(
            initialJoiningDate: ref.read(employeeDirectoryAsOfDateProvider),
            onSubmit: (draft) {
              final member = draft.toMember(
                id: _nextDirectoryMemberId(ref),
                avatarUrl: _avatarForDraft(draft),
              );
              ref
                  .read(employeeDirectoryMembersProvider.notifier)
                  .addMember(member);
              ref
                  .read(employeeDirectoryActivityProvider.notifier)
                  .recordCreated(member);
              Navigator.of(sheetContext).pop();
              _showMessage(context, '${member.name} added to the directory');
            },
          ),
    );
  }

  void _editEmployee(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryMember employee,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder:
          (sheetContext) => EmployeeDirectoryIntakeSheet(
            initialJoiningDate: ref.read(employeeDirectoryAsOfDateProvider),
            initialDraft: EmployeeDirectoryIntakeDraft.fromMember(employee),
            mode: EmployeeDirectoryIntakeSheetMode.edit,
            onSubmit: (draft) {
              final updatedMember = draft.toMember(
                id: employee.id,
                avatarUrl: employee.avatarUrl,
              );
              ref
                  .read(employeeDirectoryMembersProvider.notifier)
                  .updateMember(updatedMember);
              ref
                  .read(employeeDirectoryActivityProvider.notifier)
                  .recordUpdated(before: employee, after: updatedMember);
              Navigator.of(sheetContext).pop();
              _showMessage(context, '${updatedMember.name} profile updated');
            },
          ),
    );
  }

  void _importEmployees(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryImportPreview preview,
  ) {
    final validRows = preview.validRows;
    if (validRows.isEmpty) {
      _showMessage(context, 'No valid employee rows ready to import');
      return;
    }

    final directory = ref.read(employeeDirectoryMembersProvider.notifier);
    var nextId = _nextDirectoryMemberNumber(ref);
    for (final row in validRows) {
      final member = row.draft.toMember(
        id: nextId.toString(),
        avatarUrl: _avatarForDraft(row.draft),
      );
      directory.addMember(member);
      nextId += 1;
    }

    ref
        .read(employeeDirectoryActivityProvider.notifier)
        .recordImported(validRows.length);
    ref.read(employeeDirectoryImportCsvProvider.notifier).state = '';
    _showMessage(context, '${_profiles(validRows.length)} imported');
  }

  void _applyQualityFix(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryQualityFixReview review,
  ) {
    if (!review.canSubmit) {
      _showMessage(
        context,
        review.errors.isEmpty
            ? 'Select a quality issue to fix'
            : review.errors.first,
      );
      return;
    }

    final before = review.member!;
    final after = review.applyToMember();
    ref.read(employeeDirectoryMembersProvider.notifier).updateMember(after);
    ref
        .read(employeeDirectoryActivityProvider.notifier)
        .recordUpdated(before: before, after: after);
    ref.read(employeeDirectoryQualityFixDraftProvider.notifier).clear();
    _showMessage(context, '${after.name} quality issue fixed');
  }

  void _submitQualityGateSignoff(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryQualityGateSignoffReview review,
    DateTime signedAt,
  ) {
    if (!review.canSubmit) {
      _showMessage(
        context,
        review.errors.isEmpty
            ? 'Roster gate is not ready for sign-off'
            : review.errors.first,
      );
      return;
    }

    final id =
        'quality-gate-${ref.read(employeeDirectoryQualityGateSignoffsProvider).length + 1}';
    final signoff = review.toSignoff(id: id, signedAt: signedAt);
    ref
        .read(employeeDirectoryQualityGateSignoffsProvider.notifier)
        .add(signoff);
    ref.read(employeeDirectoryQualityGateSignoffDraftProvider.notifier).clear();
    _showMessage(context, 'Roster gate signed off by ${signoff.reviewer}');
  }

  void _publishRosterRelease(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterPublishReview review,
    DateTime publishedAt,
  ) {
    if (!review.canPublish) {
      _showMessage(
        context,
        review.errors.isEmpty
            ? 'Roster release packet is not ready'
            : review.errors.first,
      );
      return;
    }

    final id =
        'roster-release-${ref.read(employeeDirectoryRosterReleasesProvider).length + 1}';
    final release = review.toRelease(id: id, publishedAt: publishedAt);
    ref.read(employeeDirectoryRosterReleasesProvider.notifier).add(release);
    ref.read(employeeDirectoryRosterPublishDraftProvider.notifier).clear();
    _showMessage(context, '${release.versionLabel} roster packet published');
  }

  void _acknowledgeRosterHandoff(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterHandoffReview review,
    EmployeeDirectoryRosterHandoffRecipient recipient,
    DateTime acknowledgedAt,
  ) {
    final release = review.latestRelease;
    if (release == null) {
      _showMessage(context, 'Publish a roster packet before handoff');
      return;
    }

    ref
        .read(employeeDirectoryRosterHandoffRecordsProvider.notifier)
        .acknowledge(release, recipient.id, acknowledgedAt);
    _showMessage(
      context,
      '${recipient.teamName} acknowledged ${release.versionLabel}',
    );
  }

  void _resendRosterHandoff(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterHandoffReview review,
    EmployeeDirectoryRosterHandoffRecipient recipient,
    DateTime sentAt,
  ) {
    final release = review.latestRelease;
    if (release == null) {
      _showMessage(context, 'Publish a roster packet before handoff');
      return;
    }

    ref
        .read(employeeDirectoryRosterHandoffRecordsProvider.notifier)
        .resend(release, recipient.id, sentAt);
    _showMessage(
      context,
      '${recipient.teamName} reminder sent for ${release.versionLabel}',
    );
  }

  void _escalateRosterHandoff(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterHandoffReview review,
    EmployeeDirectoryRosterHandoffRecipient recipient,
    DateTime escalatedAt,
  ) {
    final release = review.latestRelease;
    if (release == null) {
      _showMessage(context, 'Publish a roster packet before handoff');
      return;
    }

    ref
        .read(employeeDirectoryRosterHandoffRecordsProvider.notifier)
        .escalate(release, recipient.id, escalatedAt);
    _showMessage(
      context,
      '${recipient.teamName} escalated for ${release.versionLabel}',
    );
  }

  void _syncRosterPayroll(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterPayrollSyncReview review,
    DateTime syncedAt,
  ) {
    if (!review.canSync) {
      _showMessage(
        context,
        review.errors.isEmpty
            ? 'Roster payroll sync is not ready'
            : review.errors.first,
      );
      return;
    }

    final id =
        'payroll-sync-${ref.read(employeeDirectoryRosterPayrollSyncRecordsProvider).length + 1}';
    final record = review.toRecord(id: id, syncedAt: syncedAt);
    ref
        .read(employeeDirectoryRosterPayrollSyncRecordsProvider.notifier)
        .add(record);
    ref.read(employeeDirectoryRosterPayrollSyncDraftProvider.notifier).clear();
    _showMessage(context, '${record.releaseVersion} synced to payroll');
  }

  void _stageRosterPayrollImport(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterPayrollImportReview review,
    DateTime stagedAt,
  ) {
    if (!review.canStage) {
      _showMessage(
        context,
        review.errors.isEmpty
            ? 'Roster payroll import is not ready'
            : review.errors.first,
      );
      return;
    }

    final id =
        'payroll-import-${ref.read(employeeDirectoryRosterPayrollImportBatchesProvider).length + 1}';
    final batch = review.toBatch(id: id, stagedAt: stagedAt);
    ref
        .read(employeeDirectoryRosterPayrollImportBatchesProvider.notifier)
        .add(batch);
    ref
        .read(employeeDirectoryRosterPayrollImportDraftProvider.notifier)
        .clear();
    _showMessage(context, '${batch.batchLabel} staged for payroll import');
  }

  void _validateRosterPayrollImport(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterPayrollValidationReview review,
    DateTime validatedAt,
  ) {
    if (!review.canValidate) {
      _showMessage(
        context,
        review.errors.isEmpty
            ? 'Payroll import validation is not ready'
            : review.errors.first,
      );
      return;
    }

    final id =
        'payroll-validation-${ref.read(employeeDirectoryRosterPayrollValidationRecordsProvider).length + 1}';
    final record = review.toRecord(id: id, validatedAt: validatedAt);
    ref
        .read(employeeDirectoryRosterPayrollValidationRecordsProvider.notifier)
        .add(record);
    ref
        .read(employeeDirectoryRosterPayrollValidationDraftProvider.notifier)
        .clear();
    _showMessage(context, '${record.batchLabel} payroll import validated');
  }

  void _launchRosterPayrollRun(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryRosterPayrollRunKickoffReview review,
    DateTime launchedAt,
  ) {
    if (!review.canLaunch) {
      _showMessage(
        context,
        review.errors.isEmpty
            ? 'Payroll run kickoff is not ready'
            : review.errors.first,
      );
      return;
    }

    final id =
        'payroll-run-kickoff-${ref.read(employeeDirectoryRosterPayrollRunKickoffRecordsProvider).length + 1}';
    final record = review.toRecord(id: id, launchedAt: launchedAt);
    ref
        .read(employeeDirectoryRosterPayrollRunKickoffRecordsProvider.notifier)
        .add(record);
    ref
        .read(employeeDirectoryRosterPayrollRunKickoffDraftProvider.notifier)
        .clear();
    _showMessage(context, '${record.runReference} payroll run launched');
  }

  void _runPayrollRunConsoleCommand(
    BuildContext context,
    WidgetRef ref,
    EmployeePayrollRunConsoleCommandType type,
    Set<String> selectedEmployeeIds,
  ) {
    final result = ref
        .read(employeePayrollRunConsoleCommandControllerProvider)
        .run(type, targetEmployeeIds: selectedEmployeeIds);
    _showMessage(context, result.message);
  }

  void _clearFilters(WidgetRef ref) {
    final allEmployeesPreset = ref
        .read(employeeDirectoryTablePresetsProvider)
        .firstWhere(
          (preset) => preset.id == EmployeeDirectoryTablePresetId.allEmployees,
        );
    ref
        .read(employeeDirectoryTablePresetControllerProvider)
        .apply(allEmployeesPreset);
    ref.read(employeeDirectorySavedViewControllerProvider).clearActive();
  }

  void _saveCustomSavedView(BuildContext context, WidgetRef ref) {
    final result =
        ref
            .read(employeeDirectorySavedViewControllerProvider)
            .saveCurrentView();
    if (!result.isSuccess) {
      _showMessage(context, result.errors.first);
      return;
    }

    _showMessage(context, '${result.view!.name} saved view captured');
  }

  void _applyCustomSavedView(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectorySavedView view,
  ) {
    ref.read(employeeDirectorySavedViewControllerProvider).apply(view);
    _showMessage(context, '${view.name} view applied');
  }

  void _deleteCustomSavedView(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectorySavedView view,
  ) {
    ref.read(employeeDirectorySavedViewControllerProvider).delete(view.id);
    _showMessage(context, '${view.name} saved view deleted');
  }

  void _assignAction(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryActionItem action,
  ) {
    const owner = 'People Ops Lead';
    ref
        .read(employeeDirectoryActionOverridesProvider.notifier)
        .assign(action, owner);
    _recordActionQueueEvent(
      ref,
      action: action,
      statusLabel: 'assigned',
      detail: '${action.title} assigned to $owner.',
    );
    _showMessage(context, '${action.title} assigned to $owner');
  }

  void _startAction(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryActionItem action,
  ) {
    ref.read(employeeDirectoryActionOverridesProvider.notifier).start(action);
    _recordActionQueueEvent(
      ref,
      action: action,
      statusLabel: 'started',
      detail: '${action.title} moved into progress.',
    );
    _showMessage(context, '${action.title} started');
  }

  void _resolveAction(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryActionItem action,
  ) {
    ref.read(employeeDirectoryActionOverridesProvider.notifier).resolve(action);
    _recordActionQueueEvent(
      ref,
      action: action,
      statusLabel: 'resolved',
      detail:
          '${action.title} resolved for ${action.affectedCount} affected profiles.',
    );
    _showMessage(context, '${action.title} resolved');
  }

  void _snoozeAction(
    BuildContext context,
    WidgetRef ref,
    EmployeeDirectoryActionItem action,
  ) {
    ref.read(employeeDirectoryActionOverridesProvider.notifier).snooze(action);
    _recordActionQueueEvent(
      ref,
      action: action,
      statusLabel: 'snoozed',
      detail: '${action.title} snoozed for three more days.',
    );
    _showMessage(context, '${action.title} snoozed');
  }

  void _recordActionQueueEvent(
    WidgetRef ref, {
    required EmployeeDirectoryActionItem action,
    required String statusLabel,
    required String detail,
  }) {
    ref
        .read(employeeDirectoryActivityProvider.notifier)
        .recordActionUpdated(
          title: '${action.title} $statusLabel',
          detail: detail,
          affectedCount: action.affectedCount,
        );
  }

  void _markManualTableChange(WidgetRef ref) {
    ref.read(employeeDirectoryTablePresetControllerProvider).markManualChange();
    ref.read(employeeDirectorySavedViewControllerProvider).clearActive();
  }

  void _applyTablePreset(WidgetRef ref, EmployeeDirectoryTablePreset preset) {
    ref.read(employeeDirectoryTablePresetControllerProvider).apply(preset);
    ref.read(employeeDirectorySavedViewControllerProvider).clearActive();
    ref.read(employeeDirectoryTableLayoutProvider.notifier).reset();
  }

  void _toggleTableColumn(WidgetRef ref, EmployeeDirectoryTableColumn column) {
    _markManualTableChange(ref);
    ref
        .read(employeeDirectoryTableLayoutProvider.notifier)
        .toggleColumn(column);
  }

  void _setTableDensity(WidgetRef ref, EmployeeDirectoryTableDensity density) {
    _markManualTableChange(ref);
    ref.read(employeeDirectoryTableLayoutProvider.notifier).setDensity(density);
  }

  void _resetTableLayout(WidgetRef ref) {
    _markManualTableChange(ref);
    ref.read(employeeDirectoryTableLayoutProvider.notifier).reset();
  }

  void _applyQualityFilter(
    WidgetRef ref,
    EmployeeDirectoryQualityFilter filter,
  ) {
    _markManualTableChange(ref);
    ref.read(employeeDirectoryQualityFilterProvider.notifier).state = filter;
    ref.read(employeeDirectoryTableSelectedIdsProvider.notifier).clear();
  }

  String _nextDirectoryMemberId(WidgetRef ref) {
    return _nextDirectoryMemberNumber(ref).toString();
  }

  int _nextDirectoryMemberNumber(WidgetRef ref) {
    var nextId = 1;
    for (final member in ref.read(employeeDirectoryMembersProvider)) {
      final parsed = int.tryParse(member.id);
      if (parsed != null && parsed >= nextId) {
        nextId = parsed + 1;
      }
    }
    return nextId;
  }

  String _avatarForDraft(EmployeeDirectoryIntakeDraft draft) {
    final signature = draft.name.trim().codeUnits.fold<int>(
      0,
      (total, codeUnit) => total + codeUnit,
    );
    final avatarIndex = (signature % 8) + 1;
    return 'https://randomuser.me/api/portraits/lego/$avatarIndex.jpg';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _profiles(int count) {
    return count == 1 ? '1 employee profile' : '$count employee profiles';
  }
}
