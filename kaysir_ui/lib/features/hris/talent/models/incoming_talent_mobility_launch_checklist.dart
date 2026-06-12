import 'incoming_talent_mobility_match.dart';

enum IncomingTalentMobilityLaunchStatus {
  planned('Planned'),
  ready('Ready'),
  blocked('Blocked'),
  launched('Launched');

  final String label;

  const IncomingTalentMobilityLaunchStatus(this.label);
}

class IncomingTalentMobilityLaunchChecklist {
  final String id;
  final String matchId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String currentRole;
  final String department;
  final String targetRole;
  final String opportunityTitle;
  final String hostDepartment;
  final String sponsorName;
  final String mobilityOwnerName;
  final IncomingTalentMobilityMoveType moveType;
  final IncomingTalentMobilityMatchStatus matchStatus;
  final IncomingTalentMobilityLaunchStatus status;
  final int fitScore;
  final String ownerName;
  final DateTime launchDate;
  final DateTime firstReviewDate;
  final bool sponsorSignedOff;
  final bool hostManagerReady;
  final bool accessReady;
  final bool communicationReady;
  final bool backfillReady;
  final bool firstReviewScheduled;
  final String riskNote;
  final String launchNotes;
  final DateTime createdAt;

  const IncomingTalentMobilityLaunchChecklist({
    required this.id,
    required this.matchId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.currentRole,
    required this.department,
    required this.targetRole,
    required this.opportunityTitle,
    required this.hostDepartment,
    required this.sponsorName,
    required this.mobilityOwnerName,
    required this.moveType,
    required this.matchStatus,
    required this.status,
    required this.fitScore,
    required this.ownerName,
    required this.launchDate,
    required this.firstReviewDate,
    required this.sponsorSignedOff,
    required this.hostManagerReady,
    required this.accessReady,
    required this.communicationReady,
    required this.backfillReady,
    required this.firstReviewScheduled,
    required this.riskNote,
    required this.launchNotes,
    required this.createdAt,
  });

  int get totalGateCount => 6;

  int get completedGateCount {
    return [
      sponsorSignedOff,
      hostManagerReady,
      accessReady,
      communicationReady,
      backfillReady,
      firstReviewScheduled,
    ].where((gate) => gate).length;
  }

  bool get allGatesReady => completedGateCount == totalGateCount;

  double get readinessRatio => completedGateCount / totalGateCount;

  bool get needsAttention {
    if (status == IncomingTalentMobilityLaunchStatus.launched) return false;
    return status == IncomingTalentMobilityLaunchStatus.blocked ||
        !allGatesReady ||
        fitScore < 75;
  }

  int daysUntilLaunch(DateTime asOfDate) {
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final launch = DateTime(launchDate.year, launchDate.month, launchDate.day);
    return launch.difference(today).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilLaunch(asOfDate);
    return status != IncomingTalentMobilityLaunchStatus.launched &&
        days >= 0 &&
        days <= 14;
  }

  IncomingTalentMobilityLaunchChecklist copyWith({
    IncomingTalentMobilityLaunchStatus? status,
  }) {
    return IncomingTalentMobilityLaunchChecklist(
      id: id,
      matchId: matchId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName,
      currentRole: currentRole,
      department: department,
      targetRole: targetRole,
      opportunityTitle: opportunityTitle,
      hostDepartment: hostDepartment,
      sponsorName: sponsorName,
      mobilityOwnerName: mobilityOwnerName,
      moveType: moveType,
      matchStatus: matchStatus,
      status: status ?? this.status,
      fitScore: fitScore,
      ownerName: ownerName,
      launchDate: launchDate,
      firstReviewDate: firstReviewDate,
      sponsorSignedOff: sponsorSignedOff,
      hostManagerReady: hostManagerReady,
      accessReady: accessReady,
      communicationReady: communicationReady,
      backfillReady: backfillReady,
      firstReviewScheduled: firstReviewScheduled,
      riskNote: riskNote,
      launchNotes: launchNotes,
      createdAt: createdAt,
    );
  }
}
