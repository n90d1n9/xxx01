import 'company_approval_rule.dart';
import 'company_change_request.dart';
import 'company_compensation_band.dart';
import 'company_contract_template.dart';
import 'company_control.dart';
import 'company_cost_center.dart';
import 'company_document.dart';
import 'company_document_audit_event.dart';
import 'company_document_requirement.dart';
import 'company_document_renewal.dart';
import 'company_employee_document_gap.dart';
import 'company_entity_lifecycle.dart';
import 'company_employer_account.dart';
import 'company_filing.dart';
import 'company_governance_contact.dart';
import 'company_job_profile.dart';
import 'company_legal_entity.dart';
import 'company_offboarding_pack.dart';
import 'company_onboarding_pack.dart';
import 'company_operating_readiness.dart';
import 'company_org_unit.dart';
import 'company_policy.dart';
import 'company_position_control.dart';
import 'company_probation_plan.dart';
import 'company_profile.dart';
import 'company_signatory.dart';
import 'company_vendor_agreement.dart';
import 'company_work_location.dart';

class CompanyManagementSummary {
  final int legalEntities;
  final int verifiedLegalEntities;
  final int locationCount;
  final int costCenterCount;
  final int positionControlCount;
  final int positionControlReadyCount;
  final int compensationBandCount;
  final int compensationBandReadyCount;
  final int jobProfileCount;
  final int jobProfileReadyCount;
  final int contractTemplateCount;
  final int contractTemplateReadyCount;
  final int onboardingPackCount;
  final int onboardingPackReadyCount;
  final int probationPlanCount;
  final int probationPlanReadyCount;
  final int offboardingPackCount;
  final int offboardingPackReadyCount;
  final int documentRequirementCount;
  final int documentRequirementReadyCount;
  final int employeeDocumentGapCount;
  final int employeeDocumentGapReadyCount;
  final int approvalRuleCount;
  final int documentCount;
  final int documentRenewalCount;
  final int documentAuditEventCount;
  final int operatingReadinessCount;
  final int operatingReadyCount;
  final int governanceContactCount;
  final int governanceContactReadyCount;
  final int entityLifecycleCount;
  final int entityLifecycleReadyCount;
  final int controlCount;
  final int controlReadyCount;
  final int employerAccountCount;
  final int employerAccountReadyCount;
  final int vendorAgreementCount;
  final int vendorAgreementReadyCount;
  final int filingCount;
  final int filingReadyCount;
  final int signatoryCount;
  final int signatoryReadyCount;
  final int changeRequestCount;
  final int openChangeCount;
  final int orgUnits;
  final int activeHeadcount;
  final int plannedHeadcount;
  final int vacancy;
  final int legalEntityRiskCount;
  final int locationRiskCount;
  final int costCenterRiskCount;
  final int positionControlRiskCount;
  final int compensationBandRiskCount;
  final int jobProfileRiskCount;
  final int contractTemplateRiskCount;
  final int onboardingPackRiskCount;
  final int probationPlanRiskCount;
  final int offboardingPackRiskCount;
  final int documentRequirementRiskCount;
  final int employeeDocumentGapRiskCount;
  final int approvalRuleRiskCount;
  final int documentRiskCount;
  final int documentRenewalRiskCount;
  final int operatingRiskCount;
  final int governanceContactRiskCount;
  final int entityLifecycleRiskCount;
  final int controlRiskCount;
  final int employerAccountRiskCount;
  final int vendorAgreementRiskCount;
  final int filingRiskCount;
  final int signatoryRiskCount;
  final int changeRequestRiskCount;
  final int policyRiskCount;
  final int orgRiskCount;
  final double readinessScore;
  final String nextAction;

