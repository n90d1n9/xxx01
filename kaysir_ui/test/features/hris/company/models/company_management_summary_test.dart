import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/company/data/company_seed_data.dart';
import 'package:kaysir/features/hris/company/models/company_approval_rule.dart';
import 'package:kaysir/features/hris/company/models/company_change_request.dart';
import 'package:kaysir/features/hris/company/models/company_compensation_band.dart';
import 'package:kaysir/features/hris/company/models/company_contract_template.dart';
import 'package:kaysir/features/hris/company/models/company_control.dart';
import 'package:kaysir/features/hris/company/models/company_cost_center.dart';
import 'package:kaysir/features/hris/company/models/company_document.dart';
import 'package:kaysir/features/hris/company/models/company_document_audit_event.dart';
import 'package:kaysir/features/hris/company/models/company_document_requirement.dart';
import 'package:kaysir/features/hris/company/models/company_document_renewal.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_gap.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_gap_recommendation.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_workload.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_workload_digest_status.dart';
import 'package:kaysir/features/hris/company/models/company_entity_lifecycle.dart';
import 'package:kaysir/features/hris/company/models/company_employer_account.dart';
import 'package:kaysir/features/hris/company/models/company_filing.dart';
import 'package:kaysir/features/hris/company/models/company_governance_action_filter.dart';
import 'package:kaysir/features/hris/company/models/company_governance_action_item.dart';
import 'package:kaysir/features/hris/company/models/company_governance_command_brief.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_audit.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_cadence.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_approval.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_audit.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_history.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_impact.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff_audit.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff_history.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff_record.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_load.dart';
import 'package:kaysir/features/hris/company/models/company_governance_saved_view.dart';
import 'package:kaysir/features/hris/company/models/company_governance_contact.dart';
import 'package:kaysir/features/hris/company/models/company_headcount_requisition.dart';
import 'package:kaysir/features/hris/company/models/company_headcount_requisition_activity.dart';
import 'package:kaysir/features/hris/company/models/company_legal_entity.dart';
import 'package:kaysir/features/hris/company/models/company_management_summary.dart';
import 'package:kaysir/features/hris/company/models/company_offboarding_pack.dart';
import 'package:kaysir/features/hris/company/models/company_onboarding_pack.dart';
import 'package:kaysir/features/hris/company/models/company_operating_readiness.dart';
import 'package:kaysir/features/hris/company/models/company_position_control.dart';
import 'package:kaysir/features/hris/company/models/company_probation_plan.dart';
import 'package:kaysir/features/hris/company/models/company_profile.dart';
import 'package:kaysir/features/hris/company/models/company_signatory.dart';
import 'package:kaysir/features/hris/company/models/company_vendor_agreement.dart';
import 'package:kaysir/features/hris/company/models/company_work_location.dart';
import 'package:kaysir/features/hris/company/models/company_workforce_plan.dart';
import 'package:kaysir/features/hris/company/models/employee_document_digest_history.dart';
import 'package:kaysir/features/hris/company/models/employee_document_digest_preview.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_follow_up.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_history.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_filter.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_plan.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_preview.dart';
import 'package:kaysir/features/hris/company/models/employee_document_workload_filter.dart';

const _employeeEvidenceSnapshots = [
  CompanyEmployeeDocumentEvidenceSnapshot(
    employeeId: '1',
    verifiedDocumentCount: 2,
    pendingDocumentCount: 1,
    rejectedDocumentCount: 0,
    openRequestCount: 0,
  ),
  CompanyEmployeeDocumentEvidenceSnapshot(
    employeeId: '2',
    verifiedDocumentCount: 3,
    pendingDocumentCount: 1,
    rejectedDocumentCount: 0,
    openRequestCount: 0,
  ),
  CompanyEmployeeDocumentEvidenceSnapshot(
    employeeId: '3',
    verifiedDocumentCount: 2,
    pendingDocumentCount: 0,
    rejectedDocumentCount: 0,
    openRequestCount: 0,
  ),
  CompanyEmployeeDocumentEvidenceSnapshot(
    employeeId: '4',
    verifiedDocumentCount: 2,
    pendingDocumentCount: 1,
    rejectedDocumentCount: 1,
    openRequestCount: 2,
  ),
  CompanyEmployeeDocumentEvidenceSnapshot(
    employeeId: '5',
    verifiedDocumentCount: 2,
    pendingDocumentCount: 2,
    rejectedDocumentCount: 0,
    openRequestCount: 1,
  ),
];

