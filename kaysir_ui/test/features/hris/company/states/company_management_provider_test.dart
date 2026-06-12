import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/company/models/company_approval_rule.dart';
import 'package:kaysir/features/hris/company/models/company_change_request.dart';
import 'package:kaysir/features/hris/company/models/company_compensation_band.dart';
import 'package:kaysir/features/hris/company/models/company_contract_template.dart';
import 'package:kaysir/features/hris/company/models/company_control.dart';
import 'package:kaysir/features/hris/company/models/company_cost_center.dart';
import 'package:kaysir/features/hris/company/models/company_document.dart';
import 'package:kaysir/features/hris/company/models/company_document_audit_event.dart';
import 'package:kaysir/features/hris/company/models/company_document_audit_filter.dart';
import 'package:kaysir/features/hris/company/models/company_document_requirement.dart';
import 'package:kaysir/features/hris/company/models/company_document_renewal.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_gap.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_gap_recommendation.dart';
import 'package:kaysir/features/hris/company/models/company_entity_lifecycle.dart';
import 'package:kaysir/features/hris/company/models/company_employer_account.dart';
import 'package:kaysir/features/hris/company/models/company_filing.dart';
import 'package:kaysir/features/hris/company/models/company_governance_action_filter.dart';
import 'package:kaysir/features/hris/company/models/company_governance_action_item.dart';
import 'package:kaysir/features/hris/company/models/company_governance_command_brief.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_cadence.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_approval.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_impact.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff_history.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff_record.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_load.dart';
import 'package:kaysir/features/hris/company/models/company_governance_saved_view.dart';
import 'package:kaysir/features/hris/company/models/company_governance_contact.dart';
import 'package:kaysir/features/hris/company/models/company_headcount_requisition.dart';
import 'package:kaysir/features/hris/company/models/company_headcount_requisition_activity.dart';
import 'package:kaysir/features/hris/company/models/company_job_profile.dart';
import 'package:kaysir/features/hris/company/models/company_legal_entity.dart';
import 'package:kaysir/features/hris/company/models/company_offboarding_pack.dart';
import 'package:kaysir/features/hris/company/models/company_onboarding_pack.dart';
import 'package:kaysir/features/hris/company/models/company_operating_readiness.dart';
import 'package:kaysir/features/hris/company/models/company_policy.dart';
import 'package:kaysir/features/hris/company/models/company_position_control.dart';
import 'package:kaysir/features/hris/company/models/company_probation_plan.dart';
import 'package:kaysir/features/hris/company/models/company_signatory.dart';
import 'package:kaysir/features/hris/company/models/company_vendor_agreement.dart';
import 'package:kaysir/features/hris/company/models/company_work_location.dart';
import 'package:kaysir/features/hris/company/models/company_workforce_plan.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_plan.dart';
import 'package:kaysir/features/hris/company/states/company_management_provider.dart';
import 'package:kaysir/features/hris/employee/models/employee_compliance_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_compliance_provider.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_request_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_request_provider.dart';