  const CompanyManagementSummary({
    required this.legalEntities,
    required this.verifiedLegalEntities,
    required this.locationCount,
    required this.costCenterCount,
    required this.positionControlCount,
    required this.positionControlReadyCount,
    required this.compensationBandCount,
    required this.compensationBandReadyCount,
    required this.jobProfileCount,
    required this.jobProfileReadyCount,
    required this.contractTemplateCount,
    required this.contractTemplateReadyCount,
    required this.onboardingPackCount,
    required this.onboardingPackReadyCount,
    required this.probationPlanCount,
    required this.probationPlanReadyCount,
    required this.offboardingPackCount,
    required this.offboardingPackReadyCount,
    required this.documentRequirementCount,
    required this.documentRequirementReadyCount,
    required this.employeeDocumentGapCount,
    required this.employeeDocumentGapReadyCount,
    required this.approvalRuleCount,
    required this.documentCount,
    required this.documentRenewalCount,
    required this.documentAuditEventCount,
    required this.operatingReadinessCount,
    required this.operatingReadyCount,
    required this.governanceContactCount,
    required this.governanceContactReadyCount,
    required this.entityLifecycleCount,
    required this.entityLifecycleReadyCount,
    required this.controlCount,
    required this.controlReadyCount,
    required this.employerAccountCount,
    required this.employerAccountReadyCount,
    required this.vendorAgreementCount,
    required this.vendorAgreementReadyCount,
    required this.filingCount,
    required this.filingReadyCount,
    required this.signatoryCount,
    required this.signatoryReadyCount,
    required this.changeRequestCount,
    required this.openChangeCount,
    required this.orgUnits,
    required this.activeHeadcount,
    required this.plannedHeadcount,
    required this.vacancy,
    required this.legalEntityRiskCount,
    required this.locationRiskCount,
    required this.costCenterRiskCount,
    required this.positionControlRiskCount,
    required this.compensationBandRiskCount,
    required this.jobProfileRiskCount,
    required this.contractTemplateRiskCount,
    required this.onboardingPackRiskCount,
    required this.probationPlanRiskCount,
    required this.offboardingPackRiskCount,
    required this.documentRequirementRiskCount,
    required this.employeeDocumentGapRiskCount,
    required this.approvalRuleRiskCount,
    required this.documentRiskCount,
    required this.documentRenewalRiskCount,
    required this.operatingRiskCount,
    required this.governanceContactRiskCount,
    required this.entityLifecycleRiskCount,
    required this.controlRiskCount,
    required this.employerAccountRiskCount,
    required this.vendorAgreementRiskCount,
    required this.filingRiskCount,
    required this.signatoryRiskCount,
    required this.changeRequestRiskCount,
    required this.policyRiskCount,
    required this.orgRiskCount,
    required this.readinessScore,
    required this.nextAction,
  });

  int get totalRisks =>
      legalEntityRiskCount +
      locationRiskCount +
      costCenterRiskCount +
      positionControlRiskCount +
      compensationBandRiskCount +
      jobProfileRiskCount +
      contractTemplateRiskCount +
      onboardingPackRiskCount +
      probationPlanRiskCount +
      offboardingPackRiskCount +
      documentRequirementRiskCount +
      employeeDocumentGapRiskCount +
      approvalRuleRiskCount +
      documentRiskCount +
      documentRenewalRiskCount +
      operatingRiskCount +
      governanceContactRiskCount +
      entityLifecycleRiskCount +
      controlRiskCount +
      employerAccountRiskCount +
      vendorAgreementRiskCount +
      filingRiskCount +
      signatoryRiskCount +
      changeRequestRiskCount +
      policyRiskCount +
      orgRiskCount;