void main() {
  test('company summary aggregates profile, org, and policy readiness', () {
    final employeeDocumentGaps = buildCompanyEmployeeDocumentGaps(
      subjects: companySeedEmployeeDocumentSubjects,
      requirements: companySeedDocumentRequirements,
      evidenceSnapshots: _employeeEvidenceSnapshots,
      asOfDate: companySeedAsOfDate,
    );
    final summary = CompanyManagementSummary.fromData(
      profile: companySeedProfile,
      legalEntities: companySeedLegalEntities,
      locations: companySeedWorkLocations,
      costCenters: companySeedCostCenters,
      positionControls: companySeedPositionControls,
      compensationBands: companySeedCompensationBands,
      jobProfiles: companySeedJobProfiles,
      contractTemplates: companySeedContractTemplates,
      onboardingPacks: companySeedOnboardingPacks,
      probationPlans: companySeedProbationPlans,
      offboardingPacks: companySeedOffboardingPacks,
      documentRequirements: companySeedDocumentRequirements,
      employeeDocumentGaps: employeeDocumentGaps,
      approvalRules: companySeedApprovalRules,
      documents: companySeedDocuments,
      documentRenewals: companySeedDocumentRenewals,
      documentAuditEvents: companySeedDocumentAuditEvents,
      operatingReadiness: companySeedOperatingReadiness,
      governanceContacts: companySeedGovernanceContacts,
      entityLifecycles: companySeedEntityLifecycles,
      controls: companySeedControls,
      employerAccounts: companySeedEmployerAccounts,
      vendorAgreements: companySeedVendorAgreements,
      filings: companySeedFilings,
      signatories: companySeedSignatories,
      changeRequests: companySeedChangeRequests,
      asOfDate: companySeedAsOfDate,
      orgUnits: companySeedOrgUnits,
      policies: companySeedPolicies,
    );

    expect(summary.legalEntities, 3);
    expect(summary.verifiedLegalEntities, 1);
    expect(summary.locationCount, 4);
    expect(summary.documentCount, 5);
    expect(summary.positionControlCount, 5);
    expect(summary.positionControlReadyCount, 2);
    expect(summary.compensationBandCount, 5);
    expect(summary.compensationBandReadyCount, 2);
    expect(summary.jobProfileCount, 5);
    expect(summary.jobProfileReadyCount, 2);
    expect(summary.contractTemplateCount, 5);
    expect(summary.contractTemplateReadyCount, 2);
    expect(summary.onboardingPackCount, 5);
    expect(summary.onboardingPackReadyCount, 2);
    expect(summary.probationPlanCount, 5);
    expect(summary.probationPlanReadyCount, 2);
    expect(summary.offboardingPackCount, 5);
    expect(summary.offboardingPackReadyCount, 2);
    expect(summary.documentRequirementCount, 5);
    expect(summary.documentRequirementReadyCount, 2);
    expect(summary.employeeDocumentGapCount, 5);
    expect(summary.employeeDocumentGapReadyCount, 0);
    expect(summary.documentRenewalCount, 4);
    expect(summary.documentAuditEventCount, 5);
    expect(summary.operatingReadinessCount, 6);
    expect(summary.operatingReadyCount, 3);
    expect(summary.governanceContactCount, 6);
    expect(summary.governanceContactReadyCount, 3);
    expect(summary.entityLifecycleCount, 5);
    expect(summary.entityLifecycleReadyCount, 2);
    expect(summary.controlCount, 5);
    expect(summary.controlReadyCount, 2);
    expect(summary.employerAccountCount, 5);
    expect(summary.employerAccountReadyCount, 2);
    expect(summary.vendorAgreementCount, 5);
    expect(summary.vendorAgreementReadyCount, 2);
    expect(summary.filingCount, 5);
    expect(summary.filingReadyCount, 2);
    expect(summary.signatoryCount, 5);
    expect(summary.signatoryReadyCount, 2);
    expect(summary.changeRequestCount, 5);
    expect(summary.openChangeCount, 4);
    expect(summary.orgUnits, 6);
    expect(summary.activeHeadcount, 101);
    expect(summary.plannedHeadcount, 110);
    expect(summary.vacancy, 9);
    expect(summary.legalEntityRiskCount, 2);
    expect(summary.locationRiskCount, 2);
    expect(summary.costCenterRiskCount, 2);
    expect(summary.positionControlRiskCount, 3);
    expect(summary.compensationBandRiskCount, 3);
    expect(summary.jobProfileRiskCount, 3);
    expect(summary.contractTemplateRiskCount, 3);
    expect(summary.onboardingPackRiskCount, 3);
    expect(summary.probationPlanRiskCount, 3);
    expect(summary.offboardingPackRiskCount, 3);
    expect(summary.documentRequirementRiskCount, 3);
    expect(summary.employeeDocumentGapRiskCount, 5);
    expect(summary.approvalRuleRiskCount, 2);
    expect(summary.documentRiskCount, 3);
    expect(summary.documentRenewalRiskCount, 3);
    expect(summary.operatingRiskCount, 3);
    expect(summary.governanceContactRiskCount, 3);
    expect(summary.entityLifecycleRiskCount, 3);
    expect(summary.controlRiskCount, 3);
    expect(summary.employerAccountRiskCount, 3);
    expect(summary.vendorAgreementRiskCount, 3);
    expect(summary.filingRiskCount, 3);
    expect(summary.signatoryRiskCount, 3);
    expect(summary.changeRequestRiskCount, 3);
    expect(summary.orgRiskCount, 4);
    expect(summary.policyRiskCount, 2);
    expect(summary.totalRisks, 76);
    expect((summary.readinessScore * 100).round(), 46);
    expect(summary.nextAction, 'Kaysir Retail Services: Review entity setup');
  });

  test('company profile readiness highlights missing legal requirements', () {
    final profile = companySeedProfile.copyWith(
      registrationNumber: '',
      taxId: '',
      employeeCount: 0,
    );

    expect(profile.isReady, isFalse);
    expect(profile.issues, [
      CompanyProfileIssue.missingRegistrationNumber,
      CompanyProfileIssue.missingTaxId,
      CompanyProfileIssue.invalidEmployeeCount,
    ]);
    expect(profile.readinessScore, lessThan(1));
  });

  test('employee document gap recommendations prioritize remediation', () {
    final employeeDocumentGaps = buildCompanyEmployeeDocumentGaps(
      subjects: companySeedEmployeeDocumentSubjects,
      requirements: companySeedDocumentRequirements,
      evidenceSnapshots: _employeeEvidenceSnapshots,
      asOfDate: companySeedAsOfDate,
    );

    final recommendations = buildCompanyEmployeeDocumentGapRecommendations(
      gaps: employeeDocumentGaps,
      asOfDate: companySeedAsOfDate,
    );

    expect(recommendations.map((recommendation) => recommendation.gapId), [
      'empdoc-emma-offboarding',
      'empdoc-david-probation',
      'empdoc-olivia-preboarding',
      'empdoc-sarah-preboarding',
      'empdoc-michael-probation',
    ]);

    final emma = recommendations.first;
    expect(emma.priority, CompanyEmployeeDocumentGapPriority.critical);
    expect(emma.actionLabel, 'Generate request');
    expect(emma.rationale, 'overdue by 6d, 7 missing, no open request');

    final david = recommendations[1];
    expect(david.priority, CompanyEmployeeDocumentGapPriority.critical);
    expect(david.actionLabel, 'Review rejected evidence');
    expect(
      david.rationale,
      'due in 7d, 5 missing, 1 pending, 1 rejected, 2 open requests',
    );

    final olivia = recommendations[2];
    expect(olivia.priority, CompanyEmployeeDocumentGapPriority.high);
    expect(olivia.actionLabel, 'Follow up request');
    expect(olivia.rationale, 'due in 2d, 6 missing, 2 pending, 1 open request');
  });

  test('employee document workload aggregates owner remediation lanes', () {
    final employeeDocumentGaps = buildCompanyEmployeeDocumentGaps(
      subjects: companySeedEmployeeDocumentSubjects,
      requirements: companySeedDocumentRequirements,
      evidenceSnapshots: _employeeEvidenceSnapshots,
      asOfDate: companySeedAsOfDate,
    );
    final recommendations = buildCompanyEmployeeDocumentGapRecommendations(
      gaps: employeeDocumentGaps,
      asOfDate: companySeedAsOfDate,
    );

    final workloads = buildCompanyEmployeeDocumentWorkloads(
      gaps: employeeDocumentGaps,
      recommendations: recommendations,
      asOfDate: companySeedAsOfDate,
    );

    expect(workloads.map((workload) => workload.ownerName), [
      'Fajar Prakoso',
      'Dewi Lestari',
      'People Operations',
      'Nadia Safitri',
    ]);

    final fajar = workloads.first;
    expect(fajar.gapCount, 2);
    expect(fajar.criticalCount, 1);
    expect(fajar.missingDocumentCount, 9);
    expect(fajar.openRequestCount, 2);
    expect(fajar.primaryAction, 'Review rejected evidence');
    expect(fajar.primaryEmployeeName, 'David Kim');
    expect(fajar.requiresEscalation, isTrue);

    final dewi = workloads[1];
    expect(dewi.entitySummary, 'Kaysir Retail Services');
    expect(dewi.overdueCount, 1);
    expect(dewi.primaryAction, 'Generate request');
  });

  test('employee document workload filters match digest and risk lanes', () {
    final asOfDate = DateTime(2026, 6, 9);
    CompanyEmployeeDocumentWorkload workload({
      required String ownerName,
      required int missingDocumentCount,
      required int criticalCount,
      required int highCount,
      required int overdueCount,
      required int dueSoonCount,
    }) {
      return CompanyEmployeeDocumentWorkload(
        ownerName: ownerName,
        entityNames: const ['PT Kaysir Nusantara'],
        gapIds: ['gap-$ownerName'],
        score: 60,
        gapCount: 1,
        criticalCount: criticalCount,
        highCount: highCount,
        overdueCount: overdueCount,
        dueSoonCount: dueSoonCount,
        openRequestCount: 1,
        missingDocumentCount: missingDocumentCount,
        pendingDocumentCount: 0,
        rejectedDocumentCount: 0,
        primaryAction: 'Generate request',
        primaryGapId: 'gap-$ownerName',
        primaryEmployeeName: ownerName,
      );
    }

    final workloads = [
      workload(
        ownerName: 'Escalated Owner',
        missingDocumentCount: 6,
        criticalCount: 1,
        highCount: 0,
        overdueCount: 0,
        dueSoonCount: 0,
      ),
      workload(
        ownerName: 'Fresh Owner',
        missingDocumentCount: 2,
        criticalCount: 0,
        highCount: 0,
        overdueCount: 0,
        dueSoonCount: 0,
      ),
      workload(
        ownerName: 'High Missing Owner',
        missingDocumentCount: 5,
        criticalCount: 0,
        highCount: 1,
        overdueCount: 0,
        dueSoonCount: 1,
      ),
    ];
    final statuses = [
      CompanyEmployeeDocumentWorkloadDigestStatus(
        ownerName: 'Fresh Owner',
        digestCount: 1,
        lastSentAt: asOfDate,
        lastAuditEventId: 'audit-fresh',
      ),
    ];

    final counts = countEmployeeDocumentWorkloadFilters(
      workloads: workloads,
      digestStatuses: statuses,
      asOfDate: asOfDate,
    );

    expect(counts[EmployeeDocumentWorkloadFilter.all], 3);
    expect(counts[EmployeeDocumentWorkloadFilter.dueDigest], 2);
    expect(counts[EmployeeDocumentWorkloadFilter.escalation], 1);
    expect(counts[EmployeeDocumentWorkloadFilter.watchlist], 2);
    expect(counts[EmployeeDocumentWorkloadFilter.highMissing], 2);
    expect(counts[EmployeeDocumentWorkloadFilter.noDigest], 2);
    expect(
      filterEmployeeDocumentWorkloads(
        workloads: workloads,
        digestStatuses: statuses,
        filter: EmployeeDocumentWorkloadFilter.noDigest,
        asOfDate: asOfDate,
      ).map((workload) => workload.ownerName),
      ['Escalated Owner', 'High Missing Owner'],
    );
  });

  test('employee document escalation plans rank owner lanes', () {
    final asOfDate = DateTime(2026, 6, 9);
    final plans = buildEmployeeDocumentEscalationPlans(
      asOfDate: asOfDate,
      workloads: [
        const CompanyEmployeeDocumentWorkload(
          ownerName: 'High Missing Owner',
          entityNames: ['PT Kaysir Nusantara'],
          gapIds: ['gap-high'],
          score: 84,
          gapCount: 1,
          criticalCount: 0,
          highCount: 0,
          overdueCount: 0,
          dueSoonCount: 1,
          openRequestCount: 1,
          missingDocumentCount: 6,
          pendingDocumentCount: 0,
          rejectedDocumentCount: 0,
          primaryAction: 'Generate request',
          primaryGapId: 'gap-high',
          primaryEmployeeName: 'Alya Rahman',
        ),
        const CompanyEmployeeDocumentWorkload(
          ownerName: 'Escalated Owner',
          entityNames: ['PT Kaysir Nusantara'],
          gapIds: ['gap-critical'],
          score: 120,
          gapCount: 1,
          criticalCount: 1,
          highCount: 0,
          overdueCount: 1,
          dueSoonCount: 0,
          openRequestCount: 2,
          missingDocumentCount: 3,
          pendingDocumentCount: 0,
          rejectedDocumentCount: 1,
          primaryAction: 'Review rejected evidence',
          primaryGapId: 'gap-critical',
          primaryEmployeeName: 'David Kim',
        ),
        const CompanyEmployeeDocumentWorkload(
          ownerName: 'Healthy Owner',
          entityNames: ['PT Kaysir Nusantara'],
          gapIds: ['gap-healthy'],
          score: 12,
          gapCount: 1,
          criticalCount: 0,
          highCount: 0,
          overdueCount: 0,
          dueSoonCount: 0,
          openRequestCount: 0,
          missingDocumentCount: 1,
          pendingDocumentCount: 0,
          rejectedDocumentCount: 0,
          primaryAction: 'Monitor evidence',
          primaryGapId: 'gap-healthy',
          primaryEmployeeName: 'Bima Santoso',
        ),
      ],
      digestStatuses: [
        CompanyEmployeeDocumentWorkloadDigestStatus(
          ownerName: 'Escalated Owner',
          digestCount: 1,
          lastSentAt: asOfDate.subtract(const Duration(days: 1)),
          lastAuditEventId: 'audit-critical',
        ),
        CompanyEmployeeDocumentWorkloadDigestStatus(
          ownerName: 'Healthy Owner',
          digestCount: 1,
          lastSentAt: asOfDate,
          lastAuditEventId: 'audit-healthy',
        ),
      ],
    );

    expect(plans.map((plan) => plan.ownerName), [
      'Escalated Owner',
      'High Missing Owner',
    ]);
    expect(plans.first.priority, EmployeeDocumentEscalationPriority.critical);
    expect(plans.first.digestFreshnessLabel, 'Digest due');
    expect(plans.first.primaryEmployeeLabel, 'David Kim');
    expect(plans.first.rationale, contains('critical'));
    expect(plans.last.priority, EmployeeDocumentEscalationPriority.high);
    expect(plans.last.rationale, contains('6 missing evidence items'));
  });

  test('employee document escalation preview skips cooldown lanes', () {
    const readyPlan = EmployeeDocumentEscalationPlan(
      ownerName: 'Fajar Prakoso',
      entitySummary: 'PT Kaysir Nusantara',
      priority: EmployeeDocumentEscalationPriority.critical,
      workloadScore: 120,
      gapCount: 1,
      criticalCount: 1,
      highCount: 0,
      overdueCount: 1,
      dueSoonCount: 0,
      missingDocumentCount: 3,
      openRequestCount: 1,
      actionLabel: 'Review rejected evidence',
      primaryEmployeeName: 'David Kim',
      digestFreshnessLabel: 'Digest due',
      digestCadenceLabel: 'Daily',
      digestDue: true,
      rationale: '1 critical document gap needs owner escalation.',
    );
    const coolingDownPlan = EmployeeDocumentEscalationPlan(
      ownerName: 'Dewi Lestari',
      entitySummary: 'Kaysir Retail Services',
      priority: EmployeeDocumentEscalationPriority.critical,
      workloadScore: 96,
      gapCount: 1,
      criticalCount: 1,
      highCount: 0,
      overdueCount: 1,
      dueSoonCount: 0,
      missingDocumentCount: 4,
      openRequestCount: 1,
      actionLabel: 'Generate request',
      primaryEmployeeName: 'Nadia Safitri',
      digestFreshnessLabel: 'Digest due',
      digestCadenceLabel: 'Daily',
      digestDue: true,
      escalationFreshnessLabel: 'Escalated today',
      escalationCount: 1,
      escalationCoolingDown: true,
      rationale: '1 critical document gap needs owner escalation.',
    );

    final preview = buildEmployeeDocumentEscalationPreview(
      ownerNames: ['Fajar Prakoso', 'Dewi Lestari', 'Fajar Prakoso'],
      plans: const [readyPlan, coolingDownPlan],
    );
    final inclusivePreview = buildEmployeeDocumentEscalationPreview(
      ownerNames: ['Fajar Prakoso', 'Dewi Lestari'],
      plans: const [readyPlan, coolingDownPlan],
      includeCoolingDown: true,
    );

    expect(preview.ownerNames, ['Fajar Prakoso']);
    expect(preview.ownerCount, 1);
    expect(preview.criticalCount, 1);
    expect(preview.gapCount, 1);
    expect(preview.missingDocumentCount, 3);
    expect(preview.openRequestCount, 1);
    expect(preview.owners.single.actionSummary, contains('David Kim'));
    expect(inclusivePreview.ownerNames, ['Fajar Prakoso', 'Dewi Lestari']);
  });

  test('employee document escalation filters count owner lanes', () {
    const readyCriticalPlan = EmployeeDocumentEscalationPlan(
      ownerName: 'Fajar Prakoso',
      entitySummary: 'PT Kaysir Nusantara',
      priority: EmployeeDocumentEscalationPriority.critical,
      workloadScore: 120,
      gapCount: 1,
      criticalCount: 1,
      highCount: 0,
      overdueCount: 1,
      dueSoonCount: 0,
      missingDocumentCount: 3,
      openRequestCount: 1,
      actionLabel: 'Review rejected evidence',
      primaryEmployeeName: 'David Kim',
      digestFreshnessLabel: 'Digest due',
      digestCadenceLabel: 'Daily',
      digestDue: true,
      rationale: '1 critical document gap needs owner escalation.',
    );
    const highPlan = EmployeeDocumentEscalationPlan(
      ownerName: 'People Operations',
      entitySummary: 'PT Kaysir Nusantara',
      priority: EmployeeDocumentEscalationPriority.high,
      workloadScore: 72,
      gapCount: 1,
      criticalCount: 0,
      highCount: 1,
      overdueCount: 0,
      dueSoonCount: 1,
      missingDocumentCount: 5,
      openRequestCount: 1,
      actionLabel: 'Generate request',
      primaryEmployeeName: 'Alya Rahman',
      digestFreshnessLabel: 'Due tomorrow',
      digestCadenceLabel: 'Every 3d',
      digestDue: false,
      rationale: '1 high-risk document gap needs owner follow-up.',
    );
    const coolingDownCriticalPlan = EmployeeDocumentEscalationPlan(
      ownerName: 'Dewi Lestari',
      entitySummary: 'Kaysir Retail Services',
      priority: EmployeeDocumentEscalationPriority.critical,
      workloadScore: 96,
      gapCount: 1,
      criticalCount: 1,
      highCount: 0,
      overdueCount: 1,
      dueSoonCount: 0,
      missingDocumentCount: 4,
      openRequestCount: 1,
      actionLabel: 'Generate request',
      primaryEmployeeName: 'Nadia Safitri',
      digestFreshnessLabel: 'Digest due',
      digestCadenceLabel: 'Daily',
      digestDue: true,
      escalationFreshnessLabel: 'Escalated today',
      escalationCount: 1,
      escalationCoolingDown: true,
      rationale: '1 critical document gap needs owner escalation.',
    );
    const plans = [readyCriticalPlan, highPlan, coolingDownCriticalPlan];

    final counts = countEmployeeDocumentEscalationFilters(plans);

    expect(counts[EmployeeDocumentEscalationFilter.all], 3);
    expect(counts[EmployeeDocumentEscalationFilter.ready], 2);
    expect(counts[EmployeeDocumentEscalationFilter.coolingDown], 1);
    expect(counts[EmployeeDocumentEscalationFilter.critical], 2);
    expect(counts[EmployeeDocumentEscalationFilter.high], 1);
    expect(counts[EmployeeDocumentEscalationFilter.digestDue], 2);
    expect(
      filterEmployeeDocumentEscalationPlans(
        plans: plans,
        filter: EmployeeDocumentEscalationFilter.ready,
      ).map((plan) => plan.ownerName),
      ['Fajar Prakoso', 'People Operations'],
    );
    expect(
      filterEmployeeDocumentEscalationPlans(
        plans: plans,
        filter: EmployeeDocumentEscalationFilter.coolingDown,
      ).single.ownerName,
      'Dewi Lestari',
    );
  });

  test('employee document escalation history summarizes audit events', () {
    final asOfDate = DateTime(2026, 6, 9);
    final workloads = [
      const CompanyEmployeeDocumentWorkload(
        ownerName: 'Fajar Prakoso',
        entityNames: ['PT Kaysir Nusantara'],
        gapIds: ['gap-critical'],
        score: 120,
        gapCount: 1,
        criticalCount: 1,
        highCount: 0,
        overdueCount: 1,
        dueSoonCount: 0,
        openRequestCount: 2,
        missingDocumentCount: 3,
        pendingDocumentCount: 0,
        rejectedDocumentCount: 1,
        primaryAction: 'Review rejected evidence',
        primaryGapId: 'gap-critical',
        primaryEmployeeName: 'David Kim',
      ),
      const CompanyEmployeeDocumentWorkload(
        ownerName: 'Dewi Lestari',
        entityNames: ['Kaysir Retail Services'],
        gapIds: ['gap-retail'],
        score: 96,
        gapCount: 1,
        criticalCount: 1,
        highCount: 0,
        overdueCount: 1,
        dueSoonCount: 0,
        openRequestCount: 1,
        missingDocumentCount: 4,
        pendingDocumentCount: 0,
        rejectedDocumentCount: 0,
        primaryAction: 'Generate request',
        primaryGapId: 'gap-retail',
        primaryEmployeeName: 'Nadia Safitri',
      ),
    ];
    final auditEvents = [
      CompanyDocumentAuditEvent(
        id: 'audit-created',
        documentId: 'doc-1',
        documentTitle: 'Company registration',
        entityName: 'PT Kaysir Nusantara',
        actorName: 'Legal Operations',
        type: CompanyDocumentAuditEventType.created,
        happenedAt: asOfDate,
        note: 'Document created',
      ),
      CompanyDocumentAuditEvent(
        id: 'audit-fajar-old',
        documentId: companyEmployeeDocumentOwnerDigestDocumentId(
          'Fajar Prakoso',
        ),
        documentTitle: 'Fajar Prakoso - Employee document workload',
        entityName: 'PT Kaysir Nusantara',
        actorName: 'People Operations',
        type: CompanyDocumentAuditEventType.employeeOwnerEscalated,
        happenedAt: asOfDate.subtract(const Duration(days: 2)),
        note: 'Old escalation',
        correlationId: companyEmployeeDocumentOwnerEscalationCorrelationId(
          'Fajar Prakoso',
        ),
      ),
      CompanyDocumentAuditEvent(
        id: 'audit-dewi-new',
        documentId: companyEmployeeDocumentOwnerDigestDocumentId(
          'Dewi Lestari',
        ),
        documentTitle: 'Dewi Lestari - Employee document workload',
        entityName: 'Kaysir Retail Services',
        actorName: 'People Operations',
        type: CompanyDocumentAuditEventType.employeeOwnerEscalated,
        happenedAt: asOfDate,
        note: 'Latest escalation',
        correlationId: companyEmployeeDocumentOwnerEscalationCorrelationId(
          'Dewi Lestari',
        ),
      ),
    ];

    final statuses = buildEmployeeDocumentEscalationStatuses(
      workloads: workloads,
      auditEvents: auditEvents,
    );
    final history = buildEmployeeDocumentEscalationHistory(
      workloads: workloads,
      auditEvents: auditEvents,
      limit: 2,
    );
    final plans = buildEmployeeDocumentEscalationPlans(
      workloads: workloads,
      digestStatuses: const [],
      escalationStatuses: statuses,
      asOfDate: asOfDate,
    );

    final fajar = statuses.singleWhere(
      (status) => status.ownerName == 'Fajar Prakoso',
    );
    expect(fajar.escalationCount, 1);
    expect(fajar.lastAuditEventId, 'audit-fajar-old');
    expect(fajar.freshnessLabel(asOfDate), 'Escalated 2d ago');
    expect(fajar.isCoolingDown(asOfDate), isFalse);

    expect(history.totalEscalationCount, 2);
    expect(history.ownerCount, 2);
    expect(history.latestLabel(asOfDate), 'Escalated today');
    expect(history.items.first.auditEventId, 'audit-dewi-new');
    expect(history.items.last.escalatedLabel(asOfDate), 'Escalated 2d ago');

    final dewiPlan = plans.singleWhere(
      (plan) => plan.ownerName == 'Dewi Lestari',
    );
    expect(dewiPlan.escalationFreshnessLabel, 'Escalated today');
    expect(dewiPlan.escalationCoolingDown, isTrue);
    expect(dewiPlan.lastEscalationAuditEventId, 'audit-dewi-new');
  });

  test('employee document escalation follow-ups rank SLA touches', () {
    final asOfDate = DateTime(2026, 6, 10);
    final followUps = buildEmployeeDocumentEscalationFollowUps(
      asOfDate: asOfDate,
      plans: [
        EmployeeDocumentEscalationPlan(
          ownerName: 'Scheduled Owner',
          entitySummary: 'PT Kaysir Nusantara',
          priority: EmployeeDocumentEscalationPriority.watchlist,
          workloadScore: 48,
          gapCount: 1,
          criticalCount: 0,
          highCount: 0,
          overdueCount: 0,
          dueSoonCount: 0,
          missingDocumentCount: 1,
          openRequestCount: 1,
          actionLabel: 'Monitor owner response',
          primaryEmployeeName: 'Bima Santoso',
          digestFreshnessLabel: 'Due in 7d',
          digestCadenceLabel: 'Weekly',
          digestDue: false,
          escalationFreshnessLabel: 'Escalated today',
          lastEscalationAuditEventId: 'audit-scheduled',
          lastEscalatedAt: asOfDate,
          escalationCount: 1,
          escalationCoolingDown: true,
          rationale: 'Digest follow-up is scheduled.',
        ),
        EmployeeDocumentEscalationPlan(
          ownerName: 'Overdue Owner',
          entitySummary: 'PT Kaysir Nusantara',
          priority: EmployeeDocumentEscalationPriority.critical,
          workloadScore: 120,
          gapCount: 1,
          criticalCount: 1,
          highCount: 0,
          overdueCount: 1,
          dueSoonCount: 0,
          missingDocumentCount: 3,
          openRequestCount: 2,
          actionLabel: 'Review rejected evidence',
          primaryEmployeeName: 'David Kim',
          digestFreshnessLabel: 'Digest due',
          digestCadenceLabel: 'Daily',
          digestDue: true,
          escalationFreshnessLabel: 'Escalated 2d ago',
          lastEscalationAuditEventId: 'audit-overdue',
          lastEscalatedAt: asOfDate.subtract(const Duration(days: 2)),
          escalationCount: 1,
          rationale: '1 critical document gap needs owner escalation.',
        ),
        EmployeeDocumentEscalationPlan(
          ownerName: 'Due Owner',
          entitySummary: 'Kaysir Retail Services',
          priority: EmployeeDocumentEscalationPriority.high,
          workloadScore: 72,
          gapCount: 1,
          criticalCount: 0,
          highCount: 1,
          overdueCount: 0,
          dueSoonCount: 1,
          missingDocumentCount: 5,
          openRequestCount: 1,
          actionLabel: 'Generate request',
          primaryEmployeeName: 'Alya Rahman',
          digestFreshnessLabel: 'Due tomorrow',
          digestCadenceLabel: 'Every 3d',
          digestDue: false,
          escalationFreshnessLabel: 'Escalated 2d ago',
          lastEscalationAuditEventId: 'audit-due',
          lastEscalatedAt: asOfDate.subtract(const Duration(days: 2)),
          escalationCount: 1,
          rationale: '1 high-risk document gap needs owner follow-up.',
        ),
      ],
    );

    expect(followUps.map((item) => item.ownerName), [
      'Overdue Owner',
      'Due Owner',
      'Scheduled Owner',
    ]);
    expect(
      followUps.first.state,
      EmployeeDocumentEscalationFollowUpState.overdue,
    );
    expect(followUps.first.nextTouchLabel(asOfDate), '1d overdue');
    expect(followUps.first.lastEscalatedLabel(asOfDate), 'Escalated 2d ago');
    expect(
      followUps[1].state,
      EmployeeDocumentEscalationFollowUpState.dueToday,
    );
    expect(followUps[1].nextTouchLabel(asOfDate), 'Due today');
    expect(
      followUps.last.state,
      EmployeeDocumentEscalationFollowUpState.scheduled,
    );
    expect(followUps.last.nextTouchLabel(asOfDate), 'Due in 3d');

    final refreshedFollowUps = buildEmployeeDocumentEscalationFollowUps(
      asOfDate: asOfDate,
      plans: [
        EmployeeDocumentEscalationPlan(
          ownerName: 'Overdue Owner',
          entitySummary: 'PT Kaysir Nusantara',
          priority: EmployeeDocumentEscalationPriority.critical,
          workloadScore: 120,
          gapCount: 1,
          criticalCount: 1,
          highCount: 0,
          overdueCount: 1,
          dueSoonCount: 0,
          missingDocumentCount: 3,
          openRequestCount: 2,
          actionLabel: 'Review rejected evidence',
          primaryEmployeeName: 'David Kim',
          digestFreshnessLabel: 'Digest due',
          digestCadenceLabel: 'Daily',
          digestDue: true,
          escalationFreshnessLabel: 'Escalated 2d ago',
          lastEscalationAuditEventId: 'audit-overdue',
          lastEscalatedAt: asOfDate.subtract(const Duration(days: 2)),
          escalationCount: 1,
          rationale: '1 critical document gap needs owner escalation.',
        ),
      ],
      auditEvents: [
        CompanyDocumentAuditEvent(
          id: 'audit-follow-up',
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            'Overdue Owner',
          ),
          documentTitle: 'Overdue Owner - Employee document workload',
          entityName: 'PT Kaysir Nusantara',
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerFollowedUp,
          happenedAt: asOfDate,
          note: 'Followed up',
          correlationId: companyEmployeeDocumentOwnerFollowUpCorrelationId(
            'Overdue Owner',
          ),
        ),
      ],
    );

    expect(
      refreshedFollowUps.single.state,
      EmployeeDocumentEscalationFollowUpState.scheduled,
    );
    expect(refreshedFollowUps.single.followUpCount, 1);
    expect(
      refreshedFollowUps.single.lastFollowUpAuditEventId,
      'audit-follow-up',
    );
    expect(
      refreshedFollowUps.single.lastTouchLabel(asOfDate),
      'Followed up today',
    );
    expect(refreshedFollowUps.single.nextTouchLabel(asOfDate), 'Due tomorrow');
  });

  test('company governance action queue prioritizes statutory actions', () {
    final asOfDate = DateTime(2026, 6, 10);
    final actions = buildCompanyGovernanceActionItems(
      filings: [
        CompanyFiling(
          id: 'labor-report',
          title: 'Annual WLK labor report',
          entityName: 'PT Kaysir Nusantara',
          type: CompanyFilingType.laborReport,
          cadence: CompanyFilingCadence.annual,
          status: CompanyFilingStatus.overdue,
          ownerName: 'People Operations',
          authorityName: 'Ministry of Manpower',
          dueDate: asOfDate.subtract(const Duration(days: 3)),
          evidenceSummary: '',
          nextStep: 'Submit labor report receipt',
          linkedRecord: 'Labor registry',
        ),
      ],
      employerAccounts: [
        CompanyEmployerAccount(
          id: 'bpjs-account',
          accountName: 'BPJS employment portal',
          entityName: 'PT Kaysir Nusantara',
          type: CompanyEmployerAccountType.socialSecurity,
          status: CompanyEmployerAccountStatus.verified,
          accountNumber: 'BPJS-01',
          ownerName: 'People Operations',
          credentialOwnerName: 'Payroll Ops',
          nextReviewDate: asOfDate.add(const Duration(days: 12)),
          evidenceSummary: 'Authority receipt captured',
          nextAction: 'Quarterly credential review',
          linkedFiling: 'BPJS monthly contribution',
        ),
      ],
      vendorAgreements: [
        CompanyVendorAgreement(
          id: 'vendor-implementation',
          vendorName: 'CheckRight Indonesia',
          serviceName: 'Background screening',
          entityName: 'PT Kaysir Nusantara',
          category: CompanyVendorAgreementCategory.backgroundCheck,
          status: CompanyVendorAgreementStatus.implementation,
          ownerName: 'Talent Operations',
          accountManagerName: 'CheckRight CSM',
          contractEndDate: asOfDate.add(const Duration(days: 80)),
          slaSummary: 'Two business day screening SLA',
          dataProtectionSummary: 'Processor DPA signed',
          nextAction: 'Close screening workflow implementation',
          linkedModule: 'Recruitment',
        ),
      ],
      signatories: [
        CompanySignatory(
          id: 'signatory-missing-backup',
          personName: 'Nadia Putri',
          title: 'Head of HR',
          entityName: 'PT Kaysir Nusantara',
          scope: CompanySignatoryScope.employmentContract,
          authorityLevel: CompanySignatoryAuthorityLevel.signer,
          status: CompanySignatoryStatus.active,
          effectiveDate: asOfDate.subtract(const Duration(days: 60)),
          expiryDate: asOfDate.add(const Duration(days: 120)),
          backupSignerName: '',
          evidenceSummary: 'Delegation letter active',
          delegationNotes: 'Assign backup signer before peak hiring',
        ),
      ],
      asOfDate: asOfDate,
    );

    expect(actions.map((item) => item.source), [
      CompanyGovernanceActionSource.filing,
      CompanyGovernanceActionSource.employerAccount,
      CompanyGovernanceActionSource.vendorAgreement,
      CompanyGovernanceActionSource.signatory,
    ]);
    expect(actions.first.severity, CompanyGovernanceActionSeverity.critical);
    expect(actions.first.dueLabel, 'Overdue 3d');
    expect(actions.first.resolveLabel, 'Mark filed');
    expect(actions.first.issueLabels, contains('Filing overdue'));

    final counts = countCompanyGovernanceActionFilters(actions);
    expect(counts[CompanyGovernanceActionFilter.all], 4);
    expect(counts[CompanyGovernanceActionFilter.critical], 1);
    expect(counts[CompanyGovernanceActionFilter.high], 3);
    expect(counts[CompanyGovernanceActionFilter.filings], 1);
    expect(counts[CompanyGovernanceActionFilter.vendors], 1);
    expect(
      filterCompanyGovernanceActionItems(
        items: actions,
        filter: CompanyGovernanceActionFilter.critical,
      ).map((item) => item.title),
      ['Annual WLK labor report'],
    );
    expect(
      filterCompanyGovernanceActionItems(
        items: actions,
        filter: CompanyGovernanceActionFilter.all,
        ownerName: 'people operations',
      ).map((item) => item.title),
      ['Annual WLK labor report', 'BPJS employment portal'],
    );

    final ownerLoads = buildCompanyGovernanceOwnerLoads(items: actions);
    expect(ownerLoads.map((load) => load.ownerLabel), [
      'People Operations',
      'Talent Operations',
      'Unassigned owner',
    ]);
    expect(ownerLoads.first.risk, CompanyGovernanceOwnerLoadRisk.critical);
    expect(ownerLoads.first.actionCount, 2);
    expect(ownerLoads.first.criticalCount, 1);
    expect(ownerLoads.first.highCount, 1);
    expect(ownerLoads.first.sourceSummary, '1 filing, 1 account');
    expect(ownerLoads.first.nextDueLabel, 'Overdue 3d');
    expect(ownerLoads.first.primaryActionLabel, 'Submit labor report receipt');

    final handoff = buildCompanyGovernanceOwnerHandoff(
      items: actions,
      ownerName: 'People Operations',
    );
    expect(handoff, isNotNull);
    expect(handoff!.ownerLabel, 'People Operations');
    expect(handoff.actionCount, 2);
    expect(handoff.criticalCount, 1);
    expect(handoff.highCount, 1);
    expect(handoff.sourceSummary, '1 filing, 1 employer account');
    expect(handoff.nextDueLabel, 'Overdue 3d');
    expect(handoff.actions.map((action) => action.title), [
      'Annual WLK labor report',
      'BPJS employment portal',
    ]);
    expect(handoff.handoffMessage, contains('Start with'));
    final handoffRecord = CompanyGovernanceOwnerHandoffRecord.fromHandoff(
      id: 'handoff-001',
      handoff: handoff,
      recordedAt: asOfDate,
      actorName: 'People Operations',
    );
    expect(handoffRecord.ownerLabel, 'People Operations');
    expect(handoffRecord.recordedDateLabel, '2026-06-10');
    expect(handoffRecord.actionCount, 2);
    expect(handoffRecord.hasAuditEvent, isFalse);
    expect(
      handoffRecord.copyWith(auditEventId: 'audit-091').hasAuditEvent,
      isTrue,
    );
    final auditPayload = CompanyGovernanceOwnerHandoffAuditPayload.fromRecord(
      record: handoffRecord,
      entityName: 'PT Kaysir Nusantara',
    );
    expect(auditPayload.documentId, 'handoff-001');
    expect(
      auditPayload.documentTitle,
      'People Operations - Governance handoff',
    );
    expect(auditPayload.entityName, 'PT Kaysir Nusantara');
    expect(auditPayload.actorName, 'People Operations');
    expect(auditPayload.correlationId, 'handoff-001');
    expect(auditPayload.note, contains('2 actions across'));
    expect(
      CompanyDocumentAuditEventType.governanceOwnerHandoffRecorded.label,
      'Governance handoff',
    );
    final cadenceAsOfDate = asOfDate.add(const Duration(days: 2));
    final handoffCadence = buildCompanyGovernanceFollowUpCadence(
      loads: ownerLoads,
      handoffRecords: [handoffRecord.copyWith(auditEventId: 'audit-handoff')],
      auditEvents: const [],
      asOfDate: cadenceAsOfDate,
    );
    expect(
      handoffCadence
          .where(
            (lane) => lane.state == CompanyGovernanceFollowUpState.needsHandoff,
          )
          .length,
      2,
    );
    final peopleCadence = handoffCadence.singleWhere(
      (lane) => lane.ownerLabel == 'People Operations',
    );
    expect(peopleCadence.state, CompanyGovernanceFollowUpState.overdue);
    expect(peopleCadence.nextTouchLabel(cadenceAsOfDate), '1d overdue');
    expect(peopleCadence.lastTouchLabel(cadenceAsOfDate), 'Handed off 2d ago');
    expect(peopleCadence.auditEventId, 'audit-handoff');
    expect(peopleCadence.canRecordFollowUp, isTrue);

    const customFollowUpPolicy = CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: 3,
      highCadenceDays: 5,
      steadyCadenceDays: 7,
    );
    final customCadence = buildCompanyGovernanceFollowUpCadence(
      loads: ownerLoads,
      handoffRecords: [handoffRecord.copyWith(auditEventId: 'audit-handoff')],
      auditEvents: const [],
      asOfDate: cadenceAsOfDate,
      policy: customFollowUpPolicy,
    ).singleWhere((lane) => lane.ownerLabel == 'People Operations');
    expect(customCadence.state, CompanyGovernanceFollowUpState.scheduled);
    expect(customCadence.nextTouchLabel(cadenceAsOfDate), 'Due tomorrow');
    expect(
      customFollowUpPolicy.cadenceLabelFor(
        CompanyGovernanceOwnerLoadRisk.critical,
      ),
      '3 days',
    );

    final followedUpCadence = buildCompanyGovernanceFollowUpCadence(
      loads: ownerLoads,
      handoffRecords: [handoffRecord.copyWith(auditEventId: 'audit-handoff')],
      auditEvents: [
        CompanyDocumentAuditEvent(
          id: 'audit-follow-up',
          documentId: 'handoff-001',
          documentTitle: 'People Operations - Governance follow-up',
          entityName: 'PT Kaysir Nusantara',
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.governanceOwnerFollowedUp,
          happenedAt: cadenceAsOfDate,
          note: 'Recorded follow-up.',
          correlationId: 'handoff-001',
        ),
      ],
      asOfDate: cadenceAsOfDate,
    ).singleWhere((lane) => lane.ownerLabel == 'People Operations');
    expect(followedUpCadence.state, CompanyGovernanceFollowUpState.scheduled);
    expect(followedUpCadence.followUpCount, 1);
    expect(followedUpCadence.lastFollowUpAuditEventId, 'audit-follow-up');
    expect(
      followedUpCadence.lastTouchLabel(cadenceAsOfDate),
      'Followed up today',
    );
    final followUpPayload = CompanyGovernanceFollowUpAuditPayload.fromLane(
      lane: peopleCadence,
      entityName: 'PT Kaysir Nusantara',
    );
    expect(followUpPayload.documentId, 'handoff-001');
    expect(
      followUpPayload.documentTitle,
      'People Operations - Governance follow-up',
    );
    expect(followUpPayload.note, contains('Recorded governance follow-up'));
    expect(
      CompanyDocumentAuditEventType.governanceOwnerFollowedUp.label,
      'Governance follow-up',
    );
    final savedViews = buildCompanyGovernanceSavedViews(
      actions: actions,
      followUpLanes: handoffCadence,
    );
    expect(
      selectedCompanyGovernanceSavedView(
        views: savedViews,
        selectedType: CompanyGovernanceSavedViewType.criticalActions,
      ).queueFilter,
      CompanyGovernanceActionFilter.critical,
    );
    expect(
      selectedCompanyGovernanceSavedView(
        views: savedViews,
        selectedType: CompanyGovernanceSavedViewType.ownerHandoffs,
      ).metricValue,
      2,
    );
    final followUpsDueView = selectedCompanyGovernanceSavedView(
      views: savedViews,
      selectedType: CompanyGovernanceSavedViewType.followUpsDue,
    );
    expect(followUpsDueView.metricValue, 1);
    expect(followUpsDueView.ownerName, 'People Operations');
    expect(
      selectedCompanyGovernanceSavedView(
        views: savedViews,
        selectedType: CompanyGovernanceSavedViewType.vendorRenewals,
      ).queueFilter,
      CompanyGovernanceActionFilter.vendors,
    );
    final followUpBrief = buildCompanyGovernanceCommandBrief(
      selectedView: followUpsDueView,
      actions: actions,
      followUpLanes: handoffCadence,
    );
    expect(
      followUpBrief.intent,
      CompanyGovernanceCommandBriefIntent.recordFollowUp,
    );
    expect(followUpBrief.ownerLabel, 'People Operations');
    expect(followUpBrief.dueFollowUpCount, 1);
    expect(followUpBrief.primaryFollowUpLane, isNotNull);
    expect(followUpBrief.headline, contains('Follow up'));

    final criticalBrief = buildCompanyGovernanceCommandBrief(
      selectedView: selectedCompanyGovernanceSavedView(
        views: savedViews,
        selectedType: CompanyGovernanceSavedViewType.criticalActions,
      ),
      actions: actions,
      followUpLanes: handoffCadence,
    );
    expect(
      criticalBrief.intent,
      CompanyGovernanceCommandBriefIntent.resolveAction,
    );
    expect(criticalBrief.visibleActionCount, 1);
    expect(criticalBrief.criticalActionCount, 1);
    expect(criticalBrief.primaryAction?.title, 'Annual WLK labor report');
    final customPolicyDraft = CompanyGovernanceFollowUpPolicyDraft.fromPolicy(
      customFollowUpPolicy,
    );
    expect(customPolicyDraft.toPolicy(), customFollowUpPolicy);
    expect(
      () => customPolicyDraft.copyWith(criticalCadenceDaysText: '0').toPolicy(),
      throwsStateError,
    );
    expect(
      CompanyGovernanceFollowUpPolicyDraft.validateCadenceDays('31', 'High'),
      'High cadence must be between 1 and 30 days',
    );
    final policyImpact = buildCompanyGovernanceFollowUpPolicyImpact(
      currentPolicy: CompanyGovernanceFollowUpPolicy.defaultPolicy,
      draft: customPolicyDraft,
      loads: ownerLoads,
      handoffRecords: [handoffRecord.copyWith(auditEventId: 'audit-handoff')],
      auditEvents: const [],
      asOfDate: cadenceAsOfDate,
    );
    expect(policyImpact.isValid, isTrue);
    expect(policyImpact.changedLaneCount, 1);
    expect(policyImpact.dueNowCount, 0);
    expect(policyImpact.headline, '1 lane shifts timing');
    expect(policyImpact.changedLanes.single.ownerName, 'People Operations');
    expect(policyImpact.changedLanes.single.previewTouchLabel, 'Due tomorrow');
    final policyApproval =
        CompanyGovernanceFollowUpPolicyApprovalRequest.create(
          id: 'governance-sla-approval-001',
          previousPolicy: CompanyGovernanceFollowUpPolicy.defaultPolicy,
          requestedPolicy: customFollowUpPolicy,
          impact: policyImpact,
          entityName: 'PT Kaysir Nusantara',
          requestedBy: 'People Operations',
          requestedAt: cadenceAsOfDate,
        );
    expect(policyApproval.status.label, 'Pending approval');
    expect(policyApproval.requestedDateLabel, '2026-06-12');
    expect(policyApproval.policyChangeLabel, contains('Critical 1d'));
    expect(policyApproval.topChangeLabel, contains('People Operations'));
    expect(policyApproval.isStaleAgainst(customFollowUpPolicy), isTrue);
    final approvedPolicyApproval = policyApproval.approve(
      decidedBy: 'Legal Operations',
      decidedAt: cadenceAsOfDate,
      auditEventId: 'audit-sla',
    );
    expect(
      approvedPolicyApproval.status,
      CompanyGovernanceFollowUpPolicyApprovalStatus.approved,
    );
    expect(approvedPolicyApproval.hasAuditEvent, isTrue);
    final approvalQueue = CompanyGovernanceFollowUpPolicyApprovalQueue(
      records: [approvedPolicyApproval, policyApproval],
    );
    expect(approvalQueue.pendingCount, 1);
    expect(approvalQueue.approvedCount, 1);
    expect(approvalQueue.latestPending?.id, policyApproval.id);
    final policyAuditPayload =
        CompanyGovernanceFollowUpPolicyAuditPayload.fromChange(
          previousPolicy: CompanyGovernanceFollowUpPolicy.defaultPolicy,
          nextPolicy: customFollowUpPolicy,
          impact: policyImpact,
          entityName: 'PT Kaysir Nusantara',
        );
    expect(policyAuditPayload.documentId, 'governance-follow-up-sla');
    expect(policyAuditPayload.documentTitle, 'Governance Follow-up SLA policy');
    expect(policyAuditPayload.correlationId, 'governance-follow-up-sla');
    expect(policyAuditPayload.note, contains('critical 1d -> 3d'));
    expect(policyAuditPayload.note, contains('1 lane shifts timing'));
    expect(policyAuditPayload.note, contains('People Operations moves from'));
    expect(
      CompanyDocumentAuditEventType.governanceFollowUpPolicyChanged.label,
      'Governance SLA changed',
    );
    final policyChangeRecord =
        CompanyGovernanceFollowUpPolicyChangeRecord.fromChange(
          id: 'governance-sla-001',
          previousPolicy: CompanyGovernanceFollowUpPolicy.defaultPolicy,
          nextPolicy: customFollowUpPolicy,
          impact: policyImpact,
          entityName: 'PT Kaysir Nusantara',
          actorName: 'People Operations',
          recordedAt: cadenceAsOfDate,
        );
    expect(policyChangeRecord.recordedDateLabel, '2026-06-12');
    expect(policyChangeRecord.policyChangeLabel, contains('Critical 1d'));
    expect(policyChangeRecord.topChangeLabel, contains('People Operations'));
    expect(policyChangeRecord.hasAuditEvent, isFalse);
    final auditedPolicyChangeRecord = policyChangeRecord.copyWith(
      auditEventId: 'audit-sla',
    );
    expect(auditedPolicyChangeRecord.hasAuditEvent, isTrue);
    final policyHistory = CompanyGovernanceFollowUpPolicyHistory(
      records: [auditedPolicyChangeRecord],
    );
    expect(policyHistory.recordCount, 1);
    expect(policyHistory.auditedCount, 1);
    expect(policyHistory.latestLabel, '2026-06-12');

    final invalidPolicyImpact = buildCompanyGovernanceFollowUpPolicyImpact(
      currentPolicy: CompanyGovernanceFollowUpPolicy.defaultPolicy,
      draft: customPolicyDraft.copyWith(highCadenceDaysText: '31'),
      loads: ownerLoads,
      handoffRecords: [handoffRecord],
      auditEvents: const [],
      asOfDate: cadenceAsOfDate,
    );
    expect(invalidPolicyImpact.isValid, isFalse);
    expect(invalidPolicyImpact.headline, 'Fix SLA values');
    expect(
      invalidPolicyImpact.validationMessage,
      'High cadence must be between 1 and 30 days',
    );
    final legalHandoffRecord = CompanyGovernanceOwnerHandoffRecord(
      id: 'handoff-002',
      ownerName: 'Legal Operations',
      actionCount: 1,
      criticalCount: 0,
      highCount: 1,
      sourceSummary: '1 vendor agreement',
      nextDueLabel: 'Contract ends in 12d',
      message:
          'Legal Operations has 1 governance action across 1 vendor agreement.',
      recordedAt: asOfDate.add(const Duration(days: 1)),
      actorName: 'People Operations',
    );
    final handoffHistory = CompanyGovernanceOwnerHandoffHistory.fromRecords(
      records: [handoffRecord, legalHandoffRecord],
    );
    expect(handoffHistory.records.map((record) => record.id), [
      'handoff-002',
      'handoff-001',
    ]);
    expect(handoffHistory.recordCount, 2);
    expect(handoffHistory.ownerCount, 2);
    expect(handoffHistory.criticalCount, 1);
    expect(handoffHistory.highCount, 2);
    expect(handoffHistory.latestLabel, '2026-06-11');
    expect(handoffHistory.matchingRecordCount('people operations'), 1);
    expect(
      handoffHistory.prioritizedRecords('people operations').first.id,
      'handoff-001',
    );
    expect(
      latestCompanyGovernanceOwnerHandoffRecord(
        records: [handoffRecord],
        ownerName: 'people operations',
      )?.id,
      'handoff-001',
    );
    expect(
      buildCompanyGovernanceOwnerHandoff(
        items: actions,
        ownerName: 'Unknown Owner',
      ),
      isNull,
    );

    final vendorAction = actions.singleWhere(
      (item) => item.source == CompanyGovernanceActionSource.vendorAgreement,
    );
    expect(
      vendorAction.resolution,
      CompanyGovernanceActionResolution.closeVendorImplementation,
    );

    final limitedActions = buildCompanyGovernanceActionItems(
      filings: const [],
      employerAccounts: const [],
      vendorAgreements: const [],
      signatories: [
        for (var i = 0; i < 3; i++)
          CompanySignatory(
            id: 'signatory-$i',
            personName: 'Signer $i',
            title: 'Director',
            entityName: 'PT Kaysir Nusantara',
            scope: CompanySignatoryScope.legalDocument,
            authorityLevel: CompanySignatoryAuthorityLevel.signer,
            status: CompanySignatoryStatus.expired,
            effectiveDate: DateTime(2025, 1, 1),
            expiryDate: DateTime(2026, 5, 1),
            backupSignerName: '',
            evidenceSummary: '',
            delegationNotes: '',
          ),
      ],
      asOfDate: asOfDate,
      limit: 2,
    );
    expect(limitedActions, hasLength(2));
  });

  test('employee document workload digest statuses read audit history', () {
    final employeeDocumentGaps = buildCompanyEmployeeDocumentGaps(
      subjects: companySeedEmployeeDocumentSubjects,
      requirements: companySeedDocumentRequirements,
      evidenceSnapshots: _employeeEvidenceSnapshots,
      asOfDate: companySeedAsOfDate,
    );
    final recommendations = buildCompanyEmployeeDocumentGapRecommendations(
      gaps: employeeDocumentGaps,
      asOfDate: companySeedAsOfDate,
    );
    final workloads = buildCompanyEmployeeDocumentWorkloads(
      gaps: employeeDocumentGaps,
      recommendations: recommendations,
      asOfDate: companySeedAsOfDate,
    );

    final statuses = buildCompanyEmployeeDocumentWorkloadDigestStatuses(
      workloads: workloads,
      auditEvents: [
        CompanyDocumentAuditEvent(
          id: 'audit-fajar-old',
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            'Fajar Prakoso',
          ),
          documentTitle: 'Fajar Prakoso - Employee document workload',
          entityName: 'PT Kaysir Nusantara',
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerDigestSent,
          happenedAt: companySeedAsOfDate.subtract(const Duration(days: 2)),
          note: 'Old digest',
          correlationId: companyEmployeeDocumentOwnerDigestCorrelationId(
            'Fajar Prakoso',
          ),
        ),
        CompanyDocumentAuditEvent(
          id: 'audit-fajar-new',
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            'Fajar Prakoso',
          ),
          documentTitle: 'Fajar Prakoso - Employee document workload',
          entityName: 'PT Kaysir Nusantara',
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerDigestSent,
          happenedAt: companySeedAsOfDate,
          note: 'Latest digest',
          correlationId: companyEmployeeDocumentOwnerDigestCorrelationId(
            'Fajar Prakoso',
          ),
        ),
      ],
    );

    final fajar = statuses.singleWhere(
      (status) => status.ownerName == 'Fajar Prakoso',
    );
    final fajarWorkload = workloads.singleWhere(
      (workload) => workload.ownerName == 'Fajar Prakoso',
    );
    expect(fajar.hasDigest, isTrue);
    expect(fajar.digestCount, 2);
    expect(fajar.lastAuditEventId, 'audit-fajar-new');
    expect(fajar.label(companySeedAsOfDate), 'Sent today');
    expect(fajar.cadenceLabel(fajarWorkload), 'Daily');
    expect(
      fajar.isDueFor(workload: fajarWorkload, asOfDate: companySeedAsOfDate),
      isFalse,
    );
    expect(
      fajar.freshnessLabel(
        workload: fajarWorkload,
        asOfDate: companySeedAsOfDate,
      ),
      'Due tomorrow',
    );
    expect(
      fajar.isDueFor(
        workload: fajarWorkload,
        asOfDate: companySeedAsOfDate.add(const Duration(days: 1)),
      ),
      isTrue,
    );

    final dewi = statuses.singleWhere(
      (status) => status.ownerName == 'Dewi Lestari',
    );
    final dewiWorkload = workloads.singleWhere(
      (workload) => workload.ownerName == 'Dewi Lestari',
    );
    expect(dewi.hasDigest, isFalse);
    expect(dewi.label(companySeedAsOfDate), 'Not sent yet');
    expect(dewi.cadenceLabel(dewiWorkload), 'Daily');
    expect(
      dewi.isDueFor(workload: dewiWorkload, asOfDate: companySeedAsOfDate),
      isTrue,
    );
    expect(
      dewi.freshnessLabel(
        workload: dewiWorkload,
        asOfDate: companySeedAsOfDate,
      ),
      'Digest due',
    );
  });

  test('employee document digest history summarizes recent audit events', () {
    final employeeDocumentGaps = buildCompanyEmployeeDocumentGaps(
      subjects: companySeedEmployeeDocumentSubjects,
      requirements: companySeedDocumentRequirements,
      evidenceSnapshots: _employeeEvidenceSnapshots,
      asOfDate: companySeedAsOfDate,
    );
    final recommendations = buildCompanyEmployeeDocumentGapRecommendations(
      gaps: employeeDocumentGaps,
      asOfDate: companySeedAsOfDate,
    );
    final workloads = buildCompanyEmployeeDocumentWorkloads(
      gaps: employeeDocumentGaps,
      recommendations: recommendations,
      asOfDate: companySeedAsOfDate,
    );

    final history = buildEmployeeDocumentDigestHistory(
      workloads: workloads,
      limit: 2,
      auditEvents: [
        CompanyDocumentAuditEvent(
          id: 'audit-created',
          documentId: 'doc-1',
          documentTitle: 'Company registration',
          entityName: 'PT Kaysir Nusantara',
          actorName: 'Legal Operations',
          type: CompanyDocumentAuditEventType.created,
          happenedAt: companySeedAsOfDate,
          note: 'Document created',
        ),
        CompanyDocumentAuditEvent(
          id: 'audit-fajar-old',
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            'Fajar Prakoso',
          ),
          documentTitle: 'Fajar Prakoso - Employee document workload',
          entityName: 'PT Kaysir Nusantara',
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerDigestSent,
          happenedAt: companySeedAsOfDate.subtract(const Duration(days: 2)),
          note: 'Old digest',
          correlationId: companyEmployeeDocumentOwnerDigestCorrelationId(
            'Fajar Prakoso',
          ),
        ),
        CompanyDocumentAuditEvent(
          id: 'audit-dewi-new',
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            'Dewi Lestari',
          ),
          documentTitle: 'Dewi Lestari - Employee document workload',
          entityName: 'Kaysir Retail Services',
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerDigestSent,
          happenedAt: companySeedAsOfDate,
          note: 'Latest digest',
          correlationId: companyEmployeeDocumentOwnerDigestCorrelationId(
            'Dewi Lestari',
          ),
        ),
      ],
    );

    expect(history.totalDigestCount, 2);
    expect(history.ownerCount, 2);
    expect(history.latestLabel(companySeedAsOfDate), 'Sent today');
    expect(history.items, hasLength(2));
    expect(history.items.first.auditEventId, 'audit-dewi-new');
    expect(history.items.first.ownerName, 'Dewi Lestari');
    expect(history.items.last.sentLabel(companySeedAsOfDate), 'Sent 2d ago');
  });

  test('employee document digest preview summarizes selected owner lanes', () {
    final employeeDocumentGaps = buildCompanyEmployeeDocumentGaps(
      subjects: companySeedEmployeeDocumentSubjects,
      requirements: companySeedDocumentRequirements,
      evidenceSnapshots: _employeeEvidenceSnapshots,
      asOfDate: companySeedAsOfDate,
    );
    final recommendations = buildCompanyEmployeeDocumentGapRecommendations(
      gaps: employeeDocumentGaps,
      asOfDate: companySeedAsOfDate,
    );
    final workloads = buildCompanyEmployeeDocumentWorkloads(
      gaps: employeeDocumentGaps,
      recommendations: recommendations,
      asOfDate: companySeedAsOfDate,
    );
    final statuses = buildCompanyEmployeeDocumentWorkloadDigestStatuses(
      workloads: workloads,
      auditEvents: const [],
    );

    final preview = buildEmployeeDocumentDigestPreview(
      ownerNames: const [
        'Fajar Prakoso',
        'Unknown Owner',
        'fajar prakoso',
        'People Operations',
      ],
      workloads: workloads,
      digestStatuses: statuses,
      asOfDate: companySeedAsOfDate,
    );

    expect(preview.ownerNames, ['Fajar Prakoso', 'People Operations']);
    expect(preview.ownerCount, 2);
    expect(preview.gapCount, 3);
    expect(preview.missingDocumentCount, 15);
    expect(preview.openRequestCount, 3);
    expect(preview.escalationCount, 1);
    expect(preview.owners.first.isDue, isTrue);
    expect(
      preview.owners.first.primarySummary,
      'Review rejected evidence for David Kim',
    );
    expect(preview.owners.last.cadenceLabel, 'Every 3d');
  });

  test('profile draft trims data and rejects incomplete submissions', () {
    final draft = CompanyProfileDraft.fromProfile(
      companySeedProfile,
    ).copyWith(legalName: ' PT Kaysir Global ', employeeCountText: '120');
    final profile = draft.toProfile('company-kaysir');

    expect(profile.legalName, 'PT Kaysir Global');
    expect(profile.employeeCount, 120);

    final invalidDraft = draft.copyWith(taxId: '');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toProfile('company-kaysir'),
      throwsA(isA<StateError>()),
    );
  });

  test('legal entity and work location drafts normalize submissions', () {
    final entityDraft = CompanyLegalEntityDraft.empty().copyWith(
      name: ' Kaysir Labs ',
      registrationNumber: 'LAB-001',
      taxId: '11.222.333.4-555.000',
      city: 'Jakarta',
      hrOwner: 'Maya Pratiwi',
      status: CompanyLegalEntityStatus.verified,
    );
    final entity = entityDraft.toLegalEntity('entity-labs');

    expect(entity.name, 'Kaysir Labs');
    expect(entity.requiresAttention, isFalse);

    final locationDraft = CompanyWorkLocationDraft.empty(
      entityName: entity.name,
    ).copyWith(
      name: ' Labs Studio ',
      city: 'Jakarta',
      region: 'Java West',
      address: 'Jl. Senopati No. 8',
      coverageOwner: 'Maya Pratiwi',
      capacityText: '16',
      assignedHeadcountText: '12',
      status: CompanyWorkLocationStatus.open,
    );
    final location = locationDraft.toLocation('loc-labs');

    expect(location.name, 'Labs Studio');
    expect(location.entityName, 'Kaysir Labs');
    expect(location.requiresAttention, isFalse);
  });

  test('cost center and approval rule drafts normalize submissions', () {
    final centerDraft = CompanyCostCenterDraft.empty().copyWith(
      code: ' cc-labs ',
      name: ' Labs Budget ',
      orgUnitName: 'Product & Commerce',
      ownerName: 'Maya Pratiwi',
      annualBudgetText: '900000000',
      allocatedHeadcountText: '8',
      activeHeadcountText: '6',
      status: CompanyCostCenterStatus.active,
    );
    final center = centerDraft.toCostCenter('cc-labs');

    expect(center.code, 'CC-LABS');
    expect(center.name, 'Labs Budget');
    expect(center.requiresAttention, isFalse);

    final ruleDraft = CompanyApprovalRuleDraft.empty().copyWith(
      domain: CompanyApprovalDomain.policy,
      scopeName: 'Product & Commerce',
      approverRole: 'Head of Product',
      backupApproverRole: 'Head of People',
      thresholdLabel: 'All policy changes',
      slaHoursText: '24',
      status: CompanyApprovalRuleStatus.active,
    );
    final rule = ruleDraft.toApprovalRule('approval-policy');

    expect(rule.domain, CompanyApprovalDomain.policy);
    expect(rule.scopeName, 'Product & Commerce');
    expect(rule.requiresAttention, isFalse);
  });

  test('position control draft normalizes authorized seats', () {
    final draft = CompanyPositionControlDraft.empty().copyWith(
      positionTitle: ' People Partner ',
      orgUnitName: 'People Operations',
      ownerName: 'Maya Pratiwi',
      authorizedSeatsText: '2',
      filledSeatsText: '1',
      fteText: '1',
      compensationBand: 'HR-4',
      nextReviewDateText: '2026-09-15',
      hiringPlan: 'Backfill after entity launch',
      linkedRequisition: 'REQ-LABS-2026-01',
    );
    final position = draft.toPositionControl('position-labs-people');

    expect(position.positionTitle, 'People Partner');
    expect(position.availableSeats, 1);
    expect(position.daysUntilReview(companySeedAsOfDate), 104);
    expect(position.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(fteText: '0');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toPositionControl('position-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('headcount requisition draft normalizes hiring intake', () {
    final draft = CompanyHeadcountRequisitionDraft.empty(
      orgUnitName: 'Product & Commerce',
    ).copyWith(
      roleTitle: ' Product Engineer ',
      hiringManagerName: ' Fajar Prakoso ',
      positionControlId: 'position-product-engineer',
      jobProfileCode: ' eng-jp-04 ',
      costCenterCode: ' cc-prod ',
      priority: CompanyHeadcountRequisitionPriority.high,
      requestedSeatsText: '2',
      targetStartDateText: '2026-07-01',
      businessCase: 'Add delivery capacity',
      budgetImpact: 'Uses product hiring plan',
      approverRole: 'Head of Product',
    );
    final requisition = draft.toRequisition('hreq-product');

    expect(requisition.roleTitle, 'Product Engineer');
    expect(requisition.jobProfileCode, 'ENG-JP-04');
    expect(requisition.costCenterCode, 'CC-PROD');
    expect(requisition.requestedSeats, 2);
    expect(requisition.daysUntilTargetStart(companySeedAsOfDate), 28);
    expect(
      requisition.issues(companySeedAsOfDate),
      contains(CompanyHeadcountRequisitionIssue.awaitingApproval),
    );

    final invalidDraft = draft.copyWith(requestedSeatsText: '0');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toRequisition('hreq-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('headcount requisition activity timeline sorts recent events', () {
    final requisition = CompanyHeadcountRequisitionDraft.empty(
          orgUnitName: 'Product & Commerce',
        )
        .copyWith(
          roleTitle: 'Product Engineer',
          hiringManagerName: 'Fajar Prakoso',
          jobProfileCode: 'ENG-JP-04',
          costCenterCode: 'CC-PROD',
          requestedSeatsText: '2',
          targetStartDateText: '2026-07-01',
          businessCase: 'Add delivery capacity',
          budgetImpact: 'Uses product hiring plan',
          approverRole: 'Head of Product',
        )
        .toRequisition('hreq-product');
    final submitted = CompanyHeadcountRequisitionActivityRecord.fromRequisition(
      id: 'activity-001',
      requisition: requisition,
      type: CompanyHeadcountRequisitionActivityType.submitted,
      happenedAt: DateTime(2026, 6),
    );
    final approved = CompanyHeadcountRequisitionActivityRecord.fromRequisition(
      id: 'activity-002',
      requisition: requisition,
      type: CompanyHeadcountRequisitionActivityType.approved,
      happenedAt: DateTime(2026, 6, 2),
      actorName: 'Head of Product',
      note: 'Approved two seats',
    );
    final timeline = CompanyHeadcountRequisitionActivityTimeline(
      records: [submitted, approved],
    );

    expect(timeline.submittedCount, 1);
    expect(timeline.approvalCount, 1);
    expect(timeline.recentRecords.first.id, 'activity-002');
    expect(approved.happenedAtLabel, '2026-06-02');
    expect(approved.note, 'Approved two seats');
  });

  test('workforce plan ranks headcount approval demand', () {
    final plan = buildCompanyWorkforcePlan(
      positions: companySeedPositionControls,
      costCenters: companySeedCostCenters,
      compensationBands: companySeedCompensationBands,
      jobProfiles: companySeedJobProfiles,
      asOfDate: companySeedAsOfDate,
    );

    expect(plan.items, hasLength(companySeedPositionControls.length));
    expect(plan.openSeatCount, 4);
    expect(plan.overfilledSeatCount, 1);
    expect(plan.pendingApprovalCount, 1);
    expect(plan.recruitingCount, 1);
    expect(plan.frozenCount, 1);
    expect(plan.actionableCount, greaterThanOrEqualTo(4));

    final topItem = plan.priorityItems.first;
    expect(topItem.title, 'Retail Supervisor');
    expect(topItem.risk, CompanyWorkforcePlanRisk.critical);
    expect(topItem.action, CompanyWorkforcePlanAction.approvePosition);
    expect(topItem.overfilledSeats, 1);
    expect(topItem.costCenterLabel, contains('CC-OPS'));
    expect(topItem.hasBudgetRisk, isTrue);
    expect(topItem.hasArchitectureRisk, isTrue);

    final recruitingItem = plan.items.singleWhere(
      (item) => item.position.id == 'position-product-engineer',
    );
    expect(recruitingItem.action, CompanyWorkforcePlanAction.closeRecruiting);
    expect(recruitingItem.openSeats, 2);
  });

  test('compensation band draft normalizes salary architecture', () {
    final draft = CompanyCompensationBandDraft.empty().copyWith(
      bandCode: ' lab-4 ',
      family: CompanyCompensationBandFamily.people,
      levelName: 'Labs Partner',
      minSalaryText: '180000000',
      midpointSalaryText: '220000000',
      maxSalaryText: '260000000',
      currency: 'idr',
      ownerName: 'Maya Pratiwi',
      approverName: 'Head of People',
      effectiveDateText: '2026-07-01',
      nextReviewDateText: '2026-10-01',
      linkedPolicy: 'Labs compensation policy',
    );
    final band = draft.toBand('band-lab-4');

    expect(band.bandCode, 'LAB-4');
    expect(band.currency, 'IDR');
    expect(band.hasValidRange, isTrue);
    expect(band.daysUntilReview(companySeedAsOfDate), 120);
    expect(band.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(maxSalaryText: '170000000');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toBand('band-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('contract template draft normalizes legal template readiness', () {
    final draft = CompanyContractTemplateDraft.empty().copyWith(
      templateName: ' Labs permanent agreement ',
      entityName: 'PT Kaysir Labs',
      type: CompanyContractTemplateType.permanentEmployment,
      status: CompanyContractTemplateStatus.active,
      jobProfileCode: ' lab-jp-04 ',
      compensationBand: ' lab-4 ',
      ownerName: 'Maya Pratiwi',
      legalReviewerName: 'Sari Wibowo',
      signatoryRole: 'Head of People',
      language: 'Bahasa Indonesia',
      versionLabel: '2026.1',
      nextReviewDateText: '2026-10-30',
      clauseSummary:
          'Permanent employment, probation, confidentiality, payroll, and benefits clauses approved.',
      onboardingChecklist: 'Identity, tax ID, BPJS, bank account',
    );
    final template = draft.toContractTemplate('contract-labs');

    expect(template.templateName, 'Labs permanent agreement');
    expect(template.jobProfileCode, 'LAB-JP-04');
    expect(template.compensationBand, 'LAB-4');
    expect(template.daysUntilReview(companySeedAsOfDate), 149);
    expect(template.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(legalReviewerName: '');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toContractTemplate('contract-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('onboarding pack draft normalizes preboarding readiness', () {
    final draft = CompanyOnboardingPackDraft.empty().copyWith(
      packName: ' Labs onboarding pack ',
      entityName: 'PT Kaysir Labs',
      type: CompanyOnboardingPackType.onboarding,
      status: CompanyOnboardingPackStatus.active,
      jobProfileCode: ' lab-jp-04 ',
      contractTemplateName: 'Labs permanent agreement',
      ownerName: 'Maya Pratiwi',
      managerHandoff: 'Manager kickoff and probation plan',
      documentChecklist: 'Identity, tax ID, BPJS, signed contract',
      accessChecklist: 'HRIS, email, payroll, document vault',
      equipmentChecklist: 'Laptop, headset, badge',
      requiredTaskCountText: '12',
      automationCoverageText: '75',
      slaDaysText: '7',
      nextReviewDateText: '2026-10-30',
      notes: 'Ready for Labs launch hiring',
    );
    final pack = draft.toOnboardingPack('onboarding-labs');

    expect(pack.packName, 'Labs onboarding pack');
    expect(pack.jobProfileCode, 'LAB-JP-04');
    expect(pack.requiredTaskCount, 12);
    expect(pack.automationCoveragePercent, 75);
    expect(pack.daysUntilReview(companySeedAsOfDate), 149);
    expect(pack.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(automationCoverageText: '120');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toOnboardingPack('onboarding-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('probation plan draft normalizes milestone readiness', () {
    final draft = CompanyProbationPlanDraft.empty().copyWith(
      planName: ' Labs probation plan ',
      entityName: 'PT Kaysir Labs',
      type: CompanyProbationPlanType.probation,
      status: CompanyProbationPlanStatus.active,
      jobProfileCode: ' lab-jp-04 ',
      onboardingPackName: 'Labs onboarding pack',
      ownerName: 'Maya Pratiwi',
      managerRole: 'Labs Manager',
      reviewCadenceDaysText: '30',
      checkpointCountText: '3',
      firstReviewDueDaysText: '30',
      finalDecisionDueDaysText: '90',
      nextReviewDateText: '2026-10-30',
      successCriteria: 'Role delivery, conduct, manager feedback',
      feedbackTemplate: 'Manager scorecard and checkpoint notes',
      notes: 'Ready for Labs hiring',
    );
    final plan = draft.toProbationPlan('probation-labs');

    expect(plan.planName, 'Labs probation plan');
    expect(plan.jobProfileCode, 'LAB-JP-04');
    expect(plan.reviewCadenceDays, 30);
    expect(plan.checkpointCount, 3);
    expect(plan.daysUntilReview(companySeedAsOfDate), 149);
    expect(plan.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(finalDecisionDueDaysText: '20');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toProbationPlan('probation-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('offboarding pack draft normalizes exit workflow readiness', () {
    final draft = CompanyOffboardingPackDraft.empty().copyWith(
      packName: ' Labs offboarding pack ',
      entityName: 'PT Kaysir Labs',
      type: CompanyOffboardingPackType.resignation,
      status: CompanyOffboardingPackStatus.active,
      jobProfileCode: ' lab-jp-04 ',
      ownerName: 'Maya Pratiwi',
      managerRole: 'Labs Manager',
      knowledgeTransferPlan: 'Project handover and manager notes',
      assetReturnChecklist: 'Laptop, badge, headset',
      accessRevocationChecklist: 'HRIS, email, repository, payroll',
      finalPayrollChecklist: 'Final salary, leave payout, expenses',
      documentChecklist: 'Clearance form and certificate',
      exitInterviewTemplate: 'Exit interview scorecard',
      requiredTaskCountText: '14',
      slaDaysText: '7',
      nextReviewDateText: '2026-10-30',
      notes: 'Ready for Labs exits',
    );
    final pack = draft.toOffboardingPack('offboarding-labs');

    expect(pack.packName, 'Labs offboarding pack');
    expect(pack.jobProfileCode, 'LAB-JP-04');
    expect(pack.requiredTaskCount, 14);
    expect(pack.slaDays, 7);
    expect(pack.daysUntilReview(companySeedAsOfDate), 149);
    expect(pack.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(finalPayrollChecklist: '');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toOffboardingPack('offboarding-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('document requirement draft normalizes lifecycle evidence rules', () {
    final draft = CompanyDocumentRequirementDraft.empty().copyWith(
      requirementName: ' Labs document matrix ',
      entityName: 'PT Kaysir Labs',
      stage: CompanyDocumentRequirementStage.preboarding,
      status: CompanyDocumentRequirementStatus.active,
      jobProfileCode: ' lab-jp-04 ',
      contractTemplateName: 'Labs permanent agreement',
      onboardingPackName: 'Labs onboarding pack',
      ownerName: 'Maya Pratiwi',
      evidenceOwnerName: 'People Operations',
      policyReference: 'Labs document policy',
      collectionChannel: 'HRIS document vault',
      storageLocation: 'Document vault / Labs',
      retentionRule: 'Employment period + 5 years',
      requiredDocumentCountText: '10',
      nextReviewDateText: '2026-10-30',
      notes: 'Ready for Labs employee evidence collection',
    );
    final requirement = draft.toDocumentRequirement('docreq-labs');

    expect(requirement.requirementName, 'Labs document matrix');
    expect(requirement.jobProfileCode, 'LAB-JP-04');
    expect(requirement.requiredDocumentCount, 10);
    expect(requirement.daysUntilReview(companySeedAsOfDate), 149);
    expect(requirement.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(onboardingPackName: '');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toDocumentRequirement('docreq-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('employee document gap builder connects requirements to evidence', () {
    final gaps = buildCompanyEmployeeDocumentGaps(
      subjects: companySeedEmployeeDocumentSubjects,
      requirements: companySeedDocumentRequirements,
      evidenceSnapshots: _employeeEvidenceSnapshots,
      asOfDate: companySeedAsOfDate,
    );
    final olivia = gaps.singleWhere(
      (gap) => gap.id == 'empdoc-olivia-preboarding',
    );
    final emma = gaps.singleWhere((gap) => gap.id == 'empdoc-emma-offboarding');

    expect(gaps, hasLength(5));
    expect(
      olivia.requirementName,
      'People Partner preboarding document matrix',
    );
    expect(olivia.status, CompanyEmployeeDocumentGapStatus.requested);
    expect(olivia.missingDocumentCount, 6);
    expect(olivia.daysUntilDue(companySeedAsOfDate), 2);
    expect(olivia.issues(companySeedAsOfDate), [
      CompanyEmployeeDocumentGapIssue.insufficientVerifiedDocuments,
      CompanyEmployeeDocumentGapIssue.dueSoon,
    ]);
    expect(emma.status, CompanyEmployeeDocumentGapStatus.blocked);
    expect(
      emma.issues(companySeedAsOfDate),
      contains(CompanyEmployeeDocumentGapIssue.overdue),
    );
  });

  test(
    'company document draft and expiry checks normalize compliance data',
    () {
      final draft = CompanyDocumentDraft.empty().copyWith(
        title: ' Retail permit ',
        documentNumber: ' SITU-2026-991 ',
        entityName: 'Kaysir Retail Services',
        ownerName: 'Dewi Lestari',
        type: CompanyDocumentType.registration,
        issuedDateText: '2026-01-10',
        expiryDateText: '2026-06-20',
        status: CompanyDocumentStatus.expiringSoon,
        linkedModule: 'Attendance',
      );
      final document = draft.toDocument('doc-retail');

      expect(document.title, 'Retail permit');
      expect(document.documentNumber, 'SITU-2026-991');
      expect(document.daysUntilExpiry(companySeedAsOfDate), 17);
      expect(document.issues(companySeedAsOfDate), [
        CompanyDocumentIssue.expiringSoon,
      ]);

      final invalidDraft = draft.copyWith(expiryDateText: '20-06-2026');
      expect(invalidDraft.isReady, isFalse);
      expect(
        () => invalidDraft.toDocument('doc-invalid'),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('document renewal draft highlights due-soon governance tasks', () {
    final draft = CompanyDocumentRenewalDraft.empty().copyWith(
      documentId: 'doc-retail-permit',
      documentTitle: ' Retail operating permit ',
      entityName: 'Kaysir Retail Services',
      ownerName: 'Dewi Lestari',
      dueDateText: '2026-06-20',
      reminderLeadDaysText: '30',
      status: CompanyDocumentRenewalStatus.inProgress,
      actionLabel: ' Collect renewal receipt ',
    );
    final task = draft.toRenewalTask('renewal-retail');

    expect(task.documentTitle, 'Retail operating permit');
    expect(task.daysUntilDue(companySeedAsOfDate), 17);
    expect(task.issues(companySeedAsOfDate), [
      CompanyDocumentRenewalIssue.dueSoon,
    ]);

    final invalidDraft = draft.copyWith(dueDateText: 'June 20');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toRenewalTask('renewal-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('operating readiness draft normalizes service enablement data', () {
    final draft = CompanyOperatingReadinessDraft.empty().copyWith(
      area: CompanyOperatingReadinessArea.leave,
      entityName: 'Kaysir Retail Services',
      ownerName: 'Dewi Lestari',
      status: CompanyOperatingReadinessStatus.ready,
      coveragePercentText: '96',
      lastReviewDateText: '2026-05-28',
      nextReviewDateText: '2026-07-01',
      linkedModule: 'Leave',
    );
    final item = draft.toReadinessItem('ops-leave-retail');

    expect(item.area, CompanyOperatingReadinessArea.leave);
    expect(item.coveragePercent, 96);
    expect(item.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(coveragePercentText: '120');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toReadinessItem('ops-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('change request draft normalizes effective-dated changes', () {
    final draft = CompanyChangeRequestDraft.empty().copyWith(
      title: ' Retail go-live ',
      entityName: 'Kaysir Retail Services',
      ownerName: 'Dewi Lestari',
      type: CompanyChangeRequestType.workLocation,
      priority: CompanyChangeRequestPriority.high,
      status: CompanyChangeRequestStatus.awaitingApproval,
      effectiveDateText: '2026-06-18',
      impactSummary: ' Enable attendance and payroll coverage ',
      approverRole: 'Head of People',
      linkedRecord: 'Bandung South Retail',
    );
    final request = draft.toChangeRequest('change-retail');

    expect(request.title, 'Retail go-live');
    expect(request.daysUntilEffective(companySeedAsOfDate), 15);
    expect(request.issues(companySeedAsOfDate), [
      CompanyChangeRequestIssue.awaitingApproval,
    ]);

    final invalidDraft = draft.copyWith(effectiveDateText: '18 June');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toChangeRequest('change-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('governance contact draft normalizes ownership coverage', () {
    final draft = CompanyGovernanceContactDraft.empty().copyWith(
      entityName: 'Kaysir Retail Services',
      role: CompanyGovernanceRole.branchOwner,
      personName: ' Dewi Lestari ',
      title: 'Retail Operations Lead',
      email: 'dewi@kaysir.id',
      phone: '+62 812 4400 2200',
      backupName: 'Nadia Safitri',
      escalationChannel: 'Retail Operations',
      lastReviewedAtText: '2026-05-21',
      nextReviewAtText: '2026-07-20',
    );
    final contact = draft.toContact('contact-retail');

    expect(contact.personName, 'Dewi Lestari');
    expect(contact.role, CompanyGovernanceRole.branchOwner);
    expect(contact.daysUntilReview(companySeedAsOfDate), 47);
    expect(contact.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(email: 'dewi');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toContact('contact-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('entity lifecycle draft normalizes launch milestones', () {
    final draft = CompanyEntityLifecycleDraft.empty().copyWith(
      title: ' Retail outlet launch ',
      entityName: 'Kaysir Retail Services',
      type: CompanyEntityLifecycleType.branchOpening,
      status: CompanyEntityLifecycleStatus.inProgress,
      ownerName: 'Dewi Lestari',
      targetDateText: '2026-06-18',
      progressPercentText: '72',
      dependencySummary: 'Retail permit and attendance policy',
      nextMilestone: 'Confirm payroll go-live',
    );
    final milestone = draft.toLifecycleMilestone('lifecycle-retail');

    expect(milestone.title, 'Retail outlet launch');
    expect(milestone.daysUntilTarget(companySeedAsOfDate), 15);
    expect(milestone.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(progressPercentText: '125');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toLifecycleMilestone('lifecycle-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('company control draft normalizes auditable controls', () {
    final draft = CompanyControlDraft.empty().copyWith(
      title: ' Privacy access review ',
      entityName: 'PT Kaysir Nusantara',
      domain: CompanyControlDomain.dataPrivacy,
      status: CompanyControlStatus.monitoring,
      severity: CompanyControlSeverity.medium,
      ownerName: 'Bagas Pranata',
      nextReviewDateText: '2026-07-15',
      evidenceSummary: ' Quarterly access review export ',
      remediationAction: ' Remove stale admin access ',
      linkedRecord: 'HRIS admin access',
    );
    final control = draft.toControl('control-privacy');

    expect(control.title, 'Privacy access review');
    expect(control.daysUntilReview(companySeedAsOfDate), 42);
    expect(control.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(nextReviewDateText: 'July 15');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toControl('control-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('employer account draft normalizes statutory account setup', () {
    final draft = CompanyEmployerAccountDraft.empty().copyWith(
      accountName: ' DJP Labs account ',
      entityName: 'Kaysir Labs',
      type: CompanyEmployerAccountType.payrollTax,
      status: CompanyEmployerAccountStatus.verified,
      accountNumber: ' NPWP-LABS-001 ',
      ownerName: 'Maya Pratiwi',
      credentialOwnerName: 'Bagas Pranata',
      nextReviewDateText: '2026-09-01',
      evidenceSummary: ' Portal access evidence captured ',
      nextAction: 'Run quarterly account access review',
      linkedFiling: 'Labs payroll tax filing',
    );
    final account = draft.toAccount('account-labs-tax');

    expect(account.accountName, 'DJP Labs account');
    expect(account.accountNumber, 'NPWP-LABS-001');
    expect(account.daysUntilReview(companySeedAsOfDate), 90);
    expect(account.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(nextReviewDateText: 'September 1');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toAccount('account-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('vendor agreement draft normalizes HR service contracts', () {
    final draft = CompanyVendorAgreementDraft.empty().copyWith(
      vendorName: ' Tanda Labs ',
      serviceName: ' Employment e-signature ',
      entityName: 'Kaysir Labs',
      category: CompanyVendorAgreementCategory.eSignature,
      status: CompanyVendorAgreementStatus.active,
      ownerName: 'Maya Pratiwi',
      accountManagerName: 'Bagas Pranata',
      contractEndDateText: '2026-09-30',
      slaSummary: 'Envelope availability 99.5%',
      dataProtectionSummary: 'DPA signed and archived',
      nextAction: 'Review envelope usage quarterly',
      linkedModule: 'Company signatory',
    );
    final agreement = draft.toAgreement('vendor-labs-esign');

    expect(agreement.vendorName, 'Tanda Labs');
    expect(agreement.serviceName, 'Employment e-signature');
    expect(agreement.daysUntilContractEnd(companySeedAsOfDate), 119);
    expect(agreement.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(contractEndDateText: 'Sept 30');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toAgreement('vendor-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('company filing draft normalizes statutory filing schedules', () {
    final draft = CompanyFilingDraft.empty().copyWith(
      title: ' Monthly payroll tax filing ',
      entityName: 'PT Kaysir Nusantara',
      type: CompanyFilingType.tax,
      cadence: CompanyFilingCadence.monthly,
      status: CompanyFilingStatus.scheduled,
      ownerName: 'Bima Ardiansyah',
      authorityName: 'DJP Online',
      dueDateText: '2026-07-10',
      evidenceSummary: ' Prior month receipt ',
      nextStep: 'Submit payroll tax receipt',
      linkedRecord: 'June payroll run',
    );
    final filing = draft.toFiling('filing-tax');

    expect(filing.title, 'Monthly payroll tax filing');
    expect(filing.daysUntilDue(companySeedAsOfDate), 37);
    expect(filing.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(dueDateText: 'July 10');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toFiling('filing-invalid'),
      throwsA(isA<StateError>()),
    );
  });

  test('company signatory draft normalizes delegation authority', () {
    final draft = CompanySignatoryDraft.empty().copyWith(
      personName: ' Nadia Safitri ',
      title: 'Head of People',
      entityName: 'PT Kaysir Nusantara',
      scope: CompanySignatoryScope.employmentContract,
      authorityLevel: CompanySignatoryAuthorityLevel.signer,
      status: CompanySignatoryStatus.active,
      effectiveDateText: '2026-01-01',
      expiryDateText: '2027-01-01',
      backupSignerName: 'Sari Wibowo',
      evidenceSummary: ' Board delegation letter ',
      delegationNotes: 'Employment contract signature authority',
    );
    final signatory = draft.toSignatory('signatory-nadia');

    expect(signatory.personName, 'Nadia Safitri');
    expect(signatory.daysUntilExpiry(companySeedAsOfDate), 212);
    expect(signatory.requiresAttention(companySeedAsOfDate), isFalse);

    final invalidDraft = draft.copyWith(expiryDateText: 'January 1');
    expect(invalidDraft.isReady, isFalse);
    expect(
      () => invalidDraft.toSignatory('signatory-invalid'),
      throwsA(isA<StateError>()),
    );
  });
}
