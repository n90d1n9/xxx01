import 'incoming_talent_governance_command_center.dart';

/// Review status for the executive talent governance meeting pack.
enum IncomingTalentGovernanceReviewPackStatus {
  urgent('Urgent'),
  scheduled('Scheduled'),
  clear('Clear');

  final String label;

  const IncomingTalentGovernanceReviewPackStatus(this.label);
}

/// Decision category used to steer talent governance agenda facilitation.
enum IncomingTalentGovernanceReviewDecisionKind {
  unblock('Unblock'),
  allocate('Allocate'),
  approve('Approve'),
  align('Align'),
  monitor('Monitor');

  final String label;

  const IncomingTalentGovernanceReviewDecisionKind(this.label);
}

/// One leadership decision item derived from a talent governance lane.
class IncomingTalentGovernanceReviewItem {
  final String id;
  final IncomingTalentGovernanceCommandLaneType laneType;
  final IncomingTalentGovernanceCommandStatus status;
  final IncomingTalentGovernanceReviewDecisionKind decisionKind;
  final String title;
  final String decisionQuestion;
  final String recommendedDecision;
  final String ownerLabel;
  final String evidencePrompt;
  final String dueLabel;
  final int signalCount;
  final int decisionCount;
  final int timeboxMinutes;
  final double pressureRatio;

  const IncomingTalentGovernanceReviewItem({
    required this.id,
    required this.laneType,
    required this.status,
    required this.decisionKind,
    required this.title,
    required this.decisionQuestion,
    required this.recommendedDecision,
    required this.ownerLabel,
    required this.evidencePrompt,
    required this.dueLabel,
    required this.signalCount,
    required this.decisionCount,
    required this.timeboxMinutes,
    required this.pressureRatio,
  });

  bool get isUrgent {
    return status == IncomingTalentGovernanceCommandStatus.critical;
  }

  double get normalizedPressureRatio {
    if (pressureRatio < 0) return 0;
    if (pressureRatio > 1) return 1;
    return pressureRatio;
  }
}

/// Executive meeting pack that converts talent governance signals into decisions.
class IncomingTalentGovernanceReviewPack {
  final IncomingTalentGovernanceReviewPackStatus status;
  final int reviewReadinessScore;
  final int agendaItemCount;
  final int urgentItemCount;
  final int scheduledItemCount;
  final int decisionQuestionCount;
  final int totalSignalCount;
  final int totalTimeboxMinutes;
  final String chairNote;
  final String facilitationFocus;
  final List<IncomingTalentGovernanceReviewItem> items;

  const IncomingTalentGovernanceReviewPack({
    required this.status,
    required this.reviewReadinessScore,
    required this.agendaItemCount,
    required this.urgentItemCount,
    required this.scheduledItemCount,
    required this.decisionQuestionCount,
    required this.totalSignalCount,
    required this.totalTimeboxMinutes,
    required this.chairNote,
    required this.facilitationFocus,
    required this.items,
  });

  double get reviewReadinessRatio => reviewReadinessScore / 100;
}
