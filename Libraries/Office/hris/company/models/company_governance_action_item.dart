import 'company_employer_account.dart';
import 'company_filing.dart';
import 'company_signatory.dart';
import 'company_vendor_agreement.dart';

/// Company governance record category represented in the action queue.
enum CompanyGovernanceActionSource {
  filing('Filing'),
  employerAccount('Employer account'),
  vendorAgreement('Vendor'),
  signatory('Signatory');

  final String label;

  const CompanyGovernanceActionSource(this.label);
}

/// Severity used to rank company governance remediation actions.
enum CompanyGovernanceActionSeverity {
  critical('Critical', 0),
  high('High', 1),
  medium('Medium', 2);

  final String label;
  final int sortRank;

  const CompanyGovernanceActionSeverity(this.label, this.sortRank);
}

/// Existing company management command that can progress a queue item.
enum CompanyGovernanceActionResolution {
  markFilingFiled('Mark filed'),
  verifyEmployerAccount('Verify account'),
  rotateEmployerCredentialOwner('Rotate owner'),
  renewVendorAgreement('Renew agreement'),
  closeVendorImplementation('Close implementation'),
  activateSignatoryEvidence('Activate evidence'),
  assignSignatoryBackup('Assign backup');

  final String label;

  const CompanyGovernanceActionResolution(this.label);
}

/// Prioritized operational action derived from statutory company records.
class CompanyGovernanceActionItem {
  final String id;
  final String recordId;
  final CompanyGovernanceActionSource source;
  final CompanyGovernanceActionSeverity severity;
  final CompanyGovernanceActionResolution resolution;
  final String title;
  final String entityName;
  final String ownerName;
  final DateTime dueDate;
  final String dueLabel;
  final String actionLabel;
  final String detail;
  final List<String> issueLabels;

  const CompanyGovernanceActionItem({
    required this.id,
    required this.recordId,
    required this.source,
    required this.severity,
    required this.resolution,
    required this.title,
    required this.entityName,
    required this.ownerName,
    required this.dueDate,
    required this.dueLabel,
    required this.actionLabel,
    required this.detail,
    required this.issueLabels,
  });

  String get entityLabel {
    return entityName.trim().isEmpty ? 'Unassigned entity' : entityName;
  }

  String get ownerLabel {
    return ownerName.trim().isEmpty ? 'Unassigned owner' : ownerName;
  }

  String get resolveLabel => resolution.label;
}

/// Builds a cross-record queue for the most urgent company governance tasks.
List<CompanyGovernanceActionItem> buildCompanyGovernanceActionItems({
  required List<CompanyFiling> filings,
  required List<CompanyEmployerAccount> employerAccounts,
  required List<CompanyVendorAgreement> vendorAgreements,
  required List<CompanySignatory> signatories,
  required DateTime asOfDate,
  int limit = 6,
}) {
  if (limit <= 0) return const [];

  final items = [
    for (final filing in filings)
      if (filing.requiresAttention(asOfDate))
        _filingActionItem(filing: filing, asOfDate: asOfDate),
    for (final account in employerAccounts)
      if (account.requiresAttention(asOfDate))
        _employerAccountActionItem(account: account, asOfDate: asOfDate),
    for (final agreement in vendorAgreements)
      if (agreement.requiresAttention(asOfDate))
        _vendorAgreementActionItem(agreement: agreement, asOfDate: asOfDate),
    for (final signatory in signatories)
      if (signatory.requiresAttention(asOfDate))
        _signatoryActionItem(signatory: signatory, asOfDate: asOfDate),
  ]..sort(_compareGovernanceActions);

  return items.take(limit).toList(growable: false);
}

CompanyGovernanceActionItem _filingActionItem({
  required CompanyFiling filing,
  required DateTime asOfDate,
}) {
  final issues = filing.issues(asOfDate);
  return CompanyGovernanceActionItem(
    id: 'filing-${filing.id}',
    recordId: filing.id,
    source: CompanyGovernanceActionSource.filing,
    severity: _filingSeverity(issues),
    resolution: CompanyGovernanceActionResolution.markFilingFiled,
    title: filing.title,
    entityName: filing.entityName,
    ownerName: filing.ownerName,
    dueDate: filing.dueDate,
    dueLabel: _dueLabel(filing.dueDate, asOfDate),
    actionLabel:
        filing.nextStep.trim().isEmpty
            ? 'Complete ${filing.type.label.toLowerCase()} filing handoff'
            : filing.nextStep,
    detail:
        '${filing.type.label} ${filing.cadence.label.toLowerCase()} filing with '
        '${issues.length} open governance ${issues.length == 1 ? 'issue' : 'issues'}.',
    issueLabels: [for (final issue in issues) issue.label],
  );
}

