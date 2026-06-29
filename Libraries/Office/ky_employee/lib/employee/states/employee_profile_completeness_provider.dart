import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_assets_models.dart';
import '../models/employee_benefits_models.dart';
import '../models/employee_compliance_models.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_document_vault_models.dart';
import '../models/employee_job_assignment_models.dart';
import '../models/employee_org_models.dart';
import '../models/employee_payroll_models.dart';
import '../models/employee_personal_records_models.dart';
import '../models/employee_profile_completeness_models.dart';
import '../models/employee_schedule_models.dart';
import '../models/employee_work_authorization_models.dart';
import 'employee_assets_provider.dart';
import 'employee_benefits_provider.dart';
import 'employee_compliance_provider.dart';
import 'employee_directory_provider.dart';
import 'employee_document_vault_provider.dart';
import 'employee_job_assignment_provider.dart';
import 'employee_org_provider.dart';
import 'employee_payroll_provider.dart';
import 'employee_personal_records_provider.dart';
import 'employee_schedule_provider.dart';
import 'employee_work_authorization_provider.dart';

final employeeProfileCompletenessProvider = Provider.family<
  EmployeeProfileCompletenessProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final members = ref.watch(employeeDirectoryMembersProvider);
  final member = _findMember(members, employeeId);
  if (member == null) return null;

  final personal = ref.watch(
    employeePersonalRecordsProfileProvider(employeeId),
  );
  final vault = ref.watch(employeeDocumentVaultProfileProvider(employeeId));
  final workAuthorization = ref.watch(
    employeeWorkAuthorizationProfileProvider(employeeId),
  );
  final jobAssignment = ref.watch(
    employeeJobAssignmentProfileProvider(employeeId),
  );
  final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
  final benefits = ref.watch(employeeBenefitsProfileProvider(employeeId));
  final org = ref.watch(employeeOrgProfileProvider(employeeId));
  final schedule = ref.watch(employeeScheduleProfileProvider(employeeId));
  final assets = ref.watch(employeeAssetAccessProfileProvider(employeeId));
  final compliance = ref.watch(employeeComplianceSummaryProvider(employeeId));

  return EmployeeProfileCompletenessProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: asOfDate,
    items: [
      _personalRecordsItem(personal),
      _documentVaultItem(vault),
      _workAuthorizationItem(workAuthorization),
      _jobAssignmentItem(jobAssignment),
      _payrollItem(payroll),
      _benefitsItem(benefits),
      _reportingItem(org),
      _scheduleItem(schedule),
      _assetsAccessItem(assets),
      _complianceItem(compliance),
    ],
  );
});

EmployeeProfileCompletenessItem _personalRecordsItem(
  EmployeePersonalRecordsProfile? personal,
) {
  if (personal == null) {
    return _item(
      area: EmployeeProfileCompletenessArea.personalRecords,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No personal records profile found.',
      nextAction: 'Create address and emergency contact records.',
    );
  }
  if (personal.addresses.isEmpty || personal.emergencyContacts.isEmpty) {
    return _item(
      area: EmployeeProfileCompletenessArea.personalRecords,
      status: EmployeeProfileCompletenessStatus.missing,
      detail:
          '${personal.addresses.length} address record(s), '
          '${personal.emergencyContacts.length} emergency contact(s).',
      nextAction: 'Add required address and emergency contact records.',
    );
  }
  if (personal.totalAttentionCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.personalRecords,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail:
          '${personal.totalAttentionCount} personal record item(s) need verification.',
      nextAction: personal.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.personalRecords,
    status: EmployeeProfileCompletenessStatus.complete,
    detail:
        '${personal.verifiedAddressCount} verified address(es), '
        '${personal.verifiedContactCount} verified contact(s).',
    nextAction: 'Personal records are current.',
  );
}

EmployeeProfileCompletenessItem _documentVaultItem(
  EmployeeDocumentVaultProfile? vault,
) {
  if (vault == null || vault.records.isEmpty) {
    return _item(
      area: EmployeeProfileCompletenessArea.documentVault,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No employee documents stored.',
      nextAction: 'Add identity and employment documents to the vault.',
    );
  }
  if (vault.uploadNeededCount > 0 || vault.expiredCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.documentVault,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail: '${vault.attentionCount} vault document(s) need attention.',
      nextAction: vault.nextAction,
    );
  }
  if (vault.pendingReviewCount > 0 || vault.expiringSoonCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.documentVault,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail:
          '${vault.pendingReviewCount} review, ${vault.expiringSoonCount} expiring.',
      nextAction: vault.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.documentVault,
    status: EmployeeProfileCompletenessStatus.complete,
    detail: '${vault.verifiedCount} verified document(s).',
    nextAction: 'Document vault is current.',
  );
}

