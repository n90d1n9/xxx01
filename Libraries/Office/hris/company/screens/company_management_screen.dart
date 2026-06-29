import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_approval_rule.dart';
import '../models/company_change_request.dart';
import '../models/company_document_audit_event.dart';
import '../models/company_document_audit_filter.dart';
import '../models/company_governance_action_item.dart';
import '../models/company_governance_follow_up_audit.dart';
import '../models/company_governance_follow_up_cadence.dart';
import '../models/company_governance_follow_up_policy.dart';
import '../models/company_governance_follow_up_policy_approval.dart';
import '../models/company_governance_follow_up_policy_history.dart';
import '../models/company_governance_follow_up_policy_impact.dart';
import '../models/company_governance_follow_up_policy_audit.dart';
import '../models/company_governance_owner_handoff_audit.dart';
import '../models/company_governance_saved_view.dart';
import '../models/company_headcount_requisition_activity.dart';
import '../models/company_operating_readiness.dart';
import '../models/employee_document_digest_preview.dart';
import '../models/employee_document_escalation_preview.dart';
import '../states/company_management_provider.dart';
import '../widgets/company_approval_rule_form_panel.dart';
import '../widgets/company_approval_rule_registry_panel.dart';
import '../widgets/company_change_request_board.dart';
import '../widgets/company_change_request_form_panel.dart';
import '../widgets/company_compensation_band_form_panel.dart';
import '../widgets/company_compensation_band_registry_panel.dart';
import '../widgets/company_contract_template_catalog_panel.dart';
import '../widgets/company_contract_template_form_panel.dart';
import '../widgets/company_control_form_panel.dart';
import '../widgets/company_control_register_panel.dart';
import '../widgets/company_cost_center_form_panel.dart';
import '../widgets/company_cost_center_registry_panel.dart';
import '../widgets/company_document_audit_detail_panel.dart';
import '../widgets/company_document_audit_timeline_panel.dart';
import '../widgets/company_document_form_panel.dart';
import '../widgets/company_document_requirement_form_panel.dart';
import '../widgets/company_document_requirement_registry_panel.dart';
import '../widgets/company_document_registry_panel.dart';
import '../widgets/company_document_renewal_board.dart';
import '../widgets/company_document_renewal_form_panel.dart';
import '../widgets/company_employee_document_gap_panel.dart';
import '../widgets/company_employee_document_workload_panel.dart';
import '../widgets/company_employer_account_form_panel.dart';
import '../widgets/company_employer_account_registry_panel.dart';
import '../widgets/company_entity_lifecycle_board.dart';
import '../widgets/company_entity_lifecycle_form_panel.dart';
import '../widgets/company_filing_calendar_panel.dart';
import '../widgets/company_filing_form_panel.dart';
import '../widgets/company_governance_follow_up_cadence_panel.dart';
import '../widgets/company_governance_follow_up_policy_approval_panel.dart';
import '../widgets/company_governance_follow_up_policy_history_panel.dart';
import '../widgets/company_governance_follow_up_policy_panel.dart';
import '../widgets/company_governance_action_queue_panel.dart';
import '../widgets/company_governance_command_brief_panel.dart';
import '../widgets/company_governance_owner_handoff_history_panel.dart';
import '../widgets/company_governance_owner_handoff_panel.dart';
import '../widgets/company_governance_owner_load_panel.dart';
import '../widgets/company_governance_saved_views_panel.dart';
import '../widgets/company_governance_contact_directory_panel.dart';
import '../widgets/company_governance_contact_form_panel.dart';
import '../widgets/company_headcount_requisition_activity_panel.dart';
import '../widgets/company_headcount_requisition_board.dart';
import '../widgets/company_headcount_requisition_form_panel.dart';
import '../widgets/company_job_profile_catalog_panel.dart';
import '../widgets/company_job_profile_form_panel.dart';
import '../widgets/company_legal_entity_form_panel.dart';
import '../widgets/company_legal_entity_registry_panel.dart';
import '../widgets/company_offboarding_pack_form_panel.dart';
import '../widgets/company_offboarding_pack_registry_panel.dart';
import '../widgets/company_onboarding_pack_form_panel.dart';
import '../widgets/company_onboarding_pack_registry_panel.dart';
import '../widgets/company_operating_readiness_form_panel.dart';
import '../widgets/company_operating_readiness_panel.dart';
import '../widgets/company_org_structure_panel.dart';
import '../widgets/company_org_unit_form_panel.dart';
import '../widgets/company_policy_settings_panel.dart';
import '../widgets/company_position_control_form_panel.dart';
import '../widgets/company_position_control_registry_panel.dart';
import '../widgets/company_probation_plan_form_panel.dart';
import '../widgets/company_probation_plan_registry_panel.dart';
import '../widgets/company_profile_form_panel.dart';
import '../widgets/company_signatory_form_panel.dart';
import '../widgets/company_signatory_matrix_panel.dart';
import '../widgets/company_summary_grid.dart';
import '../widgets/company_vendor_agreement_form_panel.dart';
import '../widgets/company_vendor_agreement_registry_panel.dart';
import '../widgets/company_work_location_form_panel.dart';
import '../widgets/company_work_location_registry_panel.dart';
import '../widgets/company_workforce_plan_panel.dart';
import '../widgets/employee_document_digest_history_panel.dart';
import '../widgets/employee_document_digest_preview_dialog.dart';
import '../widgets/employee_document_escalation_follow_up_panel.dart';
import '../widgets/employee_document_escalation_history_panel.dart';
import '../widgets/employee_document_escalation_panel.dart';
import '../widgets/employee_document_escalation_preview_dialog.dart';

