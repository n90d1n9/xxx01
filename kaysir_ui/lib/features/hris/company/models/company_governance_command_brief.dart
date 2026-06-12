import 'company_governance_action_filter.dart';
import 'company_governance_action_item.dart';
import 'company_governance_follow_up_cadence.dart';
import 'company_governance_saved_view.dart';

/// Primary intent recommended by the governance command brief.
enum CompanyGovernanceCommandBriefIntent {
  resolveAction('Resolve action'),
  prepareHandoff('Prepare handoff'),
  recordFollowUp('Record follow-up'),
  monitor('Monitor');

  final String label;

  const CompanyGovernanceCommandBriefIntent(this.label);
}

/// Selected-view brief that explains the next best governance action.
class CompanyGovernanceCommandBrief {
  final CompanyGovernanceSavedView selectedView;
  final CompanyGovernanceCommandBriefIntent intent;
  final String headline;
  final String recommendation;
  final String ownerName;
  final CompanyGovernanceActionFilter queueFilter;
  final int visibleActionCount;
  final int criticalActionCount;
  final int highActionCount;
  final int needsHandoffCount;
  final int dueFollowUpCount;
  final CompanyGovernanceActionItem? primaryAction;
  final CompanyGovernanceFollowUpLane? primaryFollowUpLane;

  const CompanyGovernanceCommandBrief({
    required this.selectedView,
    required this.intent,
    required this.headline,
    required this.recommendation,
    required this.ownerName,
    required this.queueFilter,
    required this.visibleActionCount,
    required this.criticalActionCount,
    required this.highActionCount,
    required this.needsHandoffCount,
    required this.dueFollowUpCount,
    this.primaryAction,
    this.primaryFollowUpLane,
  });

  String get ownerLabel {
    return ownerName.trim().isEmpty ? 'No owner scope' : ownerName.trim();
  }

  bool get hasOwnerScope => ownerName.trim().isNotEmpty;

  bool get hasPrimaryAction => primaryAction != null;

  bool get canRecordFollowUp {
    return primaryFollowUpLane?.canRecordFollowUp ?? false;
  }

  String get primaryActionLabel {
    return primaryAction?.actionLabel ?? primaryFollowUpLane?.rationale ?? '';
  }
}

/// Builds the governance command brief from selected view and current queues.
CompanyGovernanceCommandBrief buildCompanyGovernanceCommandBrief({
  required CompanyGovernanceSavedView selectedView,
  required List<CompanyGovernanceActionItem> actions,
  required List<CompanyGovernanceFollowUpLane> followUpLanes,
  String? selectedOwnerName,
}) {
  final ownerName = _effectiveOwnerName(
    selectedView: selectedView,
    selectedOwnerName: selectedOwnerName,
  );
  final visibleActions = filterCompanyGovernanceActionItems(
    items: actions,
    filter: selectedView.queueFilter,
    ownerName: ownerName,
  );
  final scopedFollowUps = _scopedFollowUps(
    lanes: followUpLanes,
    ownerName: ownerName,
  );
  final needsHandoffLanes =
      scopedFollowUps
          .where(
            (lane) => lane.state == CompanyGovernanceFollowUpState.needsHandoff,
          )
          .toList();
  final dueFollowUpLanes =
      scopedFollowUps
          .where(
            (lane) =>
                lane.state == CompanyGovernanceFollowUpState.overdue ||
                lane.state == CompanyGovernanceFollowUpState.dueToday,
          )
          .toList();
  final primaryDueFollowUp = dueFollowUpLanes.firstOrNull;
  final primaryHandoff = needsHandoffLanes.firstOrNull;
  final primaryAction = _primaryActionForView(
    selectedView: selectedView,
    visibleActions: visibleActions,
  );
  final intent = _intentFor(
    selectedView: selectedView,
    primaryDueFollowUp: primaryDueFollowUp,
    primaryHandoff: primaryHandoff,
    primaryAction: primaryAction,
  );
  final primaryFollowUp =
      intent == CompanyGovernanceCommandBriefIntent.prepareHandoff
          ? primaryHandoff
          : primaryDueFollowUp;

  return CompanyGovernanceCommandBrief(
    selectedView: selectedView,
    intent: intent,
    headline: _headlineFor(
      intent: intent,
      selectedView: selectedView,
      primaryAction: primaryAction,
      primaryFollowUp: primaryFollowUp,
    ),
    recommendation: _recommendationFor(
      intent: intent,
      primaryAction: primaryAction,
      primaryFollowUp: primaryFollowUp,
    ),
    ownerName:
        primaryFollowUp?.ownerLabel ?? primaryAction?.ownerLabel ?? ownerName,
    queueFilter: selectedView.queueFilter,
    visibleActionCount: visibleActions.length,
    criticalActionCount:
        visibleActions
            .where(
              (action) =>
                  action.severity == CompanyGovernanceActionSeverity.critical,
            )
            .length,
    highActionCount:
        visibleActions
            .where(
              (action) =>
                  action.severity == CompanyGovernanceActionSeverity.high,
            )
            .length,
    needsHandoffCount: needsHandoffLanes.length,
    dueFollowUpCount: dueFollowUpLanes.length,
    primaryAction: primaryAction,
    primaryFollowUpLane: primaryFollowUp,
  );
}