EmployeeProfileCompletenessItem _workAuthorizationItem(
  EmployeeWorkAuthorizationProfile? profile,
) {
  if (profile == null || profile.records.isEmpty) {
    return _item(
      area: EmployeeProfileCompletenessArea.workAuthorization,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No work authorization record found.',
      nextAction: 'Add right-to-work or visa authorization evidence.',
    );
  }
  if (profile.expiredCount > 0 || profile.evidenceIssueCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.workAuthorization,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail:
          '${profile.attentionCount} authorization record(s) need attention.',
      nextAction: profile.nextAction,
    );
  }
  if (profile.renewalDueCount > 0 || profile.reviewDueCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.workAuthorization,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail:
          '${profile.renewalDueCount} renewal(s), ${profile.reviewDueCount} review(s).',
      nextAction: profile.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.workAuthorization,
    status: EmployeeProfileCompletenessStatus.complete,
    detail: '${profile.validCount} valid authorization record(s).',
    nextAction: 'Work authorization is current.',
  );
}

EmployeeProfileCompletenessItem _jobAssignmentItem(
  EmployeeJobAssignmentProfile? profile,
) {
  final current = profile?.currentAssignment;
  if (profile == null || current == null) {
    return _item(
      area: EmployeeProfileCompletenessArea.jobAssignment,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No active job assignment.',
      nextAction: 'Create an active job assignment.',
    );
  }
  if (profile.pendingApprovalCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.jobAssignment,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail:
          '${profile.pendingApprovalCount} assignment change(s) pending approval.',
      nextAction: profile.nextAction,
    );
  }
  if (profile.scheduledSoonCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.jobAssignment,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail: '${profile.scheduledSoonCount} scheduled assignment change(s).',
      nextAction: profile.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.jobAssignment,
    status: EmployeeProfileCompletenessStatus.complete,
    detail: '${current.position} in ${current.department}.',
    nextAction: 'Job assignment is current.',
  );
}

EmployeeProfileCompletenessItem _payrollItem(EmployeePayrollProfile? payroll) {
  if (payroll == null) {
    return _item(
      area: EmployeeProfileCompletenessArea.payroll,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No payroll setup found.',
      nextAction: 'Create payroll bank, tax, and schedule setup.',
    );
  }
  if (payroll.bankAttentionCount > 0 || payroll.taxAttentionCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.payroll,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail: '${payroll.attentionCount} payroll setup item(s) need attention.',
      nextAction: payroll.nextAction,
    );
  }
  if (payroll.submittedChangeCount > 0 || payroll.approvedChangeCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.payroll,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail:
          '${payroll.submittedChangeCount + payroll.approvedChangeCount} payroll change(s) open.',
      nextAction: payroll.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.payroll,
    status: EmployeeProfileCompletenessStatus.complete,
    detail: '${payroll.schedule.payGroup} - ${payroll.schedule.currencyCode}.',
    nextAction: 'Payroll setup is current.',
  );
}

EmployeeProfileCompletenessItem _benefitsItem(
  EmployeeBenefitsProfile? benefits,
) {
  if (benefits == null || benefits.enrollments.isEmpty) {
    return _item(
      area: EmployeeProfileCompletenessArea.benefits,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No benefit enrollment found.',
      nextAction: 'Confirm benefit elections or waivers.',
    );
  }
  if (benefits.actionRequiredCount > 0 || benefits.pendingDependentCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.benefits,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail:
          '${benefits.actionRequiredCount} benefit action(s), '
          '${benefits.pendingDependentCount} dependent issue(s).',
      nextAction: benefits.nextAction,
    );
  }
  final hasMedical = benefits.enrollments.any(
    (enrollment) =>
        enrollment.type == EmployeeBenefitPlanType.medical &&
        enrollment.isActive,
  );
  if (!hasMedical) {
    return _item(
      area: EmployeeProfileCompletenessArea.benefits,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail: '${benefits.activeEnrollmentCount} active enrollment(s).',
      nextAction: benefits.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.benefits,
    status: EmployeeProfileCompletenessStatus.complete,
    detail: '${benefits.activeEnrollmentCount} active enrollment(s).',
    nextAction: 'Benefits setup is current.',
  );
}

