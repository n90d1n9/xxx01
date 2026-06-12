import 'company_compensation_band.dart';
import 'company_cost_center.dart';
import 'company_job_profile.dart';
import 'company_position_control.dart';

/// Severity level for one workforce planning queue item.
enum CompanyWorkforcePlanRisk {
  critical('Critical', 0),
  needsReview('Needs review', 1),
  healthy('Healthy', 2);

  final String label;
  final int sortRank;

  const CompanyWorkforcePlanRisk(this.label, this.sortRank);
}

/// Primary action recommended for one position-control queue item.
enum CompanyWorkforcePlanAction {
  approvePosition('Approve position'),
  closeRecruiting('Close recruiting'),
  reviewFreeze('Review freeze'),
  reviewCostCenter('Review cost center'),
  reviewArchitecture('Review architecture'),
  monitor('Monitor');

  final String label;

  const CompanyWorkforcePlanAction(this.label);
}

/// Ranked workforce planning decision for a position control.
class CompanyWorkforcePlanItem {
  final CompanyPositionControl position;
  final CompanyCostCenter? costCenter;
  final CompanyCompensationBand? compensationBand;
  final CompanyJobProfile? jobProfile;
  final bool budgetRisk;
  final bool architectureRisk;
  final CompanyWorkforcePlanRisk risk;
  final CompanyWorkforcePlanAction action;
  final String rationale;
  final int daysUntilReview;

  const CompanyWorkforcePlanItem({
    required this.position,
    required this.costCenter,
    required this.compensationBand,
    required this.jobProfile,
    required this.budgetRisk,
    required this.architectureRisk,
    required this.risk,
    required this.action,
    required this.rationale,
    required this.daysUntilReview,
  });

  String get title => position.positionTitle;

  String get ownerLabel {
    return position.ownerName.trim().isEmpty
        ? 'Unassigned owner'
        : position.ownerName.trim();
  }

  int get openSeats {
    return position.availableSeats > 0 ? position.availableSeats : 0;
  }

  int get overfilledSeats {
    return position.availableSeats < 0 ? position.availableSeats.abs() : 0;
  }

  bool get hasBudgetRisk => budgetRisk;

  bool get hasArchitectureRisk => architectureRisk;

  bool get isActionable => action != CompanyWorkforcePlanAction.monitor;

  bool get canApprovePosition {
    return action == CompanyWorkforcePlanAction.approvePosition ||
        action == CompanyWorkforcePlanAction.reviewFreeze;
  }

  bool get canCloseRecruiting {
    return action == CompanyWorkforcePlanAction.closeRecruiting;
  }

  bool get canReviewCostCenter {
    return action == CompanyWorkforcePlanAction.reviewCostCenter &&
        costCenter != null;
  }

  String get costCenterLabel {
    final center = costCenter;
    return center == null
        ? 'No cost center'
        : '${center.code} - ${center.name}';
  }

  String get compensationBandLabel {
    return compensationBand?.bandCode ??
        (position.compensationBand.trim().isEmpty
            ? 'No band'
            : position.compensationBand);
  }

  String get jobProfileLabel {
    return jobProfile?.jobCode ?? 'No matching profile';
  }

  String get reviewLabel {
    if (daysUntilReview < 0) return 'Overdue ${daysUntilReview.abs()}d';
    if (daysUntilReview == 0) return 'Today';
    return '${daysUntilReview}d';
  }
}

/// Executive workforce planning queue for open and risky headcount demand.
class CompanyWorkforcePlan {
  final List<CompanyWorkforcePlanItem> items;

  const CompanyWorkforcePlan({required this.items});

  bool get isEmpty => items.isEmpty;

  List<CompanyWorkforcePlanItem> get priorityItems {
    return items.where((item) => item.isActionable).take(5).toList();
  }

  int get actionableCount {
    return items.where((item) => item.isActionable).length;
  }

  int get criticalCount {
    return items
        .where((item) => item.risk == CompanyWorkforcePlanRisk.critical)
        .length;
  }

  int get openSeatCount {
    return items.fold(0, (total, item) => total + item.openSeats);
  }

