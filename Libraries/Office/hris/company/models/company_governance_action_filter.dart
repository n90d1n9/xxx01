import 'company_governance_action_item.dart';

/// Triage filter for narrowing the company governance action queue.
enum CompanyGovernanceActionFilter {
  all('All'),
  critical('Critical'),
  high('High'),
  filings('Filings'),
  employerAccounts('Accounts'),
  vendors('Vendors'),
  signatories('Signatories');

  final String label;

  const CompanyGovernanceActionFilter(this.label);

  bool matches(CompanyGovernanceActionItem item) {
    switch (this) {
      case CompanyGovernanceActionFilter.all:
        return true;
      case CompanyGovernanceActionFilter.critical:
        return item.severity == CompanyGovernanceActionSeverity.critical;
      case CompanyGovernanceActionFilter.high:
        return item.severity == CompanyGovernanceActionSeverity.high;
      case CompanyGovernanceActionFilter.filings:
        return item.source == CompanyGovernanceActionSource.filing;
      case CompanyGovernanceActionFilter.employerAccounts:
        return item.source == CompanyGovernanceActionSource.employerAccount;
      case CompanyGovernanceActionFilter.vendors:
        return item.source == CompanyGovernanceActionSource.vendorAgreement;
      case CompanyGovernanceActionFilter.signatories:
        return item.source == CompanyGovernanceActionSource.signatory;
    }
  }
}

/// Returns the visible governance actions for the selected queue filter.
List<CompanyGovernanceActionItem> filterCompanyGovernanceActionItems({
  required List<CompanyGovernanceActionItem> items,
  required CompanyGovernanceActionFilter filter,
  String? ownerName,
}) {
  final normalizedOwnerName = _normalizeOwnerName(ownerName);
  return items
      .where(filter.matches)
      .where(
        (item) =>
            normalizedOwnerName.isEmpty ||
            _normalizeOwnerName(item.ownerLabel) == normalizedOwnerName,
      )
      .toList(growable: false);
}

/// Counts governance actions per triage filter for filter chip badges.
Map<CompanyGovernanceActionFilter, int> countCompanyGovernanceActionFilters(
  List<CompanyGovernanceActionItem> items,
) {
  return {
    for (final filter in CompanyGovernanceActionFilter.values)
      filter: items.where(filter.matches).length,
  };
}

String _normalizeOwnerName(String? ownerName) {
  return (ownerName ?? '').trim().toLowerCase();
}
