import 'company_document_audit_event.dart';
import 'company_governance_follow_up_cadence.dart';
import 'company_governance_follow_up_policy.dart';
import 'company_governance_owner_handoff_record.dart';
import 'company_governance_owner_load.dart';

/// Severity of a draft governance follow-up SLA policy preview.
enum CompanyGovernanceFollowUpPolicyImpactSeverity {
  invalid,
  unchanged,
  balanced,
  elevated,
}

/// One owner lane whose follow-up timing changes under a draft SLA policy.
class CompanyGovernanceFollowUpPolicyImpactLane {
  final String ownerName;
  final String currentTouchLabel;
  final String previewTouchLabel;
  final CompanyGovernanceFollowUpState previewState;
  final bool becomesDueNow;

  const CompanyGovernanceFollowUpPolicyImpactLane({
    required this.ownerName,
    required this.currentTouchLabel,
    required this.previewTouchLabel,
    required this.previewState,
    required this.becomesDueNow,
  });
}

/// Preview summary for how an editable SLA policy changes follow-up lanes.
class CompanyGovernanceFollowUpPolicyImpact {
  final bool isValid;
  final String validationMessage;
  final int laneCount;
  final int needsHandoffCount;
  final int overdueCount;
  final int dueTodayCount;
  final int scheduledCount;
  final int changedLaneCount;
  final int newlyDueCount;
  final List<CompanyGovernanceFollowUpPolicyImpactLane> changedLanes;

  const CompanyGovernanceFollowUpPolicyImpact({
    required this.isValid,
    this.validationMessage = '',
    required this.laneCount,
    required this.needsHandoffCount,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.scheduledCount,
    required this.changedLaneCount,
    required this.newlyDueCount,
    required this.changedLanes,
  });

  factory CompanyGovernanceFollowUpPolicyImpact.invalid(
    String validationMessage,
  ) {
    return CompanyGovernanceFollowUpPolicyImpact(
      isValid: false,
      validationMessage: validationMessage,
      laneCount: 0,
      needsHandoffCount: 0,
      overdueCount: 0,
      dueTodayCount: 0,
      scheduledCount: 0,
      changedLaneCount: 0,
      newlyDueCount: 0,
      changedLanes: const [],
    );
  }

  int get dueNowCount => overdueCount + dueTodayCount;

  bool get hasChanges => changedLaneCount > 0;

  CompanyGovernanceFollowUpPolicyImpactSeverity get severity {
    if (!isValid) return CompanyGovernanceFollowUpPolicyImpactSeverity.invalid;
    if (!hasChanges) {
      return CompanyGovernanceFollowUpPolicyImpactSeverity.unchanged;
    }
    if (newlyDueCount > 0 || overdueCount > 0) {
      return CompanyGovernanceFollowUpPolicyImpactSeverity.elevated;
    }
    return CompanyGovernanceFollowUpPolicyImpactSeverity.balanced;
  }

  String get headline {
    if (!isValid) return 'Fix SLA values';
    if (!hasChanges) return 'No timing changes';
    if (newlyDueCount > 0) {
      return newlyDueCount == 1
          ? '1 lane becomes due now'
          : '$newlyDueCount lanes become due now';
    }
    return changedLaneCount == 1
        ? '1 lane shifts timing'
        : '$changedLaneCount lanes shift timing';
  }

  String get detail {
    if (!isValid) return validationMessage;
    if (laneCount == 0) return 'No governance owner lanes to preview.';
    return '${_countLabel(dueNowCount, 'lane')} due now, '
        '${_countLabel(needsHandoffCount, 'lane')} need handoff, '
        '${_countLabel(scheduledCount, 'lane')} scheduled after save.';
  }
}

