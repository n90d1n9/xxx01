import 'dart:math' as math;

import 'incoming_talent_governance_command_center.dart';
import 'incoming_talent_governance_review_pack.dart';

/// Builds an executive review pack from the talent governance command center.
IncomingTalentGovernanceReviewPack buildIncomingTalentGovernanceReviewPack(
  IncomingTalentGovernanceCommandCenter commandCenter,
) {
  final items =
      commandCenter.lanes
          .where((lane) => lane.needsAttention || lane.decisionCount > 0)
          .map(_reviewItemFromLane)
          .toList()
        ..sort(_compareItems);

  final urgentItemCount =
      items
          .where(
            (item) =>
                item.status == IncomingTalentGovernanceCommandStatus.critical,
          )
          .length;
  final scheduledItemCount =
      items
          .where(
            (item) =>
                item.status == IncomingTalentGovernanceCommandStatus.watch,
          )
          .length;
  final totalSignalCount = items.fold<int>(
    0,
    (total, item) => total + item.signalCount,
  );
  final decisionQuestionCount = items.fold<int>(
    0,
    (total, item) => total + math.max(1, item.decisionCount),
  );
  final totalTimeboxMinutes = items.fold<int>(
    0,
    (total, item) => total + item.timeboxMinutes,
  );
  final status = _packStatus(
    urgentItemCount: urgentItemCount,
    scheduledItemCount: scheduledItemCount,
  );

  return IncomingTalentGovernanceReviewPack(
    status: status,
    reviewReadinessScore: _reviewReadinessScore(
      urgentItemCount: urgentItemCount,
      scheduledItemCount: scheduledItemCount,
      totalSignalCount: totalSignalCount,
    ),
    agendaItemCount: items.length,
    urgentItemCount: urgentItemCount,
    scheduledItemCount: scheduledItemCount,
    decisionQuestionCount: decisionQuestionCount,
    totalSignalCount: totalSignalCount,
    totalTimeboxMinutes: totalTimeboxMinutes,
    chairNote: _chairNote(
      commandCenter: commandCenter,
      status: status,
      items: items,
    ),
    facilitationFocus: _facilitationFocus(status: status, items: items),
    items: items,
  );
}

IncomingTalentGovernanceReviewItem _reviewItemFromLane(
  IncomingTalentGovernanceCommandLane lane,
) {
  return IncomingTalentGovernanceReviewItem(
    id: 'review-pack-${lane.id}',
    laneType: lane.type,
    status: lane.status,
    decisionKind: _decisionKindForLane(lane.type),
    title: lane.title,
    decisionQuestion: _decisionQuestion(lane),
    recommendedDecision: _recommendedDecision(lane),
    ownerLabel: _ownerLabelForLane(lane.type),
    evidencePrompt: _evidencePrompt(lane),
    dueLabel: _dueLabelForStatus(lane.status),
    signalCount: lane.signalCount,
    decisionCount: lane.decisionCount,
    timeboxMinutes: _timeboxMinutes(lane),
    pressureRatio: lane.pressureRatio,
  );
}

IncomingTalentGovernanceReviewDecisionKind _decisionKindForLane(
  IncomingTalentGovernanceCommandLaneType type,
) {
  return switch (type) {
    IncomingTalentGovernanceCommandLaneType.health =>
      IncomingTalentGovernanceReviewDecisionKind.align,
    IncomingTalentGovernanceCommandLaneType.actionSla ||
    IncomingTalentGovernanceCommandLaneType
        .escalation => IncomingTalentGovernanceReviewDecisionKind.unblock,
    IncomingTalentGovernanceCommandLaneType.assurance =>
      IncomingTalentGovernanceReviewDecisionKind.approve,
    IncomingTalentGovernanceCommandLaneType.succession =>
      IncomingTalentGovernanceReviewDecisionKind.approve,
    IncomingTalentGovernanceCommandLaneType.training =>
      IncomingTalentGovernanceReviewDecisionKind.allocate,
    IncomingTalentGovernanceCommandLaneType.careerPath =>
      IncomingTalentGovernanceReviewDecisionKind.align,
  };
}

String _decisionQuestion(IncomingTalentGovernanceCommandLane lane) {
  final subject = lane.title.toLowerCase();

  return switch (lane.status) {
    IncomingTalentGovernanceCommandStatus.critical =>
      'What leadership decision removes the $subject blocker today?',
    IncomingTalentGovernanceCommandStatus.watch =>
      'Which owner and evidence keep $subject on track this week?',
    IncomingTalentGovernanceCommandStatus.stable =>
      'Should $subject stay on monthly monitoring?',
  };
}

