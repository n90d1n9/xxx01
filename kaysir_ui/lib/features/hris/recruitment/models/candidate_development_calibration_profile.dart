import 'candidate_development_check_in.dart';
import 'candidate_development_intervention.dart';
import 'candidate_development_objective.dart';

enum CandidateDevelopmentCalibrationStatus {
  ready('Ready'),
  monitor('Monitor'),
  blocked('Blocked');

  final String label;

  const CandidateDevelopmentCalibrationStatus(this.label);
}

class CandidateDevelopmentCalibrationProfile {
  final String objectiveId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String objectiveTitle;
  final String skillFocus;
  final String ownerName;
  final String mentorName;
  final DateTime dueDate;
  final CandidateDevelopmentCalibrationStatus status;
  final int readinessScore;
  final int? latestConfidence;
  final int openInterventionCount;
  final bool escalationRequired;
  final String nextAction;

  const CandidateDevelopmentCalibrationProfile({
    required this.objectiveId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.objectiveTitle,
    required this.skillFocus,
    required this.ownerName,
    required this.mentorName,
    required this.dueDate,
    required this.status,
    required this.readinessScore,
    required this.latestConfidence,
    required this.openInterventionCount,
    required this.escalationRequired,
    required this.nextAction,
  });

  bool get needsAttention =>
      status != CandidateDevelopmentCalibrationStatus.ready;

  factory CandidateDevelopmentCalibrationProfile.fromSignals({
    required CandidateDevelopmentObjective objective,
    required List<CandidateDevelopmentCheckIn> checkIns,
    required List<CandidateDevelopmentIntervention> interventions,
    required DateTime asOfDate,
  }) {
    final latestCheckIn = _latestCheckIn(checkIns);
    final openInterventions =
        interventions.where((item) => item.isOpen).toList();
    final escalationRequired = openInterventions.any(
      (item) => item.escalationRequired,
    );
    final overdue = objective.isOpen && objective.daysUntilDue(asOfDate) < 0;
    final status = _status(
      objective: objective,
      latestCheckIn: latestCheckIn,
      openInterventions: openInterventions,
      escalationRequired: escalationRequired,
      overdue: overdue,
      asOfDate: asOfDate,
    );
    final readinessScore = _readinessScore(
      objective: objective,
      latestCheckIn: latestCheckIn,
      openInterventions: openInterventions,
      escalationRequired: escalationRequired,
      overdue: overdue,
    );

    return CandidateDevelopmentCalibrationProfile(
      objectiveId: objective.id,
      candidateId: objective.candidateId,
      candidateName: objective.candidateName,
      role: objective.role,
      department: objective.department,
      objectiveTitle: objective.objectiveTitle,
      skillFocus: objective.skillFocus,
      ownerName: objective.ownerName,
      mentorName: objective.mentorName,
      dueDate: objective.dueDate,
      status: status,
      readinessScore: readinessScore,
      latestConfidence: latestCheckIn?.confidenceLevel,
      openInterventionCount: openInterventions.length,
      escalationRequired: escalationRequired,
      nextAction: _nextAction(
        status: status,
        objective: objective,
        latestCheckIn: latestCheckIn,
        openInterventions: openInterventions,
        escalationRequired: escalationRequired,
        overdue: overdue,
      ),
    );
  }
}

CandidateDevelopmentCheckIn? _latestCheckIn(
  List<CandidateDevelopmentCheckIn> checkIns,
) {
  if (checkIns.isEmpty) return null;
  final sorted = [...checkIns]
    ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
  return sorted.first;
}

CandidateDevelopmentCalibrationStatus _status({
  required CandidateDevelopmentObjective objective,
  required CandidateDevelopmentCheckIn? latestCheckIn,
  required List<CandidateDevelopmentIntervention> openInterventions,
  required bool escalationRequired,
  required bool overdue,
  required DateTime asOfDate,
}) {
  if (escalationRequired ||
      overdue ||
      latestCheckIn?.status == CandidateDevelopmentCheckInStatus.blocked) {
    return CandidateDevelopmentCalibrationStatus.blocked;
  }

  if (objective.status == CandidateDevelopmentObjectiveStatus.completed &&
      openInterventions.isEmpty) {
    return CandidateDevelopmentCalibrationStatus.ready;
  }

  if (latestCheckIn?.status == CandidateDevelopmentCheckInStatus.onTrack &&
      (latestCheckIn?.confidenceLevel ?? 0) >= 4 &&
      openInterventions.isEmpty) {
    return CandidateDevelopmentCalibrationStatus.ready;
  }

  return CandidateDevelopmentCalibrationStatus.monitor;
}

int _readinessScore({
  required CandidateDevelopmentObjective objective,
  required CandidateDevelopmentCheckIn? latestCheckIn,
  required List<CandidateDevelopmentIntervention> openInterventions,
  required bool escalationRequired,
  required bool overdue,
}) {
  var score = switch (objective.status) {
    CandidateDevelopmentObjectiveStatus.planned => 45,
    CandidateDevelopmentObjectiveStatus.active => 62,
    CandidateDevelopmentObjectiveStatus.completed => 86,
  };

  if (latestCheckIn == null) {
    score -= 8;
  } else {
    score += (latestCheckIn.confidenceLevel - 3) * 8;
    score += switch (latestCheckIn.status) {
      CandidateDevelopmentCheckInStatus.onTrack => 8,
      CandidateDevelopmentCheckInStatus.watch => 0,
      CandidateDevelopmentCheckInStatus.blocked => -18,
    };
  }

  score -= openInterventions.length * 10;
  if (escalationRequired) score -= 15;
  if (overdue) score -= 12;
  return score.clamp(0, 100);
}

String _nextAction({
  required CandidateDevelopmentCalibrationStatus status,
  required CandidateDevelopmentObjective objective,
  required CandidateDevelopmentCheckIn? latestCheckIn,
  required List<CandidateDevelopmentIntervention> openInterventions,
  required bool escalationRequired,
  required bool overdue,
}) {
  if (status == CandidateDevelopmentCalibrationStatus.ready) {
    return 'Confirm readiness for ${objective.candidateName}.';
  }
  if (escalationRequired) return 'Escalate unresolved development blocker.';
  if (overdue) return 'Recalibrate overdue objective timeline.';
  if (latestCheckIn == null) return 'Capture first development check-in.';
  if (openInterventions.isNotEmpty) {
    return 'Close ${openInterventions.length} open intervention actions.';
  }
  return 'Continue coaching and review confidence trend.';
}