  factory CompanyManagementSummary.fromData({
    required CompanyProfile profile,
    List<CompanyLegalEntity> legalEntities = const [],
    List<CompanyWorkLocation> locations = const [],
    List<CompanyCostCenter> costCenters = const [],
    List<CompanyPositionControl> positionControls = const [],
    List<CompanyCompensationBand> compensationBands = const [],
    List<CompanyJobProfile> jobProfiles = const [],
    List<CompanyContractTemplate> contractTemplates = const [],
    List<CompanyOnboardingPack> onboardingPacks = const [],
    List<CompanyProbationPlan> probationPlans = const [],
    List<CompanyOffboardingPack> offboardingPacks = const [],
    List<CompanyDocumentRequirement> documentRequirements = const [],
    List<CompanyEmployeeDocumentGap> employeeDocumentGaps = const [],
    List<CompanyApprovalRule> approvalRules = const [],
    List<CompanyDocumentRecord> documents = const [],
    List<CompanyDocumentRenewalTask> documentRenewals = const [],
    List<CompanyDocumentAuditEvent> documentAuditEvents = const [],
    List<CompanyOperatingReadinessItem> operatingReadiness = const [],
    List<CompanyGovernanceContact> governanceContacts = const [],
    List<CompanyEntityLifecycleMilestone> entityLifecycles = const [],
    List<CompanyControl> controls = const [],
    List<CompanyEmployerAccount> employerAccounts = const [],
    List<CompanyVendorAgreement> vendorAgreements = const [],
    List<CompanyFiling> filings = const [],
    List<CompanySignatory> signatories = const [],
    List<CompanyChangeRequest> changeRequests = const [],
    DateTime? asOfDate,
    required List<CompanyOrgUnit> orgUnits,
    required List<CompanyPolicySetting> policies,
  }) {
    final effectiveAsOfDate = asOfDate ?? DateTime.now();
    final planned = orgUnits.fold<int>(
      0,
      (total, unit) => total + unit.plannedHeadcount,
    );
    final active = orgUnits.fold<int>(
      0,
      (total, unit) => total + unit.activeHeadcount,
    );
    final policyReady =
        policies
            .where((policy) => policy.status == CompanyPolicyStatus.ready)
            .length;
    final policyReadiness =
        policies.isEmpty ? 1 : policyReady / policies.length;
    final orgReady = orgUnits.where((unit) => !unit.needsAttention).length;
    final orgReadiness = orgUnits.isEmpty ? 1 : orgReady / orgUnits.length;
    final verifiedEntities =
        legalEntities
            .where(
              (entity) => entity.status == CompanyLegalEntityStatus.verified,
            )
            .length;
    final legalEntityReadiness =
        legalEntities.isEmpty ? 1 : verifiedEntities / legalEntities.length;
    final locationReady =
        locations.where((location) => !location.requiresAttention).length;
    final locationReadiness =
        locations.isEmpty ? 1 : locationReady / locations.length;
    final costCenterReady =
        costCenters.where((center) => !center.requiresAttention).length;
    final costCenterReadiness =
        costCenters.isEmpty ? 1 : costCenterReady / costCenters.length;
    final positionControlReady =
        positionControls
            .where((position) => !position.requiresAttention(effectiveAsOfDate))
            .length;
    final positionControlReadiness =
        positionControls.isEmpty
            ? 1
            : positionControlReady / positionControls.length;
    final compensationBandReady =
        compensationBands
            .where((band) => !band.requiresAttention(effectiveAsOfDate))
            .length;
    final compensationBandReadiness =
        compensationBands.isEmpty
            ? 1
            : compensationBandReady / compensationBands.length;
    final jobProfileReady =
        jobProfiles
            .where((profile) => !profile.requiresAttention(effectiveAsOfDate))
            .length;
    final jobProfileReadiness =
        jobProfiles.isEmpty ? 1 : jobProfileReady / jobProfiles.length;
    final contractTemplateReady =
        contractTemplates
            .where((template) => !template.requiresAttention(effectiveAsOfDate))
            .length;
    final contractTemplateReadiness =
        contractTemplates.isEmpty
            ? 1
            : contractTemplateReady / contractTemplates.length;
    final onboardingPackReady =
        onboardingPacks
            .where((pack) => !pack.requiresAttention(effectiveAsOfDate))
            .length;
    final onboardingPackReadiness =
        onboardingPacks.isEmpty
            ? 1
            : onboardingPackReady / onboardingPacks.length;
    final probationPlanReady =
        probationPlans
            .where((plan) => !plan.requiresAttention(effectiveAsOfDate))
            .length;
    final probationPlanReadiness =
        probationPlans.isEmpty ? 1 : probationPlanReady / probationPlans.length;
    final offboardingPackReady =
        offboardingPacks
            .where((pack) => !pack.requiresAttention(effectiveAsOfDate))
            .length;
    final offboardingPackReadiness =
        offboardingPacks.isEmpty
            ? 1
            : offboardingPackReady / offboardingPacks.length;
    final documentRequirementReady =
        documentRequirements
            .where(
              (requirement) =>
                  !requirement.requiresAttention(effectiveAsOfDate),
            )
            .length;
    final documentRequirementReadiness =
        documentRequirements.isEmpty
            ? 1
            : documentRequirementReady / documentRequirements.length;
    final employeeDocumentGapReady =
        employeeDocumentGaps
            .where((gap) => !gap.requiresAttention(effectiveAsOfDate))
            .length;
    final approvalRuleReady =
        approvalRules.where((rule) => !rule.requiresAttention).length;
    final approvalRuleReadiness =
        approvalRules.isEmpty ? 1 : approvalRuleReady / approvalRules.length;
    final documentReady =
        documents
            .where((document) => !document.requiresAttention(effectiveAsOfDate))
            .length;
    final documentReadiness =
        documents.isEmpty ? 1 : documentReady / documents.length;
    final renewalReady =
        documentRenewals
            .where((task) => !task.requiresAttention(effectiveAsOfDate))
            .length;
    final renewalReadiness =
        documentRenewals.isEmpty ? 1 : renewalReady / documentRenewals.length;
    final operatingReady =
        operatingReadiness
            .where((item) => !item.requiresAttention(effectiveAsOfDate))
            .length;
    final operatingScore =
        operatingReadiness.isEmpty
            ? 1
            : operatingReady / operatingReadiness.length;
    final governanceContactReady =
        governanceContacts
            .where((contact) => !contact.requiresAttention(effectiveAsOfDate))
            .length;
    final governanceContactReadiness =
        governanceContacts.isEmpty
            ? 1
            : governanceContactReady / governanceContacts.length;
    final entityLifecycleReady =
        entityLifecycles
            .where(
              (milestone) => !milestone.requiresAttention(effectiveAsOfDate),
            )
            .length;
    final entityLifecycleReadiness =
        entityLifecycles.isEmpty
            ? 1
            : entityLifecycleReady / entityLifecycles.length;
    final controlReady =
        controls
            .where((control) => !control.requiresAttention(effectiveAsOfDate))
            .length;
    final controlReadiness =
        controls.isEmpty ? 1 : controlReady / controls.length;
    final employerAccountReady =
        employerAccounts
            .where((account) => !account.requiresAttention(effectiveAsOfDate))
            .length;
    final employerAccountReadiness =
        employerAccounts.isEmpty
            ? 1
            : employerAccountReady / employerAccounts.length;
    final vendorAgreementReady =
        vendorAgreements
            .where(
              (agreement) => !agreement.requiresAttention(effectiveAsOfDate),
            )
            .length;
    final vendorAgreementReadiness =
        vendorAgreements.isEmpty
            ? 1
            : vendorAgreementReady / vendorAgreements.length;
    final filingReady =
        filings
            .where((filing) => !filing.requiresAttention(effectiveAsOfDate))
            .length;
    final filingReadiness = filings.isEmpty ? 1 : filingReady / filings.length;
    final signatoryReady =
        signatories
            .where(
              (signatory) => !signatory.requiresAttention(effectiveAsOfDate),
            )
            .length;
    final signatoryReadiness =
        signatories.isEmpty ? 1 : signatoryReady / signatories.length;
    final changeReady =
        changeRequests
            .where((request) => !request.requiresAttention(effectiveAsOfDate))
            .length;
    final changeReadiness =
        changeRequests.isEmpty ? 1 : changeReady / changeRequests.length;
    final score =
        (profile.readinessScore * 0.08) +
        (legalEntityReadiness * 0.03) +
        (locationReadiness * 0.03) +
        (costCenterReadiness * 0.03) +
        (jobProfileReadiness * 0.02) +
        (contractTemplateReadiness * 0.02) +
        (onboardingPackReadiness * 0.02) +
        (probationPlanReadiness * 0.02) +
        (offboardingPackReadiness * 0.04) +
        (documentRequirementReadiness * 0.04) +
        (positionControlReadiness * 0.04) +
        (compensationBandReadiness * 0.04) +
        (approvalRuleReadiness * 0.05) +
        (documentReadiness * 0.04) +
        (renewalReadiness * 0.05) +
        (operatingScore * 0.04) +
        (governanceContactReadiness * 0.03) +
        (entityLifecycleReadiness * 0.05) +
        (controlReadiness * 0.04) +
        (employerAccountReadiness * 0.04) +
        (vendorAgreementReadiness * 0.04) +
        (filingReadiness * 0.05) +
        (signatoryReadiness * 0.03) +
        (changeReadiness * 0.05) +
        (orgReadiness * 0.04) +
        (policyReadiness * 0.04);
    final vacancy = planned - active;
    final fallbackEntityCount =
        orgUnits
            .map((unit) => unit.entityName)
            .where((name) => name.isNotEmpty)
            .toSet()
            .length;

    return CompanyManagementSummary(
      legalEntities:
          legalEntities.isEmpty ? fallbackEntityCount : legalEntities.length,
      verifiedLegalEntities:
          legalEntities.isEmpty ? fallbackEntityCount : verifiedEntities,
      locationCount: locations.length,
      costCenterCount: costCenters.length,
      positionControlCount: positionControls.length,
      positionControlReadyCount: positionControlReady,
      compensationBandCount: compensationBands.length,
      compensationBandReadyCount: compensationBandReady,
      jobProfileCount: jobProfiles.length,
      jobProfileReadyCount: jobProfileReady,
      contractTemplateCount: contractTemplates.length,
      contractTemplateReadyCount: contractTemplateReady,
      onboardingPackCount: onboardingPacks.length,
      onboardingPackReadyCount: onboardingPackReady,
      probationPlanCount: probationPlans.length,
      probationPlanReadyCount: probationPlanReady,
      offboardingPackCount: offboardingPacks.length,
      offboardingPackReadyCount: offboardingPackReady,
      documentRequirementCount: documentRequirements.length,
      documentRequirementReadyCount: documentRequirementReady,
      employeeDocumentGapCount: employeeDocumentGaps.length,
      employeeDocumentGapReadyCount: employeeDocumentGapReady,
      approvalRuleCount: approvalRules.length,
      documentCount: documents.length,
      documentRenewalCount: documentRenewals.length,
      documentAuditEventCount: documentAuditEvents.length,
      operatingReadinessCount: operatingReadiness.length,
      operatingReadyCount: operatingReady,
      governanceContactCount: governanceContacts.length,
      governanceContactReadyCount: governanceContactReady,
      entityLifecycleCount: entityLifecycles.length,
      entityLifecycleReadyCount: entityLifecycleReady,
      controlCount: controls.length,
      controlReadyCount: controlReady,
      employerAccountCount: employerAccounts.length,
      employerAccountReadyCount: employerAccountReady,
      vendorAgreementCount: vendorAgreements.length,
      vendorAgreementReadyCount: vendorAgreementReady,
      filingCount: filings.length,
      filingReadyCount: filingReady,
      signatoryCount: signatories.length,
      signatoryReadyCount: signatoryReady,
      changeRequestCount: changeRequests.length,
      openChangeCount:
          changeRequests
              .where(
                (request) =>
                    request.status != CompanyChangeRequestStatus.implemented,
              )
              .length,
      orgUnits: orgUnits.length,
      activeHeadcount: active,
      plannedHeadcount: planned,
      vacancy: vacancy < 0 ? 0 : vacancy,
      legalEntityRiskCount:
          legalEntities.where((entity) => entity.requiresAttention).length,
      locationRiskCount:
          locations.where((location) => location.requiresAttention).length,
      costCenterRiskCount:
          costCenters.where((center) => center.requiresAttention).length,
      positionControlRiskCount:
          positionControls
              .where(
                (position) => position.requiresAttention(effectiveAsOfDate),
              )
              .length,
      compensationBandRiskCount:
          compensationBands
              .where((band) => band.requiresAttention(effectiveAsOfDate))
              .length,
      jobProfileRiskCount:
          jobProfiles
              .where((profile) => profile.requiresAttention(effectiveAsOfDate))
              .length,
      contractTemplateRiskCount:
          contractTemplates
              .where(
                (template) => template.requiresAttention(effectiveAsOfDate),
              )
              .length,
      onboardingPackRiskCount:
          onboardingPacks
              .where((pack) => pack.requiresAttention(effectiveAsOfDate))
              .length,
      probationPlanRiskCount:
          probationPlans
              .where((plan) => plan.requiresAttention(effectiveAsOfDate))
              .length,
      offboardingPackRiskCount:
          offboardingPacks
              .where((pack) => pack.requiresAttention(effectiveAsOfDate))
              .length,
      documentRequirementRiskCount:
          documentRequirements
              .where(
                (requirement) =>
                    requirement.requiresAttention(effectiveAsOfDate),
              )
              .length,
      employeeDocumentGapRiskCount:
          employeeDocumentGaps
              .where((gap) => gap.requiresAttention(effectiveAsOfDate))
              .length,
      approvalRuleRiskCount:
          approvalRules.where((rule) => rule.requiresAttention).length,
      documentRiskCount:
          documents
              .where(
                (document) => document.requiresAttention(effectiveAsOfDate),
              )
              .length,
      documentRenewalRiskCount:
          documentRenewals
              .where((task) => task.requiresAttention(effectiveAsOfDate))
              .length,
      operatingRiskCount:
          operatingReadiness
              .where((item) => item.requiresAttention(effectiveAsOfDate))
              .length,
      governanceContactRiskCount:
          governanceContacts
              .where((contact) => contact.requiresAttention(effectiveAsOfDate))
              .length,
      entityLifecycleRiskCount:
          entityLifecycles
              .where(
                (milestone) => milestone.requiresAttention(effectiveAsOfDate),
              )
              .length,
      controlRiskCount:
          controls
              .where((control) => control.requiresAttention(effectiveAsOfDate))
              .length,
      employerAccountRiskCount:
          employerAccounts
              .where((account) => account.requiresAttention(effectiveAsOfDate))
              .length,
      vendorAgreementRiskCount:
          vendorAgreements
              .where(
                (agreement) => agreement.requiresAttention(effectiveAsOfDate),
              )
              .length,
      filingRiskCount:
          filings
              .where((filing) => filing.requiresAttention(effectiveAsOfDate))
              .length,
      signatoryRiskCount:
          signatories
              .where(
                (signatory) => signatory.requiresAttention(effectiveAsOfDate),
              )
              .length,
      changeRequestRiskCount:
          changeRequests
              .where((request) => request.requiresAttention(effectiveAsOfDate))
              .length,
      policyRiskCount:
          policies.where((policy) => policy.requiresAttention).length,
      orgRiskCount: orgUnits.where((unit) => unit.needsAttention).length,
      readinessScore: score.clamp(0, 1),
      nextAction: _nextAction(
        profile,
        legalEntities,
        locations,
        costCenters,
        positionControls,
        compensationBands,
        jobProfiles,
        contractTemplates,
        onboardingPacks,
        probationPlans,
        offboardingPacks,
        documentRequirements,
        employeeDocumentGaps,
        approvalRules,
        documents,
        documentRenewals,
        operatingReadiness,
        governanceContacts,
        entityLifecycles,
        controls,
        employerAccounts,
        vendorAgreements,
        filings,
        signatories,
        changeRequests,
        effectiveAsOfDate,
        orgUnits,
        policies,
      ),
    );
  }