  int get overfilledSeatCount {
    return items.fold(0, (total, item) => total + item.overfilledSeats);
  }

  int get pendingApprovalCount {
    return items
        .where(
          (item) =>
              item.position.status ==
              CompanyPositionControlStatus.pendingApproval,
        )
        .length;
  }

  int get recruitingCount {
    return items
        .where(
          (item) =>
              item.position.status == CompanyPositionControlStatus.recruiting,
        )
        .length;
  }

  int get frozenCount {
    return items
        .where(
          (item) => item.position.status == CompanyPositionControlStatus.frozen,
        )
        .length;
  }

  int get budgetRiskCount {
    return items.where((item) => item.hasBudgetRisk).length;
  }

  int get architectureRiskCount {
    return items.where((item) => item.hasArchitectureRisk).length;
  }
}

/// Builds a workforce planning queue from company architecture records.
CompanyWorkforcePlan buildCompanyWorkforcePlan({
  required List<CompanyPositionControl> positions,
  required List<CompanyCostCenter> costCenters,
  required List<CompanyCompensationBand> compensationBands,
  required List<CompanyJobProfile> jobProfiles,
  required DateTime asOfDate,
}) {
  final items = [
    for (final position in positions)
      _buildItem(
        position: position,
        costCenters: costCenters,
        compensationBands: compensationBands,
        jobProfiles: jobProfiles,
        asOfDate: asOfDate,
      ),
  ]..sort(_compareItems);

  return CompanyWorkforcePlan(items: items);
}

CompanyWorkforcePlanItem _buildItem({
  required CompanyPositionControl position,
  required List<CompanyCostCenter> costCenters,
  required List<CompanyCompensationBand> compensationBands,
  required List<CompanyJobProfile> jobProfiles,
  required DateTime asOfDate,
}) {
  final costCenter = _matchingCostCenter(position, costCenters);
  final compensationBand = _matchingCompensationBand(
    position,
    compensationBands,
  );
  final jobProfile = _matchingJobProfile(position, jobProfiles);
  final hasBudgetRisk = costCenter == null || costCenter.requiresAttention;
  final hasArchitectureRisk =
      compensationBand == null ||
      compensationBand.requiresAttention(asOfDate) ||
      jobProfile == null ||
      jobProfile.requiresAttention(asOfDate);
  final action = _actionFor(
    position: position,
    hasBudgetRisk: hasBudgetRisk,
    hasArchitectureRisk: hasArchitectureRisk,
  );

  return CompanyWorkforcePlanItem(
    position: position,
    costCenter: costCenter,
    compensationBand: compensationBand,
    jobProfile: jobProfile,
    budgetRisk: hasBudgetRisk,
    architectureRisk: hasArchitectureRisk,
    risk: _riskFor(
      position: position,
      hasBudgetRisk: hasBudgetRisk,
      hasArchitectureRisk: hasArchitectureRisk,
    ),
    action: action,
    rationale: _rationaleFor(
      position: position,
      action: action,
      costCenter: costCenter,
    ),
    daysUntilReview: position.daysUntilReview(asOfDate),
  );
}

CompanyCostCenter? _matchingCostCenter(
  CompanyPositionControl position,
  List<CompanyCostCenter> centers,
) {
  return centers
      .where(
        (center) =>
            _sameText(center.entityName, position.entityName) &&
            _sameText(center.orgUnitName, position.orgUnitName),
      )
      .firstOrNull;
}

CompanyCompensationBand? _matchingCompensationBand(
  CompanyPositionControl position,
  List<CompanyCompensationBand> bands,
) {
  return bands
      .where((band) => _sameText(band.bandCode, position.compensationBand))
      .firstOrNull;
}

CompanyJobProfile? _matchingJobProfile(
  CompanyPositionControl position,
  List<CompanyJobProfile> profiles,
) {
  return profiles
      .where(
        (profile) =>
            _sameText(profile.entityName, position.entityName) &&
            _sameText(profile.orgUnitName, position.orgUnitName) &&
            (_sameText(profile.compensationBand, position.compensationBand) ||
                _titleMatches(profile.jobTitle, position.positionTitle)),
      )
      .firstOrNull;
}