CompanyGovernanceActionItem _employerAccountActionItem({
  required CompanyEmployerAccount account,
  required DateTime asOfDate,
}) {
  final issues = account.issues(asOfDate);
  return CompanyGovernanceActionItem(
    id: 'employer-account-${account.id}',
    recordId: account.id,
    source: CompanyGovernanceActionSource.employerAccount,
    severity: _employerAccountSeverity(issues),
    resolution:
        issues.contains(CompanyEmployerAccountIssue.missingCredentialOwner)
            ? CompanyGovernanceActionResolution.rotateEmployerCredentialOwner
            : CompanyGovernanceActionResolution.verifyEmployerAccount,
    title: account.accountName,
    entityName: account.entityName,
    ownerName: account.ownerName,
    dueDate: account.nextReviewDate,
    dueLabel: _reviewLabel(account.nextReviewDate, asOfDate),
    actionLabel:
        account.nextAction.trim().isEmpty
            ? 'Complete ${account.type.label.toLowerCase()} account review'
            : account.nextAction,
    detail:
        '${account.type.label} account with ${issues.length} open governance '
        '${issues.length == 1 ? 'issue' : 'issues'}.',
    issueLabels: [for (final issue in issues) issue.label],
  );
}

CompanyGovernanceActionItem _vendorAgreementActionItem({
  required CompanyVendorAgreement agreement,
  required DateTime asOfDate,
}) {
  final issues = agreement.issues(asOfDate);
  return CompanyGovernanceActionItem(
    id: 'vendor-agreement-${agreement.id}',
    recordId: agreement.id,
    source: CompanyGovernanceActionSource.vendorAgreement,
    severity: _vendorAgreementSeverity(issues),
    resolution:
        issues.contains(CompanyVendorAgreementIssue.implementationOpen)
            ? CompanyGovernanceActionResolution.closeVendorImplementation
            : CompanyGovernanceActionResolution.renewVendorAgreement,
    title: agreement.vendorName,
    entityName: agreement.entityName,
    ownerName: agreement.ownerName,
    dueDate: agreement.contractEndDate,
    dueLabel: _contractEndLabel(agreement.contractEndDate, asOfDate),
    actionLabel:
        agreement.nextAction.trim().isEmpty
            ? 'Complete ${agreement.category.label.toLowerCase()} vendor review'
            : agreement.nextAction,
    detail:
        '${agreement.serviceName} agreement with ${issues.length} open '
        'vendor governance ${issues.length == 1 ? 'issue' : 'issues'}.',
    issueLabels: [for (final issue in issues) issue.label],
  );
}

CompanyGovernanceActionItem _signatoryActionItem({
  required CompanySignatory signatory,
  required DateTime asOfDate,
}) {
  final issues = signatory.issues(asOfDate);
  return CompanyGovernanceActionItem(
    id: 'signatory-${signatory.id}',
    recordId: signatory.id,
    source: CompanyGovernanceActionSource.signatory,
    severity: _signatorySeverity(issues),
    resolution:
        issues.contains(CompanySignatoryIssue.missingBackup)
            ? CompanyGovernanceActionResolution.assignSignatoryBackup
            : CompanyGovernanceActionResolution.activateSignatoryEvidence,
    title:
        signatory.personName.trim().isEmpty
            ? signatory.scope.label
            : signatory.personName,
    entityName: signatory.entityName,
    ownerName: signatory.backupSignerName,
    dueDate: signatory.expiryDate,
    dueLabel: _expiryLabel(signatory.expiryDate, asOfDate),
    actionLabel:
        signatory.delegationNotes.trim().isEmpty
            ? 'Refresh ${signatory.scope.label.toLowerCase()} authority evidence'
            : signatory.delegationNotes,
    detail:
        '${signatory.authorityLevel.label} authority for ${signatory.scope.label.toLowerCase()} '
        'with ${issues.length} open ${issues.length == 1 ? 'issue' : 'issues'}.',
    issueLabels: [for (final issue in issues) issue.label],
  );
}

CompanyGovernanceActionSeverity _filingSeverity(
  List<CompanyFilingIssue> issues,
) {
  if (issues.contains(CompanyFilingIssue.overdueDueDate) ||
      issues.contains(CompanyFilingIssue.blocked)) {
    return CompanyGovernanceActionSeverity.critical;
  }
  if (issues.contains(CompanyFilingIssue.dueSoon) ||
      issues.contains(CompanyFilingIssue.missingEvidence)) {
    return CompanyGovernanceActionSeverity.high;
  }
  return CompanyGovernanceActionSeverity.medium;
}