  static String _nextAction(
    CompanyProfile profile,
    List<CompanyLegalEntity> legalEntities,
    List<CompanyWorkLocation> locations,
    List<CompanyCostCenter> costCenters,
    List<CompanyPositionControl> positionControls,
    List<CompanyCompensationBand> compensationBands,
    List<CompanyJobProfile> jobProfiles,
    List<CompanyContractTemplate> contractTemplates,
    List<CompanyOnboardingPack> onboardingPacks,
    List<CompanyProbationPlan> probationPlans,
    List<CompanyOffboardingPack> offboardingPacks,
    List<CompanyDocumentRequirement> documentRequirements,
    List<CompanyEmployeeDocumentGap> employeeDocumentGaps,
    List<CompanyApprovalRule> approvalRules,
    List<CompanyDocumentRecord> documents,
    List<CompanyDocumentRenewalTask> documentRenewals,
    List<CompanyOperatingReadinessItem> operatingReadiness,
    List<CompanyGovernanceContact> governanceContacts,
    List<CompanyEntityLifecycleMilestone> entityLifecycles,
    List<CompanyControl> controls,
    List<CompanyEmployerAccount> employerAccounts,
    List<CompanyVendorAgreement> vendorAgreements,
    List<CompanyFiling> filings,
    List<CompanySignatory> signatories,
    List<CompanyChangeRequest> changeRequests,
    DateTime asOfDate,
    List<CompanyOrgUnit> orgUnits,
    List<CompanyPolicySetting> policies,
  ) {
    if (profile.issues.isNotEmpty) {
      return profile.issues.first.label;
    }

    final entity =
        legalEntities.where((item) => item.requiresAttention).firstOrNull;
    if (entity != null) {
      return '${entity.name}: ${entity.issues.first.label}';
    }

    final location =
        locations.where((item) => item.requiresAttention).firstOrNull;
    if (location != null) {
      return '${location.name}: ${location.issues.first.label}';
    }

    final costCenter =
        costCenters.where((item) => item.requiresAttention).firstOrNull;
    if (costCenter != null) {
      return '${costCenter.name}: ${costCenter.issues.first.label}';
    }

    final positionControl =
        positionControls
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (positionControl != null) {
      return '${positionControl.positionTitle}: ${positionControl.issues(asOfDate).first.label}';
    }

    final compensationBand =
        compensationBands
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (compensationBand != null) {
      return '${compensationBand.bandCode}: ${compensationBand.issues(asOfDate).first.label}';
    }

    final jobProfile =
        jobProfiles
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (jobProfile != null) {
      return '${jobProfile.jobTitle}: ${jobProfile.issues(asOfDate).first.label}';
    }

    final contractTemplate =
        contractTemplates
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (contractTemplate != null) {
      return '${contractTemplate.templateName}: ${contractTemplate.issues(asOfDate).first.label}';
    }

    final onboardingPack =
        onboardingPacks
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (onboardingPack != null) {
      return '${onboardingPack.packName}: ${onboardingPack.issues(asOfDate).first.label}';
    }

    final probationPlan =
        probationPlans
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (probationPlan != null) {
      return '${probationPlan.planName}: ${probationPlan.issues(asOfDate).first.label}';
    }

    final offboardingPack =
        offboardingPacks
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (offboardingPack != null) {
      return '${offboardingPack.packName}: ${offboardingPack.issues(asOfDate).first.label}';
    }

    final documentRequirement =
        documentRequirements
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (documentRequirement != null) {
      return '${documentRequirement.requirementName}: ${documentRequirement.issues(asOfDate).first.label}';
    }

    final employeeDocumentGap =
        employeeDocumentGaps
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (employeeDocumentGap != null) {
      return '${employeeDocumentGap.employeeName}: ${employeeDocumentGap.issues(asOfDate).first.label}';
    }

    final approvalRule =
        approvalRules.where((item) => item.requiresAttention).firstOrNull;
    if (approvalRule != null) {
      return '${approvalRule.domain.label}: ${approvalRule.issues.first.label}';
    }

    final document =
        documents.where((item) => item.requiresAttention(asOfDate)).firstOrNull;
    if (document != null) {
      return '${document.title}: ${document.issues(asOfDate).first.label}';
    }

    final renewal =
        documentRenewals
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (renewal != null) {
      return '${renewal.documentTitle}: ${renewal.issues(asOfDate).first.label}';
    }

    final operating =
        operatingReadiness
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (operating != null) {
      return '${operating.entityName} ${operating.area.label}: ${operating.issues(asOfDate).first.label}';
    }

    final contact =
        governanceContacts
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (contact != null) {
      return '${contact.role.label}: ${contact.issues(asOfDate).first.label}';
    }

    final lifecycle =
        entityLifecycles
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (lifecycle != null) {
      return '${lifecycle.title}: ${lifecycle.issues(asOfDate).first.label}';
    }

    final control =
        controls.where((item) => item.requiresAttention(asOfDate)).firstOrNull;
    if (control != null) {
      return '${control.title}: ${control.issues(asOfDate).first.label}';
    }

    final employerAccount =
        employerAccounts
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (employerAccount != null) {
      return '${employerAccount.accountName}: ${employerAccount.issues(asOfDate).first.label}';
    }

    final vendorAgreement =
        vendorAgreements
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (vendorAgreement != null) {
      return '${vendorAgreement.vendorName}: ${vendorAgreement.issues(asOfDate).first.label}';
    }

    final filing =
        filings.where((item) => item.requiresAttention(asOfDate)).firstOrNull;
    if (filing != null) {
      return '${filing.title}: ${filing.issues(asOfDate).first.label}';
    }

    final signatory =
        signatories
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (signatory != null) {
      return '${signatory.personName}: ${signatory.issues(asOfDate).first.label}';
    }

    final change =
        changeRequests
            .where((item) => item.requiresAttention(asOfDate))
            .firstOrNull;
    if (change != null) {
      return '${change.title}: ${change.issues(asOfDate).first.label}';
    }

    final policy = policies.where((item) => item.requiresAttention).firstOrNull;
    if (policy != null) return policy.nextAction;

    final orgUnit = orgUnits.where((unit) => unit.needsAttention).firstOrNull;
    if (orgUnit != null) {
      return '${orgUnit.name}: ${orgUnit.issues.first.label}';
    }

    return 'Company foundation is ready for HR operations.';
  }
}