CompanyWorkforcePlanRisk _riskFor({
  required CompanyPositionControl position,
  required bool hasBudgetRisk,
  required bool hasArchitectureRisk,
}) {
  if (position.availableSeats < 0 ||
      position.status == CompanyPositionControlStatus.pendingApproval) {
    return CompanyWorkforcePlanRisk.critical;
  }
  if (position.status == CompanyPositionControlStatus.recruiting ||
      position.status == CompanyPositionControlStatus.frozen ||
      hasBudgetRisk ||
      hasArchitectureRisk) {
    return CompanyWorkforcePlanRisk.needsReview;
  }
  return CompanyWorkforcePlanRisk.healthy;
}

CompanyWorkforcePlanAction _actionFor({
  required CompanyPositionControl position,
  required bool hasBudgetRisk,
  required bool hasArchitectureRisk,
}) {
  if (position.availableSeats < 0 ||
      position.status == CompanyPositionControlStatus.pendingApproval) {
    return CompanyWorkforcePlanAction.approvePosition;
  }
  if (position.status == CompanyPositionControlStatus.recruiting) {
    return CompanyWorkforcePlanAction.closeRecruiting;
  }
  if (position.status == CompanyPositionControlStatus.frozen) {
    return CompanyWorkforcePlanAction.reviewFreeze;
  }
  if (hasBudgetRisk) return CompanyWorkforcePlanAction.reviewCostCenter;
  if (hasArchitectureRisk) return CompanyWorkforcePlanAction.reviewArchitecture;
  return CompanyWorkforcePlanAction.monitor;
}

String _rationaleFor({
  required CompanyPositionControl position,
  required CompanyWorkforcePlanAction action,
  required CompanyCostCenter? costCenter,
}) {
  switch (action) {
    case CompanyWorkforcePlanAction.approvePosition:
      if (position.availableSeats < 0) {
        return 'Filled headcount is ${position.availableSeats.abs()} above authorized seats.';
      }
      return 'Position is waiting for approval before hiring can proceed.';
    case CompanyWorkforcePlanAction.closeRecruiting:
      return 'Recruiting is open for ${position.availableSeats} authorized seat${position.availableSeats == 1 ? '' : 's'}.';
    case CompanyWorkforcePlanAction.reviewFreeze:
      return 'Frozen position still carries planned workforce demand.';
    case CompanyWorkforcePlanAction.reviewCostCenter:
      return costCenter == null
          ? 'No matching cost center is linked to this org unit.'
          : '${costCenter.name} needs budget or headcount review.';
    case CompanyWorkforcePlanAction.reviewArchitecture:
      return 'Compensation band or job profile needs review before offer generation.';
    case CompanyWorkforcePlanAction.monitor:
      return 'Position control, budget, and job architecture are aligned.';
  }
}

int _compareItems(CompanyWorkforcePlanItem a, CompanyWorkforcePlanItem b) {
  final riskComparison = a.risk.sortRank.compareTo(b.risk.sortRank);
  if (riskComparison != 0) return riskComparison;

  final overfillComparison = b.overfilledSeats.compareTo(a.overfilledSeats);
  if (overfillComparison != 0) return overfillComparison;

  final openSeatComparison = b.openSeats.compareTo(a.openSeats);
  if (openSeatComparison != 0) return openSeatComparison;

  final reviewComparison = a.daysUntilReview.compareTo(b.daysUntilReview);
  if (reviewComparison != 0) return reviewComparison;

  return a.title.compareTo(b.title);
}

bool _sameText(String left, String right) {
  return left.trim().toLowerCase() == right.trim().toLowerCase();
}

bool _titleMatches(String profileTitle, String positionTitle) {
  final normalizedProfile = profileTitle.trim().toLowerCase();
  final normalizedPosition = positionTitle.trim().toLowerCase();
  if (normalizedProfile.isEmpty || normalizedPosition.isEmpty) return false;
  return normalizedProfile.contains(normalizedPosition) ||
      normalizedPosition.contains(normalizedProfile);
}
