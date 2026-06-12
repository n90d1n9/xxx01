import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/company_seed_data.dart';
import '../models/company_approval_rule.dart';
import '../models/company_change_request.dart';
import '../models/company_compensation_band.dart';
import '../models/company_contract_template.dart';
import '../models/company_control.dart';
import '../models/company_cost_center.dart';
import '../models/company_document.dart';
import '../models/company_document_audit_event.dart';
import '../models/company_document_audit_activity_summary.dart';
import '../models/company_document_audit_detail.dart';
import '../models/company_document_audit_filter.dart';
import '../models/company_document_requirement.dart';
import '../models/company_document_renewal.dart';
import '../models/company_employee_document_compliance_mapper.dart';
import '../models/company_employee_document_gap.dart';
import '../models/company_employee_document_gap_recommendation.dart';
import '../models/company_employee_document_request_mapper.dart';
import '../models/company_employee_document_verification_result.dart';
import '../models/company_employee_document_workload.dart';
import '../models/company_employee_document_workload_digest_status.dart';
import '../models/company_entity_lifecycle.dart';
import '../models/company_employer_account.dart';
import '../models/company_filing.dart';
import '../models/company_governance_follow_up_cadence.dart';
import '../models/company_governance_follow_up_policy_approval.dart';
import '../models/company_governance_follow_up_policy_history.dart';
import '../models/company_governance_follow_up_policy.dart';
import '../models/company_governance_follow_up_policy_impact.dart';
import '../models/company_governance_action_item.dart';
import '../models/company_governance_command_brief.dart';
import '../models/company_governance_owner_load.dart';
import '../models/company_governance_owner_handoff.dart';
import '../models/company_governance_owner_handoff_history.dart';
import '../models/company_governance_owner_handoff_record.dart';
import '../models/company_governance_saved_view.dart';
import '../models/company_governance_contact.dart';
import '../models/company_headcount_requisition.dart';
import '../models/company_headcount_requisition_activity.dart';
import '../models/company_job_profile.dart';
import '../models/company_legal_entity.dart';
import '../models/company_management_summary.dart';
import '../models/company_offboarding_pack.dart';
import '../models/company_onboarding_pack.dart';
import '../models/company_operating_readiness.dart';
import '../models/company_org_unit.dart';
import '../models/company_policy.dart';
import '../models/company_position_control.dart';
import '../models/company_probation_plan.dart';
import '../models/company_profile.dart';
import '../models/company_signatory.dart';
import '../models/company_vendor_agreement.dart';
import '../models/company_work_location.dart';
import '../models/company_workforce_plan.dart';
import '../models/employee_document_digest_history.dart';
import '../models/employee_document_escalation_follow_up.dart';
import '../models/employee_document_escalation_plan.dart';
import '../models/employee_document_escalation_history.dart';
import '../../employee/models/employee_compliance_models.dart';
import '../../employee/models/employee_document_request_models.dart';
import '../../employee/states/employee_compliance_provider.dart';
import '../../employee/states/employee_directory_provider.dart';
import '../../employee/states/employee_document_request_provider.dart';

const companyAllEntities = 'All';

final companySelectedEntityProvider = StateProvider<String>(
  (ref) => companyAllEntities,
);

final companyAttentionOnlyProvider = StateProvider<bool>((ref) => false);

final companyDocumentAuditFilterProvider =
    StateProvider<CompanyDocumentAuditTimelineFilter>(
      (ref) => const CompanyDocumentAuditTimelineFilter(),
    );

final companySelectedDocumentAuditEventIdProvider = StateProvider<String?>(
  (ref) => null,
);

final companySelectedGovernanceOwnerProvider = StateProvider<String?>(
  (ref) => null,
);

final companySelectedGovernanceSavedViewProvider =
    StateProvider<CompanyGovernanceSavedViewType>(
      (ref) => CompanyGovernanceSavedViewType.commandCenter,
    );

final companyGovernanceOwnerHandoffRecordsProvider = StateNotifierProvider<
  CompanyGovernanceOwnerHandoffRecordNotifier,
  List<CompanyGovernanceOwnerHandoffRecord>
>((ref) {
  return CompanyGovernanceOwnerHandoffRecordNotifier();
});

final companyAsOfDateProvider = Provider<DateTime>(
  (ref) => companySeedAsOfDate,
);

final companyProfileProvider =
    StateNotifierProvider<CompanyProfileNotifier, CompanyProfile>((ref) {
      return CompanyProfileNotifier(companySeedProfile);
    });

final companyProfileDraftProvider =
    StateNotifierProvider<CompanyProfileDraftNotifier, CompanyProfileDraft>((
      ref,
    ) {
      return CompanyProfileDraftNotifier(
        CompanyProfileDraft.fromProfile(ref.watch(companyProfileProvider)),
      );
    });

final companyOrgUnitsProvider =
    StateNotifierProvider<CompanyOrgUnitNotifier, List<CompanyOrgUnit>>((ref) {
      return CompanyOrgUnitNotifier(companySeedOrgUnits);
    });

final companyCostCentersProvider =
    StateNotifierProvider<CompanyCostCenterNotifier, List<CompanyCostCenter>>((
      ref,
    ) {
      return CompanyCostCenterNotifier(companySeedCostCenters);
    });

final companyCostCenterDraftProvider = StateNotifierProvider<
  CompanyCostCenterDraftNotifier,
  CompanyCostCenterDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyCostCenterDraftNotifier(
    CompanyCostCenterDraft.empty(entityName: entity),
  );
});

final companyPositionControlsProvider = StateNotifierProvider<
  CompanyPositionControlNotifier,
  List<CompanyPositionControl>
>((ref) {
  return CompanyPositionControlNotifier(companySeedPositionControls);
});

final companyPositionControlDraftProvider = StateNotifierProvider<
  CompanyPositionControlDraftNotifier,
  CompanyPositionControlDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final orgUnit =
      ref
          .watch(companyOrgUnitsProvider)
          .where((unit) => unit.entityName == entity)
          .map((unit) => unit.name)
          .firstOrNull ??
      'People Operations';
  return CompanyPositionControlDraftNotifier(
    CompanyPositionControlDraft.empty(entityName: entity, orgUnitName: orgUnit),
  );
});

final companyHeadcountRequisitionsProvider = StateNotifierProvider<
  CompanyHeadcountRequisitionNotifier,
  List<CompanyHeadcountRequisition>
>((ref) {
  return CompanyHeadcountRequisitionNotifier(companySeedHeadcountRequisitions);
});

final companyHeadcountRequisitionActivityRecordsProvider =
    StateNotifierProvider<
      CompanyHeadcountRequisitionActivityRecordNotifier,
      List<CompanyHeadcountRequisitionActivityRecord>
    >((ref) {
      return CompanyHeadcountRequisitionActivityRecordNotifier(
        companySeedHeadcountRequisitionActivityRecords,
      );
    });

final companyHeadcountRequisitionDraftProvider = StateNotifierProvider<
  CompanyHeadcountRequisitionDraftNotifier,
  CompanyHeadcountRequisitionDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final orgUnit =
      ref
          .watch(companyOrgUnitsProvider)
          .where((unit) => unit.entityName == entity)
          .map((unit) => unit.name)
          .firstOrNull ??
      'People Operations';
  return CompanyHeadcountRequisitionDraftNotifier(
    CompanyHeadcountRequisitionDraft.empty(
      entityName: entity,
      orgUnitName: orgUnit,
    ),
  );
});

final companyCompensationBandsProvider = StateNotifierProvider<
  CompanyCompensationBandNotifier,
  List<CompanyCompensationBand>
>((ref) {
  return CompanyCompensationBandNotifier(companySeedCompensationBands);
});

final companyCompensationBandDraftProvider = StateNotifierProvider<
  CompanyCompensationBandDraftNotifier,
  CompanyCompensationBandDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyCompensationBandDraftNotifier(
    CompanyCompensationBandDraft.empty(entityName: entity),
  );
});

final companyJobProfilesProvider =
    StateNotifierProvider<CompanyJobProfileNotifier, List<CompanyJobProfile>>((
      ref,
    ) {
      return CompanyJobProfileNotifier(companySeedJobProfiles);
    });

final companyJobProfileDraftProvider = StateNotifierProvider<
  CompanyJobProfileDraftNotifier,
  CompanyJobProfileDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final orgUnit =
      ref
          .watch(companyOrgUnitsProvider)
          .where((unit) => unit.entityName == entity)
          .map((unit) => unit.name)
          .firstOrNull ??
      'People Operations';
  final compensationBand =
      ref
          .watch(companyCompensationBandsProvider)
          .where((band) => band.entityName == entity)
          .map((band) => band.bandCode)
          .firstOrNull ??
      '';
  return CompanyJobProfileDraftNotifier(
    CompanyJobProfileDraft.empty(
      entityName: entity,
      orgUnitName: orgUnit,
      compensationBand: compensationBand,
    ),
  );
});

final companyContractTemplatesProvider = StateNotifierProvider<
  CompanyContractTemplateNotifier,
  List<CompanyContractTemplate>
>((ref) {
  return CompanyContractTemplateNotifier(companySeedContractTemplates);
});

final companyContractTemplateDraftProvider = StateNotifierProvider<
  CompanyContractTemplateDraftNotifier,
  CompanyContractTemplateDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final jobProfileCode =
      ref
          .watch(companyJobProfilesProvider)
          .where((profile) => profile.entityName == entity)
          .map((profile) => profile.jobCode)
          .firstOrNull ??
      '';
  final compensationBand =
      ref
          .watch(companyCompensationBandsProvider)
          .where((band) => band.entityName == entity)
          .map((band) => band.bandCode)
          .firstOrNull ??
      '';
  return CompanyContractTemplateDraftNotifier(
    CompanyContractTemplateDraft.empty(
      entityName: entity,
      jobProfileCode: jobProfileCode,
      compensationBand: compensationBand,
    ),
  );
});

final companyOnboardingPacksProvider = StateNotifierProvider<
  CompanyOnboardingPackNotifier,
  List<CompanyOnboardingPack>
>((ref) {
  return CompanyOnboardingPackNotifier(companySeedOnboardingPacks);
});

final companyOnboardingPackDraftProvider = StateNotifierProvider<
  CompanyOnboardingPackDraftNotifier,
  CompanyOnboardingPackDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final jobProfileCode =
      ref
          .watch(companyJobProfilesProvider)
          .where((profile) => profile.entityName == entity)
          .map((profile) => profile.jobCode)
          .firstOrNull ??
      '';
  final contractTemplateName =
      ref
          .watch(companyContractTemplatesProvider)
          .where((template) => template.entityName == entity)
          .map((template) => template.templateName)
          .firstOrNull ??
      '';
  return CompanyOnboardingPackDraftNotifier(
    CompanyOnboardingPackDraft.empty(
      entityName: entity,
      jobProfileCode: jobProfileCode,
      contractTemplateName: contractTemplateName,
    ),
  );
});

final companyProbationPlansProvider = StateNotifierProvider<
  CompanyProbationPlanNotifier,
  List<CompanyProbationPlan>
>((ref) {
  return CompanyProbationPlanNotifier(companySeedProbationPlans);
});

final companyProbationPlanDraftProvider = StateNotifierProvider<
  CompanyProbationPlanDraftNotifier,
  CompanyProbationPlanDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final jobProfileCode =
      ref
          .watch(companyJobProfilesProvider)
          .where((profile) => profile.entityName == entity)
          .map((profile) => profile.jobCode)
          .firstOrNull ??
      '';
  final onboardingPackName =
      ref
          .watch(companyOnboardingPacksProvider)
          .where((pack) => pack.entityName == entity)
          .map((pack) => pack.packName)
          .firstOrNull ??
      '';
  return CompanyProbationPlanDraftNotifier(
    CompanyProbationPlanDraft.empty(
      entityName: entity,
      jobProfileCode: jobProfileCode,
      onboardingPackName: onboardingPackName,
    ),
  );
});

final companyOffboardingPacksProvider = StateNotifierProvider<
  CompanyOffboardingPackNotifier,
  List<CompanyOffboardingPack>
>((ref) {
  return CompanyOffboardingPackNotifier(companySeedOffboardingPacks);
});

final companyOffboardingPackDraftProvider = StateNotifierProvider<
  CompanyOffboardingPackDraftNotifier,
  CompanyOffboardingPackDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final jobProfileCode =
      ref
          .watch(companyJobProfilesProvider)
          .where((profile) => profile.entityName == entity)
          .map((profile) => profile.jobCode)
          .firstOrNull ??
      '';
  return CompanyOffboardingPackDraftNotifier(
    CompanyOffboardingPackDraft.empty(
      entityName: entity,
      jobProfileCode: jobProfileCode,
    ),
  );
});

final companyDocumentRequirementsProvider = StateNotifierProvider<
  CompanyDocumentRequirementNotifier,
  List<CompanyDocumentRequirement>
>((ref) {
  return CompanyDocumentRequirementNotifier(companySeedDocumentRequirements);
});

final companyDocumentRequirementDraftProvider = StateNotifierProvider<
  CompanyDocumentRequirementDraftNotifier,
  CompanyDocumentRequirementDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  final jobProfileCode =
      ref
          .watch(companyJobProfilesProvider)
          .where((profile) => profile.entityName == entity)
          .map((profile) => profile.jobCode)
          .firstOrNull ??
      '';
  final contractTemplateName =
      ref
          .watch(companyContractTemplatesProvider)
          .where((template) => template.entityName == entity)
          .map((template) => template.templateName)
          .firstOrNull ??
      '';
  final onboardingPackName =
      ref
          .watch(companyOnboardingPacksProvider)
          .where((pack) => pack.entityName == entity)
          .map((pack) => pack.packName)
          .firstOrNull ??
      '';
  final probationPlanName =
      ref
          .watch(companyProbationPlansProvider)
          .where((plan) => plan.entityName == entity)
          .map((plan) => plan.planName)
          .firstOrNull ??
      '';
  final offboardingPackName =
      ref
          .watch(companyOffboardingPacksProvider)
          .where((pack) => pack.entityName == entity)
          .map((pack) => pack.packName)
          .firstOrNull ??
      '';
  return CompanyDocumentRequirementDraftNotifier(
    CompanyDocumentRequirementDraft.empty(
      entityName: entity,
      jobProfileCode: jobProfileCode,
      contractTemplateName: contractTemplateName,
      onboardingPackName: onboardingPackName,
      probationPlanName: probationPlanName,
      offboardingPackName: offboardingPackName,
    ),
  );
});

final companyEmployeeDocumentGapsProvider = StateNotifierProvider<
  CompanyEmployeeDocumentGapNotifier,
  List<CompanyEmployeeDocumentGap>
>((ref) {
  final members = ref.watch(employeeDirectoryMembersProvider);
  final evidenceSnapshots = [
    for (final member in members)
      _employeeDocumentEvidenceSnapshot(
        employeeId: member.id,
        records: ref.watch(employeeComplianceRecordsProvider(member.id)),
        requests:
            ref
                .watch(employeeDocumentRequestProfileProvider(member.id))
                ?.requests ??
            const [],
      ),
  ];

  final gaps = buildCompanyEmployeeDocumentGaps(
    subjects: companySeedEmployeeDocumentSubjects,
    requirements: ref.watch(companyDocumentRequirementsProvider),
    evidenceSnapshots: evidenceSnapshots,
    asOfDate: ref.watch(companyAsOfDateProvider),
  );

  return CompanyEmployeeDocumentGapNotifier(gaps, ref);
});

final companyApprovalRulesProvider = StateNotifierProvider<
  CompanyApprovalRuleNotifier,
  List<CompanyApprovalRule>
>((ref) {
  return CompanyApprovalRuleNotifier(companySeedApprovalRules);
});

final companyApprovalRuleDraftProvider = StateNotifierProvider<
  CompanyApprovalRuleDraftNotifier,
  CompanyApprovalRuleDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyApprovalRuleDraftNotifier(
    CompanyApprovalRuleDraft.empty(entityName: entity),
  );
});

final companyDocumentsProvider =
    StateNotifierProvider<CompanyDocumentNotifier, List<CompanyDocumentRecord>>(
      (ref) {
        return CompanyDocumentNotifier(companySeedDocuments);
      },
    );

final companyDocumentDraftProvider =
    StateNotifierProvider<CompanyDocumentDraftNotifier, CompanyDocumentDraft>((
      ref,
    ) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final entity =
          selectedEntity == companyAllEntities
              ? 'PT Kaysir Nusantara'
              : selectedEntity;
      return CompanyDocumentDraftNotifier(
        CompanyDocumentDraft.empty(entityName: entity),
      );
    });

final companyDocumentRenewalsProvider = StateNotifierProvider<
  CompanyDocumentRenewalNotifier,
  List<CompanyDocumentRenewalTask>
>((ref) {
  return CompanyDocumentRenewalNotifier(companySeedDocumentRenewals);
});

final companyDocumentRenewalDraftProvider = StateNotifierProvider<
  CompanyDocumentRenewalDraftNotifier,
  CompanyDocumentRenewalDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyDocumentRenewalDraftNotifier(
    CompanyDocumentRenewalDraft.empty(entityName: entity),
  );
});