String _recommendedDecision(IncomingTalentGovernanceCommandLane lane) {
  final subject = lane.title.toLowerCase();

  return switch (lane.status) {
    IncomingTalentGovernanceCommandStatus.critical =>
      'Approve immediate intervention for $subject: ${lane.nextAction}',
    IncomingTalentGovernanceCommandStatus.watch =>
      'Keep $subject on weekly governance watch and confirm the accountable owner.',
    IncomingTalentGovernanceCommandStatus.stable =>
      'Record stable posture for $subject and keep monthly monitoring.',
  };
}

String _ownerLabelForLane(IncomingTalentGovernanceCommandLaneType type) {
  return switch (type) {
    IncomingTalentGovernanceCommandLaneType.health => 'People Partner',
    IncomingTalentGovernanceCommandLaneType.actionSla => 'Talent Operations',
    IncomingTalentGovernanceCommandLaneType.escalation =>
      'HRIS Governance Lead',
    IncomingTalentGovernanceCommandLaneType.assurance =>
      'People Risk and Assurance',
    IncomingTalentGovernanceCommandLaneType.succession => 'Succession Council',
    IncomingTalentGovernanceCommandLaneType.training => 'L&D Lead',
    IncomingTalentGovernanceCommandLaneType.careerPath =>
      'Career Architecture Lead',
  };
}

String _evidencePrompt(IncomingTalentGovernanceCommandLane lane) {
  return '${lane.metricLabel} ${lane.metricValue} with ${lane.signalCount} active ${_plural(lane.signalCount, 'signal')}: ${lane.detail}';
}

String _dueLabelForStatus(IncomingTalentGovernanceCommandStatus status) {
  return switch (status) {
    IncomingTalentGovernanceCommandStatus.critical => 'Decision today',
    IncomingTalentGovernanceCommandStatus.watch => 'Decision this week',
    IncomingTalentGovernanceCommandStatus.stable => 'Monthly review',
  };
}

int _timeboxMinutes(IncomingTalentGovernanceCommandLane lane) {
  return switch (lane.status) {
    IncomingTalentGovernanceCommandStatus.critical => 15,
    IncomingTalentGovernanceCommandStatus.watch => 10,
    IncomingTalentGovernanceCommandStatus.stable => 6,
  };
}

IncomingTalentGovernanceReviewPackStatus _packStatus({
  required int urgentItemCount,
  required int scheduledItemCount,
}) {
  if (urgentItemCount > 0) {
    return IncomingTalentGovernanceReviewPackStatus.urgent;
  }
  if (scheduledItemCount > 0) {
    return IncomingTalentGovernanceReviewPackStatus.scheduled;
  }
  return IncomingTalentGovernanceReviewPackStatus.clear;
}

int _reviewReadinessScore({
  required int urgentItemCount,
  required int scheduledItemCount,
  required int totalSignalCount,
}) {
  final score =
      100 -
      (urgentItemCount * 16) -
      (scheduledItemCount * 7) -
      (math.min(totalSignalCount, 18) * 2);

  return score.clamp(0, 100);
}

String _chairNote({
  required IncomingTalentGovernanceCommandCenter commandCenter,
  required IncomingTalentGovernanceReviewPackStatus status,
  required List<IncomingTalentGovernanceReviewItem> items,
}) {
  if (items.isEmpty ||
      status == IncomingTalentGovernanceReviewPackStatus.clear) {
    return 'No extraordinary talent governance decisions are queued.';
  }

  return 'Prepare ${items.length} governance ${_plural(items.length, 'decision')} from ${commandCenter.totalSignalCount} active ${_plural(commandCenter.totalSignalCount, 'signal')}.';
}

String _facilitationFocus({
  required IncomingTalentGovernanceReviewPackStatus status,
  required List<IncomingTalentGovernanceReviewItem> items,
}) {
  if (items.isEmpty ||
      status == IncomingTalentGovernanceReviewPackStatus.clear) {
    return 'Keep the monthly talent governance health review.';
  }

  final first = items.first;
  if (status == IncomingTalentGovernanceReviewPackStatus.urgent) {
    return 'Start with ${first.title} and land the ${first.decisionKind.label.toLowerCase()} decision before other agenda items.';
  }

  return 'Confirm owners for ${items.length} scheduled governance ${_plural(items.length, 'item')}.';
}

int _compareItems(
  IncomingTalentGovernanceReviewItem left,
  IncomingTalentGovernanceReviewItem right,
) {
  final status = left.status.sortRank.compareTo(right.status.sortRank);
  if (status != 0) return status;

  final pressure = right.normalizedPressureRatio.compareTo(
    left.normalizedPressureRatio,
  );
  if (pressure != 0) return pressure;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  return left.title.compareTo(right.title);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
