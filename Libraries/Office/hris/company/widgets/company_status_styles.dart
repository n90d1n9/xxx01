import 'package:flutter/material.dart';

import '../models/company_approval_rule.dart';
import '../models/company_change_request.dart';
import '../models/company_compensation_band.dart';
import '../models/company_contract_template.dart';
import '../models/company_control.dart';
import '../models/company_cost_center.dart';
import '../models/company_document.dart';
import '../models/company_document_audit_event.dart';
import '../models/company_document_requirement.dart';
import '../models/company_document_renewal.dart';
import '../models/company_employee_document_gap.dart';
import '../models/company_employee_document_gap_recommendation.dart';
import '../models/company_entity_lifecycle.dart';
import '../models/company_employer_account.dart';
import '../models/company_filing.dart';
import '../models/company_governance_contact.dart';
import '../models/company_job_profile.dart';
import '../models/company_legal_entity.dart';
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

Color companyProfileStatusColor(CompanyStatus status) {
  switch (status) {
    case CompanyStatus.active:
      return Colors.green;
    case CompanyStatus.onboarding:
      return Colors.blue;
    case CompanyStatus.needsReview:
      return Colors.orange;
    case CompanyStatus.inactive:
      return Colors.grey;
  }
}

Color companyOrgUnitStatusColor(CompanyOrgUnitStatus status) {
  switch (status) {
    case CompanyOrgUnitStatus.active:
      return Colors.green;
    case CompanyOrgUnitStatus.hiring:
      return Colors.blue;
    case CompanyOrgUnitStatus.review:
      return Colors.orange;
    case CompanyOrgUnitStatus.paused:
      return Colors.grey;
  }
}

Color companyLegalEntityStatusColor(CompanyLegalEntityStatus status) {
  switch (status) {
    case CompanyLegalEntityStatus.verified:
      return Colors.green;
    case CompanyLegalEntityStatus.pending:
      return Colors.blueGrey;
    case CompanyLegalEntityStatus.needsReview:
      return Colors.orange;
    case CompanyLegalEntityStatus.inactive:
      return Colors.grey;
  }
}

Color companyWorkLocationStatusColor(CompanyWorkLocationStatus status) {
  switch (status) {
    case CompanyWorkLocationStatus.open:
      return Colors.green;
    case CompanyWorkLocationStatus.onboarding:
      return Colors.blue;
    case CompanyWorkLocationStatus.needsReview:
      return Colors.orange;
    case CompanyWorkLocationStatus.closed:
      return Colors.grey;
  }
}

Color companyPolicyStatusColor(CompanyPolicyStatus status) {
  switch (status) {
    case CompanyPolicyStatus.ready:
      return Colors.green;
    case CompanyPolicyStatus.draft:
      return Colors.blueGrey;
    case CompanyPolicyStatus.needsReview:
      return Colors.orange;
  }
}

Color companyCostCenterStatusColor(CompanyCostCenterStatus status) {
  switch (status) {
    case CompanyCostCenterStatus.active:
      return Colors.green;
    case CompanyCostCenterStatus.planning:
      return Colors.blueGrey;
    case CompanyCostCenterStatus.needsReview:
      return Colors.orange;
    case CompanyCostCenterStatus.archived:
      return Colors.grey;
  }
}

Color companyPositionControlStatusColor(CompanyPositionControlStatus status) {
  switch (status) {
    case CompanyPositionControlStatus.approved:
      return Colors.green;
    case CompanyPositionControlStatus.recruiting:
      return Colors.blue;
    case CompanyPositionControlStatus.pendingApproval:
      return Colors.orange;
    case CompanyPositionControlStatus.frozen:
      return Colors.blueGrey;
    case CompanyPositionControlStatus.closed:
      return Colors.grey;
  }
}

Color companyCompensationBandStatusColor(CompanyCompensationBandStatus status) {
  switch (status) {
    case CompanyCompensationBandStatus.active:
      return Colors.green;
    case CompanyCompensationBandStatus.draft:
      return Colors.blueGrey;
    case CompanyCompensationBandStatus.pendingApproval:
      return Colors.orange;
    case CompanyCompensationBandStatus.needsReview:
      return Colors.deepOrange;
    case CompanyCompensationBandStatus.retired:
      return Colors.grey;
  }
}