class CompanyManagementScreen extends ConsumerWidget {
  const CompanyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entities = ref.watch(companyEntitiesProvider);
    final selectedEntity = ref.watch(companySelectedEntityProvider);
    final attentionOnly = ref.watch(companyAttentionOnlyProvider);
    final profile = ref.watch(companyProfileProvider);
    final profileDraft = ref.watch(companyProfileDraftProvider);
    final legalEntityDraft = ref.watch(companyLegalEntityDraftProvider);
    final orgUnitDraft = ref.watch(companyOrgUnitDraftProvider);
    final locationDraft = ref.watch(companyWorkLocationDraftProvider);
    final costCenterDraft = ref.watch(companyCostCenterDraftProvider);
    final positionControlDraft = ref.watch(companyPositionControlDraftProvider);
    final headcountRequisitionDraft = ref.watch(
      companyHeadcountRequisitionDraftProvider,
    );
    final compensationBandDraft = ref.watch(
      companyCompensationBandDraftProvider,
    );
    final jobProfileDraft = ref.watch(companyJobProfileDraftProvider);
    final contractTemplateDraft = ref.watch(
      companyContractTemplateDraftProvider,
    );
    final onboardingPackDraft = ref.watch(companyOnboardingPackDraftProvider);
    final probationPlanDraft = ref.watch(companyProbationPlanDraftProvider);
    final offboardingPackDraft = ref.watch(companyOffboardingPackDraftProvider);
    final documentRequirementDraft = ref.watch(
      companyDocumentRequirementDraftProvider,
    );
    final approvalRuleDraft = ref.watch(companyApprovalRuleDraftProvider);
    final documentDraft = ref.watch(companyDocumentDraftProvider);
    final renewalDraft = ref.watch(companyDocumentRenewalDraftProvider);
    final operatingDraft = ref.watch(companyOperatingReadinessDraftProvider);
    final governanceContactDraft = ref.watch(
      companyGovernanceContactDraftProvider,
    );
    final lifecycleDraft = ref.watch(companyEntityLifecycleDraftProvider);
    final controlDraft = ref.watch(companyControlDraftProvider);
    final employerAccountDraft = ref.watch(companyEmployerAccountDraftProvider);
    final vendorAgreementDraft = ref.watch(companyVendorAgreementDraftProvider);
    final filingDraft = ref.watch(companyFilingDraftProvider);
    final signatoryDraft = ref.watch(companySignatoryDraftProvider);
    final changeDraft = ref.watch(companyChangeRequestDraftProvider);
    final summary = ref.watch(companyManagementSummaryProvider);
    final asOfDate = ref.watch(companyAsOfDateProvider);
    final legalEntities = ref.watch(filteredCompanyLegalEntitiesProvider);
    final locations = ref.watch(filteredCompanyWorkLocationsProvider);
    final costCenters = ref.watch(filteredCompanyCostCentersProvider);
    final positionControls = ref.watch(filteredCompanyPositionControlsProvider);
    final workforcePlan = ref.watch(companyWorkforcePlanProvider);
    final headcountRequisitions = ref.watch(
      filteredCompanyHeadcountRequisitionsProvider,
    );
    final headcountActivityTimeline = ref.watch(
      companyHeadcountRequisitionActivityTimelineProvider,
    );
    final compensationBands = ref.watch(
      filteredCompanyCompensationBandsProvider,
    );
    final jobProfiles = ref.watch(filteredCompanyJobProfilesProvider);
    final contractTemplates = ref.watch(
      filteredCompanyContractTemplatesProvider,
    );
    final onboardingPacks = ref.watch(filteredCompanyOnboardingPacksProvider);
    final probationPlans = ref.watch(filteredCompanyProbationPlansProvider);
    final offboardingPacks = ref.watch(filteredCompanyOffboardingPacksProvider);
    final documentRequirements = ref.watch(
      filteredCompanyDocumentRequirementsProvider,
    );
    final employeeDocumentGaps = ref.watch(
      filteredCompanyEmployeeDocumentGapsProvider,
    );
    final employeeDocumentGapRecommendations = ref.watch(
      companyEmployeeDocumentGapRecommendationsProvider,
    );
    final employeeDocumentWorkloads = ref.watch(
      companyEmployeeDocumentWorkloadsProvider,
    );
    final employeeDocumentWorkloadDigestStatuses = ref.watch(
      companyEmployeeDocumentWorkloadDigestStatusesProvider,
    );
    final employeeDocumentEscalationPlans = ref.watch(
      companyEmployeeDocumentEscalationPlansProvider,
    );
    final employeeDocumentEscalationHistory = ref.watch(
      companyEmployeeDocumentEscalationHistoryProvider,
    );
    final employeeDocumentEscalationFollowUps = ref.watch(
      companyEmployeeDocumentEscalationFollowUpsProvider,
    );
    final employeeDocumentDigestHistory = ref.watch(
      companyEmployeeDocumentDigestHistoryProvider,
    );
    final approvalRules = ref.watch(filteredCompanyApprovalRulesProvider);
    final allDocuments = ref.watch(companyDocumentsProvider);
    final documents = ref.watch(filteredCompanyDocumentsProvider);
    final renewalTasks = ref.watch(filteredCompanyDocumentRenewalsProvider);
    final auditEvents = ref.watch(filteredCompanyDocumentAuditEventsProvider);
    final auditSummary = ref.watch(companyDocumentAuditActivitySummaryProvider);
    final auditFilter = ref.watch(companyDocumentAuditFilterProvider);
    final selectedAuditEventId = ref.watch(
      companySelectedDocumentAuditEventIdProvider,
    );
    final auditDetail = ref.watch(companySelectedDocumentAuditDetailProvider);
    final operatingReadiness = ref.watch(
      filteredCompanyOperatingReadinessProvider,
    );
    final governanceContacts = ref.watch(
      filteredCompanyGovernanceContactsProvider,
    );
    final lifecycles = ref.watch(filteredCompanyEntityLifecyclesProvider);
    final controls = ref.watch(filteredCompanyControlsProvider);
    final employerAccounts = ref.watch(filteredCompanyEmployerAccountsProvider);
    final vendorAgreements = ref.watch(filteredCompanyVendorAgreementsProvider);
    final filings = ref.watch(filteredCompanyFilingsProvider);
    final signatories = ref.watch(filteredCompanySignatoriesProvider);
    final governanceActions = ref.watch(companyGovernanceActionItemsProvider);
    final governanceOwnerLoads = ref.watch(companyGovernanceOwnerLoadsProvider);
    final selectedGovernanceOwner = ref.watch(
      companySelectedGovernanceOwnerProvider,
    );
    final governanceOwnerHandoff = ref.watch(
      companyGovernanceOwnerHandoffProvider,
    );
    final governanceOwnerHandoffRecord = ref.watch(
      companySelectedGovernanceOwnerHandoffRecordProvider,
    );
    final governanceOwnerHandoffHistory = ref.watch(
      companyGovernanceOwnerHandoffHistoryProvider,
    );
    final governanceFollowUpLanes = ref.watch(
      companyGovernanceFollowUpCadenceProvider,
    );
    final governanceFollowUpPolicy = ref.watch(
      companyGovernanceFollowUpPolicyProvider,
    );
    final governanceFollowUpPolicyDraft = ref.watch(
      companyGovernanceFollowUpPolicyDraftProvider,
    );
    final governanceFollowUpPolicyImpact = ref.watch(
      companyGovernanceFollowUpPolicyImpactProvider,
    );
    final governanceFollowUpPolicyApprovalQueue = ref.watch(
      companyGovernanceFollowUpPolicyApprovalQueueProvider,
    );
    final governanceFollowUpPolicyHistory = ref.watch(
      companyGovernanceFollowUpPolicyHistoryProvider,
    );
    final governanceSavedViews = ref.watch(companyGovernanceSavedViewsProvider);
    final selectedGovernanceSavedViewType = ref.watch(
      companySelectedGovernanceSavedViewProvider,
    );
    final selectedGovernanceSavedView = ref.watch(
      companySelectedGovernanceSavedViewDetailProvider,
    );
    final governanceCommandBrief = ref.watch(
      companyGovernanceCommandBriefProvider,
    );
    final changeRequests = ref.watch(filteredCompanyChangeRequestsProvider);
    final orgUnits = ref.watch(filteredCompanyOrgUnitsProvider);
    final policies = ref.watch(filteredCompanyPoliciesProvider);
    final orgUnitNames =
        ref
            .watch(companyOrgUnitsProvider)
            .map((unit) => unit.name)
            .toSet()
            .toList()
          ..sort();
    final jobProfileCodes =
        ref
            .watch(companyJobProfilesProvider)
            .map((profile) => profile.jobCode)
            .where((code) => code.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final positionControlIds =
        ref
            .watch(companyPositionControlsProvider)
            .map((position) => position.id)
            .where((id) => id.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final costCenterCodes =
        ref
            .watch(companyCostCentersProvider)
            .map((center) => center.code)
            .where((code) => code.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final contractTemplateNames =
        ref
            .watch(companyContractTemplatesProvider)
            .map((template) => template.templateName)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final onboardingPackNames =
        ref
            .watch(companyOnboardingPacksProvider)
            .map((pack) => pack.packName)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final probationPlanNames =
        ref
            .watch(companyProbationPlansProvider)
            .map((plan) => plan.planName)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final offboardingPackNames =
        ref
            .watch(companyOffboardingPacksProvider)
            .map((pack) => pack.packName)
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final compensationBandCodes =
        ref
            .watch(companyCompensationBandsProvider)
            .map((band) => band.bandCode)
            .where((band) => band.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Company Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(companyProfileDraftProvider);
              ref.invalidate(companyLegalEntityDraftProvider);
              ref.invalidate(companyOrgUnitDraftProvider);
              ref.invalidate(companyWorkLocationDraftProvider);
              ref.invalidate(companyCostCenterDraftProvider);
              ref.invalidate(companyPositionControlDraftProvider);
              ref.invalidate(companyHeadcountRequisitionDraftProvider);
              ref.invalidate(companyCompensationBandDraftProvider);
              ref.invalidate(companyJobProfileDraftProvider);
              ref.invalidate(companyContractTemplateDraftProvider);
              ref.invalidate(companyOnboardingPackDraftProvider);
              ref.invalidate(companyProbationPlanDraftProvider);
              ref.invalidate(companyOffboardingPackDraftProvider);
              ref.invalidate(companyDocumentRequirementDraftProvider);
              ref.invalidate(companyApprovalRuleDraftProvider);
              ref.invalidate(companyDocumentDraftProvider);
              ref.invalidate(companyDocumentRenewalDraftProvider);
              ref.invalidate(companyOperatingReadinessDraftProvider);
              ref.invalidate(companyGovernanceContactDraftProvider);
              ref.invalidate(companyEntityLifecycleDraftProvider);
              ref.invalidate(companyControlDraftProvider);
              ref.invalidate(companyEmployerAccountDraftProvider);
              ref.invalidate(companyVendorAgreementDraftProvider);
              ref.invalidate(companyFilingDraftProvider);
              ref.invalidate(companySignatoryDraftProvider);
              ref.invalidate(companyChangeRequestDraftProvider);
              ref.invalidate(companyGovernanceFollowUpPolicyDraftProvider);
              ref.invalidate(companySelectedGovernanceOwnerProvider);
              ref.invalidate(companySelectedGovernanceSavedViewProvider);
            },
          ),
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              _showMessage(context, 'Company management snapshot exported');
            },
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
                icon: Icons.business_center_outlined,
                title: 'Company Management Center',
                subtitle:
                    'Legal entities, documents, work locations, cost centers, approvals, and HR policies',
                departmentLabel: 'Legal entity',
                departments: entities,
                selectedDepartment: selectedEntity,
                attentionOnly: attentionOnly,
                attentionLabel: 'Risk view',
                onDepartmentChanged: (value) {
                  if (value == null) return;
                  ref.read(companySelectedEntityProvider.notifier).state =
                      value;
                },
                onAttentionChanged: (value) {
                  ref.read(companyAttentionOnlyProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 16),
              CompanySummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 1060,
                panels: [
                  CompanyGovernanceSavedViewsPanel(
                    views: governanceSavedViews,
                    selectedType: selectedGovernanceSavedViewType,
                    onViewSelected:
                        (view) => _applyGovernanceSavedView(
                          context: context,
                          ref: ref,
                          view: view,
                        ),
                  ),
                  CompanyGovernanceCommandBriefPanel(
                    brief: governanceCommandBrief,
                    onOwnerSelected: (ownerName) {
                      ref
                          .read(companySelectedGovernanceOwnerProvider.notifier)
                          .state = ownerName;
                      _showMessage(
                        context,
                        'Governance queue filtered to $ownerName',
                      );
                    },
                    onActionSelected:
                        (item) => _resolveGovernanceAction(context, ref, item),
                    onRecordFollowUp:
                        (lane) => _recordGovernanceFollowUp(
                          context: context,
                          ref: ref,
                          lane: lane,
                          selectedEntity: selectedEntity,
                          asOfDate: asOfDate,
                        ),
                  ),
                  CompanyGovernanceActionQueuePanel(
                    items: governanceActions,
                    initialFilter: selectedGovernanceSavedView.queueFilter,
                    selectedOwnerName: selectedGovernanceOwner,
                    onOwnerFilterCleared: () {
                      ref
                          .read(companySelectedGovernanceOwnerProvider.notifier)
                          .state = null;
                    },
                    onActionSelected:
                        (item) => _resolveGovernanceAction(context, ref, item),
                  ),
                  CompanyGovernanceOwnerLoadPanel(
                    loads: governanceOwnerLoads,
                    onOwnerSelected: (ownerName) {
                      ref
                          .read(companySelectedGovernanceOwnerProvider.notifier)
                          .state = ownerName;
                      _showMessage(
                        context,
                        'Governance queue filtered to $ownerName',
                      );
                    },
                  ),
                  CompanyGovernanceOwnerHandoffPanel(
                    handoff: governanceOwnerHandoff,
                    lastRecord: governanceOwnerHandoffRecord,
                    onRecordHandoff: (handoff) {
                      final recordNotifier = ref.read(
                        companyGovernanceOwnerHandoffRecordsProvider.notifier,
                      );
                      final record = recordNotifier.record(
                        handoff: handoff,
                        recordedAt: asOfDate,
                      );
                      final auditPayload =
                          CompanyGovernanceOwnerHandoffAuditPayload.fromRecord(
                            record: record,
                            entityName:
                                selectedEntity == companyAllEntities
                                    ? 'Company Governance'
                                    : selectedEntity,
                          );
                      final auditEvent = ref
                          .read(companyDocumentAuditEventsProvider.notifier)
                          .record(
                            documentId: auditPayload.documentId,
                            documentTitle: auditPayload.documentTitle,
                            entityName: auditPayload.entityName,
                            actorName: auditPayload.actorName,
                            type:
                                CompanyDocumentAuditEventType
                                    .governanceOwnerHandoffRecorded,
                            happenedAt: asOfDate,
                            note: auditPayload.note,
                            correlationId: auditPayload.correlationId,
                          );
                      recordNotifier.attachAuditEvent(
                        recordId: record.id,
                        auditEventId: auditEvent.id,
                      );
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = auditEvent.id;
                      _showMessage(
                        context,
                        'Governance handoff recorded for ${handoff.ownerLabel}',
                      );
                    },
                  ),
                  CompanyGovernanceOwnerHandoffHistoryPanel(
                    history: governanceOwnerHandoffHistory,
                    selectedOwnerName: selectedGovernanceOwner,
                    onOwnerSelected: (ownerName) {
                      ref
                          .read(companySelectedGovernanceOwnerProvider.notifier)
                          .state = ownerName;
                      _showMessage(
                        context,
                        'Governance queue filtered to $ownerName',
                      );
                    },
                    onAuditEventSelected: (auditEventId) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = auditEventId;
                      ref
                              .read(companyDocumentAuditFilterProvider.notifier)
                              .state =
                          CompanyDocumentAuditFilterPreset.allActivity.filter;
                      _showMessage(context, 'Governance audit event selected');
                    },
                  ),
                  CompanyGovernanceFollowUpPolicyPanel(
                    policy: governanceFollowUpPolicy,
                    draft: governanceFollowUpPolicyDraft,
                    impact: governanceFollowUpPolicyImpact,
                    onCriticalChanged:
                        ref
                            .read(
                              companyGovernanceFollowUpPolicyDraftProvider
                                  .notifier,
                            )
                            .setCriticalCadenceDays,
                    onHighChanged:
                        ref
                            .read(
                              companyGovernanceFollowUpPolicyDraftProvider
                                  .notifier,
                            )
                            .setHighCadenceDays,
                    onSteadyChanged:
                        ref
                            .read(
                              companyGovernanceFollowUpPolicyDraftProvider
                                  .notifier,
                            )
                            .setSteadyCadenceDays,
                    onReset:
                        () => ref
                            .read(
                              companyGovernanceFollowUpPolicyDraftProvider
                                  .notifier,
                            )
                            .loadPolicy(
                              ref.read(companyGovernanceFollowUpPolicyProvider),
                            ),
                    onSave:
                        () => _requestGovernanceFollowUpPolicyApproval(
                          context,
                          ref,
                          selectedEntity,
                        ),
                  ),
                  CompanyGovernanceFollowUpPolicyApprovalPanel(
                    queue: governanceFollowUpPolicyApprovalQueue,
                    currentPolicy: governanceFollowUpPolicy,
                    onApprove:
                        (request) => _approveGovernanceFollowUpPolicyRequest(
                          context: context,
                          ref: ref,
                          request: request,
                          selectedEntity: selectedEntity,
                        ),
                    onReject:
                        (request) => _rejectGovernanceFollowUpPolicyRequest(
                          context: context,
                          ref: ref,
                          request: request,
                        ),
                    onAuditEventSelected: (auditEventId) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = auditEventId;
                      ref
                              .read(companyDocumentAuditFilterProvider.notifier)
                              .state =
                          CompanyDocumentAuditFilterPreset.allActivity.filter;
                      _showMessage(
                        context,
                        'Governance SLA approval audit selected',
                      );
                    },
                  ),
                  CompanyGovernanceFollowUpPolicyHistoryPanel(
                    history: governanceFollowUpPolicyHistory,
                    currentPolicy: governanceFollowUpPolicy,
                    onRestorePolicy:
                        (record) => _restoreGovernanceFollowUpPolicy(
                          context: context,
                          ref: ref,
                          record: record,
                          selectedEntity: selectedEntity,
                        ),
                    onAuditEventSelected: (auditEventId) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = auditEventId;
                      ref
                              .read(companyDocumentAuditFilterProvider.notifier)
                              .state =
                          CompanyDocumentAuditFilterPreset.allActivity.filter;
                      _showMessage(context, 'Governance SLA audit selected');
                    },
                  ),
                  CompanyGovernanceFollowUpCadencePanel(
                    lanes: governanceFollowUpLanes,
                    asOfDate: asOfDate,
                    onOwnerSelected: (ownerName) {
                      ref
                          .read(companySelectedGovernanceOwnerProvider.notifier)
                          .state = ownerName;
                      _showMessage(
                        context,
                        'Governance queue filtered to $ownerName',
                      );
                    },
                    onAuditEventSelected: (auditEventId) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = auditEventId;
                      ref
                              .read(companyDocumentAuditFilterProvider.notifier)
                              .state =
                          CompanyDocumentAuditFilterPreset.allActivity.filter;
                      _showMessage(context, 'Governance audit event selected');
                    },
                    onRecordFollowUp: (lane) {
                      _recordGovernanceFollowUp(
                        context: context,
                        ref: ref,
                        lane: lane,
                        selectedEntity: selectedEntity,
                        asOfDate: asOfDate,
                      );
                    },
                  ),
                  CompanyProfileFormPanel(
                    profile: profile,
                    draft: profileDraft,
                    onLegalNameChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setLegalName,
                    onDisplayNameChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setDisplayName,
                    onRegistrationNumberChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setRegistrationNumber,
                    onTaxIdChanged:
                        ref.read(companyProfileDraftProvider.notifier).setTaxId,
                    onIndustryChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setIndustry,
                    onWebsiteChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setWebsite,
                    onHeadquartersChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setHeadquarters,
                    onPrimaryContactChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setPrimaryContact,
                    onStatusChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setStatus,
                    onEmployeeCountChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setEmployeeCount,
                    onReset:
                        () => ref
                            .read(companyProfileDraftProvider.notifier)
                            .loadProfile(ref.read(companyProfileProvider)),
                    onSave: () => _saveProfile(context, ref),
                  ),
                  CompanyOrgUnitFormPanel(
                    draft: orgUnitDraft,
                    entities: entities,
                    onNameChanged:
                        ref.read(companyOrgUnitDraftProvider.notifier).setName,
                    onCodeChanged:
                        ref.read(companyOrgUnitDraftProvider.notifier).setCode,
                    onEntityChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setEntityName,
                    onParentChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setParentName,
                    onManagerChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setManagerName,
                    onLocationChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setLocation,
                    onPlannedHeadcountChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setPlannedHeadcount,
                    onActiveHeadcountChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setActiveHeadcount,
                    onStatusChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setStatus,
                    onClear:
                        () => ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitOrgUnit(context, ref),
                  ),
                  CompanyLegalEntityFormPanel(
                    draft: legalEntityDraft,
                    onNameChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setName,
                    onRegistrationNumberChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setRegistrationNumber,
                    onTaxIdChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setTaxId,
                    onCountryChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setCountry,
                    onCityChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setCity,
                    onHrOwnerChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setHrOwner,
                    onPayrollEnabledChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setPayrollEnabled,
                    onStatusChanged:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .setStatus,
                    onClear:
                        ref
                            .read(companyLegalEntityDraftProvider.notifier)
                            .clear,
                    onSubmit: () => _submitLegalEntity(context, ref),
                  ),
                  CompanyWorkLocationFormPanel(
                    draft: locationDraft,
                    entities: entities,
                    onNameChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setName,
                    onEntityChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setType,
                    onCityChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setCity,
                    onRegionChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setRegion,
                    onAddressChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setAddress,
                    onCoverageOwnerChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setCoverageOwner,
                    onCapacityChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setCapacity,
                    onAssignedHeadcountChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setAssignedHeadcount,
                    onAttendancePolicyLinkedChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setAttendancePolicyLinked,
                    onStatusChanged:
                        ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .setStatus,
                    onClear:
                        () => ref
                            .read(companyWorkLocationDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitWorkLocation(context, ref),
                  ),
                  CompanyCostCenterFormPanel(
                    draft: costCenterDraft,
                    entities: entities,
                    orgUnits: orgUnitNames,
                    onCodeChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setCode,
                    onNameChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setName,
                    onEntityChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setEntityName,
                    onOrgUnitChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setOrgUnitName,
                    onOwnerChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setOwnerName,
                    onAnnualBudgetChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setAnnualBudget,
                    onAllocatedHeadcountChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setAllocatedHeadcount,
                    onActiveHeadcountChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setActiveHeadcount,
                    onStatusChanged:
                        ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .setStatus,
                    onClear:
                        () => ref
                            .read(companyCostCenterDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitCostCenter(context, ref),
                  ),
                  CompanyPositionControlFormPanel(
                    draft: positionControlDraft,
                    entities: entities,
                    orgUnits: orgUnitNames,
                    onTitleChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setPositionTitle,
                    onEntityChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setEntityName,
                    onOrgUnitChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setOrgUnitName,
                    onTypeChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setType,
                    onStatusChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setStatus,
                    onOwnerChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setOwnerName,
                    onAuthorizedSeatsChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setAuthorizedSeats,
                    onFilledSeatsChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setFilledSeats,
                    onFteChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setFte,
                    onCompensationBandChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setCompensationBand,
                    onNextReviewChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setNextReviewDate,
                    onHiringPlanChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setHiringPlan,
                    onLinkedRequisitionChanged:
                        ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .setLinkedRequisition,
                    onClear:
                        () => ref
                            .read(companyPositionControlDraftProvider.notifier)
                            .clear(
                              entityName: _defaultEntity(ref),
                              orgUnitName: _defaultOrgUnit(ref),
                            ),
                    onSubmit: () => _submitPositionControl(context, ref),
                  ),
                  CompanyHeadcountRequisitionFormPanel(
                    draft: headcountRequisitionDraft,
                    entities: entities,
                    orgUnits: orgUnitNames,
                    positionControlIds: positionControlIds,
                    jobProfileCodes: jobProfileCodes,
                    costCenterCodes: costCenterCodes,
                    onRoleTitleChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setRoleTitle,
                    onEntityChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setEntityName,
                    onOrgUnitChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setOrgUnitName,
                    onHiringManagerChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setHiringManagerName,
                    onPositionControlChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setPositionControlId,
                    onJobProfileChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setJobProfileCode,
                    onCostCenterChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setCostCenterCode,
                    onTypeChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setType,
                    onPriorityChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setPriority,
                    onStatusChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setStatus,
                    onRequestedSeatsChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setRequestedSeats,
                    onTargetStartChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setTargetStartDate,
                    onBusinessCaseChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setBusinessCase,
                    onBudgetImpactChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setBudgetImpact,
                    onApproverChanged:
                        ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .setApproverRole,
                    onClear:
                        () => ref
                            .read(
                              companyHeadcountRequisitionDraftProvider.notifier,
                            )
                            .clear(
                              entityName: _defaultEntity(ref),
                              orgUnitName: _defaultOrgUnit(ref),
                            ),
                    onSubmit: () => _submitHeadcountRequisition(context, ref),
                  ),
                  CompanyCompensationBandFormPanel(
                    draft: compensationBandDraft,
                    entities: entities,
                    onBandCodeChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setBandCode,
                    onEntityChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setEntityName,
                    onFamilyChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setFamily,
                    onLevelChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setLevelName,
                    onStatusChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setStatus,
                    onMinSalaryChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setMinSalary,
                    onMidpointSalaryChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setMidpointSalary,
                    onMaxSalaryChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setMaxSalary,
                    onCurrencyChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setCurrency,
                    onOwnerChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setOwnerName,
                    onApproverChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setApproverName,
                    onEffectiveDateChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setEffectiveDate,
                    onNextReviewChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setNextReviewDate,
                    onLinkedPolicyChanged:
                        ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .setLinkedPolicy,
                    onClear:
                        () => ref
                            .read(companyCompensationBandDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitCompensationBand(context, ref),
                  ),
                  CompanyJobProfileFormPanel(
                    draft: jobProfileDraft,
                    entities: entities,
                    orgUnits: orgUnitNames,
                    compensationBands: compensationBandCodes,
                    onJobCodeChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setJobCode,
                    onJobTitleChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setJobTitle,
                    onEntityChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setEntityName,
                    onOrgUnitChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setOrgUnitName,
                    onFamilyChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setFamily,
                    onLevelChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setLevelName,
                    onStatusChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setStatus,
                    onCompensationBandChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setCompensationBand,
                    onOwnerChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setOwnerName,
                    onNextReviewChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setNextReviewDate,
                    onDescriptionChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setJobDescription,
                    onSkillsChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setSkillsSummary,
                    onLinkedPolicyChanged:
                        ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .setLinkedPolicy,
                    onClear:
                        () => ref
                            .read(companyJobProfileDraftProvider.notifier)
                            .clear(
                              entityName: _defaultEntity(ref),
                              orgUnitName: _defaultOrgUnit(ref),
                              compensationBand: _defaultCompensationBand(ref),
                            ),
                    onSubmit: () => _submitJobProfile(context, ref),
                  ),
                  CompanyContractTemplateFormPanel(
                    draft: contractTemplateDraft,
                    entities: entities,
                    jobProfileCodes: jobProfileCodes,
                    compensationBands: compensationBandCodes,
                    onTemplateNameChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setTemplateName,
                    onEntityChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setType,
                    onStatusChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setStatus,
                    onJobProfileChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setJobProfileCode,
                    onCompensationBandChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setCompensationBand,
                    onOwnerChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setOwnerName,
                    onLegalReviewerChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setLegalReviewerName,
                    onSignatoryChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setSignatoryRole,
                    onLanguageChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setLanguage,
                    onVersionChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setVersionLabel,
                    onNextReviewChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setNextReviewDate,
                    onClauseChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setClauseSummary,
                    onOnboardingChanged:
                        ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .setOnboardingChecklist,
                    onClear:
                        () => ref
                            .read(companyContractTemplateDraftProvider.notifier)
                            .clear(
                              entityName: _defaultEntity(ref),
                              jobProfileCode: _defaultJobProfileCode(ref),
                              compensationBand: _defaultCompensationBand(ref),
                            ),
                    onSubmit: () => _submitContractTemplate(context, ref),
                  ),
                  CompanyOnboardingPackFormPanel(
                    draft: onboardingPackDraft,
                    entities: entities,
                    jobProfileCodes: jobProfileCodes,
                    contractTemplateNames: contractTemplateNames,
                    onPackNameChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setPackName,
                    onEntityChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setType,
                    onStatusChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setStatus,
                    onJobProfileChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setJobProfileCode,
                    onContractTemplateChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setContractTemplateName,
                    onOwnerChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setOwnerName,
                    onManagerHandoffChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setManagerHandoff,
                    onDocumentChecklistChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setDocumentChecklist,
                    onAccessChecklistChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setAccessChecklist,
                    onEquipmentChecklistChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setEquipmentChecklist,
                    onRequiredTasksChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setRequiredTaskCount,
                    onAutomationChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setAutomationCoverage,
                    onSlaChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setSlaDays,
                    onNextReviewChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setNextReviewDate,
                    onNotesChanged:
                        ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .setNotes,
                    onClear:
                        () => ref
                            .read(companyOnboardingPackDraftProvider.notifier)
                            .clear(
                              entityName: _defaultEntity(ref),
                              jobProfileCode: _defaultJobProfileCode(ref),
                              contractTemplateName:
                                  _defaultContractTemplateName(ref),
                            ),
                    onSubmit: () => _submitOnboardingPack(context, ref),
                  ),
                  CompanyProbationPlanFormPanel(
                    draft: probationPlanDraft,
                    entities: entities,
                    jobProfileCodes: jobProfileCodes,
                    onboardingPackNames: onboardingPackNames,
                    onPlanNameChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setPlanName,
                    onEntityChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setType,
                    onStatusChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setStatus,
                    onJobProfileChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setJobProfileCode,
                    onOnboardingPackChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setOnboardingPackName,
                    onOwnerChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setOwnerName,
                    onManagerRoleChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setManagerRole,
                    onCadenceChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setReviewCadenceDays,
                    onCheckpointCountChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setCheckpointCount,
                    onFirstReviewChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setFirstReviewDueDays,
                    onFinalDecisionChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setFinalDecisionDueDays,
                    onNextReviewChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setNextReviewDate,
                    onSuccessCriteriaChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setSuccessCriteria,
                    onFeedbackTemplateChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setFeedbackTemplate,
                    onNotesChanged:
                        ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .setNotes,
                    onClear:
                        () => ref
                            .read(companyProbationPlanDraftProvider.notifier)
                            .clear(
                              entityName: _defaultEntity(ref),
                              jobProfileCode: _defaultJobProfileCode(ref),
                              onboardingPackName: _defaultOnboardingPackName(
                                ref,
                              ),
                            ),
                    onSubmit: () => _submitProbationPlan(context, ref),
                  ),
                  CompanyOffboardingPackFormPanel(
                    draft: offboardingPackDraft,
                    entities: entities,
                    jobProfileCodes: jobProfileCodes,
                    onPackNameChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setPackName,
                    onEntityChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setType,
                    onStatusChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setStatus,
                    onJobProfileChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setJobProfileCode,
                    onOwnerChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setOwnerName,
                    onManagerRoleChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setManagerRole,
                    onKnowledgeTransferChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setKnowledgeTransferPlan,
                    onAssetReturnChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setAssetReturnChecklist,
                    onAccessRevocationChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setAccessRevocationChecklist,
                    onFinalPayrollChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setFinalPayrollChecklist,
                    onDocumentChecklistChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setDocumentChecklist,
                    onExitInterviewChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setExitInterviewTemplate,
                    onRequiredTasksChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setRequiredTaskCount,
                    onSlaChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setSlaDays,
                    onNextReviewChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setNextReviewDate,
                    onNotesChanged:
                        ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .setNotes,
                    onClear:
                        () => ref
                            .read(companyOffboardingPackDraftProvider.notifier)
                            .clear(
                              entityName: _defaultEntity(ref),
                              jobProfileCode: _defaultJobProfileCode(ref),
                            ),
                    onSubmit: () => _submitOffboardingPack(context, ref),
                  ),
                  CompanyDocumentRequirementFormPanel(
                    draft: documentRequirementDraft,
                    entities: entities,
                    jobProfileCodes: jobProfileCodes,
                    contractTemplateNames: contractTemplateNames,
                    onboardingPackNames: onboardingPackNames,
                    probationPlanNames: probationPlanNames,
                    offboardingPackNames: offboardingPackNames,
                    onRequirementNameChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setRequirementName,
                    onEntityChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setEntityName,
                    onStageChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setStage,
                    onStatusChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setStatus,
                    onJobProfileChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setJobProfileCode,
                    onContractTemplateChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setContractTemplateName,
                    onOnboardingPackChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setOnboardingPackName,
                    onProbationPlanChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setProbationPlanName,
                    onOffboardingPackChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setOffboardingPackName,
                    onOwnerChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setOwnerName,
                    onEvidenceOwnerChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setEvidenceOwnerName,
                    onPolicyChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setPolicyReference,
                    onCollectionChannelChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setCollectionChannel,
                    onStorageLocationChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setStorageLocation,
                    onRetentionRuleChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setRetentionRule,
                    onRequiredDocumentsChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setRequiredDocumentCount,
                    onNextReviewChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setNextReviewDate,
                    onNotesChanged:
                        ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .setNotes,
                    onClear:
                        () => ref
                            .read(
                              companyDocumentRequirementDraftProvider.notifier,
                            )
                            .clear(
                              entityName: _defaultEntity(ref),
                              jobProfileCode: _defaultJobProfileCode(ref),
                              contractTemplateName:
                                  _defaultContractTemplateName(ref),
                              onboardingPackName: _defaultOnboardingPackName(
                                ref,
                              ),
                              probationPlanName: _defaultProbationPlanName(ref),
                              offboardingPackName: _defaultOffboardingPackName(
                                ref,
                              ),
                            ),
                    onSubmit: () => _submitDocumentRequirement(context, ref),
                  ),
                  CompanyApprovalRuleFormPanel(
                    draft: approvalRuleDraft,
                    entities: entities,
                    scopes: orgUnitNames,
                    onDomainChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setDomain,
                    onEntityChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setEntityName,
                    onScopeChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setScopeName,
                    onApproverChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setApproverRole,
                    onBackupChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setBackupApproverRole,
                    onThresholdChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setThresholdLabel,
                    onSlaChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setSlaHours,
                    onStatusChanged:
                        ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .setStatus,
                    onClear:
                        () => ref
                            .read(companyApprovalRuleDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitApprovalRule(context, ref),
                  ),
                  CompanyDocumentFormPanel(
                    draft: documentDraft,
                    entities: entities,
                    onTitleChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setTitle,
                    onDocumentNumberChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setDocumentNumber,
                    onEntityChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setEntityName,
                    onOwnerChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setOwnerName,
                    onTypeChanged:
                        ref.read(companyDocumentDraftProvider.notifier).setType,
                    onIssuedDateChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setIssuedDate,
                    onExpiryDateChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setExpiryDate,
                    onStatusChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setStatus,
                    onLinkedModuleChanged:
                        ref
                            .read(companyDocumentDraftProvider.notifier)
                            .setLinkedModule,
                    onClear:
                        () => ref
                            .read(companyDocumentDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitDocument(context, ref),
                  ),
                  CompanyDocumentRenewalFormPanel(
                    draft: renewalDraft,
                    documents: allDocuments,
                    entities: entities,
                    onDocumentChanged:
                        (documentId) => _selectRenewalDocument(ref, documentId),
                    onEntityChanged:
                        ref
                            .read(companyDocumentRenewalDraftProvider.notifier)
                            .setEntityName,
                    onOwnerChanged:
                        ref
                            .read(companyDocumentRenewalDraftProvider.notifier)
                            .setOwnerName,
                    onDueDateChanged:
                        ref
                            .read(companyDocumentRenewalDraftProvider.notifier)
                            .setDueDate,
                    onReminderLeadDaysChanged:
                        ref
                            .read(companyDocumentRenewalDraftProvider.notifier)
                            .setReminderLeadDays,
                    onStatusChanged:
                        ref
                            .read(companyDocumentRenewalDraftProvider.notifier)
                            .setStatus,
                    onActionChanged:
                        ref
                            .read(companyDocumentRenewalDraftProvider.notifier)
                            .setActionLabel,
                    onClear:
                        () => ref
                            .read(companyDocumentRenewalDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitDocumentRenewal(context, ref),
                  ),
                  CompanyOperatingReadinessFormPanel(
                    draft: operatingDraft,
                    entities: entities,
                    onAreaChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setArea,
                    onEntityChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setEntityName,
                    onOwnerChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setOwnerName,
                    onStatusChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setStatus,
                    onCoverageChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setCoveragePercent,
                    onLastReviewChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setLastReviewDate,
                    onNextReviewChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setNextReviewDate,
                    onBlockerChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setBlocker,
                    onLinkedModuleChanged:
                        ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .setLinkedModule,
                    onClear:
                        () => ref
                            .read(
                              companyOperatingReadinessDraftProvider.notifier,
                            )
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitOperatingReadiness(context, ref),
                  ),
                  CompanyGovernanceContactFormPanel(
                    draft: governanceContactDraft,
                    entities: entities,
                    onEntityChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setEntityName,
                    onRoleChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setRole,
                    onPersonChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setPersonName,
                    onTitleChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setTitle,
                    onEmailChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setEmail,
                    onPhoneChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setPhone,
                    onBackupChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setBackupName,
                    onEscalationChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setEscalationChannel,
                    onStatusChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setStatus,
                    onLastReviewChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setLastReviewedAt,
                    onNextReviewChanged:
                        ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .setNextReviewAt,
                    onClear:
                        () => ref
                            .read(
                              companyGovernanceContactDraftProvider.notifier,
                            )
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitGovernanceContact(context, ref),
                  ),
                  CompanyEntityLifecycleFormPanel(
                    draft: lifecycleDraft,
                    entities: entities,
                    onTitleChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setTitle,
                    onEntityChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setType,
                    onStatusChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setStatus,
                    onOwnerChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setOwnerName,
                    onTargetDateChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setTargetDate,
                    onProgressChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setProgressPercent,
                    onDependencyChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setDependencySummary,
                    onBlockerChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setBlocker,
                    onNextMilestoneChanged:
                        ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .setNextMilestone,
                    onClear:
                        () => ref
                            .read(companyEntityLifecycleDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitEntityLifecycle(context, ref),
                  ),
                  CompanyControlFormPanel(
                    draft: controlDraft,
                    entities: entities,
                    onTitleChanged:
                        ref.read(companyControlDraftProvider.notifier).setTitle,
                    onEntityChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setEntityName,
                    onDomainChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setDomain,
                    onStatusChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setStatus,
                    onSeverityChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setSeverity,
                    onOwnerChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setOwnerName,
                    onReviewDateChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setNextReviewDate,
                    onEvidenceChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setEvidenceSummary,
                    onRemediationChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setRemediationAction,
                    onLinkedRecordChanged:
                        ref
                            .read(companyControlDraftProvider.notifier)
                            .setLinkedRecord,
                    onClear:
                        () => ref
                            .read(companyControlDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitCompanyControl(context, ref),
                  ),
                  CompanyEmployerAccountFormPanel(
                    draft: employerAccountDraft,
                    entities: entities,
                    onAccountNameChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setAccountName,
                    onEntityChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setType,
                    onStatusChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setStatus,
                    onAccountNumberChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setAccountNumber,
                    onOwnerChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setOwnerName,
                    onCredentialOwnerChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setCredentialOwnerName,
                    onNextReviewDateChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setNextReviewDate,
                    onEvidenceChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setEvidenceSummary,
                    onNextActionChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setNextAction,
                    onLinkedFilingChanged:
                        ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .setLinkedFiling,
                    onClear:
                        () => ref
                            .read(companyEmployerAccountDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitEmployerAccount(context, ref),
                  ),
                  CompanyVendorAgreementFormPanel(
                    draft: vendorAgreementDraft,
                    entities: entities,
                    onVendorChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setVendorName,
                    onServiceChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setServiceName,
                    onEntityChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setEntityName,
                    onCategoryChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setCategory,
                    onStatusChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setStatus,
                    onOwnerChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setOwnerName,
                    onAccountManagerChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setAccountManagerName,
                    onContractEndChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setContractEndDate,
                    onSlaChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setSlaSummary,
                    onDataProtectionChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setDataProtectionSummary,
                    onNextActionChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setNextAction,
                    onLinkedModuleChanged:
                        ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .setLinkedModule,
                    onClear:
                        () => ref
                            .read(companyVendorAgreementDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitVendorAgreement(context, ref),
                  ),
                  CompanyFilingFormPanel(
                    draft: filingDraft,
                    entities: entities,
                    onTitleChanged:
                        ref.read(companyFilingDraftProvider.notifier).setTitle,
                    onEntityChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setEntityName,
                    onTypeChanged:
                        ref.read(companyFilingDraftProvider.notifier).setType,
                    onCadenceChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setCadence,
                    onStatusChanged:
                        ref.read(companyFilingDraftProvider.notifier).setStatus,
                    onOwnerChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setOwnerName,
                    onAuthorityChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setAuthorityName,
                    onDueDateChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setDueDate,
                    onEvidenceChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setEvidenceSummary,
                    onNextStepChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setNextStep,
                    onLinkedRecordChanged:
                        ref
                            .read(companyFilingDraftProvider.notifier)
                            .setLinkedRecord,
                    onClear:
                        () => ref
                            .read(companyFilingDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitCompanyFiling(context, ref),
                  ),
                  CompanySignatoryFormPanel(
                    draft: signatoryDraft,
                    entities: entities,
                    onPersonChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setPersonName,
                    onTitleChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setTitle,
                    onEntityChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setEntityName,
                    onScopeChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setScope,
                    onAuthorityChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setAuthorityLevel,
                    onStatusChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setStatus,
                    onEffectiveDateChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setEffectiveDate,
                    onExpiryDateChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setExpiryDate,
                    onBackupChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setBackupSignerName,
                    onEvidenceChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setEvidenceSummary,
                    onNotesChanged:
                        ref
                            .read(companySignatoryDraftProvider.notifier)
                            .setDelegationNotes,
                    onClear:
                        () => ref
                            .read(companySignatoryDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitCompanySignatory(context, ref),
                  ),
                  CompanyChangeRequestFormPanel(
                    draft: changeDraft,
                    entities: entities,
                    onTitleChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setTitle,
                    onEntityChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setEntityName,
                    onOwnerChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setOwnerName,
                    onTypeChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setType,
                    onPriorityChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setPriority,
                    onStatusChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setStatus,
                    onEffectiveDateChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setEffectiveDate,
                    onImpactChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setImpactSummary,
                    onApproverChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setApproverRole,
                    onLinkedRecordChanged:
                        ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .setLinkedRecord,
                    onClear:
                        () => ref
                            .read(companyChangeRequestDraftProvider.notifier)
                            .clear(entityName: _defaultEntity(ref)),
                    onSubmit: () => _submitChangeRequest(context, ref),
                  ),
                  CompanyLegalEntityRegistryPanel(
                    entities: legalEntities,
                    onMarkVerified: (id) {
                      ref
                          .read(companyLegalEntitiesProvider.notifier)
                          .markVerified(id);
                      _showMessage(context, 'Legal entity marked verified');
                    },
                  ),
                  CompanyWorkLocationRegistryPanel(
                    locations: locations,
                    onMarkReady: (id) {
                      ref
                          .read(companyWorkLocationsProvider.notifier)
                          .markReady(id);
                      _showMessage(context, 'Work location marked ready');
                    },
                  ),
                  CompanyCostCenterRegistryPanel(
                    centers: costCenters,
                    onMarkActive: (id) {
                      ref
                          .read(companyCostCentersProvider.notifier)
                          .markActive(id);
                      _showMessage(context, 'Cost center marked active');
                    },
                  ),
                  CompanyWorkforcePlanPanel(
                    plan: workforcePlan,
                    onApprovePosition: (id) {
                      ref
                          .read(companyPositionControlsProvider.notifier)
                          .approvePosition(id);
                      _showMessage(context, 'Workforce position approved');
                    },
                    onCloseRecruiting: (id) {
                      ref
                          .read(companyPositionControlsProvider.notifier)
                          .closeRecruiting(id);
                      _showMessage(context, 'Workforce recruiting closed');
                    },
                    onReviewCostCenter: (id) {
                      ref
                          .read(companyCostCentersProvider.notifier)
                          .markActive(id);
                      _showMessage(context, 'Workforce cost center reviewed');
                    },
                  ),
                  CompanyHeadcountRequisitionBoard(
                    requisitions: headcountRequisitions,
                    asOfDate: asOfDate,
                    onApprove: (id) {
                      ref
                          .read(companyHeadcountRequisitionsProvider.notifier)
                          .approve(id);
                      _recordHeadcountRequisitionActivity(
                        ref: ref,
                        requisitionId: id,
                        type: CompanyHeadcountRequisitionActivityType.approved,
                        note: 'Headcount requisition approved.',
                      );
                      _showMessage(context, 'Headcount requisition approved');
                    },
                    onOpenRecruiting: (id) {
                      ref
                          .read(companyHeadcountRequisitionsProvider.notifier)
                          .openRecruiting(id);
                      _recordHeadcountRequisitionActivity(
                        ref: ref,
                        requisitionId: id,
                        type:
                            CompanyHeadcountRequisitionActivityType
                                .recruitingOpened,
                        note: 'Recruiting opened for requisition.',
                      );
                      _showMessage(context, 'Headcount recruiting opened');
                    },
                    onMarkFilled: (id) {
                      ref
                          .read(companyHeadcountRequisitionsProvider.notifier)
                          .markFilled(id);
                      _recordHeadcountRequisitionActivity(
                        ref: ref,
                        requisitionId: id,
                        type: CompanyHeadcountRequisitionActivityType.filled,
                        note: 'Headcount requisition marked filled.',
                      );
                      _showMessage(context, 'Headcount requisition filled');
                    },
                  ),
                  CompanyHeadcountRequisitionActivityPanel(
                    timeline: headcountActivityTimeline,
                  ),
                  CompanyPositionControlRegistryPanel(
                    positions: positionControls,
                    asOfDate: asOfDate,
                    onApprove: (id) {
                      ref
                          .read(companyPositionControlsProvider.notifier)
                          .approvePosition(id);
                      _showMessage(context, 'Position control approved');
                    },
                    onCloseRecruiting: (id) {
                      ref
                          .read(companyPositionControlsProvider.notifier)
                          .closeRecruiting(id);
                      _showMessage(context, 'Position recruiting closed');
                    },
                  ),
                  CompanyCompensationBandRegistryPanel(
                    bands: compensationBands,
                    asOfDate: asOfDate,
                    onActivate: (id) {
                      ref
                          .read(companyCompensationBandsProvider.notifier)
                          .activateBand(id);
                      _showMessage(context, 'Compensation band activated');
                    },
                    onMarkReviewed: (id) {
                      ref
                          .read(companyCompensationBandsProvider.notifier)
                          .markReviewed(id);
                      _showMessage(context, 'Compensation band reviewed');
                    },
                  ),
                  CompanyJobProfileCatalogPanel(
                    profiles: jobProfiles,
                    asOfDate: asOfDate,
                    onActivate: (id) {
                      ref
                          .read(companyJobProfilesProvider.notifier)
                          .activateProfile(id);
                      _showMessage(context, 'Job profile activated');
                    },
                    onMarkReviewed: (id) {
                      ref
                          .read(companyJobProfilesProvider.notifier)
                          .markReviewed(id);
                      _showMessage(context, 'Job profile reviewed');
                    },
                  ),
                  CompanyContractTemplateCatalogPanel(
                    templates: contractTemplates,
                    asOfDate: asOfDate,
                    onActivate: (id) {
                      ref
                          .read(companyContractTemplatesProvider.notifier)
                          .activateTemplate(id);
                      _showMessage(context, 'Contract template activated');
                    },
                    onMarkReviewed: (id) {
                      ref
                          .read(companyContractTemplatesProvider.notifier)
                          .markReviewed(id);
                      _showMessage(context, 'Contract template reviewed');
                    },
                  ),
                  CompanyOnboardingPackRegistryPanel(
                    packs: onboardingPacks,
                    asOfDate: asOfDate,
                    onActivate: (id) {
                      ref
                          .read(companyOnboardingPacksProvider.notifier)
                          .activatePack(id);
                      _showMessage(context, 'Onboarding pack activated');
                    },
                    onMarkReviewed: (id) {
                      ref
                          .read(companyOnboardingPacksProvider.notifier)
                          .markReviewed(id);
                      _showMessage(context, 'Onboarding pack reviewed');
                    },
                  ),
                  CompanyProbationPlanRegistryPanel(
                    plans: probationPlans,
                    asOfDate: asOfDate,
                    onActivate: (id) {
                      ref
                          .read(companyProbationPlansProvider.notifier)
                          .activatePlan(id);
                      _showMessage(context, 'Probation plan activated');
                    },
                    onMarkReviewed: (id) {
                      ref
                          .read(companyProbationPlansProvider.notifier)
                          .markReviewed(id);
                      _showMessage(context, 'Probation plan reviewed');
                    },
                  ),
                  CompanyOffboardingPackRegistryPanel(
                    packs: offboardingPacks,
                    asOfDate: asOfDate,
                    onActivate: (id) {
                      ref
                          .read(companyOffboardingPacksProvider.notifier)
                          .activatePack(id);
                      _showMessage(context, 'Offboarding pack activated');
                    },
                    onMarkReviewed: (id) {
                      ref
                          .read(companyOffboardingPacksProvider.notifier)
                          .markReviewed(id);
                      _showMessage(context, 'Offboarding pack reviewed');
                    },
                  ),
                  CompanyDocumentRequirementRegistryPanel(
                    requirements: documentRequirements,
                    asOfDate: asOfDate,
                    onActivate: (id) {
                      ref
                          .read(companyDocumentRequirementsProvider.notifier)
                          .activateRequirement(id);
                      _showMessage(context, 'Document requirement activated');
                    },
                    onMarkReviewed: (id) {
                      ref
                          .read(companyDocumentRequirementsProvider.notifier)
                          .markReviewed(id);
                      _showMessage(context, 'Document requirement reviewed');
                    },
                  ),
                  CompanyEmployeeDocumentWorkloadPanel(
                    workloads: employeeDocumentWorkloads,
                    digestStatuses: employeeDocumentWorkloadDigestStatuses,
                    asOfDate: asOfDate,
                    onSendDigest: (ownerName) {
                      final event = ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .sendOwnerDigest(ownerName);
                      _showMessage(
                        context,
                        event == null
                            ? 'No active document workload for $ownerName'
                            : 'Employee document digest sent to $ownerName',
                      );
                    },
                    onSendDueDigests: (ownerNames) async {
                      final preview = buildEmployeeDocumentDigestPreview(
                        ownerNames: ownerNames,
                        workloads: employeeDocumentWorkloads,
                        digestStatuses: employeeDocumentWorkloadDigestStatuses,
                        asOfDate: asOfDate,
                      );
                      if (preview.isEmpty) {
                        _showMessage(
                          context,
                          'No due employee document digests',
                        );
                        return;
                      }

                      final confirmed =
                          await showEmployeeDocumentDigestPreviewDialog(
                            context: context,
                            preview: preview,
                          );
                      if (!context.mounted || confirmed != true) return;

                      final events = ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .sendOwnerDigests(preview.ownerNames);
                      final count = events.length;
                      _showMessage(
                        context,
                        count == 0
                            ? 'No due employee document digests'
                            : '$count employee document '
                                'digest${count == 1 ? '' : 's'} sent',
                      );
                    },
                  ),
                  EmployeeDocumentEscalationPanel(
                    plans: employeeDocumentEscalationPlans,
                    onEscalateOwner: (ownerName) {
                      final event = ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .escalateOwnerWorkload(ownerName);
                      if (event != null) {
                        ref
                            .read(
                              companySelectedDocumentAuditEventIdProvider
                                  .notifier,
                            )
                            .state = event.id;
                      }
                      _showMessage(
                        context,
                        event == null
                            ? 'No escalation-ready workload for $ownerName'
                            : 'Employee document escalation recorded for $ownerName',
                      );
                    },
                    onEscalateOwners: (ownerNames) async {
                      final preview = buildEmployeeDocumentEscalationPreview(
                        ownerNames: ownerNames,
                        plans: employeeDocumentEscalationPlans,
                      );
                      if (preview.isEmpty) {
                        _showMessage(
                          context,
                          'No employee document escalations ready',
                        );
                        return;
                      }

                      final confirmed =
                          await showEmployeeDocumentEscalationPreviewDialog(
                            context: context,
                            preview: preview,
                          );
                      if (!context.mounted || confirmed != true) return;

                      final events = ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .escalateOwnerWorkloads(preview.ownerNames);
                      if (events.isNotEmpty) {
                        ref
                            .read(
                              companySelectedDocumentAuditEventIdProvider
                                  .notifier,
                            )
                            .state = events.first.id;
                      }
                      final count = events.length;
                      _showMessage(
                        context,
                        count == 0
                            ? 'No employee document escalations ready'
                            : '$count employee document '
                                'escalation${count == 1 ? '' : 's'} recorded',
                      );
                    },
                  ),
                  EmployeeDocumentEscalationFollowUpPanel(
                    followUps: employeeDocumentEscalationFollowUps,
                    asOfDate: asOfDate,
                    onAuditEventSelected: (id) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = id;
                    },
                    onRecordFollowUp: (ownerName) {
                      final event = ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .recordOwnerEscalationFollowUp(ownerName);
                      if (event != null) {
                        ref
                            .read(
                              companySelectedDocumentAuditEventIdProvider
                                  .notifier,
                            )
                            .state = event.id;
                      }
                      _showMessage(
                        context,
                        event == null
                            ? 'No escalation follow-up ready for $ownerName'
                            : 'Escalation follow-up recorded for $ownerName',
                      );
                    },
                  ),
                  EmployeeDocumentEscalationHistoryPanel(
                    history: employeeDocumentEscalationHistory,
                    asOfDate: asOfDate,
                    onAuditEventSelected: (id) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = id;
                    },
                  ),
                  EmployeeDocumentDigestHistoryPanel(
                    history: employeeDocumentDigestHistory,
                    asOfDate: asOfDate,
                    onAuditEventSelected: (id) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = id;
                    },
                  ),
                  CompanyEmployeeDocumentGapPanel(
                    gaps: employeeDocumentGaps,
                    recommendations: employeeDocumentGapRecommendations,
                    asOfDate: asOfDate,
                    onGenerateRequest: (id) {
                      final request = ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .generateRequest(id);
                      _showMessage(
                        context,
                        request == null
                            ? 'Employee document request already closed'
                            : 'Employee document request ${request.id} queued',
                      );
                    },
                    onMarkVerified: (id) {
                      final result = ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .markVerified(id);
                      final evidenceCount = result.evidenceRecords.length;
                      final closedRequestCount = result.closedRequestCount;
                      _showMessage(
                        context,
                        !result.hasChanges
                            ? 'Employee document gap verified'
                            : '$evidenceCount employee evidence records verified'
                                '${closedRequestCount == 0 ? '' : ', $closedRequestCount document request closed'}',
                      );
                    },
                    onWaive: (id) {
                      ref
                          .read(companyEmployeeDocumentGapsProvider.notifier)
                          .waiveGap(id);
                      _showMessage(context, 'Employee document gap waived');
                    },
                  ),
                  CompanyApprovalRuleRegistryPanel(
                    rules: approvalRules,
                    onMarkActive: (id) {
                      ref
                          .read(companyApprovalRulesProvider.notifier)
                          .markActive(id);
                      _showMessage(context, 'Approval rule marked active');
                    },
                  ),
                  CompanyDocumentRegistryPanel(
                    documents: documents,
                    asOfDate: asOfDate,
                    onMarkVerified: (id) {
                      final document =
                          ref
                              .read(companyDocumentsProvider)
                              .where((item) => item.id == id)
                              .firstOrNull;
                      ref
                          .read(companyDocumentsProvider.notifier)
                          .markVerified(id);
                      if (document != null) {
                        ref
                            .read(companyDocumentAuditEventsProvider.notifier)
                            .record(
                              documentId: document.id,
                              documentTitle: document.title,
                              entityName: document.entityName,
                              actorName: 'People Operations',
                              type: CompanyDocumentAuditEventType.verified,
                              happenedAt: asOfDate,
                              note: 'Document marked verified from registry.',
                            );
                      }
                      _showMessage(context, 'Company document marked verified');
                    },
                  ),
                  CompanyDocumentRenewalBoard(
                    tasks: renewalTasks,
                    asOfDate: asOfDate,
                    onStart: (id) => _startDocumentRenewal(context, ref, id),
                    onComplete:
                        (id) => _completeDocumentRenewal(context, ref, id),
                  ),
                  CompanyDocumentAuditTimelinePanel(
                    events: auditEvents,
                    summary: auditSummary,
                    filter: auditFilter,
                    selectedEventId: selectedAuditEventId,
                    onPresetSelected: (preset) {
                      ref
                          .read(companyDocumentAuditFilterProvider.notifier)
                          .state = preset.filter;
                    },
                    onScopeChanged: (scope) {
                      ref
                          .read(companyDocumentAuditFilterProvider.notifier)
                          .state = auditFilter.copyWith(scope: scope);
                    },
                    onSearchChanged: (value) {
                      ref
                          .read(companyDocumentAuditFilterProvider.notifier)
                          .state = auditFilter.copyWith(searchText: value);
                    },
                    onEventSelected: (id) {
                      ref
                          .read(
                            companySelectedDocumentAuditEventIdProvider
                                .notifier,
                          )
                          .state = id;
                    },
                  ),
                  CompanyDocumentAuditDetailPanel(detail: auditDetail),
                  CompanyOperatingReadinessPanel(
                    items: operatingReadiness,
                    asOfDate: asOfDate,
                    onMarkReady: (id) {
                      ref
                          .read(companyOperatingReadinessProvider.notifier)
                          .markReady(id);
                      _showMessage(context, 'Operating service marked ready');
                    },
                  ),
                  CompanyGovernanceContactDirectoryPanel(
                    contacts: governanceContacts,
                    asOfDate: asOfDate,
                    onMarkReviewed: (id) {
                      ref
                          .read(companyGovernanceContactsProvider.notifier)
                          .markReviewed(id, asOfDate);
                      _showMessage(context, 'Governance contact reviewed');
                    },
                    onAssignBackup: (id) {
                      ref
                          .read(companyGovernanceContactsProvider.notifier)
                          .assignBackup(id, 'People Operations');
                      _showMessage(context, 'Backup owner assigned');
                    },
                  ),
                  CompanyEntityLifecycleBoard(
                    milestones: lifecycles,
                    asOfDate: asOfDate,
                    onAdvance: (id) {
                      ref
                          .read(companyEntityLifecyclesProvider.notifier)
                          .advance(id);
                      _showMessage(context, 'Lifecycle milestone advanced');
                    },
                    onLaunch: (id) {
                      ref
                          .read(companyEntityLifecyclesProvider.notifier)
                          .markLaunched(id);
                      _showMessage(context, 'Lifecycle milestone launched');
                    },
                  ),
                  CompanyControlRegisterPanel(
                    controls: controls,
                    asOfDate: asOfDate,
                    onRemediate: (id) {
                      ref
                          .read(companyControlsProvider.notifier)
                          .markRemediated(id);
                      _showMessage(context, 'Company control remediated');
                    },
                    onWaive: (id) {
                      ref.read(companyControlsProvider.notifier).waive(id);
                      _showMessage(context, 'Company control waived');
                    },
                  ),
                  CompanyEmployerAccountRegistryPanel(
                    accounts: employerAccounts,
                    asOfDate: asOfDate,
                    onMarkVerified: (id) {
                      ref
                          .read(companyEmployerAccountsProvider.notifier)
                          .markVerified(id);
                      _showMessage(context, 'Employer account marked verified');
                    },
                    onRotateCredentialOwner: (id) {
                      ref
                          .read(companyEmployerAccountsProvider.notifier)
                          .rotateCredentialOwner(id, 'People Operations');
                      _showMessage(context, 'Credential owner rotated');
                    },
                  ),
                  CompanyVendorAgreementRegistryPanel(
                    agreements: vendorAgreements,
                    asOfDate: asOfDate,
                    onRenew: (id) {
                      ref
                          .read(companyVendorAgreementsProvider.notifier)
                          .markRenewed(id);
                      _showMessage(context, 'Vendor agreement renewed');
                    },
                    onCloseImplementation: (id) {
                      ref
                          .read(companyVendorAgreementsProvider.notifier)
                          .closeImplementation(id);
                      _showMessage(context, 'Vendor implementation closed');
                    },
                  ),
                  CompanyFilingCalendarPanel(
                    filings: filings,
                    asOfDate: asOfDate,
                    onMarkFiled: (id) {
                      ref.read(companyFilingsProvider.notifier).markFiled(id);
                      _showMessage(context, 'Company filing marked filed');
                    },
                    onEscalate: (id) {
                      ref.read(companyFilingsProvider.notifier).escalate(id);
                      _showMessage(context, 'Company filing escalated');
                    },
                  ),
                  CompanySignatoryMatrixPanel(
                    signatories: signatories,
                    asOfDate: asOfDate,
                    onActivateEvidence: (id) {
                      ref
                          .read(companySignatoriesProvider.notifier)
                          .markEvidenceActive(id);
                      _showMessage(context, 'Signatory evidence activated');
                    },
                    onAssignBackup: (id) {
                      ref
                          .read(companySignatoriesProvider.notifier)
                          .assignBackup(id, 'People Operations');
                      _showMessage(context, 'Signatory backup assigned');
                    },
                  ),
                  CompanyChangeRequestBoard(
                    requests: changeRequests,
                    asOfDate: asOfDate,
                    onSchedule: (id) {
                      ref
                          .read(companyChangeRequestsProvider.notifier)
                          .markScheduled(id);
                      _showMessage(context, 'Company change scheduled');
                    },
                    onImplement: (id) {
                      ref
                          .read(companyChangeRequestsProvider.notifier)
                          .markImplemented(id);
                      _showMessage(context, 'Company change implemented');
                    },
                  ),
                  CompanyOrgStructurePanel(units: orgUnits),
                  CompanyPolicySettingsPanel(
                    policies: policies,
                    onMarkReady: (id) {
                      ref.read(companyPoliciesProvider.notifier).markReady(id);
                      _showMessage(context, 'Policy marked ready');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyGovernanceSavedView({
    required BuildContext context,
    required WidgetRef ref,
    required CompanyGovernanceSavedView view,
  }) {
    ref.read(companySelectedGovernanceSavedViewProvider.notifier).state =
        view.type;
    if (view.clearOwnerScope) {
      ref.read(companySelectedGovernanceOwnerProvider.notifier).state = null;
    } else if (view.hasOwnerScope) {
      ref.read(companySelectedGovernanceOwnerProvider.notifier).state =
          view.ownerName;
    }
    _showMessage(context, '${view.title} view applied');
  }

  void _requestGovernanceFollowUpPolicyApproval(
    BuildContext context,
    WidgetRef ref,
    String selectedEntity,
  ) {
    try {
      final previousPolicy = ref.read(companyGovernanceFollowUpPolicyProvider);
      final impact = ref.read(companyGovernanceFollowUpPolicyImpactProvider);
      if (!impact.isValid) {
        _showMessage(context, impact.validationMessage);
        return;
      }

      final requestedPolicy =
          ref.read(companyGovernanceFollowUpPolicyDraftProvider).toPolicy();
      if (requestedPolicy == previousPolicy) {
        _showMessage(context, 'Governance follow-up SLA already up to date');
        return;
      }

      final entityName =
          selectedEntity == companyAllEntities
              ? 'Company Governance'
              : selectedEntity;
      final request = ref
          .read(
            companyGovernanceFollowUpPolicyApprovalRequestsProvider.notifier,
          )
          .requestApproval(
            previousPolicy: previousPolicy,
            requestedPolicy: requestedPolicy,
            impact: impact,
            entityName: entityName,
            requestedAt: ref.read(companyAsOfDateProvider),
          );
      _showMessage(
        context,
        'Governance follow-up SLA approval requested (${request.id})',
      );
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _approveGovernanceFollowUpPolicyRequest({
    required BuildContext context,
    required WidgetRef ref,
    required CompanyGovernanceFollowUpPolicyApprovalRequest request,
    required String selectedEntity,
  }) {
    final currentPolicy = ref.read(companyGovernanceFollowUpPolicyProvider);
    if (request.isStaleAgainst(currentPolicy)) {
      _showMessage(
        context,
        'Governance SLA request is stale; reject and submit a fresh request',
      );
      return;
    }

    final approved = ref
        .read(companyGovernanceFollowUpPolicyApprovalRequestsProvider.notifier)
        .approve(
          requestId: request.id,
          decidedAt: ref.read(companyAsOfDateProvider),
        );
    if (approved == null) {
      _showMessage(context, 'Governance SLA request is no longer pending');
      return;
    }

    final auditEvent = _activateGovernanceFollowUpPolicy(
      ref: ref,
      previousPolicy: approved.previousPolicy,
      nextPolicy: approved.requestedPolicy,
      impact: approved.impact,
      selectedEntity: selectedEntity,
    );
    if (auditEvent != null) {
      ref
          .read(
            companyGovernanceFollowUpPolicyApprovalRequestsProvider.notifier,
          )
          .attachAuditEvent(
            requestId: approved.id,
            auditEventId: auditEvent.id,
          );
    }
    _showMessage(context, 'Governance follow-up SLA approved and activated');
  }

  void _rejectGovernanceFollowUpPolicyRequest({
    required BuildContext context,
    required WidgetRef ref,
    required CompanyGovernanceFollowUpPolicyApprovalRequest request,
  }) {
    final rejected = ref
        .read(companyGovernanceFollowUpPolicyApprovalRequestsProvider.notifier)
        .reject(
          requestId: request.id,
          decidedAt: ref.read(companyAsOfDateProvider),
        );
    _showMessage(
      context,
      rejected == null
          ? 'Governance SLA request is no longer pending'
          : 'Governance follow-up SLA request rejected',
    );
  }

  CompanyDocumentAuditEvent? _activateGovernanceFollowUpPolicy({
    required WidgetRef ref,
    required CompanyGovernanceFollowUpPolicy previousPolicy,
    required CompanyGovernanceFollowUpPolicy nextPolicy,
    required CompanyGovernanceFollowUpPolicyImpact impact,
    required String selectedEntity,
  }) {
    final policy = ref
        .read(companyGovernanceFollowUpPolicyProvider.notifier)
        .saveDraft(CompanyGovernanceFollowUpPolicyDraft.fromPolicy(nextPolicy));
    ref
        .read(companyGovernanceFollowUpPolicyDraftProvider.notifier)
        .loadPolicy(policy);
    if (policy == previousPolicy) return null;

    final entityName =
        selectedEntity == companyAllEntities
            ? 'Company Governance'
            : selectedEntity;
    final recordedAt = ref.read(companyAsOfDateProvider);
    final changeRecord = ref
        .read(companyGovernanceFollowUpPolicyChangeRecordsProvider.notifier)
        .recordChange(
          previousPolicy: previousPolicy,
          nextPolicy: policy,
          impact: impact,
          entityName: entityName,
          recordedAt: recordedAt,
        );
    final auditPayload = CompanyGovernanceFollowUpPolicyAuditPayload.fromChange(
      previousPolicy: previousPolicy,
      nextPolicy: policy,
      impact: impact,
      entityName: entityName,
    );
    final auditEvent = ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: auditPayload.documentId,
          documentTitle: auditPayload.documentTitle,
          entityName: auditPayload.entityName,
          actorName: auditPayload.actorName,
          type: CompanyDocumentAuditEventType.governanceFollowUpPolicyChanged,
          happenedAt: recordedAt,
          note: auditPayload.note,
          correlationId: auditPayload.correlationId,
        );
    ref
        .read(companyGovernanceFollowUpPolicyChangeRecordsProvider.notifier)
        .attachAuditEvent(
          recordId: changeRecord.id,
          auditEventId: auditEvent.id,
        );
    ref.read(companySelectedDocumentAuditEventIdProvider.notifier).state =
        auditEvent.id;
    ref.read(companyDocumentAuditFilterProvider.notifier).state =
        CompanyDocumentAuditFilterPreset.allActivity.filter;
    return auditEvent;
  }

  void _restoreGovernanceFollowUpPolicy({
    required BuildContext context,
    required WidgetRef ref,
    required CompanyGovernanceFollowUpPolicyChangeRecord record,
    required String selectedEntity,
  }) {
    ref
        .read(companyGovernanceFollowUpPolicyDraftProvider.notifier)
        .loadPolicy(record.previousPolicy);
    _requestGovernanceFollowUpPolicyApproval(context, ref, selectedEntity);
  }

  void _recordGovernanceFollowUp({
    required BuildContext context,
    required WidgetRef ref,
    required CompanyGovernanceFollowUpLane lane,
    required String selectedEntity,
    required DateTime asOfDate,
  }) {
    final auditPayload = CompanyGovernanceFollowUpAuditPayload.fromLane(
      lane: lane,
      entityName:
          selectedEntity == companyAllEntities
              ? 'Company Governance'
              : selectedEntity,
    );
    final auditEvent = ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: auditPayload.documentId,
          documentTitle: auditPayload.documentTitle,
          entityName: auditPayload.entityName,
          actorName: auditPayload.actorName,
          type: CompanyDocumentAuditEventType.governanceOwnerFollowedUp,
          happenedAt: asOfDate,
          note: auditPayload.note,
          correlationId: auditPayload.correlationId,
        );
    ref.read(companySelectedDocumentAuditEventIdProvider.notifier).state =
        auditEvent.id;
    _showMessage(
      context,
      'Governance follow-up recorded for ${lane.ownerLabel}',
    );
  }

  void _resolveGovernanceAction(
    BuildContext context,
    WidgetRef ref,
    CompanyGovernanceActionItem item,
  ) {
    switch (item.resolution) {
      case CompanyGovernanceActionResolution.markFilingFiled:
        ref.read(companyFilingsProvider.notifier).markFiled(item.recordId);
        _showMessage(context, '${item.title} marked filed');
        break;
      case CompanyGovernanceActionResolution.verifyEmployerAccount:
        ref
            .read(companyEmployerAccountsProvider.notifier)
            .markVerified(item.recordId);
        _showMessage(context, '${item.title} account verified');
        break;
      case CompanyGovernanceActionResolution.rotateEmployerCredentialOwner:
        ref
            .read(companyEmployerAccountsProvider.notifier)
            .rotateCredentialOwner(item.recordId, 'People Operations');
        _showMessage(context, '${item.title} credential owner rotated');
        break;
      case CompanyGovernanceActionResolution.renewVendorAgreement:
        ref
            .read(companyVendorAgreementsProvider.notifier)
            .markRenewed(item.recordId);
        _showMessage(context, '${item.title} renewed');
        break;
      case CompanyGovernanceActionResolution.closeVendorImplementation:
        ref
            .read(companyVendorAgreementsProvider.notifier)
            .closeImplementation(item.recordId);
        _showMessage(context, '${item.title} implementation closed');
        break;
      case CompanyGovernanceActionResolution.activateSignatoryEvidence:
        ref
            .read(companySignatoriesProvider.notifier)
            .markEvidenceActive(item.recordId);
        _showMessage(context, '${item.title} evidence activated');
        break;
      case CompanyGovernanceActionResolution.assignSignatoryBackup:
        ref
            .read(companySignatoriesProvider.notifier)
            .assignBackup(item.recordId, 'People Operations');
        _showMessage(context, '${item.title} backup assigned');
        break;
    }
  }

  void _saveProfile(BuildContext context, WidgetRef ref) {
    try {
      final profile = ref
          .read(companyProfileProvider.notifier)
          .saveDraft(ref.read(companyProfileDraftProvider));
      ref.read(companyProfileDraftProvider.notifier).loadProfile(profile);
      _showMessage(context, '${profile.title} profile saved');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitOrgUnit(BuildContext context, WidgetRef ref) {
    try {
      final unit = ref
          .read(companyOrgUnitsProvider.notifier)
          .submitDraft(ref.read(companyOrgUnitDraftProvider));
      ref
          .read(companyOrgUnitDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${unit.name} added to company structure');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitLegalEntity(BuildContext context, WidgetRef ref) {
    try {
      final entity = ref
          .read(companyLegalEntitiesProvider.notifier)
          .submitDraft(ref.read(companyLegalEntityDraftProvider));
      ref.read(companyLegalEntityDraftProvider.notifier).clear();
      _showMessage(context, '${entity.name} added to legal entities');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitWorkLocation(BuildContext context, WidgetRef ref) {
    try {
      final location = ref
          .read(companyWorkLocationsProvider.notifier)
          .submitDraft(ref.read(companyWorkLocationDraftProvider));
      ref
          .read(companyWorkLocationDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${location.name} added to work locations');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitCostCenter(BuildContext context, WidgetRef ref) {
    try {
      final center = ref
          .read(companyCostCentersProvider.notifier)
          .submitDraft(ref.read(companyCostCenterDraftProvider));
      ref
          .read(companyCostCenterDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${center.name} added to cost centers');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitPositionControl(BuildContext context, WidgetRef ref) {
    try {
      final position = ref
          .read(companyPositionControlsProvider.notifier)
          .submitDraft(ref.read(companyPositionControlDraftProvider));
      ref
          .read(companyPositionControlDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            orgUnitName: _defaultOrgUnit(ref),
          );
      _showMessage(context, '${position.positionTitle} position control added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitHeadcountRequisition(BuildContext context, WidgetRef ref) {
    try {
      final requisition = ref
          .read(companyHeadcountRequisitionsProvider.notifier)
          .submitDraft(ref.read(companyHeadcountRequisitionDraftProvider));
      ref
          .read(companyHeadcountRequisitionActivityRecordsProvider.notifier)
          .record(
            requisition: requisition,
            type: CompanyHeadcountRequisitionActivityType.submitted,
            happenedAt: ref.read(companyAsOfDateProvider),
            note: 'Headcount requisition submitted.',
          );
      ref
          .read(companyHeadcountRequisitionDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            orgUnitName: _defaultOrgUnit(ref),
          );
      _showMessage(
        context,
        '${requisition.roleTitle} headcount requisition submitted',
      );
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _recordHeadcountRequisitionActivity({
    required WidgetRef ref,
    required String requisitionId,
    required CompanyHeadcountRequisitionActivityType type,
    required String note,
  }) {
    final requisition =
        ref
            .read(companyHeadcountRequisitionsProvider)
            .where((request) => request.id == requisitionId)
            .firstOrNull;
    if (requisition == null) return;

    ref
        .read(companyHeadcountRequisitionActivityRecordsProvider.notifier)
        .record(
          requisition: requisition,
          type: type,
          happenedAt: ref.read(companyAsOfDateProvider),
          note: note,
        );
  }

  void _submitCompensationBand(BuildContext context, WidgetRef ref) {
    try {
      final band = ref
          .read(companyCompensationBandsProvider.notifier)
          .submitDraft(ref.read(companyCompensationBandDraftProvider));
      ref
          .read(companyCompensationBandDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${band.bandCode} compensation band added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitJobProfile(BuildContext context, WidgetRef ref) {
    try {
      final profile = ref
          .read(companyJobProfilesProvider.notifier)
          .submitDraft(ref.read(companyJobProfileDraftProvider));
      ref
          .read(companyJobProfileDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            orgUnitName: _defaultOrgUnit(ref),
            compensationBand: _defaultCompensationBand(ref),
          );
      _showMessage(context, '${profile.jobTitle} job profile added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitContractTemplate(BuildContext context, WidgetRef ref) {
    try {
      final template = ref
          .read(companyContractTemplatesProvider.notifier)
          .submitDraft(ref.read(companyContractTemplateDraftProvider));
      ref
          .read(companyContractTemplateDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            jobProfileCode: _defaultJobProfileCode(ref),
            compensationBand: _defaultCompensationBand(ref),
          );
      _showMessage(context, '${template.templateName} template added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitOnboardingPack(BuildContext context, WidgetRef ref) {
    try {
      final pack = ref
          .read(companyOnboardingPacksProvider.notifier)
          .submitDraft(ref.read(companyOnboardingPackDraftProvider));
      ref
          .read(companyOnboardingPackDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            jobProfileCode: _defaultJobProfileCode(ref),
            contractTemplateName: _defaultContractTemplateName(ref),
          );
      _showMessage(context, '${pack.packName} onboarding pack added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitProbationPlan(BuildContext context, WidgetRef ref) {
    try {
      final plan = ref
          .read(companyProbationPlansProvider.notifier)
          .submitDraft(ref.read(companyProbationPlanDraftProvider));
      ref
          .read(companyProbationPlanDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            jobProfileCode: _defaultJobProfileCode(ref),
            onboardingPackName: _defaultOnboardingPackName(ref),
          );
      _showMessage(context, '${plan.planName} probation plan added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitOffboardingPack(BuildContext context, WidgetRef ref) {
    try {
      final pack = ref
          .read(companyOffboardingPacksProvider.notifier)
          .submitDraft(ref.read(companyOffboardingPackDraftProvider));
      ref
          .read(companyOffboardingPackDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            jobProfileCode: _defaultJobProfileCode(ref),
          );
      _showMessage(context, '${pack.packName} offboarding pack added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitDocumentRequirement(BuildContext context, WidgetRef ref) {
    try {
      final requirement = ref
          .read(companyDocumentRequirementsProvider.notifier)
          .submitDraft(ref.read(companyDocumentRequirementDraftProvider));
      ref
          .read(companyDocumentRequirementDraftProvider.notifier)
          .clear(
            entityName: _defaultEntity(ref),
            jobProfileCode: _defaultJobProfileCode(ref),
            contractTemplateName: _defaultContractTemplateName(ref),
            onboardingPackName: _defaultOnboardingPackName(ref),
            probationPlanName: _defaultProbationPlanName(ref),
            offboardingPackName: _defaultOffboardingPackName(ref),
          );
      _showMessage(
        context,
        '${requirement.requirementName} document requirement added',
      );
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitApprovalRule(BuildContext context, WidgetRef ref) {
    try {
      final rule = ref
          .read(companyApprovalRulesProvider.notifier)
          .submitDraft(ref.read(companyApprovalRuleDraftProvider));
      ref
          .read(companyApprovalRuleDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${rule.domain.label} approval rule added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitDocument(BuildContext context, WidgetRef ref) {
    try {
      final document = ref
          .read(companyDocumentsProvider.notifier)
          .submitDraft(ref.read(companyDocumentDraftProvider));
      ref
          .read(companyDocumentDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${document.title} added to company documents');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _selectRenewalDocument(WidgetRef ref, String documentId) {
    final document =
        ref
            .read(companyDocumentsProvider)
            .where((item) => item.id == documentId)
            .firstOrNull;
    if (document == null) return;
    ref
        .read(companyDocumentRenewalDraftProvider.notifier)
        .selectDocument(document);
  }

  void _submitDocumentRenewal(BuildContext context, WidgetRef ref) {
    try {
      final task = ref
          .read(companyDocumentRenewalsProvider.notifier)
          .submitDraft(ref.read(companyDocumentRenewalDraftProvider));
      ref
          .read(companyDocumentRenewalDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      ref
          .read(companyDocumentAuditEventsProvider.notifier)
          .record(
            documentId: task.documentId,
            documentTitle: task.documentTitle,
            entityName: task.entityName,
            actorName: task.ownerName,
            type: CompanyDocumentAuditEventType.reminderSent,
            happenedAt: ref.read(companyAsOfDateProvider),
            note: 'Renewal task scheduled with ${task.reminderLeadDays}d lead.',
          );
      _showMessage(context, '${task.documentTitle} renewal scheduled');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _startDocumentRenewal(BuildContext context, WidgetRef ref, String id) {
    final task = ref
        .read(companyDocumentRenewalsProvider.notifier)
        .markInProgress(id);
    if (task == null) return;
    ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: task.documentId,
          documentTitle: task.documentTitle,
          entityName: task.entityName,
          actorName: task.ownerName,
          type: CompanyDocumentAuditEventType.renewalStarted,
          happenedAt: ref.read(companyAsOfDateProvider),
          note: task.actionLabel,
        );
    _showMessage(context, '${task.documentTitle} renewal started');
  }

  void _completeDocumentRenewal(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) {
    final task = ref
        .read(companyDocumentRenewalsProvider.notifier)
        .markCompleted(id);
    if (task == null) return;
    ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: task.documentId,
          documentTitle: task.documentTitle,
          entityName: task.entityName,
          actorName: task.ownerName,
          type: CompanyDocumentAuditEventType.renewed,
          happenedAt: ref.read(companyAsOfDateProvider),
          note: 'Renewal completed and marked ready for verification.',
        );
    _showMessage(context, '${task.documentTitle} renewal completed');
  }

  void _submitOperatingReadiness(BuildContext context, WidgetRef ref) {
    try {
      final item = ref
          .read(companyOperatingReadinessProvider.notifier)
          .submitDraft(ref.read(companyOperatingReadinessDraftProvider));
      ref
          .read(companyOperatingReadinessDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${item.area.label} service readiness added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitGovernanceContact(BuildContext context, WidgetRef ref) {
    try {
      final contact = ref
          .read(companyGovernanceContactsProvider.notifier)
          .submitDraft(ref.read(companyGovernanceContactDraftProvider));
      ref
          .read(companyGovernanceContactDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${contact.personName} governance owner added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitEntityLifecycle(BuildContext context, WidgetRef ref) {
    try {
      final milestone = ref
          .read(companyEntityLifecyclesProvider.notifier)
          .submitDraft(ref.read(companyEntityLifecycleDraftProvider));
      ref
          .read(companyEntityLifecycleDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${milestone.title} lifecycle milestone added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitCompanyControl(BuildContext context, WidgetRef ref) {
    try {
      final control = ref
          .read(companyControlsProvider.notifier)
          .submitDraft(ref.read(companyControlDraftProvider));
      ref
          .read(companyControlDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${control.title} control added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitEmployerAccount(BuildContext context, WidgetRef ref) {
    try {
      final account = ref
          .read(companyEmployerAccountsProvider.notifier)
          .submitDraft(ref.read(companyEmployerAccountDraftProvider));
      ref
          .read(companyEmployerAccountDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${account.accountName} employer account added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitVendorAgreement(BuildContext context, WidgetRef ref) {
    try {
      final agreement = ref
          .read(companyVendorAgreementsProvider.notifier)
          .submitDraft(ref.read(companyVendorAgreementDraftProvider));
      ref
          .read(companyVendorAgreementDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${agreement.vendorName} vendor agreement added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitCompanyFiling(BuildContext context, WidgetRef ref) {
    try {
      final filing = ref
          .read(companyFilingsProvider.notifier)
          .submitDraft(ref.read(companyFilingDraftProvider));
      ref
          .read(companyFilingDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${filing.title} filing added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitCompanySignatory(BuildContext context, WidgetRef ref) {
    try {
      final signatory = ref
          .read(companySignatoriesProvider.notifier)
          .submitDraft(ref.read(companySignatoryDraftProvider));
      ref
          .read(companySignatoryDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${signatory.personName} signatory added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  void _submitChangeRequest(BuildContext context, WidgetRef ref) {
    try {
      final request = ref
          .read(companyChangeRequestsProvider.notifier)
          .submitDraft(ref.read(companyChangeRequestDraftProvider));
      ref
          .read(companyChangeRequestDraftProvider.notifier)
          .clear(entityName: _defaultEntity(ref));
      _showMessage(context, '${request.type.label} change request added');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  String _defaultEntity(WidgetRef ref) {
    final selectedEntity = ref.read(companySelectedEntityProvider);
    return selectedEntity == companyAllEntities
        ? 'PT Kaysir Nusantara'
        : selectedEntity;
  }

  String _defaultOrgUnit(WidgetRef ref) {
    final entity = _defaultEntity(ref);
    return ref
            .read(companyOrgUnitsProvider)
            .where((unit) => unit.entityName == entity)
            .map((unit) => unit.name)
            .firstOrNull ??
        'People Operations';
  }

  String _defaultJobProfileCode(WidgetRef ref) {
    final entity = _defaultEntity(ref);
    return ref
            .read(companyJobProfilesProvider)
            .where((profile) => profile.entityName == entity)
            .map((profile) => profile.jobCode)
            .firstOrNull ??
        '';
  }

  String _defaultContractTemplateName(WidgetRef ref) {
    final entity = _defaultEntity(ref);
    return ref
            .read(companyContractTemplatesProvider)
            .where((template) => template.entityName == entity)
            .map((template) => template.templateName)
            .firstOrNull ??
        '';
  }

  String _defaultOnboardingPackName(WidgetRef ref) {
    final entity = _defaultEntity(ref);
    return ref
            .read(companyOnboardingPacksProvider)
            .where((pack) => pack.entityName == entity)
            .map((pack) => pack.packName)
            .firstOrNull ??
        '';
  }

  String _defaultProbationPlanName(WidgetRef ref) {
    final entity = _defaultEntity(ref);
    return ref
            .read(companyProbationPlansProvider)
            .where((plan) => plan.entityName == entity)
            .map((plan) => plan.planName)
            .firstOrNull ??
        '';
  }

  String _defaultOffboardingPackName(WidgetRef ref) {
    final entity = _defaultEntity(ref);
    return ref
            .read(companyOffboardingPacksProvider)
            .where((pack) => pack.entityName == entity)
            .map((pack) => pack.packName)
            .firstOrNull ??
        '';
  }

  String _defaultCompensationBand(WidgetRef ref) {
    final entity = _defaultEntity(ref);
    return ref
            .read(companyCompensationBandsProvider)
            .where((band) => band.entityName == entity)
            .map((band) => band.bandCode)
            .firstOrNull ??
        '';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