final companyDocumentAuditEventsProvider = StateNotifierProvider<
  CompanyDocumentAuditNotifier,
  List<CompanyDocumentAuditEvent>
>((ref) {
  return CompanyDocumentAuditNotifier(companySeedDocumentAuditEvents);
});

final companyOperatingReadinessProvider = StateNotifierProvider<
  CompanyOperatingReadinessNotifier,
  List<CompanyOperatingReadinessItem>
>((ref) {
  return CompanyOperatingReadinessNotifier(companySeedOperatingReadiness);
});

final companyOperatingReadinessDraftProvider = StateNotifierProvider<
  CompanyOperatingReadinessDraftNotifier,
  CompanyOperatingReadinessDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyOperatingReadinessDraftNotifier(
    CompanyOperatingReadinessDraft.empty(entityName: entity),
  );
});

final companyGovernanceContactsProvider = StateNotifierProvider<
  CompanyGovernanceContactNotifier,
  List<CompanyGovernanceContact>
>((ref) {
  return CompanyGovernanceContactNotifier(companySeedGovernanceContacts);
});

final companyGovernanceContactDraftProvider = StateNotifierProvider<
  CompanyGovernanceContactDraftNotifier,
  CompanyGovernanceContactDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyGovernanceContactDraftNotifier(
    CompanyGovernanceContactDraft.empty(entityName: entity),
  );
});

final companyEntityLifecyclesProvider = StateNotifierProvider<
  CompanyEntityLifecycleNotifier,
  List<CompanyEntityLifecycleMilestone>
>((ref) {
  return CompanyEntityLifecycleNotifier(companySeedEntityLifecycles);
});

final companyControlsProvider =
    StateNotifierProvider<CompanyControlNotifier, List<CompanyControl>>((ref) {
      return CompanyControlNotifier(companySeedControls);
    });

final companyControlDraftProvider =
    StateNotifierProvider<CompanyControlDraftNotifier, CompanyControlDraft>((
      ref,
    ) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final entity =
          selectedEntity == companyAllEntities
              ? 'PT Kaysir Nusantara'
              : selectedEntity;
      return CompanyControlDraftNotifier(
        CompanyControlDraft.empty(entityName: entity),
      );
    });

final companyEmployerAccountsProvider = StateNotifierProvider<
  CompanyEmployerAccountNotifier,
  List<CompanyEmployerAccount>
>((ref) {
  return CompanyEmployerAccountNotifier(companySeedEmployerAccounts);
});

final companyEmployerAccountDraftProvider = StateNotifierProvider<
  CompanyEmployerAccountDraftNotifier,
  CompanyEmployerAccountDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyEmployerAccountDraftNotifier(
    CompanyEmployerAccountDraft.empty(entityName: entity),
  );
});

final companyVendorAgreementsProvider = StateNotifierProvider<
  CompanyVendorAgreementNotifier,
  List<CompanyVendorAgreement>
>((ref) {
  return CompanyVendorAgreementNotifier(companySeedVendorAgreements);
});

final companyVendorAgreementDraftProvider = StateNotifierProvider<
  CompanyVendorAgreementDraftNotifier,
  CompanyVendorAgreementDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyVendorAgreementDraftNotifier(
    CompanyVendorAgreementDraft.empty(entityName: entity),
  );
});

final companyFilingsProvider =
    StateNotifierProvider<CompanyFilingNotifier, List<CompanyFiling>>((ref) {
      return CompanyFilingNotifier(companySeedFilings);
    });

final companyFilingDraftProvider =
    StateNotifierProvider<CompanyFilingDraftNotifier, CompanyFilingDraft>((
      ref,
    ) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final entity =
          selectedEntity == companyAllEntities
              ? 'PT Kaysir Nusantara'
              : selectedEntity;
      return CompanyFilingDraftNotifier(
        CompanyFilingDraft.empty(entityName: entity),
      );
    });

final companySignatoriesProvider =
    StateNotifierProvider<CompanySignatoryNotifier, List<CompanySignatory>>((
      ref,
    ) {
      return CompanySignatoryNotifier(companySeedSignatories);
    });

final companySignatoryDraftProvider =
    StateNotifierProvider<CompanySignatoryDraftNotifier, CompanySignatoryDraft>(
      (ref) {
        final selectedEntity = ref.watch(companySelectedEntityProvider);
        final entity =
            selectedEntity == companyAllEntities
                ? 'PT Kaysir Nusantara'
                : selectedEntity;
        return CompanySignatoryDraftNotifier(
          CompanySignatoryDraft.empty(entityName: entity),
        );
      },
    );

final companyEntityLifecycleDraftProvider = StateNotifierProvider<
  CompanyEntityLifecycleDraftNotifier,
  CompanyEntityLifecycleDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyEntityLifecycleDraftNotifier(
    CompanyEntityLifecycleDraft.empty(entityName: entity),
  );
});

final companyChangeRequestsProvider = StateNotifierProvider<
  CompanyChangeRequestNotifier,
  List<CompanyChangeRequest>
>((ref) {
  return CompanyChangeRequestNotifier(companySeedChangeRequests);
});

final companyChangeRequestDraftProvider = StateNotifierProvider<
  CompanyChangeRequestDraftNotifier,
  CompanyChangeRequestDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyChangeRequestDraftNotifier(
    CompanyChangeRequestDraft.empty(entityName: entity),
  );
});

final companyLegalEntitiesProvider =
    StateNotifierProvider<CompanyLegalEntityNotifier, List<CompanyLegalEntity>>(
      (ref) {
        return CompanyLegalEntityNotifier(companySeedLegalEntities);
      },
    );

final companyLegalEntityDraftProvider = StateNotifierProvider<
  CompanyLegalEntityDraftNotifier,
  CompanyLegalEntityDraft
>((ref) {
  return CompanyLegalEntityDraftNotifier(CompanyLegalEntityDraft.empty());
});

final companyWorkLocationsProvider = StateNotifierProvider<
  CompanyWorkLocationNotifier,
  List<CompanyWorkLocation>
>((ref) {
  return CompanyWorkLocationNotifier(companySeedWorkLocations);
});

final companyWorkLocationDraftProvider = StateNotifierProvider<
  CompanyWorkLocationDraftNotifier,
  CompanyWorkLocationDraft
>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final entity =
      selectedEntity == companyAllEntities
          ? 'PT Kaysir Nusantara'
          : selectedEntity;
  return CompanyWorkLocationDraftNotifier(
    CompanyWorkLocationDraft.empty(entityName: entity),
  );
});

final companyOrgUnitDraftProvider =
    StateNotifierProvider<CompanyOrgUnitDraftNotifier, CompanyOrgUnitDraft>((
      ref,
    ) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final entity =
          selectedEntity == companyAllEntities
              ? 'PT Kaysir Nusantara'
              : selectedEntity;
      return CompanyOrgUnitDraftNotifier(
        CompanyOrgUnitDraft.empty(entityName: entity),
      );
    });

final companyPoliciesProvider =
    StateNotifierProvider<CompanyPolicyNotifier, List<CompanyPolicySetting>>((
      ref,
    ) {
      return CompanyPolicyNotifier(companySeedPolicies);
    });

CompanyEmployeeDocumentEvidenceSnapshot _employeeDocumentEvidenceSnapshot({
  required String employeeId,
  required List<EmployeeComplianceDocumentRecord> records,
  required List<EmployeeDocumentRequest> requests,
}) {
  return CompanyEmployeeDocumentEvidenceSnapshot(
    employeeId: employeeId,
    verifiedDocumentCount:
        records
            .where(
              (record) =>
                  record.status == EmployeeComplianceDocumentStatus.verified,
            )
            .length,
    pendingDocumentCount:
        records
            .where(
              (record) =>
                  record.status == EmployeeComplianceDocumentStatus.pending,
            )
            .length,
    rejectedDocumentCount:
        records
            .where(
              (record) =>
                  record.status == EmployeeComplianceDocumentStatus.rejected,
            )
            .length,
    openRequestCount: requests.where((request) => !request.isClosed).length,
  );
}

final companyEntitiesProvider = Provider<List<String>>((ref) {
  final entities =
      ref
          .watch(companyLegalEntitiesProvider)
          .map((entity) => entity.name)
          .where((entity) => entity.trim().isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return [companyAllEntities, ...entities];
});

final filteredCompanyLegalEntitiesProvider = Provider<List<CompanyLegalEntity>>(
  (ref) {
    final selectedEntity = ref.watch(companySelectedEntityProvider);
    final attentionOnly = ref.watch(companyAttentionOnlyProvider);
    return ref
        .watch(companyLegalEntitiesProvider)
        .where(
          (entity) =>
              (selectedEntity == companyAllEntities ||
                  entity.name == selectedEntity) &&
              (!attentionOnly || entity.requiresAttention),
        )
        .toList();
  },
);

final filteredCompanyWorkLocationsProvider =
    Provider<List<CompanyWorkLocation>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      return ref
          .watch(companyWorkLocationsProvider)
          .where(
            (location) =>
                (selectedEntity == companyAllEntities ||
                    location.entityName == selectedEntity) &&
                (!attentionOnly || location.requiresAttention),
          )
          .toList();
    });

final filteredCompanyOrgUnitsProvider = Provider<List<CompanyOrgUnit>>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  return ref
      .watch(companyOrgUnitsProvider)
      .where(
        (unit) =>
            (selectedEntity == companyAllEntities ||
                unit.entityName == selectedEntity) &&
            (!attentionOnly || unit.needsAttention),
      )
      .toList();
});

final filteredCompanyCostCentersProvider = Provider<List<CompanyCostCenter>>((
  ref,
) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  return ref
      .watch(companyCostCentersProvider)
      .where(
        (center) =>
            (selectedEntity == companyAllEntities ||
                center.entityName == selectedEntity) &&
            (!attentionOnly || center.requiresAttention),
      )
      .toList();
});

final filteredCompanyPositionControlsProvider =
    Provider<List<CompanyPositionControl>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyPositionControlsProvider)
          .where(
            (position) =>
                (selectedEntity == companyAllEntities ||
                    position.entityName == selectedEntity) &&
                (!attentionOnly || position.requiresAttention(asOfDate)),
          )
          .toList();
    });

final companyWorkforcePlanProvider = Provider<CompanyWorkforcePlan>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final asOfDate = ref.watch(companyAsOfDateProvider);

  bool matchesEntity(String entityName) {
    return selectedEntity == companyAllEntities || entityName == selectedEntity;
  }

  return buildCompanyWorkforcePlan(
    positions:
        ref
            .watch(companyPositionControlsProvider)
            .where((position) => matchesEntity(position.entityName))
            .toList(),
    costCenters:
        ref
            .watch(companyCostCentersProvider)
            .where((center) => matchesEntity(center.entityName))
            .toList(),
    compensationBands:
        ref
            .watch(companyCompensationBandsProvider)
            .where((band) => matchesEntity(band.entityName))
            .toList(),
    jobProfiles:
        ref
            .watch(companyJobProfilesProvider)
            .where((profile) => matchesEntity(profile.entityName))
            .toList(),
    asOfDate: asOfDate,
  );
});

final filteredCompanyHeadcountRequisitionsProvider =
    Provider<List<CompanyHeadcountRequisition>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyHeadcountRequisitionsProvider)
          .where(
            (request) =>
                (selectedEntity == companyAllEntities ||
                    request.entityName == selectedEntity) &&
                (!attentionOnly || request.requiresAttention(asOfDate)),
          )
          .toList();
    });

final companyHeadcountRequisitionActivityTimelineProvider =
    Provider<CompanyHeadcountRequisitionActivityTimeline>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final requisitionIds =
          ref
              .watch(companyHeadcountRequisitionsProvider)
              .where(
                (request) =>
                    selectedEntity == companyAllEntities ||
                    request.entityName == selectedEntity,
              )
              .map((request) => request.id)
              .toSet();

      return CompanyHeadcountRequisitionActivityTimeline(
        records:
            ref
                .watch(companyHeadcountRequisitionActivityRecordsProvider)
                .where(
                  (record) => requisitionIds.contains(record.requisitionId),
                )
                .toList(),
      );
    });

final filteredCompanyCompensationBandsProvider =
    Provider<List<CompanyCompensationBand>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyCompensationBandsProvider)
          .where(
            (band) =>
                (selectedEntity == companyAllEntities ||
                    band.entityName == selectedEntity) &&
                (!attentionOnly || band.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyJobProfilesProvider = Provider<List<CompanyJobProfile>>((
  ref,
) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  final asOfDate = ref.watch(companyAsOfDateProvider);
  return ref
      .watch(companyJobProfilesProvider)
      .where(
        (profile) =>
            (selectedEntity == companyAllEntities ||
                profile.entityName == selectedEntity) &&
            (!attentionOnly || profile.requiresAttention(asOfDate)),
      )
      .toList();
});

final filteredCompanyContractTemplatesProvider =
    Provider<List<CompanyContractTemplate>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyContractTemplatesProvider)
          .where(
            (template) =>
                (selectedEntity == companyAllEntities ||
                    template.entityName == selectedEntity) &&
                (!attentionOnly || template.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyOnboardingPacksProvider =
    Provider<List<CompanyOnboardingPack>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyOnboardingPacksProvider)
          .where(
            (pack) =>
                (selectedEntity == companyAllEntities ||
                    pack.entityName == selectedEntity) &&
                (!attentionOnly || pack.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyProbationPlansProvider =
    Provider<List<CompanyProbationPlan>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyProbationPlansProvider)
          .where(
            (plan) =>
                (selectedEntity == companyAllEntities ||
                    plan.entityName == selectedEntity) &&
                (!attentionOnly || plan.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyOffboardingPacksProvider =
    Provider<List<CompanyOffboardingPack>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyOffboardingPacksProvider)
          .where(
            (pack) =>
                (selectedEntity == companyAllEntities ||
                    pack.entityName == selectedEntity) &&
                (!attentionOnly || pack.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyDocumentRequirementsProvider =
    Provider<List<CompanyDocumentRequirement>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyDocumentRequirementsProvider)
          .where(
            (requirement) =>
                (selectedEntity == companyAllEntities ||
                    requirement.entityName == selectedEntity) &&
                (!attentionOnly || requirement.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyEmployeeDocumentGapsProvider =
    Provider<List<CompanyEmployeeDocumentGap>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyEmployeeDocumentGapsProvider)
          .where(
            (gap) =>
                (selectedEntity == companyAllEntities ||
                    gap.entityName == selectedEntity) &&
                (!attentionOnly || gap.requiresAttention(asOfDate)),
          )
          .toList();
    });

final companyEmployeeDocumentGapRecommendationsProvider =
    Provider<List<CompanyEmployeeDocumentGapRecommendation>>((ref) {
      return buildCompanyEmployeeDocumentGapRecommendations(
        gaps: ref.watch(filteredCompanyEmployeeDocumentGapsProvider),
        asOfDate: ref.watch(companyAsOfDateProvider),
      );
    });

final companyEmployeeDocumentWorkloadsProvider =
    Provider<List<CompanyEmployeeDocumentWorkload>>((ref) {
      return buildCompanyEmployeeDocumentWorkloads(
        gaps: ref.watch(filteredCompanyEmployeeDocumentGapsProvider),
        recommendations: ref.watch(
          companyEmployeeDocumentGapRecommendationsProvider,
        ),
        asOfDate: ref.watch(companyAsOfDateProvider),
      );
    });

final companyEmployeeDocumentWorkloadDigestStatusesProvider =
    Provider<List<CompanyEmployeeDocumentWorkloadDigestStatus>>((ref) {
      return buildCompanyEmployeeDocumentWorkloadDigestStatuses(
        workloads: ref.watch(companyEmployeeDocumentWorkloadsProvider),
        auditEvents: ref.watch(companyDocumentAuditEventsProvider),
      );
    });

final companyEmployeeDocumentEscalationPlansProvider =
    Provider<List<EmployeeDocumentEscalationPlan>>((ref) {
      return buildEmployeeDocumentEscalationPlans(
        workloads: ref.watch(companyEmployeeDocumentWorkloadsProvider),
        digestStatuses: ref.watch(
          companyEmployeeDocumentWorkloadDigestStatusesProvider,
        ),
        escalationStatuses: ref.watch(
          companyEmployeeDocumentEscalationStatusesProvider,
        ),
        asOfDate: ref.watch(companyAsOfDateProvider),
      );
    });

final companyEmployeeDocumentEscalationStatusesProvider =
    Provider<List<EmployeeDocumentEscalationStatus>>((ref) {
      return buildEmployeeDocumentEscalationStatuses(
        workloads: ref.watch(companyEmployeeDocumentWorkloadsProvider),
        auditEvents: ref.watch(companyDocumentAuditEventsProvider),
      );
    });

final companyEmployeeDocumentEscalationHistoryProvider =
    Provider<EmployeeDocumentEscalationHistory>((ref) {
      return buildEmployeeDocumentEscalationHistory(
        workloads: ref.watch(companyEmployeeDocumentWorkloadsProvider),
        auditEvents: ref.watch(companyDocumentAuditEventsProvider),
      );
    });

final companyEmployeeDocumentEscalationFollowUpsProvider =
    Provider<List<EmployeeDocumentEscalationFollowUp>>((ref) {
      return buildEmployeeDocumentEscalationFollowUps(
        plans: ref.watch(companyEmployeeDocumentEscalationPlansProvider),
        auditEvents: ref.watch(companyDocumentAuditEventsProvider),
        asOfDate: ref.watch(companyAsOfDateProvider),
      );
    });

final companyEmployeeDocumentDigestHistoryProvider =
    Provider<EmployeeDocumentDigestHistory>((ref) {
      return buildEmployeeDocumentDigestHistory(
        workloads: ref.watch(companyEmployeeDocumentWorkloadsProvider),
        auditEvents: ref.watch(companyDocumentAuditEventsProvider),
      );
    });

final filteredCompanyApprovalRulesProvider =
    Provider<List<CompanyApprovalRule>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      return ref
          .watch(companyApprovalRulesProvider)
          .where(
            (rule) =>
                (selectedEntity == companyAllEntities ||
                    rule.entityName == selectedEntity) &&
                (!attentionOnly || rule.requiresAttention),
          )
          .toList();
    });

final filteredCompanyDocumentsProvider = Provider<List<CompanyDocumentRecord>>((
  ref,
) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  final asOfDate = ref.watch(companyAsOfDateProvider);
  return ref
      .watch(companyDocumentsProvider)
      .where(
        (document) =>
            (selectedEntity == companyAllEntities ||
                document.entityName == selectedEntity) &&
            (!attentionOnly || document.requiresAttention(asOfDate)),
      )
      .toList();
});

