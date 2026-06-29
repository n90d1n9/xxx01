import 'company_governance_action_item.dart';

/// Risk level for one owner across the company governance action queue.
enum CompanyGovernanceOwnerLoadRisk {
  critical('Critical load', 0),
  high('High load', 1),
  steady('Steady load', 2);

  final String label;
  final int sortRank;

  const CompanyGovernanceOwnerLoadRisk(this.label, this.sortRank);
}

/// Aggregated company governance action load for one owner or unassigned lane.
class CompanyGovernanceOwnerLoad {
  final String ownerName;
  final int actionCount;
  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int filingCount;
  final int employerAccountCount;
  final int vendorAgreementCount;
  final int signatoryCount;
  final DateTime nextDueDate;
  final String nextDueLabel;
  final String primaryActionLabel;
  final CompanyGovernanceOwnerLoadRisk risk;

  const CompanyGovernanceOwnerLoad({
    required this.ownerName,
    required this.actionCount,
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.filingCount,
    required this.employerAccountCount,
    required this.vendorAgreementCount,
    required this.signatoryCount,
    required this.nextDueDate,
    required this.nextDueLabel,
    required this.primaryActionLabel,
    required this.risk,
  });

  String get ownerLabel {
    return ownerName.trim().isEmpty ? 'Unassigned owner' : ownerName;
  }

  String get sourceSummary {
    final parts = [
      if (filingCount > 0) _countLabel(filingCount, 'filing'),
      if (employerAccountCount > 0)
        _countLabel(employerAccountCount, 'account'),
      if (vendorAgreementCount > 0) _countLabel(vendorAgreementCount, 'vendor'),
      if (signatoryCount > 0) _countLabel(signatoryCount, 'signatory'),
    ];
    return parts.isEmpty ? 'No active sources' : parts.join(', ');
  }
}

/// Builds owner-level governance workload summaries from action queue items.
List<CompanyGovernanceOwnerLoad> buildCompanyGovernanceOwnerLoads({
  required List<CompanyGovernanceActionItem> items,
  int limit = 6,
}) {
  if (limit <= 0) return const [];

  final groupedItems = <String, List<CompanyGovernanceActionItem>>{};
  for (final item in items) {
    groupedItems.putIfAbsent(item.ownerLabel, () => []).add(item);
  }

  final loads = [
    for (final entry in groupedItems.entries)
      _ownerLoad(ownerName: entry.key, items: entry.value),
  ]..sort(_compareOwnerLoads);

  return loads.take(limit).toList(growable: false);
}

CompanyGovernanceOwnerLoad _ownerLoad({
  required String ownerName,
  required List<CompanyGovernanceActionItem> items,
}) {
  final sortedItems = [...items]..sort(_compareActions);
  final criticalCount =
      items
          .where(
            (item) => item.severity == CompanyGovernanceActionSeverity.critical,
          )
          .length;
  final highCount =
      items
          .where(
            (item) => item.severity == CompanyGovernanceActionSeverity.high,
          )
          .length;
  final mediumCount =
      items
          .where(
            (item) => item.severity == CompanyGovernanceActionSeverity.medium,
          )
          .length;
  final primaryItem = sortedItems.first;

  return CompanyGovernanceOwnerLoad(
    ownerName: ownerName,
    actionCount: items.length,
    criticalCount: criticalCount,
    highCount: highCount,
    mediumCount: mediumCount,
    filingCount: _sourceCount(items, CompanyGovernanceActionSource.filing),
    employerAccountCount: _sourceCount(
      items,
      CompanyGovernanceActionSource.employerAccount,
    ),
    vendorAgreementCount: _sourceCount(
      items,
      CompanyGovernanceActionSource.vendorAgreement,
    ),
    signatoryCount: _sourceCount(
      items,
      CompanyGovernanceActionSource.signatory,
    ),
    nextDueDate: primaryItem.dueDate,
    nextDueLabel: primaryItem.dueLabel,
    primaryActionLabel: primaryItem.actionLabel,
    risk: _riskFor(criticalCount: criticalCount, highCount: highCount),
  );
}

CompanyGovernanceOwnerLoadRisk _riskFor({
  required int criticalCount,
  required int highCount,
}) {
  if (criticalCount > 0) return CompanyGovernanceOwnerLoadRisk.critical;
  if (highCount > 0) return CompanyGovernanceOwnerLoadRisk.high;
  return CompanyGovernanceOwnerLoadRisk.steady;
}

int _sourceCount(
  List<CompanyGovernanceActionItem> items,
  CompanyGovernanceActionSource source,
) {
  return items.where((item) => item.source == source).length;
}

int _compareOwnerLoads(
  CompanyGovernanceOwnerLoad a,
  CompanyGovernanceOwnerLoad b,
) {
  final riskComparison = a.risk.sortRank.compareTo(b.risk.sortRank);
  if (riskComparison != 0) return riskComparison;

  final actionComparison = b.actionCount.compareTo(a.actionCount);
  if (actionComparison != 0) return actionComparison;

  final dueComparison = _dateOnly(
    a.nextDueDate,
  ).compareTo(_dateOnly(b.nextDueDate));
  if (dueComparison != 0) return dueComparison;

  return a.ownerLabel.compareTo(b.ownerLabel);
}

int _compareActions(
  CompanyGovernanceActionItem a,
  CompanyGovernanceActionItem b,
) {
  final severityComparison = a.severity.sortRank.compareTo(b.severity.sortRank);
  if (severityComparison != 0) return severityComparison;

  final dueComparison = _dateOnly(a.dueDate).compareTo(_dateOnly(b.dueDate));
  if (dueComparison != 0) return dueComparison;

  return a.title.compareTo(b.title);
}

String _countLabel(int count, String label) {
  return '$count $label${count == 1 ? '' : 's'}';
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