Color companyJobProfileStatusColor(CompanyJobProfileStatus status) {
  switch (status) {
    case CompanyJobProfileStatus.active:
      return Colors.green;
    case CompanyJobProfileStatus.draft:
      return Colors.blueGrey;
    case CompanyJobProfileStatus.pendingApproval:
      return Colors.orange;
    case CompanyJobProfileStatus.needsReview:
      return Colors.deepOrange;
    case CompanyJobProfileStatus.retired:
      return Colors.grey;
  }
}

Color companyContractTemplateStatusColor(CompanyContractTemplateStatus status) {
  switch (status) {
    case CompanyContractTemplateStatus.active:
      return Colors.green;
    case CompanyContractTemplateStatus.draft:
      return Colors.blueGrey;
    case CompanyContractTemplateStatus.pendingLegalReview:
      return Colors.orange;
    case CompanyContractTemplateStatus.needsReview:
      return Colors.deepOrange;
    case CompanyContractTemplateStatus.retired:
      return Colors.grey;
  }
}

Color companyOnboardingPackStatusColor(CompanyOnboardingPackStatus status) {
  switch (status) {
    case CompanyOnboardingPackStatus.active:
      return Colors.green;
    case CompanyOnboardingPackStatus.draft:
      return Colors.blueGrey;
    case CompanyOnboardingPackStatus.pendingOwnerReview:
      return Colors.orange;
    case CompanyOnboardingPackStatus.needsReview:
      return Colors.deepOrange;
    case CompanyOnboardingPackStatus.retired:
      return Colors.grey;
  }
}

Color companyProbationPlanStatusColor(CompanyProbationPlanStatus status) {
  switch (status) {
    case CompanyProbationPlanStatus.active:
      return Colors.green;
    case CompanyProbationPlanStatus.draft:
      return Colors.blueGrey;
    case CompanyProbationPlanStatus.pendingOwnerReview:
      return Colors.orange;
    case CompanyProbationPlanStatus.needsReview:
      return Colors.deepOrange;
    case CompanyProbationPlanStatus.retired:
      return Colors.grey;
  }
}

Color companyOffboardingPackStatusColor(CompanyOffboardingPackStatus status) {
  switch (status) {
    case CompanyOffboardingPackStatus.active:
      return Colors.green;
    case CompanyOffboardingPackStatus.draft:
      return Colors.blueGrey;
    case CompanyOffboardingPackStatus.pendingOwnerReview:
      return Colors.orange;
    case CompanyOffboardingPackStatus.needsReview:
      return Colors.deepOrange;
    case CompanyOffboardingPackStatus.retired:
      return Colors.grey;
  }
}

Color companyDocumentRequirementStatusColor(
  CompanyDocumentRequirementStatus status,
) {
  switch (status) {
    case CompanyDocumentRequirementStatus.active:
      return Colors.green;
    case CompanyDocumentRequirementStatus.draft:
      return Colors.blueGrey;
    case CompanyDocumentRequirementStatus.pendingLegalReview:
      return Colors.orange;
    case CompanyDocumentRequirementStatus.needsReview:
      return Colors.deepOrange;
    case CompanyDocumentRequirementStatus.retired:
      return Colors.grey;
  }
}

Color companyEmployeeDocumentGapStatusColor(
  CompanyEmployeeDocumentGapStatus status,
) {
  switch (status) {
    case CompanyEmployeeDocumentGapStatus.complete:
      return Colors.green;
    case CompanyEmployeeDocumentGapStatus.requested:
      return Colors.blue;
    case CompanyEmployeeDocumentGapStatus.missing:
      return Colors.orange;
    case CompanyEmployeeDocumentGapStatus.blocked:
      return Colors.red;
    case CompanyEmployeeDocumentGapStatus.waived:
      return Colors.grey;
  }
}

Color companyEmployeeDocumentGapPriorityColor(
  CompanyEmployeeDocumentGapPriority priority,
) {
  switch (priority) {
    case CompanyEmployeeDocumentGapPriority.low:
      return Colors.green;
    case CompanyEmployeeDocumentGapPriority.medium:
      return Colors.blue;
    case CompanyEmployeeDocumentGapPriority.high:
      return Colors.orange;
    case CompanyEmployeeDocumentGapPriority.critical:
      return Colors.red;
  }
}