void main() {
  test('company provider exposes a full management summary', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(companyManagementSummaryProvider);

    expect(summary.legalEntities, 3);
    expect(summary.verifiedLegalEntities, 1);
    expect(summary.locationCount, 4);
    expect(summary.activeHeadcount, 101);
    expect(summary.legalEntityRiskCount, 2);
    expect(summary.locationRiskCount, 2);
    expect(summary.costCenterRiskCount, 2);
    expect(summary.approvalRuleRiskCount, 2);
    expect(summary.documentCount, 5);
    expect(summary.documentRiskCount, 3);
    expect(summary.documentRenewalCount, 4);
    expect(summary.documentRenewalRiskCount, 3);
    expect(summary.documentAuditEventCount, 5);
    expect(summary.operatingReadinessCount, 6);
    expect(summary.operatingReadyCount, 3);
    expect(summary.operatingRiskCount, 3);
    expect(summary.governanceContactCount, 6);
    expect(summary.governanceContactReadyCount, 3);
    expect(summary.governanceContactRiskCount, 3);
    expect(summary.entityLifecycleCount, 5);
    expect(summary.entityLifecycleReadyCount, 2);
    expect(summary.entityLifecycleRiskCount, 3);
    expect(summary.controlCount, 5);
    expect(summary.controlReadyCount, 2);
    expect(summary.controlRiskCount, 3);
    expect(summary.employerAccountCount, 5);
    expect(summary.employerAccountReadyCount, 2);
    expect(summary.employerAccountRiskCount, 3);
    expect(summary.positionControlCount, 5);
    expect(summary.positionControlReadyCount, 2);
    expect(summary.positionControlRiskCount, 3);
    expect(summary.compensationBandCount, 5);
    expect(summary.compensationBandReadyCount, 2);
    expect(summary.compensationBandRiskCount, 3);
    expect(summary.jobProfileCount, 5);
    expect(summary.jobProfileReadyCount, 2);
    expect(summary.jobProfileRiskCount, 3);
    expect(summary.contractTemplateCount, 5);
    expect(summary.contractTemplateReadyCount, 2);
    expect(summary.contractTemplateRiskCount, 3);
    expect(summary.onboardingPackCount, 5);
    expect(summary.onboardingPackReadyCount, 2);
    expect(summary.onboardingPackRiskCount, 3);
    expect(summary.probationPlanCount, 5);
    expect(summary.probationPlanReadyCount, 2);
    expect(summary.probationPlanRiskCount, 3);
    expect(summary.offboardingPackCount, 5);
    expect(summary.offboardingPackReadyCount, 2);
    expect(summary.offboardingPackRiskCount, 3);
    expect(summary.documentRequirementCount, 5);
    expect(summary.documentRequirementReadyCount, 2);
    expect(summary.documentRequirementRiskCount, 3);
    expect(summary.employeeDocumentGapCount, 5);
    expect(summary.employeeDocumentGapReadyCount, 0);
    expect(summary.employeeDocumentGapRiskCount, 5);
    expect(summary.vendorAgreementCount, 5);
    expect(summary.vendorAgreementReadyCount, 2);
    expect(summary.vendorAgreementRiskCount, 3);
    expect(summary.filingCount, 5);
    expect(summary.filingReadyCount, 2);
    expect(summary.filingRiskCount, 3);
    expect(summary.signatoryCount, 5);
    expect(summary.signatoryReadyCount, 2);
    expect(summary.signatoryRiskCount, 3);
    expect(summary.changeRequestCount, 5);
    expect(summary.openChangeCount, 4);
    expect(summary.changeRequestRiskCount, 3);
    expect(summary.policyRiskCount, 2);
    expect(summary.orgRiskCount, 4);
    expect(summary.totalRisks, 76);
    expect((summary.readinessScore * 100).round(), 46);
  });

  test('company provider exposes a governance action queue', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final actions = container.read(companyGovernanceActionItemsProvider);

    expect(actions, isNotEmpty);
    expect(actions, hasLength(lessThanOrEqualTo(6)));
    expect(actions.first.severity, CompanyGovernanceActionSeverity.critical);
    expect(
      actions.map((item) => item.source).toSet(),
      containsAll([
        CompanyGovernanceActionSource.filing,
        CompanyGovernanceActionSource.employerAccount,
        CompanyGovernanceActionSource.vendorAgreement,
        CompanyGovernanceActionSource.signatory,
      ]),
    );
    expect(actions.first.issueLabels, isNotEmpty);
    expect(actions.first.resolveLabel, isNotEmpty);

    final ownerLoads = container.read(companyGovernanceOwnerLoadsProvider);
    expect(ownerLoads, isNotEmpty);
    expect(ownerLoads.first.risk, CompanyGovernanceOwnerLoadRisk.critical);
    expect(ownerLoads.first.actionCount, greaterThan(0));
    expect(ownerLoads.first.sourceSummary, isNotEmpty);

    expect(container.read(companySelectedGovernanceOwnerProvider), isNull);
    container.read(companySelectedGovernanceOwnerProvider.notifier).state =
        ownerLoads.first.ownerLabel;
    expect(
      container.read(companySelectedGovernanceOwnerProvider),
      ownerLoads.first.ownerLabel,
    );
    final handoff = container.read(companyGovernanceOwnerHandoffProvider);
    expect(handoff, isA<CompanyGovernanceOwnerHandoff>());
    expect(handoff!.ownerLabel, ownerLoads.first.ownerLabel);
    expect(handoff.actions, isNotEmpty);
    final asOfDate = container.read(companyAsOfDateProvider);
    final expectedDateLabel =
        '${asOfDate.year}-${asOfDate.month.toString().padLeft(2, '0')}-${asOfDate.day.toString().padLeft(2, '0')}';
    final record = container
        .read(companyGovernanceOwnerHandoffRecordsProvider.notifier)
        .record(handoff: handoff, recordedAt: asOfDate);
    expect(record.id, 'governance-handoff-001');
    expect(record.recordedDateLabel, expectedDateLabel);
    container
        .read(companyGovernanceOwnerHandoffRecordsProvider.notifier)
        .attachAuditEvent(recordId: record.id, auditEventId: 'audit-091');
    expect(
      container
          .read(companySelectedGovernanceOwnerHandoffRecordProvider)
          ?.auditEventId,
      'audit-091',
    );
    expect(
      container.read(companySelectedGovernanceOwnerHandoffRecordProvider),
      isA<CompanyGovernanceOwnerHandoffRecord>(),
    );
    final handoffHistory = container.read(
      companyGovernanceOwnerHandoffHistoryProvider,
    );
    expect(handoffHistory, isA<CompanyGovernanceOwnerHandoffHistory>());
    expect(handoffHistory.recordCount, 1);
    expect(handoffHistory.latestLabel, expectedDateLabel);
    expect(
      handoffHistory.prioritizedRecords(ownerLoads.first.ownerLabel).single.id,
      record.id,
    );
    final followUpLanes = container.read(
      companyGovernanceFollowUpCadenceProvider,
    );
    expect(followUpLanes, isNotEmpty);
    final selectedFollowUpLane = followUpLanes.singleWhere(
      (lane) => lane.ownerLabel == ownerLoads.first.ownerLabel,
    );
    expect(
      selectedFollowUpLane.state,
      CompanyGovernanceFollowUpState.scheduled,
    );
    expect(selectedFollowUpLane.handoffRecordId, record.id);
    expect(selectedFollowUpLane.auditEventId, 'audit-091');
    const customFollowUpPolicy = CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: 4,
      highCadenceDays: 5,
      steadyCadenceDays: 6,
    );
    final draftNotifier = container.read(
      companyGovernanceFollowUpPolicyDraftProvider.notifier,
    );
    draftNotifier.setCriticalCadenceDays('4');
    draftNotifier.setHighCadenceDays('5');
    draftNotifier.setSteadyCadenceDays('6');
    final draftImpact = container.read(
      companyGovernanceFollowUpPolicyImpactProvider,
    );
    expect(draftImpact.isValid, isTrue);
    expect(draftImpact.changedLaneCount, 1);
    expect(draftImpact.changedLanes.single.previewTouchLabel, 'Due in 4d');
    expect(
      draftImpact.severity,
      CompanyGovernanceFollowUpPolicyImpactSeverity.balanced,
    );
    final approvalRequest = container
        .read(companyGovernanceFollowUpPolicyApprovalRequestsProvider.notifier)
        .requestApproval(
          previousPolicy: CompanyGovernanceFollowUpPolicy.defaultPolicy,
          requestedPolicy: customFollowUpPolicy,
          impact: draftImpact,
          entityName: 'Company Governance',
          requestedAt: asOfDate,
        );
    expect(
      container
          .read(companyGovernanceFollowUpPolicyApprovalQueueProvider)
          .pendingCount,
      1,
    );
    final approvedRequest = container
        .read(companyGovernanceFollowUpPolicyApprovalRequestsProvider.notifier)
        .approve(requestId: approvalRequest.id, decidedAt: asOfDate);
    expect(
      approvedRequest?.status,
      CompanyGovernanceFollowUpPolicyApprovalStatus.approved,
    );
    container
        .read(companyGovernanceFollowUpPolicyApprovalRequestsProvider.notifier)
        .attachAuditEvent(
          requestId: approvalRequest.id,
          auditEventId: 'audit-sla-approval',
        );
    final approvalQueue = container.read(
      companyGovernanceFollowUpPolicyApprovalQueueProvider,
    );
    expect(approvalQueue.pendingCount, 0);
    expect(approvalQueue.approvedCount, 1);
    expect(approvalQueue.records.first.auditEventId, 'audit-sla-approval');
    final policyChangeRecord = container
        .read(companyGovernanceFollowUpPolicyChangeRecordsProvider.notifier)
        .recordChange(
          previousPolicy: CompanyGovernanceFollowUpPolicy.defaultPolicy,
          nextPolicy: customFollowUpPolicy,
          impact: draftImpact,
          entityName: 'Company Governance',
          recordedAt: asOfDate,
        );
    container
        .read(companyGovernanceFollowUpPolicyChangeRecordsProvider.notifier)
        .attachAuditEvent(
          recordId: policyChangeRecord.id,
          auditEventId: 'audit-sla',
        );
    final policyHistory = container.read(
      companyGovernanceFollowUpPolicyHistoryProvider,
    );
    expect(policyHistory.recordCount, 1);
    expect(policyHistory.auditedCount, 1);
    expect(policyHistory.latest?.auditEventId, 'audit-sla');

    final savedFollowUpPolicy = container
        .read(companyGovernanceFollowUpPolicyProvider.notifier)
        .saveDraft(
          container.read(companyGovernanceFollowUpPolicyDraftProvider),
        );
    expect(savedFollowUpPolicy, customFollowUpPolicy);
    expect(
      container
          .read(companyGovernanceFollowUpPolicyDraftProvider)
          .criticalCadenceDaysText,
      '4',
    );
    final customFollowUpLane = container
        .read(companyGovernanceFollowUpCadenceProvider)
        .singleWhere((lane) => lane.ownerLabel == ownerLoads.first.ownerLabel);
    expect(
      customFollowUpLane.nextTouchDate,
      DateTime(
        asOfDate.year,
        asOfDate.month,
        asOfDate.day,
      ).add(const Duration(days: 4)),
    );
    expect(
      container.read(companyGovernanceFollowUpPolicyImpactProvider).hasChanges,
      isFalse,
    );
    final savedViews = container.read(companyGovernanceSavedViewsProvider);
    expect(savedViews, isNotEmpty);
    expect(
      container.read(companySelectedGovernanceSavedViewDetailProvider).type,
      CompanyGovernanceSavedViewType.commandCenter,
    );
    container.read(companySelectedGovernanceSavedViewProvider.notifier).state =
        CompanyGovernanceSavedViewType.vendorRenewals;
    expect(
      container
          .read(companySelectedGovernanceSavedViewDetailProvider)
          .queueFilter,
      CompanyGovernanceActionFilter.vendors,
    );
    final commandBrief = container.read(companyGovernanceCommandBriefProvider);
    expect(commandBrief, isA<CompanyGovernanceCommandBrief>());
    expect(commandBrief.queueFilter, CompanyGovernanceActionFilter.vendors);
    expect(
      commandBrief.intent,
      anyOf(
        CompanyGovernanceCommandBriefIntent.resolveAction,
        CompanyGovernanceCommandBriefIntent.monitor,
      ),
    );

    container.read(companySelectedEntityProvider.notifier).state =
        'Kaysir Retail Services';

    final retailActions = container.read(companyGovernanceActionItemsProvider);
    expect(
      retailActions.every(
        (item) => item.entityName == 'Kaysir Retail Services',
      ),
      isTrue,
    );
  });

  test('entity and risk filters focus company structure', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(companySelectedEntityProvider.notifier).state =
        'PT Kaysir Nusantara';
    container.read(companyAttentionOnlyProvider.notifier).state = true;

    final units = container.read(filteredCompanyOrgUnitsProvider);
    final entities = container.read(filteredCompanyLegalEntitiesProvider);
    final locations = container.read(filteredCompanyWorkLocationsProvider);
    final costCenters = container.read(filteredCompanyCostCentersProvider);
    final positionControls = container.read(
      filteredCompanyPositionControlsProvider,
    );
    final compensationBands = container.read(
      filteredCompanyCompensationBandsProvider,
    );
    final jobProfiles = container.read(filteredCompanyJobProfilesProvider);
    final contractTemplates = container.read(
      filteredCompanyContractTemplatesProvider,
    );
    final onboardingPacks = container.read(
      filteredCompanyOnboardingPacksProvider,
    );
    final probationPlans = container.read(
      filteredCompanyProbationPlansProvider,
    );
    final offboardingPacks = container.read(
      filteredCompanyOffboardingPacksProvider,
    );
    final documentRequirements = container.read(
      filteredCompanyDocumentRequirementsProvider,
    );
    final employeeDocumentGaps = container.read(
      filteredCompanyEmployeeDocumentGapsProvider,
    );
    final approvalRules = container.read(filteredCompanyApprovalRulesProvider);
    final documents = container.read(filteredCompanyDocumentsProvider);
    final renewals = container.read(filteredCompanyDocumentRenewalsProvider);
    final operatingReadiness = container.read(
      filteredCompanyOperatingReadinessProvider,
    );
    final governanceContacts = container.read(
      filteredCompanyGovernanceContactsProvider,
    );
    final lifecycles = container.read(filteredCompanyEntityLifecyclesProvider);
    final controls = container.read(filteredCompanyControlsProvider);
    final employerAccounts = container.read(
      filteredCompanyEmployerAccountsProvider,
    );
    final vendorAgreements = container.read(
      filteredCompanyVendorAgreementsProvider,
    );
    final filings = container.read(filteredCompanyFilingsProvider);
    final signatories = container.read(filteredCompanySignatoriesProvider);
    final changeRequests = container.read(
      filteredCompanyChangeRequestsProvider,
    );
    final policies = container.read(filteredCompanyPoliciesProvider);
    final summary = container.read(companyManagementSummaryProvider);

    expect(entities, isEmpty);
    expect(locations.map((location) => location.name), [
      'Remote Collaboration Hub',
    ]);
    expect(units.map((unit) => unit.name), [
      'People Operations',
      'Product & Commerce',
    ]);
    expect(costCenters.map((center) => center.name), ['Product & Commerce']);
    expect(positionControls.map((position) => position.positionTitle), [
      'Product Engineer',
      'Compliance Lead',
    ]);
    expect(compensationBands.map((band) => band.bandCode), ['ENG-4', 'GOV-6']);
    expect(jobProfiles.map((profile) => profile.jobTitle), ['Compliance Lead']);
    expect(contractTemplates.map((template) => template.templateName), [
      'Compliance lead appointment addendum',
    ]);
    expect(onboardingPacks.map((pack) => pack.packName), [
      'Compliance Lead executive onboarding pack',
    ]);
    expect(probationPlans.map((plan) => plan.planName), [
      'Compliance Lead executive probation plan',
    ]);
    expect(offboardingPacks.map((pack) => pack.packName), [
      'Compliance Lead executive exit pack',
    ]);
    expect(
      documentRequirements.map((requirement) => requirement.requirementName),
      ['Compliance Lead executive evidence matrix'],
    );
    expect(employeeDocumentGaps.map((gap) => gap.employeeName), [
      'Olivia Wilson',
      'Michael Chen',
      'David Kim',
      'Sarah Johnson',
    ]);
    expect(approvalRules, isEmpty);
    expect(documents, isEmpty);
    expect(renewals, isEmpty);
    expect(operatingReadiness, isEmpty);
    expect(governanceContacts, isEmpty);
    expect(lifecycles.map((milestone) => milestone.title), [
      'Product commerce restructure',
    ]);
    expect(controls.map((control) => control.title), [
      'Employee data privacy access control',
      'Remote attendance policy control',
    ]);
    expect(employerAccounts.map((account) => account.accountName), [
      'WLK labor registry account',
    ]);
    expect(vendorAgreements.map((agreement) => agreement.vendorName), [
      'Tanda Digital',
    ]);
    expect(filings.map((filing) => filing.title), [
      'Annual WLK labor report',
      'Monthly PPh 21 payroll tax filing',
    ]);
    expect(signatories.map((signatory) => signatory.personName), [
      'Fajar Prakoso',
    ]);
    expect(changeRequests.map((request) => request.title), [
      'Product cost center split',
    ]);
    expect(policies.map((policy) => policy.status).toSet(), {
      CompanyPolicyStatus.draft,
      CompanyPolicyStatus.needsReview,
    });
    expect(summary.legalEntities, 1);
    expect(summary.locationRiskCount, 1);
    expect(summary.costCenterRiskCount, 1);
    expect(summary.approvalRuleRiskCount, 0);
    expect(summary.documentRiskCount, 0);
    expect(summary.documentRenewalRiskCount, 0);
    expect(summary.operatingRiskCount, 0);
    expect(summary.governanceContactRiskCount, 0);
    expect(summary.entityLifecycleRiskCount, 1);
    expect(summary.controlRiskCount, 2);
    expect(summary.positionControlRiskCount, 2);
    expect(summary.compensationBandRiskCount, 2);
    expect(summary.jobProfileRiskCount, 1);
    expect(summary.contractTemplateRiskCount, 1);
    expect(summary.onboardingPackRiskCount, 1);
    expect(summary.probationPlanRiskCount, 1);
    expect(summary.offboardingPackRiskCount, 1);
    expect(summary.documentRequirementRiskCount, 1);
    expect(summary.employeeDocumentGapRiskCount, 4);
    expect(summary.employerAccountRiskCount, 1);
    expect(summary.vendorAgreementRiskCount, 1);
    expect(summary.filingRiskCount, 2);
    expect(summary.signatoryRiskCount, 1);
    expect(summary.changeRequestRiskCount, 1);
    expect(summary.orgRiskCount, 2);
    expect(summary.policyRiskCount, 2);
  });

  test(
    'company provider exposes prioritized employee document recommendations',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final recommendations = container.read(
        companyEmployeeDocumentGapRecommendationsProvider,
      );

      expect(recommendations, hasLength(5));
      expect(recommendations.first.gapId, 'empdoc-emma-offboarding');
      expect(
        recommendations.first.priority,
        CompanyEmployeeDocumentGapPriority.critical,
      );
      expect(recommendations.first.actionLabel, 'Generate request');
      expect(recommendations[1].gapId, 'empdoc-david-probation');
      expect(recommendations[1].actionLabel, 'Review rejected evidence');

      container.read(companySelectedEntityProvider.notifier).state =
          'Kaysir Retail Services';

      final retailRecommendations = container.read(
        companyEmployeeDocumentGapRecommendationsProvider,
      );

      expect(retailRecommendations, hasLength(1));
      expect(retailRecommendations.single.gapId, 'empdoc-emma-offboarding');
    },
  );

  test('company provider exposes employee document owner workloads', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final workloads = container.read(companyEmployeeDocumentWorkloadsProvider);

    expect(workloads.map((workload) => workload.ownerName), [
      'Fajar Prakoso',
      'Dewi Lestari',
      'People Operations',
      'Nadia Safitri',
    ]);
    expect(workloads.first.gapCount, 2);
    expect(workloads.first.primaryAction, 'Review rejected evidence');
    expect(workloads.first.requiresEscalation, isTrue);

    container.read(companySelectedEntityProvider.notifier).state =
        'Kaysir Retail Services';

    final retailWorkloads = container.read(
      companyEmployeeDocumentWorkloadsProvider,
    );

    expect(retailWorkloads, hasLength(1));
    expect(retailWorkloads.single.ownerName, 'Dewi Lestari');
    expect(retailWorkloads.single.primaryAction, 'Generate request');
    expect(retailWorkloads.single.overdueCount, 1);
  });

  test('company provider exposes employee document escalation plans', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final plans = container.read(
      companyEmployeeDocumentEscalationPlansProvider,
    );

    expect(plans, isNotEmpty);
    expect(plans.first.ownerName, 'Fajar Prakoso');
    expect(plans.first.priority, EmployeeDocumentEscalationPriority.critical);
    expect(plans.first.digestDue, isTrue);
    expect(plans.first.rationale, contains('critical'));
  });

  test('company owner escalation action records employee audit event', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final event = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .escalateOwnerWorkload('Fajar Prakoso');

    expect(event, isNotNull);
    expect(event!.id, 'audit-006');
    expect(event.type, CompanyDocumentAuditEventType.employeeOwnerEscalated);
    expect(event.type.isEmployeeDocumentEvent, isTrue);
    expect(event.documentId, 'employee-doc-workload-fajar-prakoso');
    expect(event.documentTitle, 'Fajar Prakoso - Employee document workload');
    expect(event.entityName, 'PT Kaysir Nusantara');
    expect(event.actorName, 'People Operations');
    expect(event.correlationId, 'owner-escalation-fajar-prakoso');
    expect(event.note, contains('Escalated owner workload'));
    expect(event.note, contains('Critical priority'));
    expect(event.note, contains('Review rejected evidence for David Kim'));

    final auditEvents = container.read(companyDocumentAuditEventsProvider);
    expect(auditEvents.first.id, event.id);

    final escalationStatuses = container.read(
      companyEmployeeDocumentEscalationStatusesProvider,
    );
    final fajarEscalationStatus = escalationStatuses.singleWhere(
      (status) => status.ownerName == 'Fajar Prakoso',
    );
    expect(fajarEscalationStatus.escalationCount, 1);
    expect(fajarEscalationStatus.lastAuditEventId, event.id);
    expect(
      fajarEscalationStatus.freshnessLabel(
        container.read(companyAsOfDateProvider),
      ),
      'Escalated today',
    );

    final escalationHistory = container.read(
      companyEmployeeDocumentEscalationHistoryProvider,
    );
    expect(escalationHistory.totalEscalationCount, 1);
    expect(escalationHistory.ownerCount, 1);
    expect(escalationHistory.items.single.auditEventId, event.id);
    expect(escalationHistory.items.single.ownerName, 'Fajar Prakoso');

    final plans = container.read(
      companyEmployeeDocumentEscalationPlansProvider,
    );
    final fajarPlan = plans.singleWhere(
      (plan) => plan.ownerName == 'Fajar Prakoso',
    );
    expect(fajarPlan.escalationFreshnessLabel, 'Escalated today');
    expect(fajarPlan.escalationCoolingDown, isTrue);
    expect(fajarPlan.lastEscalationAuditEventId, event.id);

    final followUps = container.read(
      companyEmployeeDocumentEscalationFollowUpsProvider,
    );
    expect(followUps.single.ownerName, 'Fajar Prakoso');
    expect(followUps.single.lastEscalationAuditEventId, event.id);
    expect(
      followUps.single.nextTouchLabel(container.read(companyAsOfDateProvider)),
      'Due tomorrow',
    );

    final duplicateEvent = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .escalateOwnerWorkload('Fajar Prakoso');
    expect(duplicateEvent, isNull);

    var summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(summary.totalEventCount, 6);
    expect(summary.employeeDocumentEventCount, 1);

    container
        .read(companyDocumentAuditFilterProvider.notifier)
        .state = const CompanyDocumentAuditTimelineFilter(
      scope: CompanyDocumentAuditTimelineScope.employeeDocuments,
    );

    final employeeEvents = container.read(
      filteredCompanyDocumentAuditEventsProvider,
    );
    summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(employeeEvents.single.type, event.type);
    expect(summary.filteredEventCount, 1);

    final missingEvent = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .escalateOwnerWorkload('Unknown Owner');
    expect(missingEvent, isNull);
  });

  test('company owner escalation batch records ready owner audit events', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final ownerNames =
        container
            .read(companyEmployeeDocumentEscalationPlansProvider)
            .map((plan) => plan.ownerName)
            .toList();

    expect(ownerNames, [
      'Fajar Prakoso',
      'Dewi Lestari',
      'People Operations',
      'Nadia Safitri',
    ]);

    final events = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .escalateOwnerWorkloads([...ownerNames, 'Fajar Prakoso']);

    expect(events, hasLength(4));
    expect(events.map((event) => event.type).toSet(), {
      CompanyDocumentAuditEventType.employeeOwnerEscalated,
    });
    expect(events.map((event) => event.documentId).toList(), [
      'employee-doc-workload-fajar-prakoso',
      'employee-doc-workload-dewi-lestari',
      'employee-doc-workload-people-operations',
      'employee-doc-workload-nadia-safitri',
    ]);

    final history = container.read(
      companyEmployeeDocumentEscalationHistoryProvider,
    );
    expect(history.totalEscalationCount, 4);
    expect(history.ownerCount, 4);

    final refreshedPlans = container.read(
      companyEmployeeDocumentEscalationPlansProvider,
    );
    expect(refreshedPlans.every((plan) => plan.escalationCoolingDown), isTrue);

    final summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(summary.employeeDocumentEventCount, 4);
  });

  test('company owner escalation follow-up records employee audit event', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final escalationEvent = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .escalateOwnerWorkload('Fajar Prakoso');
    expect(escalationEvent, isNotNull);

    final event = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .recordOwnerEscalationFollowUp('Fajar Prakoso');

    expect(event, isNotNull);
    expect(event!.id, 'audit-007');
    expect(event.type, CompanyDocumentAuditEventType.employeeOwnerFollowedUp);
    expect(event.type.isEmployeeDocumentEvent, isTrue);
    expect(event.documentId, 'employee-doc-workload-fajar-prakoso');
    expect(event.correlationId, 'owner-follow-up-fajar-prakoso');
    expect(event.note, contains('Recorded owner escalation follow-up'));
    expect(event.note, contains('Review rejected evidence for David Kim'));

    final followUps = container.read(
      companyEmployeeDocumentEscalationFollowUpsProvider,
    );
    final fajarFollowUp = followUps.singleWhere(
      (item) => item.ownerName == 'Fajar Prakoso',
    );
    expect(fajarFollowUp.followUpCount, 1);
    expect(fajarFollowUp.lastFollowUpAuditEventId, event.id);
    expect(
      fajarFollowUp.lastTouchLabel(container.read(companyAsOfDateProvider)),
      'Followed up today',
    );
    expect(
      fajarFollowUp.nextTouchLabel(container.read(companyAsOfDateProvider)),
      'Due tomorrow',
    );

    final summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(summary.employeeDocumentEventCount, 2);

    final missingEvent = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .recordOwnerEscalationFollowUp('Unknown Owner');
    expect(missingEvent, isNull);
  });

  test('company owner digest action records employee document audit event', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var digestStatuses = container.read(
      companyEmployeeDocumentWorkloadDigestStatusesProvider,
    );
    expect(
      digestStatuses.every(
        (status) => status.label(DateTime(2026, 6, 3)) == 'Not sent yet',
      ),
      isTrue,
    );
    final initialWorkloads = container.read(
      companyEmployeeDocumentWorkloadsProvider,
    );
    expect(
      digestStatuses.every(
        (status) => status.isDueFor(
          workload: initialWorkloads.singleWhere(
            (workload) => workload.ownerName == status.ownerName,
          ),
          asOfDate: container.read(companyAsOfDateProvider),
        ),
      ),
      isTrue,
    );

    final event = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .sendOwnerDigest('Fajar Prakoso');

    expect(event, isNotNull);
    expect(event!.id, 'audit-006');
    expect(event.type, CompanyDocumentAuditEventType.employeeOwnerDigestSent);
    expect(event.documentId, 'employee-doc-workload-fajar-prakoso');
    expect(event.documentTitle, 'Fajar Prakoso - Employee document workload');
    expect(event.entityName, 'PT Kaysir Nusantara');
    expect(event.actorName, 'People Operations');
    expect(event.correlationId, 'owner-workload-fajar-prakoso');
    expect(
      event.note,
      'Sent owner digest for 2 employee document gaps: '
      '9 missing evidence items, 2 open requests. '
      'Top action: Review rejected evidence for David Kim.',
    );

    final auditEvents = container.read(companyDocumentAuditEventsProvider);
    expect(auditEvents.first.id, event.id);
    digestStatuses = container.read(
      companyEmployeeDocumentWorkloadDigestStatusesProvider,
    );
    final fajarDigestStatus = digestStatuses.singleWhere(
      (status) => status.ownerName == 'Fajar Prakoso',
    );
    final fajarWorkload = container
        .read(companyEmployeeDocumentWorkloadsProvider)
        .singleWhere((workload) => workload.ownerName == 'Fajar Prakoso');
    expect(fajarDigestStatus.digestCount, 1);
    expect(fajarDigestStatus.lastAuditEventId, event.id);
    expect(
      fajarDigestStatus.label(container.read(companyAsOfDateProvider)),
      'Sent today',
    );
    expect(
      fajarDigestStatus.isDueFor(
        workload: fajarWorkload,
        asOfDate: container.read(companyAsOfDateProvider),
      ),
      isFalse,
    );
    expect(
      fajarDigestStatus.freshnessLabel(
        workload: fajarWorkload,
        asOfDate: container.read(companyAsOfDateProvider),
      ),
      'Due tomorrow',
    );
    final digestHistory = container.read(
      companyEmployeeDocumentDigestHistoryProvider,
    );
    expect(digestHistory.totalDigestCount, 1);
    expect(digestHistory.ownerCount, 1);
    expect(digestHistory.items.single.auditEventId, event.id);
    expect(digestHistory.items.single.ownerName, 'Fajar Prakoso');

    var summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(summary.totalEventCount, 6);
    expect(summary.employeeDocumentEventCount, 1);

    container
        .read(companyDocumentAuditFilterProvider.notifier)
        .state = const CompanyDocumentAuditTimelineFilter(
      scope: CompanyDocumentAuditTimelineScope.employeeDocuments,
    );

    final employeeEvents = container.read(
      filteredCompanyDocumentAuditEventsProvider,
    );
    summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(employeeEvents.single.type, event.type);
    expect(summary.filteredEventCount, 1);

    final missingEvent = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .sendOwnerDigest('Unknown Owner');
    expect(missingEvent, isNull);
  });

  test('company owner digest batch records due owner audit events', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final asOfDate = container.read(companyAsOfDateProvider);
    final workloads = container.read(companyEmployeeDocumentWorkloadsProvider);
    final statuses = container.read(
      companyEmployeeDocumentWorkloadDigestStatusesProvider,
    );
    final statusesByOwner = {
      for (final status in statuses) status.ownerName: status,
    };
    final dueOwnerNames = [
      for (final workload in workloads)
        if (statusesByOwner[workload.ownerName]!.isDueFor(
          workload: workload,
          asOfDate: asOfDate,
        ))
          workload.ownerName,
    ];

    expect(dueOwnerNames, [
      'Fajar Prakoso',
      'Dewi Lestari',
      'People Operations',
      'Nadia Safitri',
    ]);

    final events = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .sendOwnerDigests([...dueOwnerNames, 'Fajar Prakoso']);

    expect(events, hasLength(4));
    expect(events.map((event) => event.type).toSet(), {
      CompanyDocumentAuditEventType.employeeOwnerDigestSent,
    });
    expect(events.map((event) => event.documentId).toList(), [
      'employee-doc-workload-fajar-prakoso',
      'employee-doc-workload-dewi-lestari',
      'employee-doc-workload-people-operations',
      'employee-doc-workload-nadia-safitri',
    ]);

    final refreshedStatuses = container.read(
      companyEmployeeDocumentWorkloadDigestStatusesProvider,
    );
    final refreshedByOwner = {
      for (final status in refreshedStatuses) status.ownerName: status,
    };
    for (final workload in workloads) {
      final status = refreshedByOwner[workload.ownerName]!;
      expect(status.digestCount, 1);
      expect(status.isDueFor(workload: workload, asOfDate: asOfDate), isFalse);
    }

    final summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(summary.employeeDocumentEventCount, 4);
  });

  test(
    'profile, entity, location, cost center, approval, document, owner, change, and org drafts update company state',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profileDraft = container.read(companyProfileDraftProvider.notifier);
      profileDraft.setLegalName('PT Kaysir Global');
      profileDraft.setEmployeeCount('120');

      final profile = container
          .read(companyProfileProvider.notifier)
          .saveDraft(container.read(companyProfileDraftProvider));

      expect(profile.legalName, 'PT Kaysir Global');
      expect(container.read(companyProfileProvider).employeeCount, 120);

      final entityDraft = container.read(
        companyLegalEntityDraftProvider.notifier,
      );
      entityDraft.setName('Kaysir Labs');
      entityDraft.setRegistrationNumber('LAB-001');
      entityDraft.setTaxId('11.222.333.4-555.000');
      entityDraft.setCity('Jakarta');
      entityDraft.setHrOwner('Maya Pratiwi');
      entityDraft.setStatus(CompanyLegalEntityStatus.verified);

      final entity = container
          .read(companyLegalEntitiesProvider.notifier)
          .submitDraft(container.read(companyLegalEntityDraftProvider));

      expect(entity.name, 'Kaysir Labs');
      expect(container.read(companyLegalEntitiesProvider), hasLength(4));

      final locationDraft = container.read(
        companyWorkLocationDraftProvider.notifier,
      );
      locationDraft.setName('Labs Studio');
      locationDraft.setEntityName(entity.name);
      locationDraft.setCity('Jakarta');
      locationDraft.setRegion('Java West');
      locationDraft.setAddress('Jl. Senopati No. 8');
      locationDraft.setCoverageOwner('Maya Pratiwi');
      locationDraft.setCapacity('16');
      locationDraft.setAssignedHeadcount('12');
      locationDraft.setStatus(CompanyWorkLocationStatus.open);

      final location = container
          .read(companyWorkLocationsProvider.notifier)
          .submitDraft(container.read(companyWorkLocationDraftProvider));

      expect(location.name, 'Labs Studio');
      expect(location.requiresAttention, isFalse);
      expect(container.read(companyWorkLocationsProvider), hasLength(5));

      final costDraft = container.read(companyCostCenterDraftProvider.notifier);
      costDraft.setCode('cc-labs');
      costDraft.setName('Labs Budget');
      costDraft.setEntityName(entity.name);
      costDraft.setOrgUnitName('Product & Commerce');
      costDraft.setOwnerName('Maya Pratiwi');
      costDraft.setAnnualBudget('900000000');
      costDraft.setAllocatedHeadcount('8');
      costDraft.setActiveHeadcount('6');
      costDraft.setStatus(CompanyCostCenterStatus.active);

      final center = container
          .read(companyCostCentersProvider.notifier)
          .submitDraft(container.read(companyCostCenterDraftProvider));

      expect(center.code, 'CC-LABS');
      expect(center.requiresAttention, isFalse);
      expect(container.read(companyCostCentersProvider), hasLength(5));

      final positionDraft = container.read(
        companyPositionControlDraftProvider.notifier,
      );
      positionDraft.setPositionTitle('Labs HR Generalist');
      positionDraft.setEntityName(entity.name);
      positionDraft.setOrgUnitName('People Operations');
      positionDraft.setType(CompanyPositionControlType.permanent);
      positionDraft.setStatus(CompanyPositionControlStatus.approved);
      positionDraft.setOwnerName('Maya Pratiwi');
      positionDraft.setAuthorizedSeats('2');
      positionDraft.setFilledSeats('1');
      positionDraft.setFte('1');
      positionDraft.setCompensationBand('HR-4');
      positionDraft.setNextReviewDate('2026-09-15');
      positionDraft.setHiringPlan('Backfill after Labs entity launch');
      positionDraft.setLinkedRequisition('REQ-LABS-2026-01');

      final position = container
          .read(companyPositionControlsProvider.notifier)
          .submitDraft(container.read(companyPositionControlDraftProvider));

      expect(position.positionTitle, 'Labs HR Generalist');
      expect(position.availableSeats, 1);
      expect(
        position.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyPositionControlsProvider), hasLength(6));

      final bandDraft = container.read(
        companyCompensationBandDraftProvider.notifier,
      );
      bandDraft.setBandCode('LAB-4');
      bandDraft.setEntityName(entity.name);
      bandDraft.setFamily(CompanyCompensationBandFamily.people);
      bandDraft.setLevelName('Labs Partner');
      bandDraft.setStatus(CompanyCompensationBandStatus.active);
      bandDraft.setMinSalary('180000000');
      bandDraft.setMidpointSalary('220000000');
      bandDraft.setMaxSalary('260000000');
      bandDraft.setCurrency('IDR');
      bandDraft.setOwnerName('Maya Pratiwi');
      bandDraft.setApproverName('Head of People');
      bandDraft.setEffectiveDate('2026-07-01');
      bandDraft.setNextReviewDate('2026-10-01');
      bandDraft.setLinkedPolicy('Labs compensation policy');

      final band = container
          .read(companyCompensationBandsProvider.notifier)
          .submitDraft(container.read(companyCompensationBandDraftProvider));

      expect(band.bandCode, 'LAB-4');
      expect(band.hasValidRange, isTrue);
      expect(
        band.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyCompensationBandsProvider), hasLength(6));

      final jobDraft = container.read(companyJobProfileDraftProvider.notifier);
      jobDraft.setJobCode('lab-jp-04');
      jobDraft.setJobTitle('Labs People Partner');
      jobDraft.setEntityName(entity.name);
      jobDraft.setOrgUnitName('People Operations');
      jobDraft.setFamily(CompanyJobFamily.people);
      jobDraft.setLevelName('Labs Partner');
      jobDraft.setStatus(CompanyJobProfileStatus.active);
      jobDraft.setCompensationBand('LAB-4');
      jobDraft.setOwnerName('Maya Pratiwi');
      jobDraft.setNextReviewDate('2026-10-15');
      jobDraft.setJobDescription(
        'Partners with Labs managers on people operations and onboarding.',
      );
      jobDraft.setSkillsSummary(
        'Employee relations, onboarding, workforce planning',
      );
      jobDraft.setLinkedPolicy('Labs job architecture');

      final jobProfile = container
          .read(companyJobProfilesProvider.notifier)
          .submitDraft(container.read(companyJobProfileDraftProvider));

      expect(jobProfile.jobCode, 'LAB-JP-04');
      expect(jobProfile.compensationBand, 'LAB-4');
      expect(
        jobProfile.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyJobProfilesProvider), hasLength(6));

      final contractDraft = container.read(
        companyContractTemplateDraftProvider.notifier,
      );
      contractDraft.setTemplateName('Labs permanent agreement');
      contractDraft.setEntityName(entity.name);
      contractDraft.setType(CompanyContractTemplateType.permanentEmployment);
      contractDraft.setStatus(CompanyContractTemplateStatus.active);
      contractDraft.setJobProfileCode('LAB-JP-04');
      contractDraft.setCompensationBand('LAB-4');
      contractDraft.setOwnerName('Maya Pratiwi');
      contractDraft.setLegalReviewerName('Sari Wibowo');
      contractDraft.setSignatoryRole('Head of People');
      contractDraft.setLanguage('Bahasa Indonesia');
      contractDraft.setVersionLabel('2026.1');
      contractDraft.setNextReviewDate('2026-10-30');
      contractDraft.setClauseSummary(
        'Permanent employment, probation, confidentiality, payroll, and benefits clauses approved.',
      );
      contractDraft.setOnboardingChecklist(
        'Identity, tax ID, BPJS, bank account, manager intro',
      );

      final contract = container
          .read(companyContractTemplatesProvider.notifier)
          .submitDraft(container.read(companyContractTemplateDraftProvider));

      expect(contract.templateName, 'Labs permanent agreement');
      expect(contract.jobProfileCode, 'LAB-JP-04');
      expect(contract.compensationBand, 'LAB-4');
      expect(
        contract.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyContractTemplatesProvider), hasLength(6));

      final onboardingDraft = container.read(
        companyOnboardingPackDraftProvider.notifier,
      );
      onboardingDraft.setPackName('Labs onboarding pack');
      onboardingDraft.setEntityName(entity.name);
      onboardingDraft.setType(CompanyOnboardingPackType.onboarding);
      onboardingDraft.setStatus(CompanyOnboardingPackStatus.active);
      onboardingDraft.setJobProfileCode('LAB-JP-04');
      onboardingDraft.setContractTemplateName('Labs permanent agreement');
      onboardingDraft.setOwnerName('Maya Pratiwi');
      onboardingDraft.setManagerHandoff('Manager kickoff and probation plan');
      onboardingDraft.setDocumentChecklist(
        'Identity, tax ID, BPJS, signed contract',
      );
      onboardingDraft.setAccessChecklist(
        'HRIS, email, payroll, document vault',
      );
      onboardingDraft.setEquipmentChecklist('Laptop, headset, badge');
      onboardingDraft.setRequiredTaskCount('12');
      onboardingDraft.setAutomationCoverage('75');
      onboardingDraft.setSlaDays('7');
      onboardingDraft.setNextReviewDate('2026-10-30');
      onboardingDraft.setNotes('Ready for Labs launch hiring');

      final onboardingPack = container
          .read(companyOnboardingPacksProvider.notifier)
          .submitDraft(container.read(companyOnboardingPackDraftProvider));

      expect(onboardingPack.packName, 'Labs onboarding pack');
      expect(onboardingPack.jobProfileCode, 'LAB-JP-04');
      expect(onboardingPack.requiredTaskCount, 12);
      expect(
        onboardingPack.requiresAttention(
          container.read(companyAsOfDateProvider),
        ),
        isFalse,
      );
      expect(container.read(companyOnboardingPacksProvider), hasLength(6));

      final probationDraft = container.read(
        companyProbationPlanDraftProvider.notifier,
      );
      probationDraft.setPlanName('Labs probation plan');
      probationDraft.setEntityName(entity.name);
      probationDraft.setType(CompanyProbationPlanType.probation);
      probationDraft.setStatus(CompanyProbationPlanStatus.active);
      probationDraft.setJobProfileCode('LAB-JP-04');
      probationDraft.setOnboardingPackName('Labs onboarding pack');
      probationDraft.setOwnerName('Maya Pratiwi');
      probationDraft.setManagerRole('Labs Manager');
      probationDraft.setReviewCadenceDays('30');
      probationDraft.setCheckpointCount('3');
      probationDraft.setFirstReviewDueDays('30');
      probationDraft.setFinalDecisionDueDays('90');
      probationDraft.setNextReviewDate('2026-10-30');
      probationDraft.setSuccessCriteria(
        'Role delivery, conduct, manager feedback',
      );
      probationDraft.setFeedbackTemplate(
        'Manager scorecard and checkpoint notes',
      );
      probationDraft.setNotes('Ready for Labs hiring');

      final probationPlan = container
          .read(companyProbationPlansProvider.notifier)
          .submitDraft(container.read(companyProbationPlanDraftProvider));

      expect(probationPlan.planName, 'Labs probation plan');
      expect(probationPlan.jobProfileCode, 'LAB-JP-04');
      expect(probationPlan.reviewCadenceDays, 30);
      expect(
        probationPlan.requiresAttention(
          container.read(companyAsOfDateProvider),
        ),
        isFalse,
      );
      expect(container.read(companyProbationPlansProvider), hasLength(6));

      final offboardingDraft = container.read(
        companyOffboardingPackDraftProvider.notifier,
      );
      offboardingDraft.setPackName('Labs offboarding pack');
      offboardingDraft.setEntityName(entity.name);
      offboardingDraft.setType(CompanyOffboardingPackType.resignation);
      offboardingDraft.setStatus(CompanyOffboardingPackStatus.active);
      offboardingDraft.setJobProfileCode('LAB-JP-04');
      offboardingDraft.setOwnerName('Maya Pratiwi');
      offboardingDraft.setManagerRole('Labs Manager');
      offboardingDraft.setKnowledgeTransferPlan(
        'Project handover and manager notes',
      );
      offboardingDraft.setAssetReturnChecklist('Laptop, badge, headset');
      offboardingDraft.setAccessRevocationChecklist(
        'HRIS, email, repository, payroll',
      );
      offboardingDraft.setFinalPayrollChecklist(
        'Final salary, leave payout, expenses',
      );
      offboardingDraft.setDocumentChecklist('Clearance form and certificate');
      offboardingDraft.setExitInterviewTemplate('Exit interview scorecard');
      offboardingDraft.setRequiredTaskCount('14');
      offboardingDraft.setSlaDays('7');
      offboardingDraft.setNextReviewDate('2026-10-30');
      offboardingDraft.setNotes('Ready for Labs exits');

      final offboardingPack = container
          .read(companyOffboardingPacksProvider.notifier)
          .submitDraft(container.read(companyOffboardingPackDraftProvider));

      expect(offboardingPack.packName, 'Labs offboarding pack');
      expect(offboardingPack.jobProfileCode, 'LAB-JP-04');
      expect(offboardingPack.requiredTaskCount, 14);
      expect(
        offboardingPack.requiresAttention(
          container.read(companyAsOfDateProvider),
        ),
        isFalse,
      );
      expect(container.read(companyOffboardingPacksProvider), hasLength(6));

      final documentRequirementDraft = container.read(
        companyDocumentRequirementDraftProvider.notifier,
      );
      documentRequirementDraft.setRequirementName('Labs document matrix');
      documentRequirementDraft.setEntityName(entity.name);
      documentRequirementDraft.setStage(
        CompanyDocumentRequirementStage.preboarding,
      );
      documentRequirementDraft.setStatus(
        CompanyDocumentRequirementStatus.active,
      );
      documentRequirementDraft.setJobProfileCode('LAB-JP-04');
      documentRequirementDraft.setContractTemplateName(
        'Labs permanent agreement',
      );
      documentRequirementDraft.setOnboardingPackName('Labs onboarding pack');
      documentRequirementDraft.setOwnerName('Maya Pratiwi');
      documentRequirementDraft.setEvidenceOwnerName('People Operations');
      documentRequirementDraft.setPolicyReference('Labs document policy');
      documentRequirementDraft.setCollectionChannel('HRIS document vault');
      documentRequirementDraft.setStorageLocation('Document vault / Labs');
      documentRequirementDraft.setRetentionRule('Employment period + 5 years');
      documentRequirementDraft.setRequiredDocumentCount('10');
      documentRequirementDraft.setNextReviewDate('2026-10-30');
      documentRequirementDraft.setNotes(
        'Ready for Labs employee evidence collection',
      );

      final documentRequirement = container
          .read(companyDocumentRequirementsProvider.notifier)
          .submitDraft(container.read(companyDocumentRequirementDraftProvider));

      expect(documentRequirement.requirementName, 'Labs document matrix');
      expect(documentRequirement.jobProfileCode, 'LAB-JP-04');
      expect(documentRequirement.requiredDocumentCount, 10);
      expect(
        documentRequirement.requiresAttention(
          container.read(companyAsOfDateProvider),
        ),
        isFalse,
      );
      expect(container.read(companyDocumentRequirementsProvider), hasLength(6));

      final approvalDraft = container.read(
        companyApprovalRuleDraftProvider.notifier,
      );
      approvalDraft.setDomain(CompanyApprovalDomain.policy);
      approvalDraft.setEntityName(entity.name);
      approvalDraft.setScopeName('Product & Commerce');
      approvalDraft.setApproverRole('Head of Product');
      approvalDraft.setBackupApproverRole('Head of People');
      approvalDraft.setThresholdLabel('All policy changes');
      approvalDraft.setSlaHours('24');
      approvalDraft.setStatus(CompanyApprovalRuleStatus.active);

      final rule = container
          .read(companyApprovalRulesProvider.notifier)
          .submitDraft(container.read(companyApprovalRuleDraftProvider));

      expect(rule.domain, CompanyApprovalDomain.policy);
      expect(rule.requiresAttention, isFalse);
      expect(container.read(companyApprovalRulesProvider), hasLength(5));

      final documentDraft = container.read(
        companyDocumentDraftProvider.notifier,
      );
      documentDraft.setTitle('Labs tax registration');
      documentDraft.setDocumentNumber('NPWP-LABS-001');
      documentDraft.setEntityName(entity.name);
      documentDraft.setOwnerName('Maya Pratiwi');
      documentDraft.setType(CompanyDocumentType.tax);
      documentDraft.setIssuedDate('2026-02-01');
      documentDraft.setExpiryDate('2029-02-01');
      documentDraft.setLinkedModule('Payroll');
      documentDraft.setStatus(CompanyDocumentStatus.verified);

      final document = container
          .read(companyDocumentsProvider.notifier)
          .submitDraft(container.read(companyDocumentDraftProvider));

      expect(document.title, 'Labs tax registration');
      expect(
        document.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyDocumentsProvider), hasLength(6));

      final renewalDraft = container.read(
        companyDocumentRenewalDraftProvider.notifier,
      );
      renewalDraft.selectDocument(document);
      renewalDraft.setOwnerName('Maya Pratiwi');
      renewalDraft.setDueDate('2028-02-01');
      renewalDraft.setReminderLeadDays('90');
      renewalDraft.setActionLabel('Prepare tax renewal packet');

      final renewal = container
          .read(companyDocumentRenewalsProvider.notifier)
          .submitDraft(container.read(companyDocumentRenewalDraftProvider));

      expect(renewal.documentTitle, 'Labs tax registration');
      expect(
        renewal.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyDocumentRenewalsProvider), hasLength(5));

      final operatingDraft = container.read(
        companyOperatingReadinessDraftProvider.notifier,
      );
      operatingDraft.setArea(CompanyOperatingReadinessArea.leave);
      operatingDraft.setEntityName(entity.name);
      operatingDraft.setOwnerName('Maya Pratiwi');
      operatingDraft.setStatus(CompanyOperatingReadinessStatus.ready);
      operatingDraft.setCoveragePercent('95');
      operatingDraft.setLastReviewDate('2026-05-28');
      operatingDraft.setNextReviewDate('2026-07-01');
      operatingDraft.setLinkedModule('Leave');

      final operating = container
          .read(companyOperatingReadinessProvider.notifier)
          .submitDraft(container.read(companyOperatingReadinessDraftProvider));

      expect(operating.area, CompanyOperatingReadinessArea.leave);
      expect(
        operating.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyOperatingReadinessProvider), hasLength(7));

      final contactDraft = container.read(
        companyGovernanceContactDraftProvider.notifier,
      );
      contactDraft.setEntityName(entity.name);
      contactDraft.setRole(CompanyGovernanceRole.peopleOwner);
      contactDraft.setPersonName('Maya Pratiwi');
      contactDraft.setTitle('People Partner');
      contactDraft.setEmail('maya@kaysir.id');
      contactDraft.setPhone('+62 812 4400 5500');
      contactDraft.setBackupName('Nadia Safitri');
      contactDraft.setEscalationChannel('People Operations');
      contactDraft.setLastReviewedAt('2026-05-28');
      contactDraft.setNextReviewAt('2026-08-28');

      final contact = container
          .read(companyGovernanceContactsProvider.notifier)
          .submitDraft(container.read(companyGovernanceContactDraftProvider));

      expect(contact.personName, 'Maya Pratiwi');
      expect(
        contact.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyGovernanceContactsProvider), hasLength(7));

      final lifecycleDraft = container.read(
        companyEntityLifecycleDraftProvider.notifier,
      );
      lifecycleDraft.setTitle('Labs payroll launch');
      lifecycleDraft.setEntityName(entity.name);
      lifecycleDraft.setType(CompanyEntityLifecycleType.payrollActivation);
      lifecycleDraft.setStatus(CompanyEntityLifecycleStatus.inProgress);
      lifecycleDraft.setOwnerName('Maya Pratiwi');
      lifecycleDraft.setTargetDate('2026-08-15');
      lifecycleDraft.setProgressPercent('65');
      lifecycleDraft.setDependencySummary(
        'Payroll route and legal entity verification',
      );
      lifecycleDraft.setNextMilestone('Run payroll sandbox');

      final lifecycle = container
          .read(companyEntityLifecyclesProvider.notifier)
          .submitDraft(container.read(companyEntityLifecycleDraftProvider));

      expect(lifecycle.title, 'Labs payroll launch');
      expect(
        lifecycle.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyEntityLifecyclesProvider), hasLength(6));

      final controlDraft = container.read(companyControlDraftProvider.notifier);
      controlDraft.setTitle('Labs payroll access control');
      controlDraft.setEntityName(entity.name);
      controlDraft.setDomain(CompanyControlDomain.payroll);
      controlDraft.setStatus(CompanyControlStatus.monitoring);
      controlDraft.setSeverity(CompanyControlSeverity.medium);
      controlDraft.setOwnerName('Maya Pratiwi');
      controlDraft.setNextReviewDate('2026-08-20');
      controlDraft.setEvidenceSummary('Payroll access approval captured');
      controlDraft.setRemediationAction('Review access after first payroll');
      controlDraft.setLinkedRecord('Labs payroll launch');

      final control = container
          .read(companyControlsProvider.notifier)
          .submitDraft(container.read(companyControlDraftProvider));

      expect(control.title, 'Labs payroll access control');
      expect(
        control.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyControlsProvider), hasLength(6));

      final accountDraft = container.read(
        companyEmployerAccountDraftProvider.notifier,
      );
      accountDraft.setAccountName('Labs DJP payroll account');
      accountDraft.setEntityName(entity.name);
      accountDraft.setType(CompanyEmployerAccountType.payrollTax);
      accountDraft.setStatus(CompanyEmployerAccountStatus.verified);
      accountDraft.setAccountNumber('NPWP-LABS-001');
      accountDraft.setOwnerName('Maya Pratiwi');
      accountDraft.setCredentialOwnerName('Bagas Pranata');
      accountDraft.setNextReviewDate('2026-09-01');
      accountDraft.setEvidenceSummary('Portal access evidence captured');
      accountDraft.setNextAction('Run quarterly access review');
      accountDraft.setLinkedFiling('Labs payroll tax filing');

      final account = container
          .read(companyEmployerAccountsProvider.notifier)
          .submitDraft(container.read(companyEmployerAccountDraftProvider));

      expect(account.accountName, 'Labs DJP payroll account');
      expect(
        account.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyEmployerAccountsProvider), hasLength(6));

      final vendorDraft = container.read(
        companyVendorAgreementDraftProvider.notifier,
      );
      vendorDraft.setVendorName('Tanda Labs');
      vendorDraft.setServiceName('Employment e-signature');
      vendorDraft.setEntityName(entity.name);
      vendorDraft.setCategory(CompanyVendorAgreementCategory.eSignature);
      vendorDraft.setStatus(CompanyVendorAgreementStatus.active);
      vendorDraft.setOwnerName('Maya Pratiwi');
      vendorDraft.setAccountManagerName('Bagas Pranata');
      vendorDraft.setContractEndDate('2026-09-30');
      vendorDraft.setSlaSummary('Envelope availability 99.5%');
      vendorDraft.setDataProtectionSummary('DPA signed and archived');
      vendorDraft.setNextAction('Review envelope usage quarterly');
      vendorDraft.setLinkedModule('Company signatory');

      final agreement = container
          .read(companyVendorAgreementsProvider.notifier)
          .submitDraft(container.read(companyVendorAgreementDraftProvider));

      expect(agreement.vendorName, 'Tanda Labs');
      expect(
        agreement.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyVendorAgreementsProvider), hasLength(6));

      final filingDraft = container.read(companyFilingDraftProvider.notifier);
      filingDraft.setTitle('Labs payroll tax filing');
      filingDraft.setEntityName(entity.name);
      filingDraft.setType(CompanyFilingType.tax);
      filingDraft.setCadence(CompanyFilingCadence.monthly);
      filingDraft.setStatus(CompanyFilingStatus.scheduled);
      filingDraft.setOwnerName('Maya Pratiwi');
      filingDraft.setAuthorityName('DJP Online');
      filingDraft.setDueDate('2026-08-10');
      filingDraft.setEvidenceSummary('Payroll calendar prepared');
      filingDraft.setNextStep('Submit first Labs payroll tax filing');
      filingDraft.setLinkedRecord('Labs payroll launch');

      final filing = container
          .read(companyFilingsProvider.notifier)
          .submitDraft(container.read(companyFilingDraftProvider));

      expect(filing.title, 'Labs payroll tax filing');
      expect(
        filing.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyFilingsProvider), hasLength(6));

      final signatoryDraft = container.read(
        companySignatoryDraftProvider.notifier,
      );
      signatoryDraft.setPersonName('Maya Pratiwi');
      signatoryDraft.setTitle('People Partner');
      signatoryDraft.setEntityName(entity.name);
      signatoryDraft.setScope(CompanySignatoryScope.employmentContract);
      signatoryDraft.setAuthorityLevel(CompanySignatoryAuthorityLevel.signer);
      signatoryDraft.setStatus(CompanySignatoryStatus.active);
      signatoryDraft.setEffectiveDate('2026-07-01');
      signatoryDraft.setExpiryDate('2027-07-01');
      signatoryDraft.setBackupSignerName('Nadia Safitri');
      signatoryDraft.setEvidenceSummary('Labs delegation letter captured');
      signatoryDraft.setDelegationNotes('Employment contract signer for Labs');

      final signatory = container
          .read(companySignatoriesProvider.notifier)
          .submitDraft(container.read(companySignatoryDraftProvider));

      expect(signatory.personName, 'Maya Pratiwi');
      expect(
        signatory.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companySignatoriesProvider), hasLength(6));

      final changeDraft = container.read(
        companyChangeRequestDraftProvider.notifier,
      );
      changeDraft.setTitle('Labs launch governance');
      changeDraft.setEntityName(entity.name);
      changeDraft.setOwnerName('Maya Pratiwi');
      changeDraft.setType(CompanyChangeRequestType.legalEntity);
      changeDraft.setPriority(CompanyChangeRequestPriority.low);
      changeDraft.setStatus(CompanyChangeRequestStatus.scheduled);
      changeDraft.setEffectiveDate('2026-07-15');
      changeDraft.setImpactSummary('Enable HR policy and payroll handover.');
      changeDraft.setApproverRole('Head of People');
      changeDraft.setLinkedRecord(entity.name);

      final change = container
          .read(companyChangeRequestsProvider.notifier)
          .submitDraft(container.read(companyChangeRequestDraftProvider));

      expect(change.title, 'Labs launch governance');
      expect(
        change.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(container.read(companyChangeRequestsProvider), hasLength(6));

      final orgDraft = container.read(companyOrgUnitDraftProvider.notifier);
      orgDraft.setName('Legal Affairs');
      orgDraft.setCode('legal');
      orgDraft.setManagerName('Sari Wibowo');
      orgDraft.setLocation('Jakarta Central HQ');
      orgDraft.setPlannedHeadcount('4');
      orgDraft.setActiveHeadcount('2');

      final unit = container
          .read(companyOrgUnitsProvider.notifier)
          .submitDraft(container.read(companyOrgUnitDraftProvider));

      expect(unit.name, 'Legal Affairs');
      expect(unit.code, 'LEGAL');
      expect(container.read(companyOrgUnitsProvider), hasLength(7));
    },
  );

  test('renewal actions reduce task risk and record audit events', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final started = container
        .read(companyDocumentRenewalsProvider.notifier)
        .markInProgress('renewal-bpjs');
    container
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: started!.documentId,
          documentTitle: started.documentTitle,
          entityName: started.entityName,
          actorName: started.ownerName,
          type: CompanyDocumentAuditEventType.renewalStarted,
          happenedAt: container.read(companyAsOfDateProvider),
          note: started.actionLabel,
        );

    final completed = container
        .read(companyDocumentRenewalsProvider.notifier)
        .markCompleted('renewal-retail-permit');
    container
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: completed!.documentId,
          documentTitle: completed.documentTitle,
          entityName: completed.entityName,
          actorName: completed.ownerName,
          type: CompanyDocumentAuditEventType.renewed,
          happenedAt: container.read(companyAsOfDateProvider),
          note: 'Renewal completed.',
        );

    final summary = container.read(companyManagementSummaryProvider);
    final events = container.read(companyDocumentAuditEventsProvider);

    expect(started.status, CompanyDocumentRenewalStatus.inProgress);
    expect(completed.status, CompanyDocumentRenewalStatus.completed);
    expect(summary.documentRenewalRiskCount, 2);
    expect(events, hasLength(7));
    expect(events.first.type, CompanyDocumentAuditEventType.renewed);
  });

  test('operating readiness action reduces service risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyOperatingReadinessProvider.notifier)
        .markReady('ops-payroll-fulfillment');

    final payroll = container
        .read(companyOperatingReadinessProvider)
        .singleWhere((item) => item.id == 'ops-payroll-fulfillment');
    final summary = container.read(companyManagementSummaryProvider);

    expect(payroll.status, CompanyOperatingReadinessStatus.ready);
    expect(payroll.coveragePercent, 100);
    expect(payroll.blocker, isEmpty);
    expect(
      payroll.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.operatingRiskCount, 2);
  });

  test('change request implementation reduces effective-dated risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyChangeRequestsProvider.notifier)
        .markImplemented('change-retail-outlet');

    final request = container
        .read(companyChangeRequestsProvider)
        .singleWhere((item) => item.id == 'change-retail-outlet');
    final summary = container.read(companyManagementSummaryProvider);

    expect(request.status, CompanyChangeRequestStatus.implemented);
    expect(
      request.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.changeRequestRiskCount, 2);
  });

  test('governance contact actions reduce owner coverage risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyGovernanceContactsProvider.notifier)
        .assignBackup('contact-fulfillment-payroll', 'Nadia Safitri');
    container
        .read(companyGovernanceContactsProvider.notifier)
        .markReviewed(
          'contact-retail-branch-owner',
          container.read(companyAsOfDateProvider),
        );

    final payroll = container
        .read(companyGovernanceContactsProvider)
        .singleWhere((contact) => contact.id == 'contact-fulfillment-payroll');
    final retail = container
        .read(companyGovernanceContactsProvider)
        .singleWhere((contact) => contact.id == 'contact-retail-branch-owner');
    final summary = container.read(companyManagementSummaryProvider);

    expect(payroll.backupName, 'Nadia Safitri');
    expect(payroll.status, CompanyGovernanceContactStatus.active);
    expect(retail.status, CompanyGovernanceContactStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.governanceContactRiskCount, 1);
  });

  test('entity lifecycle actions reduce launch governance risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyEntityLifecyclesProvider.notifier)
        .markLaunched('lifecycle-fulfillment-payroll');

    final payroll = container
        .read(companyEntityLifecyclesProvider)
        .singleWhere(
          (milestone) => milestone.id == 'lifecycle-fulfillment-payroll',
        );
    final summary = container.read(companyManagementSummaryProvider);

    expect(payroll.status, CompanyEntityLifecycleStatus.launched);
    expect(payroll.progressPercent, 100);
    expect(payroll.blocker, isEmpty);
    expect(
      payroll.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.entityLifecycleRiskCount, 2);
  });

  test('company control actions reduce control risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyControlsProvider.notifier)
        .markRemediated('control-privacy-access');

    final privacy = container
        .read(companyControlsProvider)
        .singleWhere((control) => control.id == 'control-privacy-access');
    final summary = container.read(companyManagementSummaryProvider);

    expect(privacy.status, CompanyControlStatus.healthy);
    expect(privacy.severity, CompanyControlSeverity.high);
    expect(privacy.remediationAction, isEmpty);
    expect(
      privacy.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.controlRiskCount, 2);
  });

  test('company position control actions reduce workforce risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialPlan = container.read(companyWorkforcePlanProvider);
    expect(initialPlan.openSeatCount, 4);
    expect(initialPlan.overfilledSeatCount, 1);
    expect(initialPlan.pendingApprovalCount, 1);
    expect(initialPlan.priorityItems.first.title, 'Retail Supervisor');
    expect(
      initialPlan.priorityItems.first.action,
      CompanyWorkforcePlanAction.approvePosition,
    );

    container
        .read(companyPositionControlsProvider.notifier)
        .closeRecruiting('position-product-engineer');
    container
        .read(companyPositionControlsProvider.notifier)
        .approvePosition('position-retail-supervisor');

    final product = container
        .read(companyPositionControlsProvider)
        .singleWhere((position) => position.id == 'position-product-engineer');
    final retail = container
        .read(companyPositionControlsProvider)
        .singleWhere((position) => position.id == 'position-retail-supervisor');
    final updatedPlan = container.read(companyWorkforcePlanProvider);
    final summary = container.read(companyManagementSummaryProvider);

    expect(product.status, CompanyPositionControlStatus.approved);
    expect(product.filledSeats, product.authorizedSeats);
    expect(
      product.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyPositionControlStatus.approved);
    expect(retail.authorizedSeats, 5);
    expect(retail.compensationBand, 'Band reviewed');
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(updatedPlan.overfilledSeatCount, 0);
    expect(updatedPlan.pendingApprovalCount, 0);
    expect(updatedPlan.recruitingCount, 0);
    expect(summary.positionControlRiskCount, 1);
  });

  test('company headcount requisitions move through hiring approval', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialRequests = container.read(
      filteredCompanyHeadcountRequisitionsProvider,
    );
    expect(initialRequests, hasLength(3));
    expect(
      initialRequests.first.issues(container.read(companyAsOfDateProvider)),
      contains(CompanyHeadcountRequisitionIssue.awaitingApproval),
    );
    expect(
      container
          .read(companyHeadcountRequisitionActivityTimelineProvider)
          .records,
      hasLength(5),
    );

    final draftNotifier = container.read(
      companyHeadcountRequisitionDraftProvider.notifier,
    );
    draftNotifier
      ..setRoleTitle('Product Designer')
      ..setOrgUnitName('Product & Commerce')
      ..setHiringManagerName('Fajar Prakoso')
      ..setPositionControlId('position-product-engineer')
      ..setJobProfileCode('ENG-JP-04')
      ..setCostCenterCode('CC-PROD')
      ..setPriority(CompanyHeadcountRequisitionPriority.high)
      ..setRequestedSeats('1')
      ..setTargetStartDate('2026-07-15')
      ..setBusinessCase('Add design capacity for checkout experiments')
      ..setBudgetImpact('Uses product hiring plan')
      ..setApproverRole('Head of Product');

    final requisition = container
        .read(companyHeadcountRequisitionsProvider.notifier)
        .submitDraft(container.read(companyHeadcountRequisitionDraftProvider));
    container
        .read(companyHeadcountRequisitionActivityRecordsProvider.notifier)
        .record(
          requisition: requisition,
          type: CompanyHeadcountRequisitionActivityType.submitted,
          happenedAt: container.read(companyAsOfDateProvider),
        );
    expect(requisition.id, 'hreq-004');
    expect(
      requisition.status,
      CompanyHeadcountRequisitionStatus.awaitingApproval,
    );

    container
        .read(companyHeadcountRequisitionsProvider.notifier)
        .approve(requisition.id);
    container
        .read(companyHeadcountRequisitionsProvider.notifier)
        .openRecruiting(requisition.id);
    container
        .read(companyHeadcountRequisitionsProvider.notifier)
        .markFilled(requisition.id);
    container
        .read(companyHeadcountRequisitionActivityRecordsProvider.notifier)
        .record(
          requisition: container
              .read(companyHeadcountRequisitionsProvider)
              .singleWhere((request) => request.id == requisition.id),
          type: CompanyHeadcountRequisitionActivityType.filled,
          happenedAt: container.read(companyAsOfDateProvider),
          note: 'Filled from provider test',
        );

    final filled = container
        .read(companyHeadcountRequisitionsProvider)
        .singleWhere((request) => request.id == requisition.id);
    final timeline = container.read(
      companyHeadcountRequisitionActivityTimelineProvider,
    );
    expect(filled.status, CompanyHeadcountRequisitionStatus.filled);
    expect(
      filled.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(timeline.records, hasLength(7));
    expect(timeline.filledCount, 1);
    expect(timeline.recentRecords.first.note, 'Filled from provider test');
  });

  test('company compensation band actions reduce pay architecture risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyCompensationBandsProvider.notifier)
        .activateBand('band-gov-6');
    container
        .read(companyCompensationBandsProvider.notifier)
        .markReviewed('band-ops-4');

    final governance = container
        .read(companyCompensationBandsProvider)
        .singleWhere((band) => band.id == 'band-gov-6');
    final retail = container
        .read(companyCompensationBandsProvider)
        .singleWhere((band) => band.id == 'band-ops-4');
    final summary = container.read(companyManagementSummaryProvider);

    expect(governance.status, CompanyCompensationBandStatus.active);
    expect(governance.approverName, 'Head of People');
    expect(
      governance.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyCompensationBandStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.compensationBandRiskCount, 1);
  });

  test('company job profile actions reduce job architecture risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyJobProfilesProvider.notifier)
        .activateProfile('job-compliance-lead');
    container
        .read(companyJobProfilesProvider.notifier)
        .markReviewed('job-retail-supervisor');

    final compliance = container
        .read(companyJobProfilesProvider)
        .singleWhere((profile) => profile.id == 'job-compliance-lead');
    final retail = container
        .read(companyJobProfilesProvider)
        .singleWhere((profile) => profile.id == 'job-retail-supervisor');
    final summary = container.read(companyManagementSummaryProvider);

    expect(compliance.status, CompanyJobProfileStatus.active);
    expect(compliance.ownerName, 'People Operations');
    expect(
      compliance.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyJobProfileStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.jobProfileRiskCount, 1);
  });

  test('company contract template actions reduce legal template risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyContractTemplatesProvider.notifier)
        .activateTemplate('contract-compliance-lead');
    container
        .read(companyContractTemplatesProvider.notifier)
        .markReviewed('contract-retail-fixed-term');

    final compliance = container
        .read(companyContractTemplatesProvider)
        .singleWhere((template) => template.id == 'contract-compliance-lead');
    final retail = container
        .read(companyContractTemplatesProvider)
        .singleWhere((template) => template.id == 'contract-retail-fixed-term');
    final summary = container.read(companyManagementSummaryProvider);

    expect(compliance.status, CompanyContractTemplateStatus.active);
    expect(compliance.ownerName, 'People Operations');
    expect(compliance.signatoryRole, 'Authorized company signatory');
    expect(compliance.versionLabel, '2026.reviewed');
    expect(
      compliance.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyContractTemplateStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.contractTemplateRiskCount, 1);
  });

  test('company onboarding pack actions reduce preboarding risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyOnboardingPacksProvider.notifier)
        .activatePack('onboarding-compliance-lead');
    container
        .read(companyOnboardingPacksProvider.notifier)
        .markReviewed('onboarding-retail-supervisor');

    final compliance = container
        .read(companyOnboardingPacksProvider)
        .singleWhere((pack) => pack.id == 'onboarding-compliance-lead');
    final retail = container
        .read(companyOnboardingPacksProvider)
        .singleWhere((pack) => pack.id == 'onboarding-retail-supervisor');
    final summary = container.read(companyManagementSummaryProvider);

    expect(compliance.status, CompanyOnboardingPackStatus.active);
    expect(compliance.ownerName, 'People Operations');
    expect(compliance.requiredTaskCount, 10);
    expect(compliance.slaDays, 7);
    expect(
      compliance.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyOnboardingPackStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.onboardingPackRiskCount, 1);
  });

  test('company probation plan actions reduce milestone risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyProbationPlansProvider.notifier)
        .activatePlan('probation-compliance-lead');
    container
        .read(companyProbationPlansProvider.notifier)
        .markReviewed('probation-retail-supervisor');

    final compliance = container
        .read(companyProbationPlansProvider)
        .singleWhere((plan) => plan.id == 'probation-compliance-lead');
    final retail = container
        .read(companyProbationPlansProvider)
        .singleWhere((plan) => plan.id == 'probation-retail-supervisor');
    final summary = container.read(companyManagementSummaryProvider);

    expect(compliance.status, CompanyProbationPlanStatus.active);
    expect(compliance.ownerName, 'People Operations');
    expect(compliance.reviewCadenceDays, 30);
    expect(compliance.checkpointCount, 3);
    expect(compliance.firstReviewDueDays, 30);
    expect(compliance.finalDecisionDueDays, 90);
    expect(
      compliance.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyProbationPlanStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.probationPlanRiskCount, 1);
  });

  test('company offboarding pack actions reduce exit workflow risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyOffboardingPacksProvider.notifier)
        .activatePack('offboarding-compliance-lead');
    container
        .read(companyOffboardingPacksProvider.notifier)
        .markReviewed('offboarding-retail-supervisor');

    final compliance = container
        .read(companyOffboardingPacksProvider)
        .singleWhere((pack) => pack.id == 'offboarding-compliance-lead');
    final retail = container
        .read(companyOffboardingPacksProvider)
        .singleWhere((pack) => pack.id == 'offboarding-retail-supervisor');
    final summary = container.read(companyManagementSummaryProvider);

    expect(compliance.status, CompanyOffboardingPackStatus.active);
    expect(compliance.ownerName, 'People Operations');
    expect(compliance.requiredTaskCount, 12);
    expect(compliance.slaDays, 7);
    expect(compliance.finalPayrollChecklist, isNotEmpty);
    expect(
      compliance.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyOffboardingPackStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.offboardingPackRiskCount, 1);
  });

  test('company document requirement actions reduce evidence risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyDocumentRequirementsProvider.notifier)
        .activateRequirement('docreq-compliance-lead-executive');
    container
        .read(companyDocumentRequirementsProvider.notifier)
        .markReviewed('docreq-retail-supervisor-offboarding');

    final compliance = container
        .read(companyDocumentRequirementsProvider)
        .singleWhere(
          (requirement) => requirement.id == 'docreq-compliance-lead-executive',
        );
    final retail = container
        .read(companyDocumentRequirementsProvider)
        .singleWhere(
          (requirement) =>
              requirement.id == 'docreq-retail-supervisor-offboarding',
        );
    final summary = container.read(companyManagementSummaryProvider);

    expect(compliance.status, CompanyDocumentRequirementStatus.active);
    expect(compliance.ownerName, 'People Operations');
    expect(compliance.policyReference, 'Employee document policy');
    expect(compliance.requiredDocumentCount, 6);
    expect(
      compliance.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(retail.status, CompanyDocumentRequirementStatus.active);
    expect(
      retail.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.documentRequirementRiskCount, 1);
  });

  test('company employee document gap actions reduce collection risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final request = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .generateRequest('empdoc-michael-probation');
    final initialOlivia = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-olivia-preboarding');
    final verification = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .markVerified('empdoc-olivia-preboarding');
    final verifiedRecords = verification.evidenceRecords;
    container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .waiveGap('empdoc-emma-offboarding');

    final michael = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-michael-probation');
    final olivia = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-olivia-preboarding');
    final emma = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-emma-offboarding');
    final oliviaRecords = container.read(
      employeeComplianceRecordsProvider('5'),
    );
    final michaelProfile =
        container.read(employeeDocumentRequestProfileProvider('2'))!;
    final auditEvents = container.read(companyDocumentAuditEventsProvider);
    final summary = container.read(companyManagementSummaryProvider);

    expect(request, isNotNull);
    expect(request!.id, 'EDR-2-002');
    expect(request.employeeId, '2');
    expect(request.employeeName, 'Michael Chen');
    expect(request.type, EmployeeDocumentRequestType.custom);
    expect(request.owner, 'Fajar Prakoso');
    expect(request.requestedBy, 'Fajar Prakoso');
    expect(request.dueDate, DateTime(2026, 6, 20));
    expect(request.correlationId, 'empdoc-michael-probation');
    expect(
      request.purpose,
      'Collect 4 missing documents for probation evidence under PT Kaysir Nusantara.',
    );
    expect(
      michaelProfile.requests.map((profileRequest) => profileRequest.id),
      contains('EDR-2-002'),
    );
    expect(michael.status, CompanyEmployeeDocumentGapStatus.requested);
    expect(michael.openRequestCount, 1);
    expect(verification.closedRequestCount, 0);
    expect(verifiedRecords, hasLength(initialOlivia.missingDocumentCount));
    expect(verifiedRecords.first.id, 'ECD-5-005');
    expect(
      verifiedRecords.every(
        (record) =>
            record.status == EmployeeComplianceDocumentStatus.verified &&
            record.employeeId == '5' &&
            record.type == EmployeeComplianceDocumentType.identity &&
            record.correlationId == 'empdoc-olivia-preboarding',
      ),
      isTrue,
    );
    expect(
      oliviaRecords.where((record) => record.isVerified).length,
      olivia.requiredDocumentCount,
    );
    expect(olivia.status, CompanyEmployeeDocumentGapStatus.complete);
    expect(olivia.verifiedDocumentCount, olivia.requiredDocumentCount);
    expect(emma.status, CompanyEmployeeDocumentGapStatus.waived);
    expect(auditEvents, hasLength(8));
    expect(auditEvents.take(3).map((event) => event.type), [
      CompanyDocumentAuditEventType.employeeGapWaived,
      CompanyDocumentAuditEventType.employeeEvidenceVerified,
      CompanyDocumentAuditEventType.employeeRequestGenerated,
    ]);
    expect(auditEvents.first.documentId, 'empdoc-emma-offboarding');
    expect(auditEvents.first.correlationId, 'empdoc-emma-offboarding');
    expect(summary.employeeDocumentGapRiskCount, 3);
  });

  test('company gap verification closes generated document requests', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final request =
        container
            .read(companyEmployeeDocumentGapsProvider.notifier)
            .generateRequest('empdoc-michael-probation')!;
    final initialMichael = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-michael-probation');

    expect(request.status, EmployeeDocumentRequestStatus.requested);
    expect(request.correlationId, 'empdoc-michael-probation');
    expect(initialMichael.openRequestCount, 1);

    final verification = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .markVerified('empdoc-michael-probation');
    final michael = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-michael-probation');
    final profile =
        container.read(employeeDocumentRequestProfileProvider('2'))!;
    final closedRequest = profile.requests.singleWhere(
      (profileRequest) => profileRequest.id == request.id,
    );
    final auditEvents = container.read(companyDocumentAuditEventsProvider);
    final summary = container.read(companyManagementSummaryProvider);

    expect(
      verification.evidenceRecords,
      hasLength(initialMichael.missingDocumentCount),
    );
    expect(verification.closedRequestCount, 1);
    expect(
      verification.evidenceRecords.every(
        (record) => record.correlationId == 'empdoc-michael-probation',
      ),
      isTrue,
    );
    expect(closedRequest.status, EmployeeDocumentRequestStatus.issued);
    expect(closedRequest.correlationId, 'empdoc-michael-probation');
    expect(closedRequest.isClosed, isTrue);
    expect(profile.requestedCount, 0);
    expect(michael.status, CompanyEmployeeDocumentGapStatus.complete);
    expect(michael.openRequestCount, 0);
    expect(auditEvents, hasLength(8));
    expect(auditEvents.take(3).map((event) => event.type), [
      CompanyDocumentAuditEventType.employeeRequestClosed,
      CompanyDocumentAuditEventType.employeeEvidenceVerified,
      CompanyDocumentAuditEventType.employeeRequestGenerated,
    ]);
    expect(auditEvents.first.documentId, 'empdoc-michael-probation');
    expect(auditEvents.first.correlationId, 'empdoc-michael-probation');
    expect(
      auditEvents.first.note,
      'Closed 1 generated employee document request after evidence verification.',
    );
    expect(summary.employeeDocumentGapRiskCount, 4);
  });

  test('company audit detail links selected employee document context', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final request =
        container
            .read(companyEmployeeDocumentGapsProvider.notifier)
            .generateRequest('empdoc-michael-probation')!;
    final initialMichael = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-michael-probation');

    container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .markVerified('empdoc-michael-probation');

    final requestClosedEvent = container
        .read(companyDocumentAuditEventsProvider)
        .firstWhere(
          (event) =>
              event.type == CompanyDocumentAuditEventType.employeeRequestClosed,
        );

    container.read(companySelectedDocumentAuditEventIdProvider.notifier).state =
        requestClosedEvent.id;

    final detail = container.read(companySelectedDocumentAuditDetailProvider)!;

    expect(detail.event.id, requestClosedEvent.id);
    expect(detail.event.correlationId, 'empdoc-michael-probation');
    expect(detail.employeeDocumentGap?.id, 'empdoc-michael-probation');
    expect(detail.employeeDocumentRequest?.id, request.id);
    expect(
      detail.employeeDocumentRequest?.correlationId,
      detail.event.correlationId,
    );
    expect(
      detail.evidenceRecords,
      hasLength(initialMichael.missingDocumentCount),
    );
    expect(
      detail.evidenceRecords.every(
        (record) => record.correlationId == detail.event.correlationId,
      ),
      isTrue,
    );
    expect(detail.linkedRecordCount, initialMichael.missingDocumentCount + 2);
  });

  test('company audit filters isolate employee document activity', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(summary.totalEventCount, 5);
    expect(summary.companyDocumentEventCount, 5);
    expect(summary.employeeDocumentEventCount, 0);
    expect(summary.filteredEventCount, 5);

    container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .generateRequest('empdoc-michael-probation');
    container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .markVerified('empdoc-michael-probation');

    container
        .read(companyDocumentAuditFilterProvider.notifier)
        .state = const CompanyDocumentAuditTimelineFilter(
      scope: CompanyDocumentAuditTimelineScope.employeeDocuments,
    );

    final employeeEvents = container.read(
      filteredCompanyDocumentAuditEventsProvider,
    );
    summary = container.read(companyDocumentAuditActivitySummaryProvider);

    expect(summary.totalEventCount, 8);
    expect(summary.companyDocumentEventCount, 5);
    expect(summary.employeeDocumentEventCount, 3);
    expect(summary.filteredEventCount, 3);
    expect(employeeEvents.map((event) => event.type), [
      CompanyDocumentAuditEventType.employeeRequestClosed,
      CompanyDocumentAuditEventType.employeeEvidenceVerified,
      CompanyDocumentAuditEventType.employeeRequestGenerated,
    ]);

    container
        .read(companyDocumentAuditFilterProvider.notifier)
        .state = const CompanyDocumentAuditTimelineFilter(
      scope: CompanyDocumentAuditTimelineScope.employeeDocuments,
      searchText: 'Michael',
    );

    final searchedEmployeeEvents = container.read(
      filteredCompanyDocumentAuditEventsProvider,
    );
    summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(searchedEmployeeEvents, hasLength(3));
    expect(summary.filteredEventCount, 3);

    container
        .read(companyDocumentAuditFilterProvider.notifier)
        .state = const CompanyDocumentAuditTimelineFilter(
      scope: CompanyDocumentAuditTimelineScope.companyDocuments,
    );

    final companyDocumentEvents = container.read(
      filteredCompanyDocumentAuditEventsProvider,
    );
    summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(companyDocumentEvents, hasLength(5));
    expect(summary.filteredEventCount, 5);
    expect(
      companyDocumentEvents.any((event) => event.type.isEmployeeDocumentEvent),
      isFalse,
    );

    container.read(companyDocumentAuditFilterProvider.notifier).state =
        CompanyDocumentAuditFilterPreset.employeeEvidence.filter;
    final employeeEvidenceEvents = container.read(
      filteredCompanyDocumentAuditEventsProvider,
    );
    summary = container.read(companyDocumentAuditActivitySummaryProvider);
    expect(employeeEvidenceEvents.map((event) => event.type), [
      CompanyDocumentAuditEventType.employeeEvidenceVerified,
    ]);
    expect(summary.filteredEventCount, 1);

    container.read(companyDocumentAuditFilterProvider.notifier).state =
        CompanyDocumentAuditFilterPreset.requestLifecycle.filter;
    final requestLifecycleEvents = container.read(
      filteredCompanyDocumentAuditEventsProvider,
    );
    expect(requestLifecycleEvents.map((event) => event.type), [
      CompanyDocumentAuditEventType.employeeRequestClosed,
      CompanyDocumentAuditEventType.employeeRequestGenerated,
    ]);

    container.read(companyDocumentAuditFilterProvider.notifier).state =
        CompanyDocumentAuditFilterPreset.allActivity.filter;
    expect(
      container.read(filteredCompanyDocumentAuditEventsProvider),
      hasLength(8),
    );
  });

  test('company gap request generation normalizes overdue due dates', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final request = container
        .read(companyEmployeeDocumentGapsProvider.notifier)
        .generateRequest('empdoc-emma-offboarding');
    final profile =
        container.read(employeeDocumentRequestProfileProvider('3'))!;
    final emma = container
        .read(companyEmployeeDocumentGapsProvider)
        .singleWhere((gap) => gap.id == 'empdoc-emma-offboarding');

    expect(request, isNotNull);
    expect(request!.id, 'EDR-3-001');
    expect(request.employeeId, '3');
    expect(request.owner, 'Dewi Lestari');
    expect(request.status, EmployeeDocumentRequestStatus.requested);
    expect(request.dueDate, DateTime(2026, 6, 6));
    expect(profile.requestedCount, 1);
    expect(
      profile.requests.map((profileRequest) => profileRequest.id),
      contains('EDR-3-001'),
    );
    expect(emma.openRequestCount, 1);
    expect(emma.status, CompanyEmployeeDocumentGapStatus.blocked);
  });

  test('company filing actions reduce statutory filing risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyFilingsProvider.notifier)
        .markFiled('filing-annual-labor-report');

    final laborReport = container
        .read(companyFilingsProvider)
        .singleWhere((filing) => filing.id == 'filing-annual-labor-report');
    final summary = container.read(companyManagementSummaryProvider);

    expect(laborReport.status, CompanyFilingStatus.filed);
    expect(laborReport.evidenceSummary, 'Submission receipt captured');
    expect(laborReport.dueDate, DateTime(2027, 5, 31));
    expect(
      laborReport.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.filingRiskCount, 2);
  });

  test('company employer account actions reduce account risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyEmployerAccountsProvider.notifier)
        .markVerified('account-retail-payroll-bank');

    final account = container
        .read(companyEmployerAccountsProvider)
        .singleWhere((account) => account.id == 'account-retail-payroll-bank');
    final summary = container.read(companyManagementSummaryProvider);

    expect(account.status, CompanyEmployerAccountStatus.verified);
    expect(account.evidenceSummary, 'Employer account evidence captured');
    expect(
      account.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.employerAccountRiskCount, 2);
  });

  test('company vendor agreement actions reduce vendor risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyVendorAgreementsProvider.notifier)
        .markRenewed('vendor-esignature');

    final agreement = container
        .read(companyVendorAgreementsProvider)
        .singleWhere((agreement) => agreement.id == 'vendor-esignature');
    final summary = container.read(companyManagementSummaryProvider);

    expect(agreement.status, CompanyVendorAgreementStatus.active);
    expect(agreement.contractEndDate, DateTime(2027, 6, 20));
    expect(
      agreement.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.vendorAgreementRiskCount, 2);
  });

  test('company signatory actions reduce delegation risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companySignatoriesProvider.notifier)
        .markEvidenceActive('signatory-alya-payroll');

    final payrollSigner = container
        .read(companySignatoriesProvider)
        .singleWhere((signatory) => signatory.id == 'signatory-alya-payroll');
    final summary = container.read(companyManagementSummaryProvider);

    expect(payrollSigner.status, CompanySignatoryStatus.active);
    expect(payrollSigner.evidenceSummary, 'Delegation evidence captured');
    expect(
      payrollSigner.requiresAttention(container.read(companyAsOfDateProvider)),
      isFalse,
    );
    expect(summary.signatoryRiskCount, 2);
  });

  test(
    'document verification reduces statutory risk when data is complete',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(companyDocumentsProvider.notifier)
          .markVerified('doc-warehouse-lease');

      final lease = container
          .read(companyDocumentsProvider)
          .singleWhere((document) => document.id == 'doc-warehouse-lease');
      final summary = container.read(companyManagementSummaryProvider);

      expect(lease.status, CompanyDocumentStatus.verified);
      expect(
        lease.requiresAttention(container.read(companyAsOfDateProvider)),
        isFalse,
      );
      expect(summary.documentRiskCount, 2);
    },
  );

  test('marking policy ready reduces policy risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyPoliciesProvider.notifier)
        .markReady('policy-probation');

    final summary = container.read(companyManagementSummaryProvider);

    expect(summary.policyRiskCount, 1);
    expect(
      container
          .read(companyPoliciesProvider)
          .singleWhere((policy) => policy.id == 'policy-probation')
          .status,
      CompanyPolicyStatus.ready,
    );
  });

  test('entity and location readiness actions reduce operating risk', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(companyLegalEntitiesProvider.notifier)
        .markVerified('entity-fulfillment');
    container
        .read(companyWorkLocationsProvider.notifier)
        .markReady('loc-remote-hub');

    final fulfillment = container
        .read(companyLegalEntitiesProvider)
        .singleWhere((entity) => entity.id == 'entity-fulfillment');
    final remoteHub = container
        .read(companyWorkLocationsProvider)
        .singleWhere((location) => location.id == 'loc-remote-hub');
    final summary = container.read(companyManagementSummaryProvider);

    expect(fulfillment.status, CompanyLegalEntityStatus.verified);
    expect(fulfillment.payrollEnabled, isTrue);
    expect(remoteHub.status, CompanyWorkLocationStatus.open);
    expect(remoteHub.attendancePolicyLinked, isTrue);
    expect(remoteHub.coverageOwner, 'People Operations');
    expect(summary.legalEntityRiskCount, 1);
    expect(summary.locationRiskCount, 2);
  });

  test(
    'approval activation reduces route risk while cost center activation preserves data risks',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(companyCostCentersProvider.notifier)
          .markActive('cc-retail-ops');
      container
          .read(companyApprovalRulesProvider.notifier)
          .markActive('approval-org-change');

      final retailOps = container
          .read(companyCostCentersProvider)
          .singleWhere((center) => center.id == 'cc-retail-ops');
      final orgChange = container
          .read(companyApprovalRulesProvider)
          .singleWhere((rule) => rule.id == 'approval-org-change');
      final summary = container.read(companyManagementSummaryProvider);

      expect(retailOps.status, CompanyCostCenterStatus.active);
      expect(retailOps.requiresAttention, isTrue);
      expect(orgChange.status, CompanyApprovalRuleStatus.active);
      expect(orgChange.requiresAttention, isFalse);
      expect(summary.costCenterRiskCount, 2);
      expect(summary.approvalRuleRiskCount, 1);
    },
  );
}