final filteredCompanyDocumentRenewalsProvider =
    Provider<List<CompanyDocumentRenewalTask>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyDocumentRenewalsProvider)
          .where(
            (task) =>
                (selectedEntity == companyAllEntities ||
                    task.entityName == selectedEntity) &&
                (!attentionOnly || task.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyDocumentAuditEventsProvider =
    Provider<List<CompanyDocumentAuditEvent>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final filter = ref.watch(companyDocumentAuditFilterProvider);
      final events =
          ref
              .watch(companyDocumentAuditEventsProvider)
              .where(
                (event) =>
                    (selectedEntity == companyAllEntities ||
                        event.entityName == selectedEntity) &&
                    filter.matches(event),
              )
              .toList();
      events.sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
      return events;
    });

final companyDocumentAuditActivitySummaryProvider =
    Provider<CompanyDocumentAuditActivitySummary>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final allEntityEvents =
          ref
              .watch(companyDocumentAuditEventsProvider)
              .where(
                (event) =>
                    selectedEntity == companyAllEntities ||
                    event.entityName == selectedEntity,
              )
              .toList();

      return CompanyDocumentAuditActivitySummary.fromEvents(
        allEvents: allEntityEvents,
        filteredEvents: ref.watch(filteredCompanyDocumentAuditEventsProvider),
      );
    });

final companySelectedDocumentAuditDetailProvider =
    Provider<CompanyDocumentAuditDetail?>((ref) {
      final selectedEventId = ref.watch(
        companySelectedDocumentAuditEventIdProvider,
      );
      if (selectedEventId == null) return null;

      final event =
          ref
              .watch(companyDocumentAuditEventsProvider)
              .where((item) => item.id == selectedEventId)
              .firstOrNull;
      if (event == null) return null;

      final companyDocument =
          ref
              .watch(companyDocumentsProvider)
              .where((document) => document.id == event.documentId)
              .firstOrNull;
      final correlationId =
          event.correlationId.trim().isEmpty
              ? event.documentId
              : event.correlationId;
      final employeeGap =
          event.type.isEmployeeDocumentEvent
              ? ref
                  .watch(companyEmployeeDocumentGapsProvider)
                  .where((gap) => gap.id == correlationId)
                  .firstOrNull
              : null;
      final requestProfile =
          employeeGap == null
              ? null
              : ref.watch(
                employeeDocumentRequestProfileProvider(employeeGap.employeeId),
              );
      final request =
          employeeGap == null || requestProfile == null
              ? null
              : requestProfile.requests
                  .where(
                    (item) => employeeDocumentRequestMatchesCompanyGap(
                      request: item,
                      gap: employeeGap,
                    ),
                  )
                  .firstOrNull;
      final evidenceRecords =
          employeeGap == null
              ? const <EmployeeComplianceDocumentRecord>[]
              : ref
                  .watch(
                    employeeComplianceRecordsProvider(employeeGap.employeeId),
                  )
                  .where(
                    (record) => employeeComplianceRecordMatchesCompanyGap(
                      record: record,
                      gap: employeeGap,
                    ),
                  )
                  .toList();

      return CompanyDocumentAuditDetail(
        event: event,
        companyDocument: companyDocument,
        employeeDocumentGap: employeeGap,
        employeeDocumentRequest: request,
        evidenceRecords: evidenceRecords,
      );
    });