Color companyApprovalRuleStatusColor(CompanyApprovalRuleStatus status) {
  switch (status) {
    case CompanyApprovalRuleStatus.active:
      return Colors.green;
    case CompanyApprovalRuleStatus.draft:
      return Colors.blueGrey;
    case CompanyApprovalRuleStatus.paused:
      return Colors.orange;
  }
}

Color companyDocumentStatusColor(CompanyDocumentStatus status) {
  switch (status) {
    case CompanyDocumentStatus.verified:
      return Colors.green;
    case CompanyDocumentStatus.pending:
      return Colors.blueGrey;
    case CompanyDocumentStatus.expiringSoon:
      return Colors.orange;
    case CompanyDocumentStatus.expired:
      return Colors.red;
    case CompanyDocumentStatus.missing:
      return Colors.deepOrange;
  }
}

Color companyDocumentRenewalStatusColor(CompanyDocumentRenewalStatus status) {
  switch (status) {
    case CompanyDocumentRenewalStatus.scheduled:
      return Colors.blueGrey;
    case CompanyDocumentRenewalStatus.inProgress:
      return Colors.blue;
    case CompanyDocumentRenewalStatus.waitingAuthority:
      return Colors.orange;
    case CompanyDocumentRenewalStatus.blocked:
      return Colors.red;
    case CompanyDocumentRenewalStatus.completed:
      return Colors.green;
  }
}

Color companyDocumentAuditEventColor(CompanyDocumentAuditEventType type) {
  switch (type) {
    case CompanyDocumentAuditEventType.created:
      return Colors.blueGrey;
    case CompanyDocumentAuditEventType.reviewed:
      return Colors.indigo;
    case CompanyDocumentAuditEventType.reminderSent:
      return Colors.orange;
    case CompanyDocumentAuditEventType.renewalStarted:
      return Colors.blue;
    case CompanyDocumentAuditEventType.renewed:
      return Colors.green;
    case CompanyDocumentAuditEventType.verified:
      return Colors.green;
    case CompanyDocumentAuditEventType.escalated:
      return Colors.red;
    case CompanyDocumentAuditEventType.employeeRequestGenerated:
      return Colors.blue;
    case CompanyDocumentAuditEventType.employeeEvidenceVerified:
      return Colors.green;
    case CompanyDocumentAuditEventType.employeeRequestClosed:
      return Colors.teal;
    case CompanyDocumentAuditEventType.employeeGapWaived:
      return Colors.deepPurple;
    case CompanyDocumentAuditEventType.employeeOwnerDigestSent:
      return Colors.indigo;
    case CompanyDocumentAuditEventType.employeeOwnerEscalated:
      return Colors.red;
    case CompanyDocumentAuditEventType.employeeOwnerFollowedUp:
      return Colors.teal;
    case CompanyDocumentAuditEventType.governanceOwnerHandoffRecorded:
      return Colors.deepPurple;
    case CompanyDocumentAuditEventType.governanceOwnerFollowedUp:
      return Colors.teal;
    case CompanyDocumentAuditEventType.governanceFollowUpPolicyChanged:
      return Colors.indigo;
  }
}

Color companyOperatingReadinessStatusColor(
  CompanyOperatingReadinessStatus status,
) {
  switch (status) {
    case CompanyOperatingReadinessStatus.ready:
      return Colors.green;
    case CompanyOperatingReadinessStatus.inProgress:
      return Colors.blue;
    case CompanyOperatingReadinessStatus.needsReview:
      return Colors.orange;
    case CompanyOperatingReadinessStatus.blocked:
      return Colors.red;
    case CompanyOperatingReadinessStatus.notStarted:
      return Colors.blueGrey;
  }
}

Color companyChangeRequestStatusColor(CompanyChangeRequestStatus status) {
  switch (status) {
    case CompanyChangeRequestStatus.draft:
      return Colors.blueGrey;
    case CompanyChangeRequestStatus.awaitingApproval:
      return Colors.orange;
    case CompanyChangeRequestStatus.scheduled:
      return Colors.blue;
    case CompanyChangeRequestStatus.implemented:
      return Colors.green;
    case CompanyChangeRequestStatus.blocked:
      return Colors.red;
  }
}