/// Builds a draft SLA impact preview from current governance follow-up inputs.
CompanyGovernanceFollowUpPolicyImpact
buildCompanyGovernanceFollowUpPolicyImpact({
  required CompanyGovernanceFollowUpPolicy currentPolicy,
  required CompanyGovernanceFollowUpPolicyDraft draft,
  required List<CompanyGovernanceOwnerLoad> loads,
  required List<CompanyGovernanceOwnerHandoffRecord> handoffRecords,
  required List<CompanyDocumentAuditEvent> auditEvents,
  required DateTime asOfDate,
  int changedLaneLimit = 3,
}) {
  final previewPolicy = _tryPolicy(draft);
  if (previewPolicy == null) {
    return CompanyGovernanceFollowUpPolicyImpact.invalid(
      _policyValidationMessage(draft),
    );
  }

  final laneLimit = loads.isEmpty ? 0 : loads.length;
  final currentLanes = buildCompanyGovernanceFollowUpCadence(
    loads: loads,
    handoffRecords: handoffRecords,
    auditEvents: auditEvents,
    asOfDate: asOfDate,
    policy: currentPolicy,
    limit: laneLimit,
  );
  final previewLanes = buildCompanyGovernanceFollowUpCadence(
    loads: loads,
    handoffRecords: handoffRecords,
    auditEvents: auditEvents,
    asOfDate: asOfDate,
    policy: previewPolicy,
    limit: laneLimit,
  );
  final currentByOwner = {
    for (final lane in currentLanes) lane.ownerLabel: lane,
  };

  final changedLanes = <CompanyGovernanceFollowUpPolicyImpactLane>[];
  var changedLaneCount = 0;
  var newlyDueCount = 0;

  for (final previewLane in previewLanes) {
    final currentLane = currentByOwner[previewLane.ownerLabel];
    if (currentLane == null) continue;

    final changed =
        currentLane.state != previewLane.state ||
        _dateOnly(currentLane.nextTouchDate) !=
            _dateOnly(previewLane.nextTouchDate);
    if (!changed) continue;

    changedLaneCount++;
    final becomesDueNow =
        !_isDueNow(currentLane.state) && _isDueNow(previewLane.state);
    if (becomesDueNow) newlyDueCount++;

    if (changedLanes.length < changedLaneLimit) {
      changedLanes.add(
        CompanyGovernanceFollowUpPolicyImpactLane(
          ownerName: previewLane.ownerLabel,
          currentTouchLabel: currentLane.nextTouchLabel(asOfDate),
          previewTouchLabel: previewLane.nextTouchLabel(asOfDate),
          previewState: previewLane.state,
          becomesDueNow: becomesDueNow,
        ),
      );
    }
  }

  return CompanyGovernanceFollowUpPolicyImpact(
    isValid: true,
    laneCount: previewLanes.length,
    needsHandoffCount: _countState(
      previewLanes,
      CompanyGovernanceFollowUpState.needsHandoff,
    ),
    overdueCount: _countState(
      previewLanes,
      CompanyGovernanceFollowUpState.overdue,
    ),
    dueTodayCount: _countState(
      previewLanes,
      CompanyGovernanceFollowUpState.dueToday,
    ),
    scheduledCount: _countState(
      previewLanes,
      CompanyGovernanceFollowUpState.scheduled,
    ),
    changedLaneCount: changedLaneCount,
    newlyDueCount: newlyDueCount,
    changedLanes: changedLanes,
  );
}

CompanyGovernanceFollowUpPolicy? _tryPolicy(
  CompanyGovernanceFollowUpPolicyDraft draft,
) {
  try {
    return draft.toPolicy();
  } on StateError {
    return null;
  }
}

String _policyValidationMessage(CompanyGovernanceFollowUpPolicyDraft draft) {
  for (final entry in [
    (label: 'Critical', value: draft.criticalCadenceDaysText),
    (label: 'High', value: draft.highCadenceDaysText),
    (label: 'Steady', value: draft.steadyCadenceDaysText),
  ]) {
    final error = CompanyGovernanceFollowUpPolicyDraft.validateCadenceDays(
      entry.value,
      entry.label,
    );
    if (error != null) return error;
  }
  return 'SLA cadence values are invalid.';
}

bool _isDueNow(CompanyGovernanceFollowUpState state) {
  return state == CompanyGovernanceFollowUpState.overdue ||
      state == CompanyGovernanceFollowUpState.dueToday;
}

int _countState(
  List<CompanyGovernanceFollowUpLane> lanes,
  CompanyGovernanceFollowUpState state,
) {
  return lanes.where((lane) => lane.state == state).length;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String _countLabel(int count, String label) {
  return '$count $label${count == 1 ? '' : 's'}';
}