String _effectiveOwnerName({
  required CompanyGovernanceSavedView selectedView,
  required String? selectedOwnerName,
}) {
  final explicitOwner = selectedOwnerName?.trim() ?? '';
  if (explicitOwner.isNotEmpty) return explicitOwner;
  return selectedView.ownerName.trim();
}

List<CompanyGovernanceFollowUpLane> _scopedFollowUps({
  required List<CompanyGovernanceFollowUpLane> lanes,
  required String ownerName,
}) {
  final normalizedOwner = ownerName.trim().toLowerCase();
  if (normalizedOwner.isEmpty) return lanes;

  return lanes
      .where((lane) => lane.ownerLabel.trim().toLowerCase() == normalizedOwner)
      .toList(growable: false);
}

CompanyGovernanceActionItem? _primaryActionForView({
  required CompanyGovernanceSavedView selectedView,
  required List<CompanyGovernanceActionItem> visibleActions,
}) {
  if (visibleActions.isEmpty) return null;

  if (selectedView.type == CompanyGovernanceSavedViewType.commandCenter) {
    return visibleActions.firstWhere(
      (action) => action.severity == CompanyGovernanceActionSeverity.critical,
      orElse: () => visibleActions.first,
    );
  }
  return visibleActions.first;
}

CompanyGovernanceCommandBriefIntent _intentFor({
  required CompanyGovernanceSavedView selectedView,
  required CompanyGovernanceFollowUpLane? primaryDueFollowUp,
  required CompanyGovernanceFollowUpLane? primaryHandoff,
  required CompanyGovernanceActionItem? primaryAction,
}) {
  switch (selectedView.type) {
    case CompanyGovernanceSavedViewType.ownerHandoffs:
      if (primaryHandoff != null) {
        return CompanyGovernanceCommandBriefIntent.prepareHandoff;
      }
      break;
    case CompanyGovernanceSavedViewType.followUpsDue:
      if (primaryDueFollowUp != null) {
        return CompanyGovernanceCommandBriefIntent.recordFollowUp;
      }
      break;
    case CompanyGovernanceSavedViewType.commandCenter:
      if (primaryDueFollowUp != null) {
        return CompanyGovernanceCommandBriefIntent.recordFollowUp;
      }
      if (primaryHandoff != null) {
        return CompanyGovernanceCommandBriefIntent.prepareHandoff;
      }
      break;
    case CompanyGovernanceSavedViewType.criticalActions:
    case CompanyGovernanceSavedViewType.vendorRenewals:
      break;
  }

  if (primaryAction != null) {
    return CompanyGovernanceCommandBriefIntent.resolveAction;
  }
  return CompanyGovernanceCommandBriefIntent.monitor;
}

String _headlineFor({
  required CompanyGovernanceCommandBriefIntent intent,
  required CompanyGovernanceSavedView selectedView,
  required CompanyGovernanceActionItem? primaryAction,
  required CompanyGovernanceFollowUpLane? primaryFollowUp,
}) {
  switch (intent) {
    case CompanyGovernanceCommandBriefIntent.recordFollowUp:
      return 'Follow up with ${primaryFollowUp?.ownerLabel ?? 'governance owner'}';
    case CompanyGovernanceCommandBriefIntent.prepareHandoff:
      return 'Prepare handoff for ${primaryFollowUp?.ownerLabel ?? 'governance owner'}';
    case CompanyGovernanceCommandBriefIntent.resolveAction:
      return 'Resolve ${primaryAction?.title ?? selectedView.title}';
    case CompanyGovernanceCommandBriefIntent.monitor:
      return '${selectedView.title} is clear';
  }
}

String _recommendationFor({
  required CompanyGovernanceCommandBriefIntent intent,
  required CompanyGovernanceActionItem? primaryAction,
  required CompanyGovernanceFollowUpLane? primaryFollowUp,
}) {
  switch (intent) {
    case CompanyGovernanceCommandBriefIntent.recordFollowUp:
      return primaryFollowUp?.rationale ??
          'Record the next governance owner touch.';
    case CompanyGovernanceCommandBriefIntent.prepareHandoff:
      return primaryFollowUp?.rationale ??
          'Select the owner lane and record the governance handoff.';
    case CompanyGovernanceCommandBriefIntent.resolveAction:
      return primaryAction?.actionLabel ??
          'Resolve the highest priority governance action.';
    case CompanyGovernanceCommandBriefIntent.monitor:
      return 'No matching governance actions need attention in this view.';
  }
}