EmployeeProfileCompletenessItem _reportingItem(EmployeeOrgProfile? org) {
  final manager = org?.manager;
  if (org == null || manager == null) {
    return _item(
      area: EmployeeProfileCompletenessArea.reporting,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No manager assigned.',
      nextAction: 'Assign a manager and reporting chain.',
    );
  }
  if (org.riskCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.reporting,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail: '${org.riskCount} reporting risk signal(s).',
      nextAction: org.nextAction,
    );
  }
  if (org.pendingRelationshipCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.reporting,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail: '${org.pendingRelationshipCount} pending org relationship(s).',
      nextAction: org.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.reporting,
    status: EmployeeProfileCompletenessStatus.complete,
    detail: 'Reports to ${manager.name}.',
    nextAction: 'Reporting line is aligned.',
  );
}

EmployeeProfileCompletenessItem _scheduleItem(
  EmployeeScheduleProfile? schedule,
) {
  if (schedule == null || schedule.assignment.workDays.isEmpty) {
    return _item(
      area: EmployeeProfileCompletenessArea.schedule,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No work schedule assigned.',
      nextAction: 'Assign a work schedule.',
    );
  }
  if (schedule.highSeverityCount > 0 || schedule.attendanceRiskCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.schedule,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail: '${schedule.attentionCount} schedule or attendance item(s) open.',
      nextAction: schedule.nextAction,
    );
  }
  if (schedule.pendingAdjustmentCount > 0 ||
      schedule.approvedAdjustmentCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.schedule,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail:
          '${schedule.pendingAdjustmentCount + schedule.approvedAdjustmentCount} schedule adjustment(s) open.',
      nextAction: schedule.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.schedule,
    status: EmployeeProfileCompletenessStatus.complete,
    detail:
        '${schedule.assignment.daysLabel}, ${schedule.assignment.hoursLabel}.',
    nextAction: 'Schedule is aligned.',
  );
}

EmployeeProfileCompletenessItem _assetsAccessItem(
  EmployeeAssetAccessProfile? assets,
) {
  if (assets == null ||
      (assets.assets.isEmpty && assets.accessGrants.isEmpty)) {
    return _item(
      area: EmployeeProfileCompletenessArea.assetsAccess,
      status: EmployeeProfileCompletenessStatus.missing,
      detail: 'No assets or access grants assigned.',
      nextAction: 'Assign required assets and access grants.',
    );
  }
  if (assets.attentionCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.assetsAccess,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail:
          '${assets.attentionCount} asset or access item(s) need attention.',
      nextAction: assets.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.assetsAccess,
    status: EmployeeProfileCompletenessStatus.complete,
    detail:
        '${assets.activeAssetCount} asset(s), ${assets.activeAccessCount} access grant(s).',
    nextAction: 'Assets and access are current.',
  );
}

EmployeeProfileCompletenessItem _complianceItem(
  EmployeeComplianceDocumentSummary compliance,
) {
  final issueCount =
      compliance.pendingCount +
      compliance.rejectedCount +
      compliance.overdueCount;
  if (issueCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.compliance,
      status: EmployeeProfileCompletenessStatus.actionRequired,
      detail: '$issueCount compliance document issue(s).',
      nextAction: compliance.nextAction,
    );
  }
  if (compliance.expiringSoonCount > 0) {
    return _item(
      area: EmployeeProfileCompletenessArea.compliance,
      status: EmployeeProfileCompletenessStatus.inProgress,
      detail:
          '${compliance.expiringSoonCount} compliance document(s) expiring.',
      nextAction: compliance.nextAction,
    );
  }
  return _item(
    area: EmployeeProfileCompletenessArea.compliance,
    status: EmployeeProfileCompletenessStatus.complete,
    detail: '${compliance.verifiedCount} verified compliance document(s).',
    nextAction: 'Compliance records are current.',
  );
}

EmployeeProfileCompletenessItem _item({
  required EmployeeProfileCompletenessArea area,
  required EmployeeProfileCompletenessStatus status,
  required String detail,
  required String nextAction,
}) {
  return EmployeeProfileCompletenessItem(
    area: area,
    status: status,
    score: _scoreFor(status),
    detail: detail,
    nextAction: nextAction,
  );
}

int _scoreFor(EmployeeProfileCompletenessStatus status) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.complete => 100,
    EmployeeProfileCompletenessStatus.inProgress => 70,
    EmployeeProfileCompletenessStatus.actionRequired => 40,
    EmployeeProfileCompletenessStatus.missing => 0,
  };
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> items,
  String employeeId,
) {
  for (final item in items) {
    if (item.id == employeeId) return item;
  }
  return null;
}