final filteredCompanyOperatingReadinessProvider =
    Provider<List<CompanyOperatingReadinessItem>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyOperatingReadinessProvider)
          .where(
            (item) =>
                (selectedEntity == companyAllEntities ||
                    item.entityName == selectedEntity) &&
                (!attentionOnly || item.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyGovernanceContactsProvider =
    Provider<List<CompanyGovernanceContact>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyGovernanceContactsProvider)
          .where(
            (contact) =>
                (selectedEntity == companyAllEntities ||
                    contact.entityName == selectedEntity) &&
                (!attentionOnly || contact.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyEntityLifecyclesProvider =
    Provider<List<CompanyEntityLifecycleMilestone>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyEntityLifecyclesProvider)
          .where(
            (milestone) =>
                (selectedEntity == companyAllEntities ||
                    milestone.entityName == selectedEntity) &&
                (!attentionOnly || milestone.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyControlsProvider = Provider<List<CompanyControl>>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  final asOfDate = ref.watch(companyAsOfDateProvider);
  return ref
      .watch(companyControlsProvider)
      .where(
        (control) =>
            (selectedEntity == companyAllEntities ||
                control.entityName == selectedEntity) &&
            (!attentionOnly || control.requiresAttention(asOfDate)),
      )
      .toList();
});

final filteredCompanyEmployerAccountsProvider =
    Provider<List<CompanyEmployerAccount>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyEmployerAccountsProvider)
          .where(
            (account) =>
                (selectedEntity == companyAllEntities ||
                    account.entityName == selectedEntity) &&
                (!attentionOnly || account.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyVendorAgreementsProvider =
    Provider<List<CompanyVendorAgreement>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyVendorAgreementsProvider)
          .where(
            (agreement) =>
                (selectedEntity == companyAllEntities ||
                    agreement.entityName == selectedEntity) &&
                (!attentionOnly || agreement.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyFilingsProvider = Provider<List<CompanyFiling>>((ref) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  final asOfDate = ref.watch(companyAsOfDateProvider);
  final filings =
      ref
          .watch(companyFilingsProvider)
          .where(
            (filing) =>
                (selectedEntity == companyAllEntities ||
                    filing.entityName == selectedEntity) &&
                (!attentionOnly || filing.requiresAttention(asOfDate)),
          )
          .toList();
  filings.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return filings;
});

final filteredCompanySignatoriesProvider = Provider<List<CompanySignatory>>((
  ref,
) {
  final selectedEntity = ref.watch(companySelectedEntityProvider);
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  final asOfDate = ref.watch(companyAsOfDateProvider);
  return ref
      .watch(companySignatoriesProvider)
      .where(
        (signatory) =>
            (selectedEntity == companyAllEntities ||
                signatory.entityName == selectedEntity) &&
            (!attentionOnly || signatory.requiresAttention(asOfDate)),
      )
      .toList();
});

final companyGovernanceActionItemsProvider =
    Provider<List<CompanyGovernanceActionItem>>((ref) {
      return buildCompanyGovernanceActionItems(
        filings: ref.watch(filteredCompanyFilingsProvider),
        employerAccounts: ref.watch(filteredCompanyEmployerAccountsProvider),
        vendorAgreements: ref.watch(filteredCompanyVendorAgreementsProvider),
        signatories: ref.watch(filteredCompanySignatoriesProvider),
        asOfDate: ref.watch(companyAsOfDateProvider),
      );
    });

final companyGovernanceOwnerLoadsProvider =
    Provider<List<CompanyGovernanceOwnerLoad>>((ref) {
      return buildCompanyGovernanceOwnerLoads(
        items: ref.watch(companyGovernanceActionItemsProvider),
      );
    });

final companyGovernanceOwnerHandoffProvider =
    Provider<CompanyGovernanceOwnerHandoff?>((ref) {
      return buildCompanyGovernanceOwnerHandoff(
        items: ref.watch(companyGovernanceActionItemsProvider),
        ownerName: ref.watch(companySelectedGovernanceOwnerProvider),
      );
    });

final companySelectedGovernanceOwnerHandoffRecordProvider =
    Provider<CompanyGovernanceOwnerHandoffRecord?>((ref) {
      return latestCompanyGovernanceOwnerHandoffRecord(
        records: ref.watch(companyGovernanceOwnerHandoffRecordsProvider),
        ownerName: ref.watch(companySelectedGovernanceOwnerProvider),
      );
    });

final companyGovernanceOwnerHandoffHistoryProvider =
    Provider<CompanyGovernanceOwnerHandoffHistory>((ref) {
      return CompanyGovernanceOwnerHandoffHistory.fromRecords(
        records: ref.watch(companyGovernanceOwnerHandoffRecordsProvider),
      );
    });

final companyGovernanceFollowUpPolicyProvider = StateNotifierProvider<
  CompanyGovernanceFollowUpPolicyNotifier,
  CompanyGovernanceFollowUpPolicy
>((ref) {
  return CompanyGovernanceFollowUpPolicyNotifier();
});

final companyGovernanceFollowUpPolicyDraftProvider = StateNotifierProvider<
  CompanyGovernanceFollowUpPolicyDraftNotifier,
  CompanyGovernanceFollowUpPolicyDraft
>((ref) {
  return CompanyGovernanceFollowUpPolicyDraftNotifier(
    CompanyGovernanceFollowUpPolicyDraft.fromPolicy(
      ref.watch(companyGovernanceFollowUpPolicyProvider),
    ),
  );
});

final companyGovernanceFollowUpPolicyImpactProvider =
    Provider<CompanyGovernanceFollowUpPolicyImpact>((ref) {
      return buildCompanyGovernanceFollowUpPolicyImpact(
        currentPolicy: ref.watch(companyGovernanceFollowUpPolicyProvider),
        draft: ref.watch(companyGovernanceFollowUpPolicyDraftProvider),
        loads: ref.watch(companyGovernanceOwnerLoadsProvider),
        handoffRecords: ref.watch(companyGovernanceOwnerHandoffRecordsProvider),
        auditEvents: ref.watch(companyDocumentAuditEventsProvider),
        asOfDate: ref.watch(companyAsOfDateProvider),
      );
    });

final companyGovernanceFollowUpPolicyApprovalRequestsProvider =
    StateNotifierProvider<
      CompanyGovernanceFollowUpPolicyApprovalRequestNotifier,
      List<CompanyGovernanceFollowUpPolicyApprovalRequest>
    >((ref) {
      return CompanyGovernanceFollowUpPolicyApprovalRequestNotifier();
    });

final companyGovernanceFollowUpPolicyApprovalQueueProvider =
    Provider<CompanyGovernanceFollowUpPolicyApprovalQueue>((ref) {
      return CompanyGovernanceFollowUpPolicyApprovalQueue(
        records: ref.watch(
          companyGovernanceFollowUpPolicyApprovalRequestsProvider,
        ),
      );
    });

final companyGovernanceFollowUpPolicyChangeRecordsProvider =
    StateNotifierProvider<
      CompanyGovernanceFollowUpPolicyChangeRecordNotifier,
      List<CompanyGovernanceFollowUpPolicyChangeRecord>
    >((ref) {
      return CompanyGovernanceFollowUpPolicyChangeRecordNotifier();
    });

final companyGovernanceFollowUpPolicyHistoryProvider =
    Provider<CompanyGovernanceFollowUpPolicyHistory>((ref) {
      return CompanyGovernanceFollowUpPolicyHistory(
        records: ref.watch(
          companyGovernanceFollowUpPolicyChangeRecordsProvider,
        ),
      );
    });

final companyGovernanceFollowUpCadenceProvider =
    Provider<List<CompanyGovernanceFollowUpLane>>((ref) {
      return buildCompanyGovernanceFollowUpCadence(
        loads: ref.watch(companyGovernanceOwnerLoadsProvider),
        handoffRecords: ref.watch(companyGovernanceOwnerHandoffRecordsProvider),
        auditEvents: ref.watch(companyDocumentAuditEventsProvider),
        asOfDate: ref.watch(companyAsOfDateProvider),
        policy: ref.watch(companyGovernanceFollowUpPolicyProvider),
      );
    });

final companyGovernanceSavedViewsProvider =
    Provider<List<CompanyGovernanceSavedView>>((ref) {
      return buildCompanyGovernanceSavedViews(
        actions: ref.watch(companyGovernanceActionItemsProvider),
        followUpLanes: ref.watch(companyGovernanceFollowUpCadenceProvider),
      );
    });

final companySelectedGovernanceSavedViewDetailProvider =
    Provider<CompanyGovernanceSavedView>((ref) {
      return selectedCompanyGovernanceSavedView(
        views: ref.watch(companyGovernanceSavedViewsProvider),
        selectedType: ref.watch(companySelectedGovernanceSavedViewProvider),
      );
    });

final companyGovernanceCommandBriefProvider =
    Provider<CompanyGovernanceCommandBrief>((ref) {
      return buildCompanyGovernanceCommandBrief(
        selectedView: ref.watch(
          companySelectedGovernanceSavedViewDetailProvider,
        ),
        actions: ref.watch(companyGovernanceActionItemsProvider),
        followUpLanes: ref.watch(companyGovernanceFollowUpCadenceProvider),
        selectedOwnerName: ref.watch(companySelectedGovernanceOwnerProvider),
      );
    });

final filteredCompanyChangeRequestsProvider =
    Provider<List<CompanyChangeRequest>>((ref) {
      final selectedEntity = ref.watch(companySelectedEntityProvider);
      final attentionOnly = ref.watch(companyAttentionOnlyProvider);
      final asOfDate = ref.watch(companyAsOfDateProvider);
      return ref
          .watch(companyChangeRequestsProvider)
          .where(
            (request) =>
                (selectedEntity == companyAllEntities ||
                    request.entityName == selectedEntity) &&
                (!attentionOnly || request.requiresAttention(asOfDate)),
          )
          .toList();
    });

final filteredCompanyPoliciesProvider = Provider<List<CompanyPolicySetting>>((
  ref,
) {
  final attentionOnly = ref.watch(companyAttentionOnlyProvider);
  return ref
      .watch(companyPoliciesProvider)
      .where((policy) => !attentionOnly || policy.requiresAttention)
      .toList();
});

final companyManagementSummaryProvider = Provider<CompanyManagementSummary>((
  ref,
) {
  return CompanyManagementSummary.fromData(
    profile: ref.watch(companyProfileProvider),
    legalEntities: ref.watch(filteredCompanyLegalEntitiesProvider),
    locations: ref.watch(filteredCompanyWorkLocationsProvider),
    costCenters: ref.watch(filteredCompanyCostCentersProvider),
    positionControls: ref.watch(filteredCompanyPositionControlsProvider),
    compensationBands: ref.watch(filteredCompanyCompensationBandsProvider),
    jobProfiles: ref.watch(filteredCompanyJobProfilesProvider),
    contractTemplates: ref.watch(filteredCompanyContractTemplatesProvider),
    onboardingPacks: ref.watch(filteredCompanyOnboardingPacksProvider),
    probationPlans: ref.watch(filteredCompanyProbationPlansProvider),
    offboardingPacks: ref.watch(filteredCompanyOffboardingPacksProvider),
    documentRequirements: ref.watch(
      filteredCompanyDocumentRequirementsProvider,
    ),
    employeeDocumentGaps: ref.watch(
      filteredCompanyEmployeeDocumentGapsProvider,
    ),
    approvalRules: ref.watch(filteredCompanyApprovalRulesProvider),
    documents: ref.watch(filteredCompanyDocumentsProvider),
    documentRenewals: ref.watch(filteredCompanyDocumentRenewalsProvider),
    documentAuditEvents: ref.watch(filteredCompanyDocumentAuditEventsProvider),
    operatingReadiness: ref.watch(filteredCompanyOperatingReadinessProvider),
    governanceContacts: ref.watch(filteredCompanyGovernanceContactsProvider),
    entityLifecycles: ref.watch(filteredCompanyEntityLifecyclesProvider),
    controls: ref.watch(filteredCompanyControlsProvider),
    employerAccounts: ref.watch(filteredCompanyEmployerAccountsProvider),
    vendorAgreements: ref.watch(filteredCompanyVendorAgreementsProvider),
    filings: ref.watch(filteredCompanyFilingsProvider),
    signatories: ref.watch(filteredCompanySignatoriesProvider),
    changeRequests: ref.watch(filteredCompanyChangeRequestsProvider),
    asOfDate: ref.watch(companyAsOfDateProvider),
    orgUnits: ref.watch(filteredCompanyOrgUnitsProvider),
    policies: ref.watch(filteredCompanyPoliciesProvider),
  );
});

/// Stores recorded governance owner handoffs for the current company session.
class CompanyGovernanceOwnerHandoffRecordNotifier
    extends StateNotifier<List<CompanyGovernanceOwnerHandoffRecord>> {
  CompanyGovernanceOwnerHandoffRecordNotifier() : super(const []);

  CompanyGovernanceOwnerHandoffRecord record({
    required CompanyGovernanceOwnerHandoff handoff,
    required DateTime recordedAt,
    String actorName = 'People Operations',
  }) {
    final record = CompanyGovernanceOwnerHandoffRecord.fromHandoff(
      id: _nextId(),
      handoff: handoff,
      recordedAt: recordedAt,
      actorName: actorName,
    );
    state = [record, ...state];
    return record;
  }

  void attachAuditEvent({
    required String recordId,
    required String auditEventId,
  }) {
    final normalizedAuditEventId = auditEventId.trim();
    if (normalizedAuditEventId.isEmpty) return;

    state = [
      for (final record in state)
        if (record.id == recordId)
          record.copyWith(auditEventId: normalizedAuditEventId)
        else
          record,
    ];
  }

  String _nextId() {
    return 'governance-handoff-${(state.length + 1).toString().padLeft(3, '0')}';
  }
}

/// Stores the active governance follow-up SLA policy for the session.
class CompanyGovernanceFollowUpPolicyNotifier
    extends StateNotifier<CompanyGovernanceFollowUpPolicy> {
  CompanyGovernanceFollowUpPolicyNotifier()
    : super(CompanyGovernanceFollowUpPolicy.defaultPolicy);

  CompanyGovernanceFollowUpPolicy saveDraft(
    CompanyGovernanceFollowUpPolicyDraft draft,
  ) {
    final policy = draft.toPolicy();
    state = policy;
    return policy;
  }

  void restoreDefaults() {
    state = CompanyGovernanceFollowUpPolicy.defaultPolicy;
  }
}

/// Manages editable governance follow-up SLA form state.
class CompanyGovernanceFollowUpPolicyDraftNotifier
    extends StateNotifier<CompanyGovernanceFollowUpPolicyDraft> {
  CompanyGovernanceFollowUpPolicyDraftNotifier(super.state);

  void setCriticalCadenceDays(String value) {
    state = state.copyWith(criticalCadenceDaysText: value);
  }

  void setHighCadenceDays(String value) {
    state = state.copyWith(highCadenceDaysText: value);
  }

  void setSteadyCadenceDays(String value) {
    state = state.copyWith(steadyCadenceDaysText: value);
  }

  void loadPolicy(CompanyGovernanceFollowUpPolicy policy) {
    state = CompanyGovernanceFollowUpPolicyDraft.fromPolicy(policy);
  }
}

/// Stores governance follow-up SLA policy approval requests.
class CompanyGovernanceFollowUpPolicyApprovalRequestNotifier
    extends
        StateNotifier<List<CompanyGovernanceFollowUpPolicyApprovalRequest>> {
  CompanyGovernanceFollowUpPolicyApprovalRequestNotifier() : super(const []);

  CompanyGovernanceFollowUpPolicyApprovalRequest requestApproval({
    required CompanyGovernanceFollowUpPolicy previousPolicy,
    required CompanyGovernanceFollowUpPolicy requestedPolicy,
    required CompanyGovernanceFollowUpPolicyImpact impact,
    required String entityName,
    required DateTime requestedAt,
    String requestedBy = 'People Operations',
  }) {
    final request = CompanyGovernanceFollowUpPolicyApprovalRequest.create(
      id: _nextId(),
      previousPolicy: previousPolicy,
      requestedPolicy: requestedPolicy,
      impact: impact,
      entityName: entityName,
      requestedBy: requestedBy,
      requestedAt: requestedAt,
    );
    state = [request, ...state];
    return request;
  }

  CompanyGovernanceFollowUpPolicyApprovalRequest? approve({
    required String requestId,
    required DateTime decidedAt,
    String decidedBy = 'People Operations',
  }) {
    final request = _requestById(requestId);
    if (request == null || !request.isPending) return null;

    final approved = request.approve(
      decidedBy: decidedBy,
      decidedAt: decidedAt,
    );
    _replace(approved);
    return approved;
  }

  CompanyGovernanceFollowUpPolicyApprovalRequest? reject({
    required String requestId,
    required DateTime decidedAt,
    String decidedBy = 'People Operations',
  }) {
    final request = _requestById(requestId);
    if (request == null || !request.isPending) return null;

    final rejected = request.reject(decidedBy: decidedBy, decidedAt: decidedAt);
    _replace(rejected);
    return rejected;
  }

  void attachAuditEvent({
    required String requestId,
    required String auditEventId,
  }) {
    final request = _requestById(requestId);
    if (request == null) return;

    final normalizedAuditEventId = auditEventId.trim();
    if (normalizedAuditEventId.isEmpty) return;

    _replace(request.copyWith(auditEventId: normalizedAuditEventId));
  }

  CompanyGovernanceFollowUpPolicyApprovalRequest? _requestById(String id) {
    for (final request in state) {
      if (request.id == id) return request;
    }
    return null;
  }

  void _replace(CompanyGovernanceFollowUpPolicyApprovalRequest updated) {
    state = [
      for (final request in state)
        if (request.id == updated.id) updated else request,
    ];
  }

  String _nextId() {
    return 'governance-sla-approval-${(state.length + 1).toString().padLeft(3, '0')}';
  }
}

/// Stores structured governance follow-up SLA policy changes.
class CompanyGovernanceFollowUpPolicyChangeRecordNotifier
    extends StateNotifier<List<CompanyGovernanceFollowUpPolicyChangeRecord>> {
  CompanyGovernanceFollowUpPolicyChangeRecordNotifier() : super(const []);

  CompanyGovernanceFollowUpPolicyChangeRecord recordChange({
    required CompanyGovernanceFollowUpPolicy previousPolicy,
    required CompanyGovernanceFollowUpPolicy nextPolicy,
    required CompanyGovernanceFollowUpPolicyImpact impact,
    required String entityName,
    required DateTime recordedAt,
    String actorName = 'People Operations',
  }) {
    final record = CompanyGovernanceFollowUpPolicyChangeRecord.fromChange(
      id: _nextId(),
      previousPolicy: previousPolicy,
      nextPolicy: nextPolicy,
      impact: impact,
      entityName: entityName,
      actorName: actorName,
      recordedAt: recordedAt,
    );
    state = [record, ...state];
    return record;
  }

  void attachAuditEvent({
    required String recordId,
    required String auditEventId,
  }) {
    final normalizedAuditEventId = auditEventId.trim();
    if (normalizedAuditEventId.isEmpty) return;

    state = [
      for (final record in state)
        if (record.id == recordId)
          record.copyWith(auditEventId: normalizedAuditEventId)
        else
          record,
    ];
  }

  String _nextId() {
    return 'governance-sla-${(state.length + 1).toString().padLeft(3, '0')}';
  }
}

class CompanyProfileNotifier extends StateNotifier<CompanyProfile> {
  CompanyProfileNotifier(super.state);

  CompanyProfile saveDraft(CompanyProfileDraft draft) {
    final profile = draft.toProfile(state.id);
    state = profile;
    return profile;
  }
}

class CompanyProfileDraftNotifier extends StateNotifier<CompanyProfileDraft> {
  CompanyProfileDraftNotifier(super.state);

  void loadProfile(CompanyProfile profile) {
    state = CompanyProfileDraft.fromProfile(profile);
  }

  void setLegalName(String value) {
    state = state.copyWith(legalName: value);
  }

  void setDisplayName(String value) {
    state = state.copyWith(displayName: value);
  }

  void setRegistrationNumber(String value) {
    state = state.copyWith(registrationNumber: value);
  }

  void setTaxId(String value) {
    state = state.copyWith(taxId: value);
  }

  void setIndustry(String value) {
    state = state.copyWith(industry: value);
  }

  void setWebsite(String value) {
    state = state.copyWith(website: value);
  }

  void setHeadquarters(String value) {
    state = state.copyWith(headquarters: value);
  }

  void setPrimaryContact(String value) {
    state = state.copyWith(primaryContact: value);
  }

  void setStatus(CompanyStatus value) {
    state = state.copyWith(status: value);
  }

  void setEmployeeCount(String value) {
    state = state.copyWith(employeeCountText: value);
  }
}

class CompanyCostCenterNotifier extends StateNotifier<List<CompanyCostCenter>> {
  CompanyCostCenterNotifier(List<CompanyCostCenter> centers)
    : super([...centers]);

  CompanyCostCenter submitDraft(CompanyCostCenterDraft draft) {
    final center = draft.toCostCenter(_nextId());
    state = [...state, center];
    return center;
  }

  void markActive(String id) {
    state = [
      for (final center in state)
        if (center.id == id)
          center.copyWith(status: CompanyCostCenterStatus.active)
        else
          center,
    ];
  }

  String _nextId() => 'cc-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyCostCenterDraftNotifier
    extends StateNotifier<CompanyCostCenterDraft> {
  CompanyCostCenterDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyCostCenterDraft.empty(entityName: entityName);
  }

  void setCode(String value) {
    state = state.copyWith(code: value);
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOrgUnitName(String value) {
    state = state.copyWith(orgUnitName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setAnnualBudget(String value) {
    state = state.copyWith(annualBudgetText: value);
  }

  void setAllocatedHeadcount(String value) {
    state = state.copyWith(allocatedHeadcountText: value);
  }

  void setActiveHeadcount(String value) {
    state = state.copyWith(activeHeadcountText: value);
  }

  void setStatus(CompanyCostCenterStatus value) {
    state = state.copyWith(status: value);
  }
}

class CompanyPositionControlNotifier
    extends StateNotifier<List<CompanyPositionControl>> {
  CompanyPositionControlNotifier(List<CompanyPositionControl> positions)
    : super([...positions]);

  CompanyPositionControl submitDraft(CompanyPositionControlDraft draft) {
    final position = draft.toPositionControl(_nextId());
    state = [...state, position];
    return position;
  }

  void approvePosition(String id) {
    state = [
      for (final position in state)
        if (position.id == id)
          position.copyWith(
            status: CompanyPositionControlStatus.approved,
            authorizedSeats:
                position.filledSeats > position.authorizedSeats
                    ? position.filledSeats
                    : position.authorizedSeats,
            compensationBand:
                position.compensationBand.trim().isEmpty
                    ? 'Band reviewed'
                    : position.compensationBand,
            nextReviewDate: DateTime(
              position.nextReviewDate.year,
              position.nextReviewDate.month,
              position.nextReviewDate.day + 90,
            ),
            hiringPlan:
                position.hiringPlan.trim().isEmpty
                    ? 'Position control approved'
                    : position.hiringPlan,
          )
        else
          position,
    ];
  }

  void closeRecruiting(String id) {
    state = [
      for (final position in state)
        if (position.id == id)
          position.copyWith(
            status: CompanyPositionControlStatus.approved,
            filledSeats: position.authorizedSeats,
            nextReviewDate: DateTime(
              position.nextReviewDate.year,
              position.nextReviewDate.month,
              position.nextReviewDate.day + 90,
            ),
            hiringPlan: 'Hiring plan fulfilled',
          )
        else
          position,
    ];
  }

  String _nextId() =>
      'position-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyPositionControlDraftNotifier
    extends StateNotifier<CompanyPositionControlDraft> {
  CompanyPositionControlDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String orgUnitName = 'People Operations',
  }) {
    state = CompanyPositionControlDraft.empty(
      entityName: entityName,
      orgUnitName: orgUnitName,
    );
  }

  void setPositionTitle(String value) {
    state = state.copyWith(positionTitle: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOrgUnitName(String value) {
    state = state.copyWith(orgUnitName: value);
  }

  void setType(CompanyPositionControlType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CompanyPositionControlStatus value) {
    state = state.copyWith(status: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setAuthorizedSeats(String value) {
    state = state.copyWith(authorizedSeatsText: value);
  }

  void setFilledSeats(String value) {
    state = state.copyWith(filledSeatsText: value);
  }

  void setFte(String value) {
    state = state.copyWith(fteText: value);
  }

  void setCompensationBand(String value) {
    state = state.copyWith(compensationBand: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setHiringPlan(String value) {
    state = state.copyWith(hiringPlan: value);
  }

  void setLinkedRequisition(String value) {
    state = state.copyWith(linkedRequisition: value);
  }
}

class CompanyHeadcountRequisitionNotifier
    extends StateNotifier<List<CompanyHeadcountRequisition>> {
  CompanyHeadcountRequisitionNotifier(
    List<CompanyHeadcountRequisition> requisitions,
  ) : super([...requisitions]);

  CompanyHeadcountRequisition submitDraft(
    CompanyHeadcountRequisitionDraft draft,
  ) {
    final requisition = draft.toRequisition(_nextId());
    state = [...state, requisition];
    return requisition;
  }

  void approve(String id) {
    _updateStatus(id, CompanyHeadcountRequisitionStatus.approved);
  }

  void openRecruiting(String id) {
    _updateStatus(id, CompanyHeadcountRequisitionStatus.recruiting);
  }

  void markFilled(String id) {
    _updateStatus(id, CompanyHeadcountRequisitionStatus.filled);
  }

  void _updateStatus(String id, CompanyHeadcountRequisitionStatus status) {
    state = [
      for (final requisition in state)
        if (requisition.id == id)
          requisition.copyWith(status: status)
        else
          requisition,
    ];
  }

  String _nextId() {
    return 'hreq-${(state.length + 1).toString().padLeft(3, '0')}';
  }
}

class CompanyHeadcountRequisitionActivityRecordNotifier
    extends StateNotifier<List<CompanyHeadcountRequisitionActivityRecord>> {
  CompanyHeadcountRequisitionActivityRecordNotifier(
    List<CompanyHeadcountRequisitionActivityRecord> records,
  ) : super([...records]);

  CompanyHeadcountRequisitionActivityRecord record({
    required CompanyHeadcountRequisition requisition,
    required CompanyHeadcountRequisitionActivityType type,
    required DateTime happenedAt,
    String actorName = 'People Operations',
    String note = '',
  }) {
    final record = CompanyHeadcountRequisitionActivityRecord.fromRequisition(
      id: _nextId(),
      requisition: requisition,
      type: type,
      happenedAt: happenedAt,
      actorName: actorName,
      note: note,
    );
    state = [record, ...state];
    return record;
  }

  String _nextId() {
    return 'hreq-activity-${(state.length + 1).toString().padLeft(3, '0')}';
  }
}

class CompanyHeadcountRequisitionDraftNotifier
    extends StateNotifier<CompanyHeadcountRequisitionDraft> {
  CompanyHeadcountRequisitionDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String orgUnitName = 'People Operations',
  }) {
    state = CompanyHeadcountRequisitionDraft.empty(
      entityName: entityName,
      orgUnitName: orgUnitName,
    );
  }

  void setRoleTitle(String value) {
    state = state.copyWith(roleTitle: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOrgUnitName(String value) {
    state = state.copyWith(orgUnitName: value);
  }

  void setHiringManagerName(String value) {
    state = state.copyWith(hiringManagerName: value);
  }

  void setPositionControlId(String value) {
    state = state.copyWith(positionControlId: value);
  }

  void setJobProfileCode(String value) {
    state = state.copyWith(jobProfileCode: value);
  }

  void setCostCenterCode(String value) {
    state = state.copyWith(costCenterCode: value);
  }

  void setType(CompanyHeadcountRequisitionType value) {
    state = state.copyWith(type: value);
  }

  void setPriority(CompanyHeadcountRequisitionPriority value) {
    state = state.copyWith(priority: value);
  }

  void setStatus(CompanyHeadcountRequisitionStatus value) {
    state = state.copyWith(status: value);
  }

  void setRequestedSeats(String value) {
    state = state.copyWith(requestedSeatsText: value);
  }

  void setTargetStartDate(String value) {
    state = state.copyWith(targetStartDateText: value);
  }

  void setBusinessCase(String value) {
    state = state.copyWith(businessCase: value);
  }

  void setBudgetImpact(String value) {
    state = state.copyWith(budgetImpact: value);
  }

  void setApproverRole(String value) {
    state = state.copyWith(approverRole: value);
  }
}

class CompanyCompensationBandNotifier
    extends StateNotifier<List<CompanyCompensationBand>> {
  CompanyCompensationBandNotifier(List<CompanyCompensationBand> bands)
    : super([...bands]);

  CompanyCompensationBand submitDraft(CompanyCompensationBandDraft draft) {
    final band = draft.toBand(_nextId());
    state = [...state, band];
    return band;
  }

  void activateBand(String id) {
    state = [
      for (final band in state)
        if (band.id == id)
          band.copyWith(
            status: CompanyCompensationBandStatus.active,
            approverName:
                band.approverName.trim().isEmpty
                    ? 'Head of People'
                    : band.approverName,
            nextReviewDate: DateTime(
              band.nextReviewDate.year + 1,
              band.nextReviewDate.month,
              band.nextReviewDate.day,
            ),
          )
        else
          band,
    ];
  }

  void markReviewed(String id) {
    state = [
      for (final band in state)
        if (band.id == id)
          band.copyWith(
            status: CompanyCompensationBandStatus.active,
            nextReviewDate: DateTime(
              band.nextReviewDate.year + 1,
              band.nextReviewDate.month,
              band.nextReviewDate.day,
            ),
          )
        else
          band,
    ];
  }

  String _nextId() => 'band-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyCompensationBandDraftNotifier
    extends StateNotifier<CompanyCompensationBandDraft> {
  CompanyCompensationBandDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyCompensationBandDraft.empty(entityName: entityName);
  }

  void setBandCode(String value) {
    state = state.copyWith(bandCode: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setFamily(CompanyCompensationBandFamily value) {
    state = state.copyWith(family: value);
  }

  void setLevelName(String value) {
    state = state.copyWith(levelName: value);
  }

  void setStatus(CompanyCompensationBandStatus value) {
    state = state.copyWith(status: value);
  }

  void setMinSalary(String value) {
    state = state.copyWith(minSalaryText: value);
  }

  void setMidpointSalary(String value) {
    state = state.copyWith(midpointSalaryText: value);
  }

  void setMaxSalary(String value) {
    state = state.copyWith(maxSalaryText: value);
  }

  void setCurrency(String value) {
    state = state.copyWith(currency: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setApproverName(String value) {
    state = state.copyWith(approverName: value);
  }

  void setEffectiveDate(String value) {
    state = state.copyWith(effectiveDateText: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setLinkedPolicy(String value) {
    state = state.copyWith(linkedPolicy: value);
  }
}

class CompanyJobProfileNotifier extends StateNotifier<List<CompanyJobProfile>> {
  CompanyJobProfileNotifier(List<CompanyJobProfile> profiles)
    : super([...profiles]);

  CompanyJobProfile submitDraft(CompanyJobProfileDraft draft) {
    final profile = draft.toJobProfile(_nextId());
    state = [...state, profile];
    return profile;
  }

  void activateProfile(String id) {
    state = [
      for (final profile in state)
        if (profile.id == id)
          profile.copyWith(
            status: CompanyJobProfileStatus.active,
            ownerName:
                profile.ownerName.trim().isEmpty
                    ? 'People Operations'
                    : profile.ownerName,
            jobDescription:
                profile.jobDescription.trim().isEmpty
                    ? 'Job purpose and accountability reviewed.'
                    : profile.jobDescription,
            skillsSummary:
                profile.skillsSummary.trim().isEmpty
                    ? 'Core capabilities reviewed by People Operations.'
                    : profile.skillsSummary,
            nextReviewDate: DateTime(
              profile.nextReviewDate.year + 1,
              profile.nextReviewDate.month,
              profile.nextReviewDate.day,
            ),
          )
        else
          profile,
    ];
  }

  void markReviewed(String id) {
    state = [
      for (final profile in state)
        if (profile.id == id)
          profile.copyWith(
            status: CompanyJobProfileStatus.active,
            nextReviewDate: DateTime(
              profile.nextReviewDate.year + 1,
              profile.nextReviewDate.month,
              profile.nextReviewDate.day,
            ),
          )
        else
          profile,
    ];
  }

  String _nextId() => 'job-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyJobProfileDraftNotifier
    extends StateNotifier<CompanyJobProfileDraft> {
  CompanyJobProfileDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String orgUnitName = 'People Operations',
    String compensationBand = '',
  }) {
    state = CompanyJobProfileDraft.empty(
      entityName: entityName,
      orgUnitName: orgUnitName,
      compensationBand: compensationBand,
    );
  }

  void setJobCode(String value) {
    state = state.copyWith(jobCode: value);
  }

  void setJobTitle(String value) {
    state = state.copyWith(jobTitle: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOrgUnitName(String value) {
    state = state.copyWith(orgUnitName: value);
  }

  void setFamily(CompanyJobFamily value) {
    state = state.copyWith(family: value);
  }

  void setLevelName(String value) {
    state = state.copyWith(levelName: value);
  }

  void setStatus(CompanyJobProfileStatus value) {
    state = state.copyWith(status: value);
  }

  void setCompensationBand(String value) {
    state = state.copyWith(compensationBand: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setJobDescription(String value) {
    state = state.copyWith(jobDescription: value);
  }

  void setSkillsSummary(String value) {
    state = state.copyWith(skillsSummary: value);
  }

  void setLinkedPolicy(String value) {
    state = state.copyWith(linkedPolicy: value);
  }
}

class CompanyContractTemplateNotifier
    extends StateNotifier<List<CompanyContractTemplate>> {
  CompanyContractTemplateNotifier(List<CompanyContractTemplate> templates)
    : super([...templates]);

  CompanyContractTemplate submitDraft(CompanyContractTemplateDraft draft) {
    final template = draft.toContractTemplate(_nextId());
    state = [...state, template];
    return template;
  }

  void activateTemplate(String id) {
    state = [
      for (final template in state)
        if (template.id == id)
          template.copyWith(
            status: CompanyContractTemplateStatus.active,
            ownerName:
                template.ownerName.trim().isEmpty
                    ? 'People Operations'
                    : template.ownerName,
            legalReviewerName:
                template.legalReviewerName.trim().isEmpty
                    ? 'Legal Operations'
                    : template.legalReviewerName,
            signatoryRole:
                template.signatoryRole.trim().isEmpty
                    ? 'Authorized company signatory'
                    : template.signatoryRole,
            language:
                template.language.trim().isEmpty
                    ? 'Bahasa Indonesia'
                    : template.language,
            versionLabel:
                template.versionLabel.trim().isEmpty
                    ? '2026.reviewed'
                    : template.versionLabel,
            clauseSummary:
                template.clauseSummary.trim().isEmpty
                    ? 'Employment template clauses reviewed and approved.'
                    : template.clauseSummary,
            nextReviewDate: DateTime(
              template.nextReviewDate.year + 1,
              template.nextReviewDate.month,
              template.nextReviewDate.day,
            ),
          )
        else
          template,
    ];
  }

  void markReviewed(String id) {
    state = [
      for (final template in state)
        if (template.id == id)
          template.copyWith(
            status: CompanyContractTemplateStatus.active,
            nextReviewDate: DateTime(
              template.nextReviewDate.year + 1,
              template.nextReviewDate.month,
              template.nextReviewDate.day,
            ),
          )
        else
          template,
    ];
  }

  String _nextId() =>
      'contract-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyContractTemplateDraftNotifier
    extends StateNotifier<CompanyContractTemplateDraft> {
  CompanyContractTemplateDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String compensationBand = '',
  }) {
    state = CompanyContractTemplateDraft.empty(
      entityName: entityName,
      jobProfileCode: jobProfileCode,
      compensationBand: compensationBand,
    );
  }

  void setTemplateName(String value) {
    state = state.copyWith(templateName: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyContractTemplateType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CompanyContractTemplateStatus value) {
    state = state.copyWith(status: value);
  }

  void setJobProfileCode(String value) {
    state = state.copyWith(jobProfileCode: value);
  }

  void setCompensationBand(String value) {
    state = state.copyWith(compensationBand: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setLegalReviewerName(String value) {
    state = state.copyWith(legalReviewerName: value);
  }

  void setSignatoryRole(String value) {
    state = state.copyWith(signatoryRole: value);
  }

  void setLanguage(String value) {
    state = state.copyWith(language: value);
  }

  void setVersionLabel(String value) {
    state = state.copyWith(versionLabel: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setClauseSummary(String value) {
    state = state.copyWith(clauseSummary: value);
  }

  void setOnboardingChecklist(String value) {
    state = state.copyWith(onboardingChecklist: value);
  }
}

class CompanyOnboardingPackNotifier
    extends StateNotifier<List<CompanyOnboardingPack>> {
  CompanyOnboardingPackNotifier(List<CompanyOnboardingPack> packs)
    : super([...packs]);

  CompanyOnboardingPack submitDraft(CompanyOnboardingPackDraft draft) {
    final pack = draft.toOnboardingPack(_nextId());
    state = [...state, pack];
    return pack;
  }

  void activatePack(String id) {
    state = [
      for (final pack in state)
        if (pack.id == id)
          pack.copyWith(
            status: CompanyOnboardingPackStatus.active,
            ownerName:
                pack.ownerName.trim().isEmpty
                    ? 'People Operations'
                    : pack.ownerName,
            managerHandoff:
                pack.managerHandoff.trim().isEmpty
                    ? 'Manager kickoff and onboarding owner handoff completed.'
                    : pack.managerHandoff,
            documentChecklist:
                pack.documentChecklist.trim().isEmpty
                    ? 'Identity, tax, payroll, and contract documents captured.'
                    : pack.documentChecklist,
            accessChecklist:
                pack.accessChecklist.trim().isEmpty
                    ? 'Core HRIS and workspace access checklist configured.'
                    : pack.accessChecklist,
            equipmentChecklist:
                pack.equipmentChecklist.trim().isEmpty
                    ? 'Equipment and workspace readiness checklist configured.'
                    : pack.equipmentChecklist,
            requiredTaskCount:
                pack.requiredTaskCount <= 0 ? 10 : pack.requiredTaskCount,
            slaDays: pack.slaDays <= 0 ? 7 : pack.slaDays,
            nextReviewDate: DateTime(
              pack.nextReviewDate.year + 1,
              pack.nextReviewDate.month,
              pack.nextReviewDate.day,
            ),
          )
        else
          pack,
    ];
  }

  void markReviewed(String id) {
    state = [
      for (final pack in state)
        if (pack.id == id)
          pack.copyWith(
            status: CompanyOnboardingPackStatus.active,
            nextReviewDate: DateTime(
              pack.nextReviewDate.year + 1,
              pack.nextReviewDate.month,
              pack.nextReviewDate.day,
            ),
          )
        else
          pack,
    ];
  }

  String _nextId() =>
      'onboarding-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyOnboardingPackDraftNotifier
    extends StateNotifier<CompanyOnboardingPackDraft> {
  CompanyOnboardingPackDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String contractTemplateName = '',
  }) {
    state = CompanyOnboardingPackDraft.empty(
      entityName: entityName,
      jobProfileCode: jobProfileCode,
      contractTemplateName: contractTemplateName,
    );
  }

  void setPackName(String value) {
    state = state.copyWith(packName: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyOnboardingPackType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CompanyOnboardingPackStatus value) {
    state = state.copyWith(status: value);
  }

  void setJobProfileCode(String value) {
    state = state.copyWith(jobProfileCode: value);
  }

  void setContractTemplateName(String value) {
    state = state.copyWith(contractTemplateName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setManagerHandoff(String value) {
    state = state.copyWith(managerHandoff: value);
  }

  void setDocumentChecklist(String value) {
    state = state.copyWith(documentChecklist: value);
  }

  void setAccessChecklist(String value) {
    state = state.copyWith(accessChecklist: value);
  }

  void setEquipmentChecklist(String value) {
    state = state.copyWith(equipmentChecklist: value);
  }

  void setRequiredTaskCount(String value) {
    state = state.copyWith(requiredTaskCountText: value);
  }

  void setAutomationCoverage(String value) {
    state = state.copyWith(automationCoverageText: value);
  }

  void setSlaDays(String value) {
    state = state.copyWith(slaDaysText: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }
}

class CompanyProbationPlanNotifier
    extends StateNotifier<List<CompanyProbationPlan>> {
  CompanyProbationPlanNotifier(List<CompanyProbationPlan> plans)
    : super([...plans]);

  CompanyProbationPlan submitDraft(CompanyProbationPlanDraft draft) {
    final plan = draft.toProbationPlan(_nextId());
    state = [...state, plan];
    return plan;
  }

  void activatePlan(String id) {
    state = [
      for (final plan in state)
        if (plan.id == id)
          plan.copyWith(
            status: CompanyProbationPlanStatus.active,
            ownerName:
                plan.ownerName.trim().isEmpty
                    ? 'People Operations'
                    : plan.ownerName,
            managerRole:
                plan.managerRole.trim().isEmpty
                    ? 'Hiring manager'
                    : plan.managerRole,
            reviewCadenceDays:
                plan.reviewCadenceDays <= 0 ? 30 : plan.reviewCadenceDays,
            checkpointCount:
                plan.checkpointCount <= 0 ? 3 : plan.checkpointCount,
            firstReviewDueDays:
                plan.firstReviewDueDays <= 0 ? 30 : plan.firstReviewDueDays,
            finalDecisionDueDays: _safeFinalDecisionDays(plan),
            successCriteria:
                plan.successCriteria.trim().isEmpty
                    ? 'Role expectations, conduct, delivery quality, and manager readiness confirmed.'
                    : plan.successCriteria,
            feedbackTemplate:
                plan.feedbackTemplate.trim().isEmpty
                    ? 'Manager feedback, peer input, checkpoint notes, and final decision.'
                    : plan.feedbackTemplate,
            nextReviewDate: DateTime(
              plan.nextReviewDate.year + 1,
              plan.nextReviewDate.month,
              plan.nextReviewDate.day,
            ),
          )
        else
          plan,
    ];
  }

  void markReviewed(String id) {
    state = [
      for (final plan in state)
        if (plan.id == id)
          plan.copyWith(
            status: CompanyProbationPlanStatus.active,
            nextReviewDate: DateTime(
              plan.nextReviewDate.year + 1,
              plan.nextReviewDate.month,
              plan.nextReviewDate.day,
            ),
          )
        else
          plan,
    ];
  }

  int _safeFinalDecisionDays(CompanyProbationPlan plan) {
    final firstReview =
        plan.firstReviewDueDays <= 0 ? 30 : plan.firstReviewDueDays;
    if (plan.finalDecisionDueDays <= 0 ||
        plan.finalDecisionDueDays < firstReview) {
      return firstReview + 60;
    }
    return plan.finalDecisionDueDays;
  }

  String _nextId() =>
      'probation-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyProbationPlanDraftNotifier
    extends StateNotifier<CompanyProbationPlanDraft> {
  CompanyProbationPlanDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String onboardingPackName = '',
  }) {
    state = CompanyProbationPlanDraft.empty(
      entityName: entityName,
      jobProfileCode: jobProfileCode,
      onboardingPackName: onboardingPackName,
    );
  }

  void setPlanName(String value) {
    state = state.copyWith(planName: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyProbationPlanType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CompanyProbationPlanStatus value) {
    state = state.copyWith(status: value);
  }

  void setJobProfileCode(String value) {
    state = state.copyWith(jobProfileCode: value);
  }

  void setOnboardingPackName(String value) {
    state = state.copyWith(onboardingPackName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setManagerRole(String value) {
    state = state.copyWith(managerRole: value);
  }

  void setReviewCadenceDays(String value) {
    state = state.copyWith(reviewCadenceDaysText: value);
  }

  void setCheckpointCount(String value) {
    state = state.copyWith(checkpointCountText: value);
  }

  void setFirstReviewDueDays(String value) {
    state = state.copyWith(firstReviewDueDaysText: value);
  }

  void setFinalDecisionDueDays(String value) {
    state = state.copyWith(finalDecisionDueDaysText: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void setFeedbackTemplate(String value) {
    state = state.copyWith(feedbackTemplate: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }
}

class CompanyOffboardingPackNotifier
    extends StateNotifier<List<CompanyOffboardingPack>> {
  CompanyOffboardingPackNotifier(List<CompanyOffboardingPack> packs)
    : super([...packs]);

  CompanyOffboardingPack submitDraft(CompanyOffboardingPackDraft draft) {
    final pack = draft.toOffboardingPack(_nextId());
    state = [...state, pack];
    return pack;
  }

  void activatePack(String id) {
    state = [
      for (final pack in state)
        if (pack.id == id)
          pack.copyWith(
            status: CompanyOffboardingPackStatus.active,
            ownerName:
                pack.ownerName.trim().isEmpty
                    ? 'People Operations'
                    : pack.ownerName,
            managerRole:
                pack.managerRole.trim().isEmpty
                    ? 'Line manager'
                    : pack.managerRole,
            knowledgeTransferPlan:
                pack.knowledgeTransferPlan.trim().isEmpty
                    ? 'Knowledge handover, open work, and successor notes captured.'
                    : pack.knowledgeTransferPlan,
            assetReturnChecklist:
                pack.assetReturnChecklist.trim().isEmpty
                    ? 'Company assets, badge, devices, and workspace access returned.'
                    : pack.assetReturnChecklist,
            accessRevocationChecklist:
                pack.accessRevocationChecklist.trim().isEmpty
                    ? 'Core systems, collaboration tools, and payroll access revoked.'
                    : pack.accessRevocationChecklist,
            finalPayrollChecklist:
                pack.finalPayrollChecklist.trim().isEmpty
                    ? 'Final payroll, leave payout, expenses, and tax documents cleared.'
                    : pack.finalPayrollChecklist,
            documentChecklist:
                pack.documentChecklist.trim().isEmpty
                    ? 'Exit documents, clearance evidence, and certificate captured.'
                    : pack.documentChecklist,
            exitInterviewTemplate:
                pack.exitInterviewTemplate.trim().isEmpty
                    ? 'Exit interview, manager notes, retention signal, and process feedback.'
                    : pack.exitInterviewTemplate,
            requiredTaskCount:
                pack.requiredTaskCount <= 0 ? 12 : pack.requiredTaskCount,
            slaDays: pack.slaDays <= 0 ? 7 : pack.slaDays,
            nextReviewDate: DateTime(
              pack.nextReviewDate.year + 1,
              pack.nextReviewDate.month,
              pack.nextReviewDate.day,
            ),
          )
        else
          pack,
    ];
  }

  void markReviewed(String id) {
    state = [
      for (final pack in state)
        if (pack.id == id)
          pack.copyWith(
            status: CompanyOffboardingPackStatus.active,
            nextReviewDate: DateTime(
              pack.nextReviewDate.year + 1,
              pack.nextReviewDate.month,
              pack.nextReviewDate.day,
            ),
          )
        else
          pack,
    ];
  }

  String _nextId() =>
      'offboarding-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyOffboardingPackDraftNotifier
    extends StateNotifier<CompanyOffboardingPackDraft> {
  CompanyOffboardingPackDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
  }) {
    state = CompanyOffboardingPackDraft.empty(
      entityName: entityName,
      jobProfileCode: jobProfileCode,
    );
  }

  void setPackName(String value) {
    state = state.copyWith(packName: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyOffboardingPackType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CompanyOffboardingPackStatus value) {
    state = state.copyWith(status: value);
  }

  void setJobProfileCode(String value) {
    state = state.copyWith(jobProfileCode: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setManagerRole(String value) {
    state = state.copyWith(managerRole: value);
  }

  void setKnowledgeTransferPlan(String value) {
    state = state.copyWith(knowledgeTransferPlan: value);
  }

  void setAssetReturnChecklist(String value) {
    state = state.copyWith(assetReturnChecklist: value);
  }

  void setAccessRevocationChecklist(String value) {
    state = state.copyWith(accessRevocationChecklist: value);
  }

  void setFinalPayrollChecklist(String value) {
    state = state.copyWith(finalPayrollChecklist: value);
  }

  void setDocumentChecklist(String value) {
    state = state.copyWith(documentChecklist: value);
  }

  void setExitInterviewTemplate(String value) {
    state = state.copyWith(exitInterviewTemplate: value);
  }

  void setRequiredTaskCount(String value) {
    state = state.copyWith(requiredTaskCountText: value);
  }

  void setSlaDays(String value) {
    state = state.copyWith(slaDaysText: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }
}

class CompanyDocumentRequirementNotifier
    extends StateNotifier<List<CompanyDocumentRequirement>> {
  CompanyDocumentRequirementNotifier(List<CompanyDocumentRequirement> rules)
    : super([...rules]);

  CompanyDocumentRequirement submitDraft(
    CompanyDocumentRequirementDraft draft,
  ) {
    final requirement = draft.toDocumentRequirement(_nextId());
    state = [...state, requirement];
    return requirement;
  }

  void activateRequirement(String id) {
    state = [
      for (final requirement in state)
        if (requirement.id == id)
          requirement.copyWith(
            status: CompanyDocumentRequirementStatus.active,
            ownerName:
                requirement.ownerName.trim().isEmpty
                    ? 'People Operations'
                    : requirement.ownerName,
            evidenceOwnerName:
                requirement.evidenceOwnerName.trim().isEmpty
                    ? 'HRIS Document Owner'
                    : requirement.evidenceOwnerName,
            policyReference:
                requirement.policyReference.trim().isEmpty
                    ? 'Employee document policy'
                    : requirement.policyReference,
            collectionChannel:
                requirement.collectionChannel.trim().isEmpty
                    ? 'HRIS document vault'
                    : requirement.collectionChannel,
            storageLocation:
                requirement.storageLocation.trim().isEmpty
                    ? 'Document vault / People Operations'
                    : requirement.storageLocation,
            retentionRule:
                requirement.retentionRule.trim().isEmpty
                    ? 'Employment period + 5 years'
                    : requirement.retentionRule,
            requiredDocumentCount:
                requirement.requiredDocumentCount <= 0
                    ? 6
                    : requirement.requiredDocumentCount,
            nextReviewDate: DateTime(
              requirement.nextReviewDate.year + 1,
              requirement.nextReviewDate.month,
              requirement.nextReviewDate.day,
            ),
          )
        else
          requirement,
    ];
  }

  void markReviewed(String id) {
    state = [
      for (final requirement in state)
        if (requirement.id == id)
          requirement.copyWith(
            status: CompanyDocumentRequirementStatus.active,
            nextReviewDate: DateTime(
              requirement.nextReviewDate.year + 1,
              requirement.nextReviewDate.month,
              requirement.nextReviewDate.day,
            ),
          )
        else
          requirement,
    ];
  }

  String _nextId() => 'docreq-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyDocumentRequirementDraftNotifier
    extends StateNotifier<CompanyDocumentRequirementDraft> {
  CompanyDocumentRequirementDraftNotifier(super.state);

  void clear({
    String entityName = 'PT Kaysir Nusantara',
    String jobProfileCode = '',
    String contractTemplateName = '',
    String onboardingPackName = '',
    String probationPlanName = '',
    String offboardingPackName = '',
  }) {
    state = CompanyDocumentRequirementDraft.empty(
      entityName: entityName,
      jobProfileCode: jobProfileCode,
      contractTemplateName: contractTemplateName,
      onboardingPackName: onboardingPackName,
      probationPlanName: probationPlanName,
      offboardingPackName: offboardingPackName,
    );
  }

  void setRequirementName(String value) {
    state = state.copyWith(requirementName: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setStage(CompanyDocumentRequirementStage value) {
    state = state.copyWith(stage: value);
  }

  void setStatus(CompanyDocumentRequirementStatus value) {
    state = state.copyWith(status: value);
  }

  void setJobProfileCode(String value) {
    state = state.copyWith(jobProfileCode: value);
  }

  void setContractTemplateName(String value) {
    state = state.copyWith(contractTemplateName: value);
  }

  void setOnboardingPackName(String value) {
    state = state.copyWith(onboardingPackName: value);
  }

  void setProbationPlanName(String value) {
    state = state.copyWith(probationPlanName: value);
  }

  void setOffboardingPackName(String value) {
    state = state.copyWith(offboardingPackName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setEvidenceOwnerName(String value) {
    state = state.copyWith(evidenceOwnerName: value);
  }

  void setPolicyReference(String value) {
    state = state.copyWith(policyReference: value);
  }

  void setCollectionChannel(String value) {
    state = state.copyWith(collectionChannel: value);
  }

  void setStorageLocation(String value) {
    state = state.copyWith(storageLocation: value);
  }

  void setRetentionRule(String value) {
    state = state.copyWith(retentionRule: value);
  }

  void setRequiredDocumentCount(String value) {
    state = state.copyWith(requiredDocumentCountText: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }
}

class CompanyEmployeeDocumentGapNotifier
    extends StateNotifier<List<CompanyEmployeeDocumentGap>> {
  final Ref _ref;

  CompanyEmployeeDocumentGapNotifier(
    List<CompanyEmployeeDocumentGap> gaps,
    this._ref,
  ) : super([...gaps]);

  EmployeeDocumentRequest? generateRequest(String id) {
    final gap = _gapById(id);
    if (gap == null ||
        gap.status == CompanyEmployeeDocumentGapStatus.complete ||
        gap.status == CompanyEmployeeDocumentGapStatus.waived) {
      return null;
    }

    final baseDraft = _ref.read(
      employeeDocumentRequestDraftProvider(gap.employeeId),
    );
    if (baseDraft == null) {
      throw StateError('Employee document request draft is unavailable');
    }

    final draft = buildEmployeeDocumentRequestDraftFromGap(
      gap: gap,
      baseDraft: baseDraft,
      actionAsOfDate: _ref.read(companyAsOfDateProvider),
    );
    _recordGapAudit(
      gap: gap,
      type: CompanyDocumentAuditEventType.employeeRequestGenerated,
      note:
          'Generated employee document request for '
          '${gap.missingDocumentCount} missing evidence item'
          '${gap.missingDocumentCount == 1 ? '' : 's'}.',
    );
    final request = _ref
        .read(employeeDocumentRequestProfileProvider(gap.employeeId).notifier)
        .submitDraft(draft);

    if (!mounted) return request;

    state = [
      for (final current in state)
        if (current.id == id)
          current.copyWith(
            openRequestCount: current.openRequestCount + 1,
            status:
                current.status == CompanyEmployeeDocumentGapStatus.blocked
                    ? CompanyEmployeeDocumentGapStatus.blocked
                    : CompanyEmployeeDocumentGapStatus.requested,
          )
        else
          current,
    ];
    return request;
  }

  CompanyEmployeeDocumentVerificationResult markVerified(String id) {
    final gap = _gapById(id);
    if (gap == null || gap.status == CompanyEmployeeDocumentGapStatus.waived) {
      return const CompanyEmployeeDocumentVerificationResult.empty();
    }

    final missingCount = gap.missingDocumentCount;
    final requestIdsToClose = _openGeneratedRequestIds(gap);
    final requestNotifier = _ref.read(
      employeeDocumentRequestProfileProvider(gap.employeeId).notifier,
    );

    if (missingCount <= 0) {
      _recordClosedRequestAudit(gap, requestIdsToClose.length);
      for (final requestId in requestIdsToClose) {
        requestNotifier.issueRequest(requestId);
      }
      if (mounted) {
        _markGapComplete(id);
      }
      return CompanyEmployeeDocumentVerificationResult(
        evidenceRecords: const [],
        closedRequestCount: requestIdsToClose.length,
      );
    }

    final baseDraft = _ref.read(
      employeeComplianceDocumentDraftProvider(gap.employeeId),
    );
    if (baseDraft == null) {
      throw StateError('Employee compliance document draft is unavailable');
    }

    final recordsNotifier = _ref.read(
      employeeComplianceRecordsProvider(gap.employeeId).notifier,
    );
    _recordGapAudit(
      gap: gap,
      type: CompanyDocumentAuditEventType.employeeEvidenceVerified,
      note:
          'Verified $missingCount employee evidence record'
          '${missingCount == 1 ? '' : 's'} from the company gap queue.',
    );
    _recordClosedRequestAudit(gap, requestIdsToClose.length);
    final records = <EmployeeComplianceDocumentRecord>[];
    for (var index = 0; index < missingCount; index++) {
      final record = recordsNotifier.addDraft(
        buildEmployeeComplianceDocumentDraftFromGap(
          gap: gap,
          baseDraft: baseDraft,
          sequenceNumber: gap.verifiedDocumentCount + index + 1,
        ),
      );
      recordsNotifier.verify(record.id);
      records.add(
        record.copyWith(status: EmployeeComplianceDocumentStatus.verified),
      );
    }
    for (final requestId in requestIdsToClose) {
      requestNotifier.issueRequest(requestId);
    }

    final result = CompanyEmployeeDocumentVerificationResult(
      evidenceRecords: records,
      closedRequestCount: requestIdsToClose.length,
    );

    if (!mounted) return result;

    _markGapComplete(id);
    return result;
  }

  void _markGapComplete(String id) {
    state = [
      for (final gap in state)
        if (gap.id == id)
          gap.copyWith(
            verifiedDocumentCount: gap.requiredDocumentCount,
            pendingDocumentCount: 0,
            rejectedDocumentCount: 0,
            openRequestCount: 0,
            status: CompanyEmployeeDocumentGapStatus.complete,
          )
        else
          gap,
    ];
  }

  void waiveGap(String id) {
    final gap = _gapById(id);
    if (gap == null) return;

    _recordGapAudit(
      gap: gap,
      type: CompanyDocumentAuditEventType.employeeGapWaived,
      note: 'Waived employee document gap from the company queue.',
    );
    state = [
      for (final current in state)
        if (current.id == id)
          current.copyWith(status: CompanyEmployeeDocumentGapStatus.waived)
        else
          current,
    ];
  }

  CompanyDocumentAuditEvent? sendOwnerDigest(String ownerName) {
    final asOfDate = _ref.read(companyAsOfDateProvider);
    final workload = _activeOwnerWorkload(ownerName, asOfDate: asOfDate);
    if (workload == null) return null;

    return _ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            workload.ownerName,
          ),
          documentTitle: '${workload.ownerName} - Employee document workload',
          entityName: workload.entitySummary,
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerDigestSent,
          happenedAt: asOfDate,
          note: _ownerDigestNote(workload),
          correlationId: companyEmployeeDocumentOwnerDigestCorrelationId(
            workload.ownerName,
          ),
        );
  }

  List<CompanyDocumentAuditEvent> sendOwnerDigests(
    Iterable<String> ownerNames,
  ) {
    final events = <CompanyDocumentAuditEvent>[];
    final seenOwners = <String>{};
    for (final ownerName in ownerNames) {
      final normalizedOwner = _normalizeOwnerName(ownerName);
      if (!seenOwners.add(normalizedOwner)) continue;

      final event = sendOwnerDigest(ownerName);
      if (event != null) events.add(event);
    }
    return events;
  }

  CompanyDocumentAuditEvent? escalateOwnerWorkload(String ownerName) {
    final asOfDate = _ref.read(companyAsOfDateProvider);
    final workload = _activeOwnerWorkload(ownerName, asOfDate: asOfDate);
    if (workload == null) return null;

    final digestStatuses = buildCompanyEmployeeDocumentWorkloadDigestStatuses(
      workloads: [workload],
      auditEvents: _ref.read(companyDocumentAuditEventsProvider),
    );
    final escalationStatuses = buildEmployeeDocumentEscalationStatuses(
      workloads: [workload],
      auditEvents: _ref.read(companyDocumentAuditEventsProvider),
    );
    final plans = buildEmployeeDocumentEscalationPlans(
      workloads: [workload],
      digestStatuses: digestStatuses,
      escalationStatuses: escalationStatuses,
      asOfDate: asOfDate,
      limit: 1,
    );
    if (plans.isEmpty) return null;

    final plan = plans.first;
    if (plan.escalationCoolingDown) return null;

    return _ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            plan.ownerName,
          ),
          documentTitle: '${plan.ownerName} - Employee document workload',
          entityName: plan.entitySummary,
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerEscalated,
          happenedAt: asOfDate,
          note: _ownerEscalationNote(plan),
          correlationId: companyEmployeeDocumentOwnerEscalationCorrelationId(
            plan.ownerName,
          ),
        );
  }

  List<CompanyDocumentAuditEvent> escalateOwnerWorkloads(
    Iterable<String> ownerNames,
  ) {
    final events = <CompanyDocumentAuditEvent>[];
    final seenOwners = <String>{};
    for (final ownerName in ownerNames) {
      final normalizedOwner = _normalizeOwnerName(ownerName);
      if (!seenOwners.add(normalizedOwner)) continue;

      final event = escalateOwnerWorkload(ownerName);
      if (event != null) events.add(event);
    }
    return events;
  }

  CompanyDocumentAuditEvent? recordOwnerEscalationFollowUp(String ownerName) {
    final asOfDate = _ref.read(companyAsOfDateProvider);
    final workload = _activeOwnerWorkload(ownerName, asOfDate: asOfDate);
    if (workload == null) return null;

    final auditEvents = _ref.read(companyDocumentAuditEventsProvider);
    final digestStatuses = buildCompanyEmployeeDocumentWorkloadDigestStatuses(
      workloads: [workload],
      auditEvents: auditEvents,
    );
    final escalationStatuses = buildEmployeeDocumentEscalationStatuses(
      workloads: [workload],
      auditEvents: auditEvents,
    );
    final plans = buildEmployeeDocumentEscalationPlans(
      workloads: [workload],
      digestStatuses: digestStatuses,
      escalationStatuses: escalationStatuses,
      asOfDate: asOfDate,
      limit: 1,
    );
    if (plans.isEmpty) return null;

    final followUps = buildEmployeeDocumentEscalationFollowUps(
      plans: plans,
      auditEvents: auditEvents,
      asOfDate: asOfDate,
      limit: 1,
    );
    final followUp = followUps.firstOrNull;
    if (followUp == null) return null;

    return _ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: companyEmployeeDocumentOwnerDigestDocumentId(
            followUp.ownerName,
          ),
          documentTitle: '${followUp.ownerName} - Employee document workload',
          entityName: followUp.entitySummary,
          actorName: 'People Operations',
          type: CompanyDocumentAuditEventType.employeeOwnerFollowedUp,
          happenedAt: _ref.read(companyAsOfDateProvider),
          note: _ownerEscalationFollowUpNote(followUp),
          correlationId: companyEmployeeDocumentOwnerFollowUpCorrelationId(
            followUp.ownerName,
          ),
        );
  }

  CompanyEmployeeDocumentWorkload? _activeOwnerWorkload(
    String ownerName, {
    required DateTime asOfDate,
  }) {
    final normalizedOwner = _normalizeOwnerName(ownerName);
    final ownerGaps =
        state
            .where(
              (gap) =>
                  _normalizeOwnerName(_gapOwnerName(gap)) == normalizedOwner &&
                  gap.requiresAttention(asOfDate),
            )
            .toList();
    if (ownerGaps.isEmpty) return null;

    final recommendations = buildCompanyEmployeeDocumentGapRecommendations(
      gaps: ownerGaps,
      asOfDate: asOfDate,
    );
    final workloads = buildCompanyEmployeeDocumentWorkloads(
      gaps: ownerGaps,
      recommendations: recommendations,
      asOfDate: asOfDate,
      limit: 1,
    );
    return workloads.firstOrNull;
  }

  CompanyEmployeeDocumentGap? _gapById(String id) {
    for (final gap in state) {
      if (gap.id == id) return gap;
    }
    return null;
  }

  List<String> _openGeneratedRequestIds(CompanyEmployeeDocumentGap gap) {
    final profile = _ref.read(
      employeeDocumentRequestProfileProvider(gap.employeeId),
    );
    if (profile == null) return const [];

    return profile.requests
        .where(
          (request) =>
              !request.isClosed &&
              employeeDocumentRequestMatchesCompanyGap(
                request: request,
                gap: gap,
              ),
        )
        .map((request) => request.id)
        .toList();
  }

  void _recordClosedRequestAudit(
    CompanyEmployeeDocumentGap gap,
    int closedRequestCount,
  ) {
    if (closedRequestCount <= 0) return;

    _recordGapAudit(
      gap: gap,
      type: CompanyDocumentAuditEventType.employeeRequestClosed,
      note:
          'Closed $closedRequestCount generated employee document request'
          '${closedRequestCount == 1 ? '' : 's'} after evidence verification.',
    );
  }

  void _recordGapAudit({
    required CompanyEmployeeDocumentGap gap,
    required CompanyDocumentAuditEventType type,
    required String note,
  }) {
    _ref
        .read(companyDocumentAuditEventsProvider.notifier)
        .record(
          documentId: gap.id,
          documentTitle: _gapAuditTitle(gap),
          entityName: gap.entityName,
          actorName: _gapAuditActor(gap),
          type: type,
          happenedAt: _ref.read(companyAsOfDateProvider),
          note: note,
          correlationId: gap.id,
        );
  }

  String _gapAuditTitle(CompanyEmployeeDocumentGap gap) {
    return '${gap.employeeName} - ${gap.requirementName}';
  }

  String _gapAuditActor(CompanyEmployeeDocumentGap gap) {
    return gap.ownerName.trim().isEmpty
        ? 'People Operations'
        : gap.ownerName.trim();
  }

  String _gapOwnerName(CompanyEmployeeDocumentGap gap) {
    return gap.ownerName.trim().isEmpty ? 'Unassigned' : gap.ownerName.trim();
  }

  String _normalizeOwnerName(String ownerName) {
    final normalized = ownerName.trim().toLowerCase();
    return normalized.isEmpty ? 'unassigned' : normalized;
  }

  String _ownerDigestNote(CompanyEmployeeDocumentWorkload workload) {
    return 'Sent owner digest for ${workload.gapCount} employee document gap'
        '${workload.gapCount == 1 ? '' : 's'}: '
        '${workload.missingDocumentCount} missing evidence item'
        '${workload.missingDocumentCount == 1 ? '' : 's'}, '
        '${workload.openRequestCount} open request'
        '${workload.openRequestCount == 1 ? '' : 's'}. '
        'Top action: ${workload.primaryAction}'
        '${workload.primaryEmployeeName.trim().isEmpty ? '' : ' for ${workload.primaryEmployeeName}'}.';
  }

  String _ownerEscalationNote(EmployeeDocumentEscalationPlan plan) {
    return 'Escalated owner workload for ${plan.gapCount} employee document gap'
        '${plan.gapCount == 1 ? '' : 's'}: '
        '${plan.priority.label} priority, '
        '${plan.missingDocumentCount} missing evidence item'
        '${plan.missingDocumentCount == 1 ? '' : 's'}, '
        '${plan.openRequestCount} open request'
        '${plan.openRequestCount == 1 ? '' : 's'}. '
        '${plan.rationale} '
        'Top action: ${plan.actionLabel}'
        '${plan.primaryEmployeeName.trim().isEmpty ? '' : ' for ${plan.primaryEmployeeName}'}. '
        'Digest: ${plan.digestFreshnessLabel}, ${plan.digestCadenceLabel}.';
  }

  String _ownerEscalationFollowUpNote(
    EmployeeDocumentEscalationFollowUp followUp,
  ) {
    return 'Recorded owner escalation follow-up for '
        '${followUp.ownerName}: ${followUp.state.label.toLowerCase()}, '
        '${followUp.missingDocumentCount} missing evidence item'
        '${followUp.missingDocumentCount == 1 ? '' : 's'}, '
        '${followUp.openRequestCount} open request'
        '${followUp.openRequestCount == 1 ? '' : 's'}. '
        'Next touch was ${followUp.nextTouchLabel(_ref.read(companyAsOfDateProvider)).toLowerCase()}. '
        'Action: ${followUp.actionLabel}'
        '${followUp.primaryEmployeeName.trim().isEmpty ? '' : ' for ${followUp.primaryEmployeeName}'}.';
  }
}

class CompanyApprovalRuleNotifier
    extends StateNotifier<List<CompanyApprovalRule>> {
  CompanyApprovalRuleNotifier(List<CompanyApprovalRule> rules)
    : super([...rules]);

  CompanyApprovalRule submitDraft(CompanyApprovalRuleDraft draft) {
    final rule = draft.toApprovalRule(_nextId());
    state = [...state, rule];
    return rule;
  }

  void markActive(String id) {
    state = [
      for (final rule in state)
        if (rule.id == id)
          rule.copyWith(status: CompanyApprovalRuleStatus.active, slaHours: 24)
        else
          rule,
    ];
  }

  String _nextId() =>
      'approval-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyApprovalRuleDraftNotifier
    extends StateNotifier<CompanyApprovalRuleDraft> {
  CompanyApprovalRuleDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyApprovalRuleDraft.empty(entityName: entityName);
  }

  void setDomain(CompanyApprovalDomain value) {
    state = state.copyWith(domain: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setScopeName(String value) {
    state = state.copyWith(scopeName: value);
  }

  void setApproverRole(String value) {
    state = state.copyWith(approverRole: value);
  }

  void setBackupApproverRole(String value) {
    state = state.copyWith(backupApproverRole: value);
  }

  void setThresholdLabel(String value) {
    state = state.copyWith(thresholdLabel: value);
  }

  void setSlaHours(String value) {
    state = state.copyWith(slaHoursText: value);
  }

  void setStatus(CompanyApprovalRuleStatus value) {
    state = state.copyWith(status: value);
  }
}

class CompanyDocumentNotifier
    extends StateNotifier<List<CompanyDocumentRecord>> {
  CompanyDocumentNotifier(List<CompanyDocumentRecord> documents)
    : super([...documents]);

  CompanyDocumentRecord submitDraft(CompanyDocumentDraft draft) {
    final document = draft.toDocument(_nextId());
    state = [...state, document];
    return document;
  }

  void markVerified(String id) {
    state = [
      for (final document in state)
        if (document.id == id)
          document.copyWith(status: CompanyDocumentStatus.verified)
        else
          document,
    ];
  }

  String _nextId() => 'doc-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyDocumentDraftNotifier extends StateNotifier<CompanyDocumentDraft> {
  CompanyDocumentDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyDocumentDraft.empty(entityName: entityName);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDocumentNumber(String value) {
    state = state.copyWith(documentNumber: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setType(CompanyDocumentType value) {
    state = state.copyWith(type: value);
  }

  void setIssuedDate(String value) {
    state = state.copyWith(issuedDateText: value);
  }

  void setExpiryDate(String value) {
    state = state.copyWith(expiryDateText: value);
  }

  void setStatus(CompanyDocumentStatus value) {
    state = state.copyWith(status: value);
  }

  void setLinkedModule(String value) {
    state = state.copyWith(linkedModule: value);
  }
}

class CompanyDocumentRenewalNotifier
    extends StateNotifier<List<CompanyDocumentRenewalTask>> {
  CompanyDocumentRenewalNotifier(List<CompanyDocumentRenewalTask> tasks)
    : super([...tasks]);

  CompanyDocumentRenewalTask submitDraft(CompanyDocumentRenewalDraft draft) {
    final task = draft.toRenewalTask(_nextId());
    state = [...state, task];
    return task;
  }

  CompanyDocumentRenewalTask? markInProgress(String id) {
    CompanyDocumentRenewalTask? updatedTask;
    state = [
      for (final task in state)
        if (task.id == id)
          updatedTask = task.copyWith(
            status: CompanyDocumentRenewalStatus.inProgress,
            lastActivity: 'Renewal work started',
            actionLabel:
                task.actionLabel.trim().isEmpty
                    ? 'Complete renewal packet'
                    : task.actionLabel,
          )
        else
          task,
    ];
    return updatedTask;
  }

  CompanyDocumentRenewalTask? markCompleted(String id) {
    CompanyDocumentRenewalTask? updatedTask;
    state = [
      for (final task in state)
        if (task.id == id)
          updatedTask = task.copyWith(
            status: CompanyDocumentRenewalStatus.completed,
            lastActivity: 'Renewal completed',
            actionLabel: 'No action needed.',
          )
        else
          task,
    ];
    return updatedTask;
  }

  String _nextId() =>
      'renewal-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyDocumentRenewalDraftNotifier
    extends StateNotifier<CompanyDocumentRenewalDraft> {
  CompanyDocumentRenewalDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyDocumentRenewalDraft.empty(entityName: entityName);
  }

  void selectDocument(CompanyDocumentRecord document) {
    state = state.copyWith(
      documentId: document.id,
      documentTitle: document.title,
      entityName: document.entityName,
      ownerName:
          state.ownerName.trim().isEmpty ? document.ownerName : state.ownerName,
      dueDateText:
          document.expiryDate == null
              ? state.dueDateText
              : _formatDate(document.expiryDate!),
    );
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setDueDate(String value) {
    state = state.copyWith(dueDateText: value);
  }

  void setReminderLeadDays(String value) {
    state = state.copyWith(reminderLeadDaysText: value);
  }

  void setStatus(CompanyDocumentRenewalStatus value) {
    state = state.copyWith(status: value);
  }

  void setActionLabel(String value) {
    state = state.copyWith(actionLabel: value);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class CompanyDocumentAuditNotifier
    extends StateNotifier<List<CompanyDocumentAuditEvent>> {
  CompanyDocumentAuditNotifier(List<CompanyDocumentAuditEvent> events)
    : super([...events]);

  CompanyDocumentAuditEvent record({
    required String documentId,
    required String documentTitle,
    required String entityName,
    required String actorName,
    required CompanyDocumentAuditEventType type,
    required DateTime happenedAt,
    required String note,
    String correlationId = '',
  }) {
    final event = CompanyDocumentAuditEvent(
      id: _nextId(),
      documentId: documentId,
      documentTitle: documentTitle,
      entityName: entityName,
      actorName: actorName,
      type: type,
      happenedAt: happenedAt,
      note: note,
      correlationId: correlationId.trim(),
    );
    state = [event, ...state];
    return event;
  }

  String _nextId() => 'audit-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyOperatingReadinessNotifier
    extends StateNotifier<List<CompanyOperatingReadinessItem>> {
  CompanyOperatingReadinessNotifier(List<CompanyOperatingReadinessItem> items)
    : super([...items]);

  CompanyOperatingReadinessItem submitDraft(
    CompanyOperatingReadinessDraft draft,
  ) {
    final item = draft.toReadinessItem(_nextId());
    state = [...state, item];
    return item;
  }

  void markReady(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            status: CompanyOperatingReadinessStatus.ready,
            coveragePercent: item.coveragePercent < 100 ? 100 : null,
            blocker: '',
          )
        else
          item,
    ];
  }

  String _nextId() => 'ops-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyOperatingReadinessDraftNotifier
    extends StateNotifier<CompanyOperatingReadinessDraft> {
  CompanyOperatingReadinessDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyOperatingReadinessDraft.empty(entityName: entityName);
  }

  void setArea(CompanyOperatingReadinessArea value) {
    state = state.copyWith(area: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setStatus(CompanyOperatingReadinessStatus value) {
    state = state.copyWith(status: value);
  }

  void setCoveragePercent(String value) {
    state = state.copyWith(coveragePercentText: value);
  }

  void setLastReviewDate(String value) {
    state = state.copyWith(lastReviewDateText: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setBlocker(String value) {
    state = state.copyWith(blocker: value);
  }

  void setLinkedModule(String value) {
    state = state.copyWith(linkedModule: value);
  }
}

class CompanyGovernanceContactNotifier
    extends StateNotifier<List<CompanyGovernanceContact>> {
  CompanyGovernanceContactNotifier(List<CompanyGovernanceContact> contacts)
    : super([...contacts]);

  CompanyGovernanceContact submitDraft(CompanyGovernanceContactDraft draft) {
    final contact = draft.toContact(_nextId());
    state = [...state, contact];
    return contact;
  }

  void markReviewed(String id, DateTime reviewedAt) {
    state = [
      for (final contact in state)
        if (contact.id == id)
          contact.copyWith(
            status:
                contact.backupName.trim().isEmpty
                    ? CompanyGovernanceContactStatus.missingBackup
                    : CompanyGovernanceContactStatus.active,
            lastReviewedAt: reviewedAt,
            nextReviewAt: reviewedAt.add(const Duration(days: 90)),
          )
        else
          contact,
    ];
  }

  void assignBackup(String id, String backupName) {
    state = [
      for (final contact in state)
        if (contact.id == id)
          contact.copyWith(
            backupName: backupName,
            status: CompanyGovernanceContactStatus.active,
          )
        else
          contact,
    ];
  }

  String _nextId() =>
      'contact-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyGovernanceContactDraftNotifier
    extends StateNotifier<CompanyGovernanceContactDraft> {
  CompanyGovernanceContactDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyGovernanceContactDraft.empty(entityName: entityName);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setRole(CompanyGovernanceRole value) {
    state = state.copyWith(role: value);
  }

  void setPersonName(String value) {
    state = state.copyWith(personName: value);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPhone(String value) {
    state = state.copyWith(phone: value);
  }

  void setBackupName(String value) {
    state = state.copyWith(backupName: value);
  }

  void setEscalationChannel(String value) {
    state = state.copyWith(escalationChannel: value);
  }

  void setStatus(CompanyGovernanceContactStatus value) {
    state = state.copyWith(status: value);
  }

  void setLastReviewedAt(String value) {
    state = state.copyWith(lastReviewedAtText: value);
  }

  void setNextReviewAt(String value) {
    state = state.copyWith(nextReviewAtText: value);
  }
}

class CompanyEntityLifecycleNotifier
    extends StateNotifier<List<CompanyEntityLifecycleMilestone>> {
  CompanyEntityLifecycleNotifier(List<CompanyEntityLifecycleMilestone> items)
    : super([...items]);

  CompanyEntityLifecycleMilestone submitDraft(
    CompanyEntityLifecycleDraft draft,
  ) {
    final milestone = draft.toLifecycleMilestone(_nextId());
    state = [...state, milestone];
    return milestone;
  }

  void advance(String id) {
    state = [
      for (final milestone in state)
        if (milestone.id == id)
          milestone.copyWith(
            status:
                milestone.status == CompanyEntityLifecycleStatus.blocked
                    ? CompanyEntityLifecycleStatus.inProgress
                    : milestone.status,
            progressPercent:
                milestone.progressPercent + 20 > 100
                    ? 100
                    : milestone.progressPercent + 20,
            blocker: '',
          )
        else
          milestone,
    ];
  }

  void markLaunched(String id) {
    state = [
      for (final milestone in state)
        if (milestone.id == id)
          milestone.copyWith(
            status: CompanyEntityLifecycleStatus.launched,
            progressPercent: 100,
            blocker: '',
          )
        else
          milestone,
    ];
  }

  String _nextId() =>
      'lifecycle-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyEntityLifecycleDraftNotifier
    extends StateNotifier<CompanyEntityLifecycleDraft> {
  CompanyEntityLifecycleDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyEntityLifecycleDraft.empty(entityName: entityName);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyEntityLifecycleType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CompanyEntityLifecycleStatus value) {
    state = state.copyWith(status: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setTargetDate(String value) {
    state = state.copyWith(targetDateText: value);
  }

  void setProgressPercent(String value) {
    state = state.copyWith(progressPercentText: value);
  }

  void setDependencySummary(String value) {
    state = state.copyWith(dependencySummary: value);
  }

  void setBlocker(String value) {
    state = state.copyWith(blocker: value);
  }

  void setNextMilestone(String value) {
    state = state.copyWith(nextMilestone: value);
  }
}

class CompanyControlNotifier extends StateNotifier<List<CompanyControl>> {
  CompanyControlNotifier(List<CompanyControl> controls) : super([...controls]);

  CompanyControl submitDraft(CompanyControlDraft draft) {
    final control = draft.toControl(_nextId());
    state = [...state, control];
    return control;
  }

  void markRemediated(String id) {
    state = [
      for (final control in state)
        if (control.id == id)
          control.copyWith(
            status: CompanyControlStatus.healthy,
            severity:
                control.severity == CompanyControlSeverity.critical
                    ? CompanyControlSeverity.high
                    : control.severity,
            evidenceSummary:
                control.evidenceSummary.trim().isEmpty
                    ? 'Remediation evidence captured'
                    : control.evidenceSummary,
            remediationAction: '',
            nextReviewDate: control.nextReviewDate.add(
              const Duration(days: 90),
            ),
          )
        else
          control,
    ];
  }

  void waive(String id) {
    state = [
      for (final control in state)
        if (control.id == id)
          control.copyWith(
            status: CompanyControlStatus.waived,
            remediationAction: '',
          )
        else
          control,
    ];
  }

  String _nextId() =>
      'control-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyControlDraftNotifier extends StateNotifier<CompanyControlDraft> {
  CompanyControlDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyControlDraft.empty(entityName: entityName);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setDomain(CompanyControlDomain value) {
    state = state.copyWith(domain: value);
  }

  void setStatus(CompanyControlStatus value) {
    state = state.copyWith(status: value);
  }

  void setSeverity(CompanyControlSeverity value) {
    state = state.copyWith(severity: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setRemediationAction(String value) {
    state = state.copyWith(remediationAction: value);
  }

  void setLinkedRecord(String value) {
    state = state.copyWith(linkedRecord: value);
  }
}

class CompanyEmployerAccountNotifier
    extends StateNotifier<List<CompanyEmployerAccount>> {
  CompanyEmployerAccountNotifier(List<CompanyEmployerAccount> accounts)
    : super([...accounts]);

  CompanyEmployerAccount submitDraft(CompanyEmployerAccountDraft draft) {
    final account = draft.toAccount(_nextId());
    state = [...state, account];
    return account;
  }

  void markVerified(String id) {
    state = [
      for (final account in state)
        if (account.id == id)
          account.copyWith(
            status: CompanyEmployerAccountStatus.verified,
            evidenceSummary:
                account.evidenceSummary.trim().isEmpty
                    ? 'Employer account evidence captured'
                    : account.evidenceSummary,
            nextReviewDate: account.nextReviewDate.add(
              const Duration(days: 90),
            ),
          )
        else
          account,
    ];
  }

  void rotateCredentialOwner(String id, String credentialOwnerName) {
    state = [
      for (final account in state)
        if (account.id == id)
          account.copyWith(
            credentialOwnerName: credentialOwnerName.trim(),
            nextAction: 'Credential ownership rotated and access reviewed',
          )
        else
          account,
    ];
  }

  String _nextId() =>
      'employer-account-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyEmployerAccountDraftNotifier
    extends StateNotifier<CompanyEmployerAccountDraft> {
  CompanyEmployerAccountDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyEmployerAccountDraft.empty(entityName: entityName);
  }

  void setAccountName(String value) {
    state = state.copyWith(accountName: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyEmployerAccountType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(CompanyEmployerAccountStatus value) {
    state = state.copyWith(status: value);
  }

  void setAccountNumber(String value) {
    state = state.copyWith(accountNumber: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setCredentialOwnerName(String value) {
    state = state.copyWith(credentialOwnerName: value);
  }

  void setNextReviewDate(String value) {
    state = state.copyWith(nextReviewDateText: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setLinkedFiling(String value) {
    state = state.copyWith(linkedFiling: value);
  }
}

class CompanyVendorAgreementNotifier
    extends StateNotifier<List<CompanyVendorAgreement>> {
  CompanyVendorAgreementNotifier(List<CompanyVendorAgreement> agreements)
    : super([...agreements]);

  CompanyVendorAgreement submitDraft(CompanyVendorAgreementDraft draft) {
    final agreement = draft.toAgreement(_nextId());
    state = [...state, agreement];
    return agreement;
  }

  void markRenewed(String id) {
    state = [
      for (final agreement in state)
        if (agreement.id == id)
          agreement.copyWith(
            status: CompanyVendorAgreementStatus.active,
            contractEndDate: DateTime(
              agreement.contractEndDate.year + 1,
              agreement.contractEndDate.month,
              agreement.contractEndDate.day,
            ),
            dataProtectionSummary:
                agreement.dataProtectionSummary.trim().isEmpty
                    ? 'DPA renewal evidence captured'
                    : agreement.dataProtectionSummary,
            nextAction: 'Run quarterly vendor performance review',
          )
        else
          agreement,
    ];
  }

  void closeImplementation(String id) {
    state = [
      for (final agreement in state)
        if (agreement.id == id)
          agreement.copyWith(
            status: CompanyVendorAgreementStatus.active,
            accountManagerName:
                agreement.accountManagerName.trim().isEmpty
                    ? 'People Operations'
                    : agreement.accountManagerName,
            dataProtectionSummary:
                agreement.dataProtectionSummary.trim().isEmpty
                    ? 'Implementation DPA captured'
                    : agreement.dataProtectionSummary,
            nextAction: 'Monitor first production service cycle',
          )
        else
          agreement,
    ];
  }

  String _nextId() =>
      'vendor-agreement-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyVendorAgreementDraftNotifier
    extends StateNotifier<CompanyVendorAgreementDraft> {
  CompanyVendorAgreementDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyVendorAgreementDraft.empty(entityName: entityName);
  }

  void setVendorName(String value) {
    state = state.copyWith(vendorName: value);
  }

  void setServiceName(String value) {
    state = state.copyWith(serviceName: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setCategory(CompanyVendorAgreementCategory value) {
    state = state.copyWith(category: value);
  }

  void setStatus(CompanyVendorAgreementStatus value) {
    state = state.copyWith(status: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setAccountManagerName(String value) {
    state = state.copyWith(accountManagerName: value);
  }

  void setContractEndDate(String value) {
    state = state.copyWith(contractEndDateText: value);
  }

  void setSlaSummary(String value) {
    state = state.copyWith(slaSummary: value);
  }

  void setDataProtectionSummary(String value) {
    state = state.copyWith(dataProtectionSummary: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setLinkedModule(String value) {
    state = state.copyWith(linkedModule: value);
  }
}

class CompanyFilingNotifier extends StateNotifier<List<CompanyFiling>> {
  CompanyFilingNotifier(List<CompanyFiling> filings) : super([...filings]);

  CompanyFiling submitDraft(CompanyFilingDraft draft) {
    final filing = draft.toFiling(_nextId());
    state = [...state, filing];
    return filing;
  }

  void markFiled(String id) {
    state = [
      for (final filing in state)
        if (filing.id == id)
          filing.copyWith(
            status: CompanyFilingStatus.filed,
            evidenceSummary:
                filing.evidenceSummary.trim().isEmpty
                    ? 'Submission receipt captured'
                    : filing.evidenceSummary,
            dueDate: _nextDueDate(filing),
          )
        else
          filing,
    ];
  }

  void escalate(String id) {
    state = [
      for (final filing in state)
        if (filing.id == id)
          filing.copyWith(
            status: CompanyFilingStatus.blocked,
            nextStep:
                filing.nextStep.trim().isEmpty
                    ? 'Escalate filing owner and authority dependency'
                    : filing.nextStep,
          )
        else
          filing,
    ];
  }

  DateTime _nextDueDate(CompanyFiling filing) {
    switch (filing.cadence) {
      case CompanyFilingCadence.monthly:
        return DateTime(
          filing.dueDate.year,
          filing.dueDate.month + 1,
          filing.dueDate.day,
        );
      case CompanyFilingCadence.quarterly:
        return DateTime(
          filing.dueDate.year,
          filing.dueDate.month + 3,
          filing.dueDate.day,
        );
      case CompanyFilingCadence.annual:
        return DateTime(
          filing.dueDate.year + 1,
          filing.dueDate.month,
          filing.dueDate.day,
        );
      case CompanyFilingCadence.oneOff:
        return filing.dueDate;
    }
  }

  String _nextId() => 'filing-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyFilingDraftNotifier extends StateNotifier<CompanyFilingDraft> {
  CompanyFilingDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyFilingDraft.empty(entityName: entityName);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyFilingType value) {
    state = state.copyWith(type: value);
  }

  void setCadence(CompanyFilingCadence value) {
    state = state.copyWith(cadence: value);
  }

  void setStatus(CompanyFilingStatus value) {
    state = state.copyWith(status: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setAuthorityName(String value) {
    state = state.copyWith(authorityName: value);
  }

  void setDueDate(String value) {
    state = state.copyWith(dueDateText: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setNextStep(String value) {
    state = state.copyWith(nextStep: value);
  }

  void setLinkedRecord(String value) {
    state = state.copyWith(linkedRecord: value);
  }
}

class CompanySignatoryNotifier extends StateNotifier<List<CompanySignatory>> {
  CompanySignatoryNotifier(List<CompanySignatory> signatories)
    : super([...signatories]);

  CompanySignatory submitDraft(CompanySignatoryDraft draft) {
    final signatory = draft.toSignatory(_nextId());
    state = [...state, signatory];
    return signatory;
  }

  void markEvidenceActive(String id) {
    state = [
      for (final signatory in state)
        if (signatory.id == id)
          signatory.copyWith(
            status: CompanySignatoryStatus.active,
            evidenceSummary:
                signatory.evidenceSummary.trim().isEmpty
                    ? 'Delegation evidence captured'
                    : signatory.evidenceSummary,
            expiryDate: signatory.expiryDate.add(const Duration(days: 180)),
          )
        else
          signatory,
    ];
  }

  void assignBackup(String id, String backupName) {
    state = [
      for (final signatory in state)
        if (signatory.id == id)
          signatory.copyWith(backupSignerName: backupName.trim())
        else
          signatory,
    ];
  }

  String _nextId() =>
      'signatory-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanySignatoryDraftNotifier
    extends StateNotifier<CompanySignatoryDraft> {
  CompanySignatoryDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanySignatoryDraft.empty(entityName: entityName);
  }

  void setPersonName(String value) {
    state = state.copyWith(personName: value);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setScope(CompanySignatoryScope value) {
    state = state.copyWith(scope: value);
  }

  void setAuthorityLevel(CompanySignatoryAuthorityLevel value) {
    state = state.copyWith(authorityLevel: value);
  }

  void setStatus(CompanySignatoryStatus value) {
    state = state.copyWith(status: value);
  }

  void setEffectiveDate(String value) {
    state = state.copyWith(effectiveDateText: value);
  }

  void setExpiryDate(String value) {
    state = state.copyWith(expiryDateText: value);
  }

  void setBackupSignerName(String value) {
    state = state.copyWith(backupSignerName: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setDelegationNotes(String value) {
    state = state.copyWith(delegationNotes: value);
  }
}

class CompanyChangeRequestNotifier
    extends StateNotifier<List<CompanyChangeRequest>> {
  CompanyChangeRequestNotifier(List<CompanyChangeRequest> requests)
    : super([...requests]);

  CompanyChangeRequest submitDraft(CompanyChangeRequestDraft draft) {
    final request = draft.toChangeRequest(_nextId());
    state = [...state, request];
    return request;
  }

  void markScheduled(String id) {
    state = [
      for (final request in state)
        if (request.id == id)
          request.copyWith(status: CompanyChangeRequestStatus.scheduled)
        else
          request,
    ];
  }

  void markImplemented(String id) {
    state = [
      for (final request in state)
        if (request.id == id)
          request.copyWith(status: CompanyChangeRequestStatus.implemented)
        else
          request,
    ];
  }

  String _nextId() => 'change-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyChangeRequestDraftNotifier
    extends StateNotifier<CompanyChangeRequestDraft> {
  CompanyChangeRequestDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyChangeRequestDraft.empty(entityName: entityName);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setType(CompanyChangeRequestType value) {
    state = state.copyWith(type: value);
  }

  void setPriority(CompanyChangeRequestPriority value) {
    state = state.copyWith(priority: value);
  }

  void setStatus(CompanyChangeRequestStatus value) {
    state = state.copyWith(status: value);
  }

  void setEffectiveDate(String value) {
    state = state.copyWith(effectiveDateText: value);
  }

  void setImpactSummary(String value) {
    state = state.copyWith(impactSummary: value);
  }

  void setApproverRole(String value) {
    state = state.copyWith(approverRole: value);
  }

  void setLinkedRecord(String value) {
    state = state.copyWith(linkedRecord: value);
  }
}

class CompanyLegalEntityNotifier
    extends StateNotifier<List<CompanyLegalEntity>> {
  CompanyLegalEntityNotifier(List<CompanyLegalEntity> entities)
    : super([...entities]);

  CompanyLegalEntity submitDraft(CompanyLegalEntityDraft draft) {
    final entity = draft.toLegalEntity(_nextId());
    state = [...state, entity];
    return entity;
  }

  void markVerified(String id) {
    state = [
      for (final entity in state)
        if (entity.id == id)
          entity.copyWith(
            payrollEnabled: true,
            status: CompanyLegalEntityStatus.verified,
          )
        else
          entity,
    ];
  }

  String _nextId() => 'entity-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyLegalEntityDraftNotifier
    extends StateNotifier<CompanyLegalEntityDraft> {
  CompanyLegalEntityDraftNotifier(super.state);

  void clear() {
    state = CompanyLegalEntityDraft.empty();
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setRegistrationNumber(String value) {
    state = state.copyWith(registrationNumber: value);
  }

  void setTaxId(String value) {
    state = state.copyWith(taxId: value);
  }

  void setCountry(String value) {
    state = state.copyWith(country: value);
  }

  void setCity(String value) {
    state = state.copyWith(city: value);
  }

  void setHrOwner(String value) {
    state = state.copyWith(hrOwner: value);
  }

  void setPayrollEnabled(bool value) {
    state = state.copyWith(payrollEnabled: value);
  }

  void setStatus(CompanyLegalEntityStatus value) {
    state = state.copyWith(status: value);
  }
}

class CompanyWorkLocationNotifier
    extends StateNotifier<List<CompanyWorkLocation>> {
  CompanyWorkLocationNotifier(List<CompanyWorkLocation> locations)
    : super([...locations]);

  CompanyWorkLocation submitDraft(CompanyWorkLocationDraft draft) {
    final location = draft.toLocation(_nextId());
    state = [...state, location];
    return location;
  }

  void markReady(String id) {
    state = [
      for (final location in state)
        if (location.id == id)
          location.copyWith(
            coverageOwner:
                location.coverageOwner.trim().isEmpty
                    ? 'People Operations'
                    : location.coverageOwner,
            attendancePolicyLinked: true,
            status: CompanyWorkLocationStatus.open,
          )
        else
          location,
    ];
  }

  String _nextId() => 'loc-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyWorkLocationDraftNotifier
    extends StateNotifier<CompanyWorkLocationDraft> {
  CompanyWorkLocationDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyWorkLocationDraft.empty(entityName: entityName);
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setType(CompanyWorkLocationType value) {
    state = state.copyWith(type: value);
  }

  void setCity(String value) {
    state = state.copyWith(city: value);
  }

  void setRegion(String value) {
    state = state.copyWith(region: value);
  }

  void setAddress(String value) {
    state = state.copyWith(address: value);
  }

  void setCoverageOwner(String value) {
    state = state.copyWith(coverageOwner: value);
  }

  void setCapacity(String value) {
    state = state.copyWith(capacityText: value);
  }

  void setAssignedHeadcount(String value) {
    state = state.copyWith(assignedHeadcountText: value);
  }

  void setAttendancePolicyLinked(bool value) {
    state = state.copyWith(attendancePolicyLinked: value);
  }

  void setStatus(CompanyWorkLocationStatus value) {
    state = state.copyWith(status: value);
  }
}

class CompanyOrgUnitNotifier extends StateNotifier<List<CompanyOrgUnit>> {
  CompanyOrgUnitNotifier(List<CompanyOrgUnit> units) : super([...units]);

  CompanyOrgUnit submitDraft(CompanyOrgUnitDraft draft) {
    final unit = draft.toOrgUnit(_nextId());
    state = [...state, unit];
    return unit;
  }

  String _nextId() => 'org-${(state.length + 1).toString().padLeft(3, '0')}';
}

class CompanyOrgUnitDraftNotifier extends StateNotifier<CompanyOrgUnitDraft> {
  CompanyOrgUnitDraftNotifier(super.state);

  void clear({String entityName = 'PT Kaysir Nusantara'}) {
    state = CompanyOrgUnitDraft.empty(entityName: entityName);
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setCode(String value) {
    state = state.copyWith(code: value);
  }

  void setEntityName(String value) {
    state = state.copyWith(entityName: value);
  }

  void setParentName(String value) {
    state = state.copyWith(parentName: value);
  }

  void setManagerName(String value) {
    state = state.copyWith(managerName: value);
  }

  void setLocation(String value) {
    state = state.copyWith(location: value);
  }

  void setPlannedHeadcount(String value) {
    state = state.copyWith(plannedHeadcountText: value);
  }

  void setActiveHeadcount(String value) {
    state = state.copyWith(activeHeadcountText: value);
  }

  void setStatus(CompanyOrgUnitStatus value) {
    state = state.copyWith(status: value);
  }
}

class CompanyPolicyNotifier extends StateNotifier<List<CompanyPolicySetting>> {
  CompanyPolicyNotifier(List<CompanyPolicySetting> policies)
    : super([...policies]);

  void markReady(String id) {
    state = [
      for (final policy in state)
        if (policy.id == id)
          policy.copyWith(
            status: CompanyPolicyStatus.ready,
            nextAction: 'No action needed.',
          )
        else
          policy,
    ];
  }
}