CompanyGovernanceActionSeverity _employerAccountSeverity(
  List<CompanyEmployerAccountIssue> issues,
) {
  if (issues.contains(CompanyEmployerAccountIssue.reviewOverdue) ||
      issues.contains(CompanyEmployerAccountIssue.suspended)) {
    return CompanyGovernanceActionSeverity.critical;
  }
  if (issues.contains(CompanyEmployerAccountIssue.reviewDueSoon) ||
      issues.contains(CompanyEmployerAccountIssue.pendingAuthority) ||
      issues.contains(CompanyEmployerAccountIssue.setupBlocked) ||
      issues.contains(CompanyEmployerAccountIssue.needsReview)) {
    return CompanyGovernanceActionSeverity.high;
  }
  return CompanyGovernanceActionSeverity.medium;
}

CompanyGovernanceActionSeverity _vendorAgreementSeverity(
  List<CompanyVendorAgreementIssue> issues,
) {
  if (issues.contains(CompanyVendorAgreementIssue.reviewOverdue) ||
      issues.contains(CompanyVendorAgreementIssue.expired) ||
      issues.contains(CompanyVendorAgreementIssue.suspended)) {
    return CompanyGovernanceActionSeverity.critical;
  }
  if (issues.contains(CompanyVendorAgreementIssue.reviewDueSoon) ||
      issues.contains(CompanyVendorAgreementIssue.implementationOpen) ||
      issues.contains(CompanyVendorAgreementIssue.renewalDue) ||
      issues.contains(CompanyVendorAgreementIssue.missingDataProtection)) {
    return CompanyGovernanceActionSeverity.high;
  }
  return CompanyGovernanceActionSeverity.medium;
}

CompanyGovernanceActionSeverity _signatorySeverity(
  List<CompanySignatoryIssue> issues,
) {
  if (issues.contains(CompanySignatoryIssue.expiryOverdue) ||
      issues.contains(CompanySignatoryIssue.inactiveAuthority)) {
    return CompanyGovernanceActionSeverity.critical;
  }
  if (issues.contains(CompanySignatoryIssue.expiringSoon) ||
      issues.contains(CompanySignatoryIssue.pendingEvidence) ||
      issues.contains(CompanySignatoryIssue.missingEvidence) ||
      issues.contains(CompanySignatoryIssue.missingBackup)) {
    return CompanyGovernanceActionSeverity.high;
  }
  return CompanyGovernanceActionSeverity.medium;
}

int _compareGovernanceActions(
  CompanyGovernanceActionItem a,
  CompanyGovernanceActionItem b,
) {
  final severityComparison = a.severity.sortRank.compareTo(b.severity.sortRank);
  if (severityComparison != 0) return severityComparison;

  final dateComparison = _dateOnly(a.dueDate).compareTo(_dateOnly(b.dueDate));
  if (dateComparison != 0) return dateComparison;

  final sourceComparison = a.source.index.compareTo(b.source.index);
  if (sourceComparison != 0) return sourceComparison;

  return a.title.compareTo(b.title);
}

String _dueLabel(DateTime dueDate, DateTime asOfDate) {
  final days = _dateOnly(dueDate).difference(_dateOnly(asOfDate)).inDays;
  if (days < 0) return 'Overdue ${days.abs()}d';
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  return 'Due in ${days}d';
}

String _reviewLabel(DateTime reviewDate, DateTime asOfDate) {
  final days = _dateOnly(reviewDate).difference(_dateOnly(asOfDate)).inDays;
  if (days < 0) return 'Review overdue ${days.abs()}d';
  if (days == 0) return 'Review today';
  if (days == 1) return 'Review tomorrow';
  return 'Review in ${days}d';
}

String _contractEndLabel(DateTime contractEndDate, DateTime asOfDate) {
  final days =
      _dateOnly(contractEndDate).difference(_dateOnly(asOfDate)).inDays;
  if (days < 0) return 'Contract overdue ${days.abs()}d';
  if (days == 0) return 'Contract ends today';
  if (days == 1) return 'Contract ends tomorrow';
  return 'Contract ends in ${days}d';
}

String _expiryLabel(DateTime expiryDate, DateTime asOfDate) {
  final days = _dateOnly(expiryDate).difference(_dateOnly(asOfDate)).inDays;
  if (days < 0) return 'Expired ${days.abs()}d';
  if (days == 0) return 'Expires today';
  if (days == 1) return 'Expires tomorrow';
  return 'Expires in ${days}d';
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
