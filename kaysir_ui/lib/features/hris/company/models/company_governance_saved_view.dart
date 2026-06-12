import 'company_governance_action_filter.dart';
import 'company_governance_action_item.dart';
import 'company_governance_follow_up_cadence.dart';

/// Saved governance work modes that focus the company command center.
enum CompanyGovernanceSavedViewType {
  commandCenter,
  criticalActions,
  ownerHandoffs,
  followUpsDue,
  vendorRenewals,
}

/// Operational preset for focusing governance queue, owner scope, and cadence.
class CompanyGovernanceSavedView {
  final CompanyGovernanceSavedViewType type;
  final String title;
  final String description;
  final String metricLabel;
  final int metricValue;
  final CompanyGovernanceActionFilter queueFilter;
  final String ownerName;
  final bool clearOwnerScope;

  const CompanyGovernanceSavedView({
    required this.type,
    required this.title,
    required this.description,
    required this.metricLabel,
    required this.metricValue,
    required this.queueFilter,
    this.ownerName = '',
    this.clearOwnerScope = false,
  });

  String get ownerLabel {
    return ownerName.trim().isEmpty ? 'No owner scope' : ownerName.trim();
  }

  bool get hasOwnerScope => ownerName.trim().isNotEmpty;

  bool get hasAttention => metricValue > 0;
}

/// Builds saved governance views from the current action and follow-up state.
List<CompanyGovernanceSavedView> buildCompanyGovernanceSavedViews({
  required List<CompanyGovernanceActionItem> actions,
  required List<CompanyGovernanceFollowUpLane> followUpLanes,
}) {
  final criticalActions =
      actions
          .where(
            (action) =>
                action.severity == CompanyGovernanceActionSeverity.critical,
          )
          .toList();
  final needsHandoffLanes =
      followUpLanes
          .where(
            (lane) => lane.state == CompanyGovernanceFollowUpState.needsHandoff,
          )
          .toList();
  final dueFollowUpLanes =
      followUpLanes
          .where(
            (lane) =>
                lane.state == CompanyGovernanceFollowUpState.overdue ||
                lane.state == CompanyGovernanceFollowUpState.dueToday,
          )
          .toList();
  final vendorActions =
      actions
          .where(
            (action) =>
                action.source == CompanyGovernanceActionSource.vendorAgreement,
          )
          .toList();

  return [
    CompanyGovernanceSavedView(
      type: CompanyGovernanceSavedViewType.commandCenter,
      title: 'Command center',
      description: 'All governance actions, owners, handoffs, and follow-ups.',
      metricLabel: 'Actions',
      metricValue: actions.length,
      queueFilter: CompanyGovernanceActionFilter.all,
      clearOwnerScope: true,
    ),
    CompanyGovernanceSavedView(
      type: CompanyGovernanceSavedViewType.criticalActions,
      title: 'Critical actions',
      description: 'Statutory or authority work requiring immediate action.',
      metricLabel: 'Critical',
      metricValue: criticalActions.length,
      queueFilter: CompanyGovernanceActionFilter.critical,
      clearOwnerScope: true,
    ),
    CompanyGovernanceSavedView(
      type: CompanyGovernanceSavedViewType.ownerHandoffs,
      title: 'Owner handoffs',
      description: 'Owner lanes that need a recorded governance handoff.',
      metricLabel: 'No handoff',
      metricValue: needsHandoffLanes.length,
      queueFilter: CompanyGovernanceActionFilter.all,
      ownerName: _firstOwner(needsHandoffLanes),
    ),
    CompanyGovernanceSavedView(
      type: CompanyGovernanceSavedViewType.followUpsDue,
      title: 'Follow-ups due',
      description: 'Handoffs that need a same-day or overdue touch.',
      metricLabel: 'Due',
      metricValue: dueFollowUpLanes.length,
      queueFilter: CompanyGovernanceActionFilter.all,
      ownerName: _firstOwner(dueFollowUpLanes),
    ),
    CompanyGovernanceSavedView(
      type: CompanyGovernanceSavedViewType.vendorRenewals,
      title: 'Vendor renewals',
      description: 'Vendor agreements with renewal or implementation risk.',
      metricLabel: 'Vendors',
      metricValue: vendorActions.length,
      queueFilter: CompanyGovernanceActionFilter.vendors,
      clearOwnerScope: true,
    ),
  ];
}

/// Finds a saved governance view by type, falling back to command center.
CompanyGovernanceSavedView selectedCompanyGovernanceSavedView({
  required List<CompanyGovernanceSavedView> views,
  required CompanyGovernanceSavedViewType selectedType,
}) {
  return views.firstWhere(
    (view) => view.type == selectedType,
    orElse:
        () => views.firstWhere(
          (view) => view.type == CompanyGovernanceSavedViewType.commandCenter,
        ),
  );
}

String _firstOwner(List<CompanyGovernanceFollowUpLane> lanes) {
  for (final lane in lanes) {
    if (lane.ownerLabel.trim().isNotEmpty) return lane.ownerLabel;
  }
  return '';
}
