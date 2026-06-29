import 'company_governance_action_item.dart';

/// One prioritized action included in a governance owner handoff brief.
class CompanyGovernanceOwnerHandoffAction {
  final String id;
  final String title;
  final String sourceLabel;
  final String severityLabel;
  final String dueLabel;
  final String resolveLabel;
  final String actionLabel;

  const CompanyGovernanceOwnerHandoffAction({
    required this.id,
    required this.title,
    required this.sourceLabel,
    required this.severityLabel,
    required this.dueLabel,
    required this.resolveLabel,
    required this.actionLabel,
  });
}

/// Owner-specific brief for routing company governance remediation work.
class CompanyGovernanceOwnerHandoff {
  final String ownerName;
  final int actionCount;
  final int criticalCount;
  final int highCount;
  final String sourceSummary;
  final String nextDueLabel;
  final String handoffMessage;
  final List<CompanyGovernanceOwnerHandoffAction> actions;

  const CompanyGovernanceOwnerHandoff({
    required this.ownerName,
    required this.actionCount,
    required this.criticalCount,
    required this.highCount,
    required this.sourceSummary,
    required this.nextDueLabel,
    required this.handoffMessage,
    required this.actions,
  });

  String get ownerLabel {
    return ownerName.trim().isEmpty ? 'Unassigned owner' : ownerName;
  }

  bool get hasCriticalActions => criticalCount > 0;
}

/// Builds a handoff brief for a selected governance owner.
CompanyGovernanceOwnerHandoff? buildCompanyGovernanceOwnerHandoff({
  required List<CompanyGovernanceActionItem> items,
  required String? ownerName,
  int actionLimit = 3,
}) {
  final normalizedOwner = _normalizeOwnerName(ownerName);
  if (normalizedOwner.isEmpty || actionLimit <= 0) return null;

  final ownerItems =
      items
          .where(
            (item) => _normalizeOwnerName(item.ownerLabel) == normalizedOwner,
          )
          .toList()
        ..sort(_compareActions);
  if (ownerItems.isEmpty) return null;

  final criticalCount =
      ownerItems
          .where(
            (item) => item.severity == CompanyGovernanceActionSeverity.critical,
          )
          .length;
  final highCount =
      ownerItems
          .where(
            (item) => item.severity == CompanyGovernanceActionSeverity.high,
          )
          .length;
  final ownerLabel = ownerItems.first.ownerLabel;
  final sourceSummary = _sourceSummary(ownerItems);
  final firstItem = ownerItems.first;

  return CompanyGovernanceOwnerHandoff(
    ownerName: ownerLabel,
    actionCount: ownerItems.length,
    criticalCount: criticalCount,
    highCount: highCount,
    sourceSummary: sourceSummary,
    nextDueLabel: firstItem.dueLabel,
    handoffMessage: _handoffMessage(
      ownerName: ownerLabel,
      actionCount: ownerItems.length,
      criticalCount: criticalCount,
      highCount: highCount,
      sourceSummary: sourceSummary,
      nextDueLabel: firstItem.dueLabel,
      primaryActionLabel: firstItem.actionLabel,
    ),
    actions: ownerItems
        .take(actionLimit)
        .map(
          (item) => CompanyGovernanceOwnerHandoffAction(
            id: item.id,
            title: item.title,
            sourceLabel: item.source.label,
            severityLabel: item.severity.label,
            dueLabel: item.dueLabel,
            resolveLabel: item.resolveLabel,
            actionLabel: item.actionLabel,
          ),
        )
        .toList(growable: false),
  );
}

String _handoffMessage({
  required String ownerName,
  required int actionCount,
  required int criticalCount,
  required int highCount,
  required String sourceSummary,
  required String nextDueLabel,
  required String primaryActionLabel,
}) {
  final priority =
      criticalCount > 0
          ? '$criticalCount critical'
          : highCount > 0
          ? '$highCount high-priority'
          : 'steady';
  return '$ownerName has $actionCount governance action'
      '${actionCount == 1 ? '' : 's'} across $sourceSummary. '
      'Priority is $priority, next touch is $nextDueLabel. '
      'Start with: $primaryActionLabel.';
}

String _sourceSummary(List<CompanyGovernanceActionItem> items) {
  final counts = <CompanyGovernanceActionSource, int>{};
  for (final item in items) {
    counts[item.source] = (counts[item.source] ?? 0) + 1;
  }
  final parts = [
    for (final source in CompanyGovernanceActionSource.values)
      if ((counts[source] ?? 0) > 0) _countLabel(counts[source]!, source.label),
  ];
  return parts.join(', ');
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
  return '$count ${label.toLowerCase()}${count == 1 ? '' : 's'}';
}

String _normalizeOwnerName(String? ownerName) {
  return (ownerName ?? '').trim().toLowerCase();
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