Color companyChangeRequestPriorityColor(CompanyChangeRequestPriority priority) {
  switch (priority) {
    case CompanyChangeRequestPriority.low:
      return Colors.green;
    case CompanyChangeRequestPriority.medium:
      return Colors.blue;
    case CompanyChangeRequestPriority.high:
      return Colors.orange;
    case CompanyChangeRequestPriority.critical:
      return Colors.red;
  }
}

Color companyGovernanceContactStatusColor(
  CompanyGovernanceContactStatus status,
) {
  switch (status) {
    case CompanyGovernanceContactStatus.active:
      return Colors.green;
    case CompanyGovernanceContactStatus.missingBackup:
      return Colors.orange;
    case CompanyGovernanceContactStatus.needsReview:
      return Colors.blueGrey;
    case CompanyGovernanceContactStatus.inactive:
      return Colors.red;
  }
}

Color companyEntityLifecycleStatusColor(CompanyEntityLifecycleStatus status) {
  switch (status) {
    case CompanyEntityLifecycleStatus.planned:
      return Colors.blueGrey;
    case CompanyEntityLifecycleStatus.inProgress:
      return Colors.blue;
    case CompanyEntityLifecycleStatus.blocked:
      return Colors.red;
    case CompanyEntityLifecycleStatus.launched:
      return Colors.green;
    case CompanyEntityLifecycleStatus.archived:
      return Colors.grey;
  }
}

Color companyControlStatusColor(CompanyControlStatus status) {
  switch (status) {
    case CompanyControlStatus.healthy:
      return Colors.green;
    case CompanyControlStatus.monitoring:
      return Colors.blue;
    case CompanyControlStatus.remediation:
      return Colors.orange;
    case CompanyControlStatus.overdue:
      return Colors.red;
    case CompanyControlStatus.waived:
      return Colors.grey;
  }
}

Color companyControlSeverityColor(CompanyControlSeverity severity) {
  switch (severity) {
    case CompanyControlSeverity.low:
      return Colors.green;
    case CompanyControlSeverity.medium:
      return Colors.blue;
    case CompanyControlSeverity.high:
      return Colors.orange;
    case CompanyControlSeverity.critical:
      return Colors.red;
  }
}

Color companyEmployerAccountStatusColor(CompanyEmployerAccountStatus status) {
  switch (status) {
    case CompanyEmployerAccountStatus.verified:
      return Colors.green;
    case CompanyEmployerAccountStatus.setupInProgress:
      return Colors.blue;
    case CompanyEmployerAccountStatus.pendingAuthority:
      return Colors.orange;
    case CompanyEmployerAccountStatus.needsReview:
      return Colors.deepOrange;
    case CompanyEmployerAccountStatus.suspended:
      return Colors.red;
  }
}

Color companyVendorAgreementStatusColor(CompanyVendorAgreementStatus status) {
  switch (status) {
    case CompanyVendorAgreementStatus.active:
      return Colors.green;
    case CompanyVendorAgreementStatus.implementation:
      return Colors.blue;
    case CompanyVendorAgreementStatus.renewalDue:
      return Colors.orange;
    case CompanyVendorAgreementStatus.expired:
      return Colors.red;
    case CompanyVendorAgreementStatus.suspended:
      return Colors.grey;
  }
}

Color companyFilingStatusColor(CompanyFilingStatus status) {
  switch (status) {
    case CompanyFilingStatus.scheduled:
      return Colors.blueGrey;
    case CompanyFilingStatus.inProgress:
      return Colors.blue;
    case CompanyFilingStatus.filed:
      return Colors.green;
    case CompanyFilingStatus.overdue:
      return Colors.red;
    case CompanyFilingStatus.blocked:
      return Colors.orange;
  }
}

Color companySignatoryStatusColor(CompanySignatoryStatus status) {
  switch (status) {
    case CompanySignatoryStatus.active:
      return Colors.green;
    case CompanySignatoryStatus.pendingEvidence:
      return Colors.orange;
    case CompanySignatoryStatus.expiringSoon:
      return Colors.deepOrange;
    case CompanySignatoryStatus.expired:
      return Colors.red;
    case CompanySignatoryStatus.revoked:
      return Colors.grey;
  }
}
