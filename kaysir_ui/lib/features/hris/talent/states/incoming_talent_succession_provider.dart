import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_calibration_models.dart';
import '../models/incoming_talent_profile_timeline_models.dart';
import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_profile_timeline_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCandidatesProvider =
    Provider<List<IncomingTalentSuccessionCandidate>>((ref) {
      final candidates =
          ref
              .watch(incomingTalentProfileTimelinesProvider)
              .map(_candidateFromTimeline)
              .toList()
            ..sort(_compareCandidates);

      return candidates;
    });

final filteredIncomingTalentSuccessionCandidatesProvider =
    Provider<List<IncomingTalentSuccessionCandidate>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionCandidatesProvider)
          .where(
            (candidate) =>
                (selectedDepartment == talentAllDepartments ||
                    candidate.department == selectedDepartment) &&
                (!attentionOnly || candidate.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionSummaryProvider =
    Provider<IncomingTalentSuccessionSummary>((ref) {
      return IncomingTalentSuccessionSummary.fromCandidates(
        ref.watch(filteredIncomingTalentSuccessionCandidatesProvider),
      );
    });

IncomingTalentSuccessionCandidate _candidateFromTimeline(
  IncomingTalentProfileTimeline timeline,
) {
  final readiness = _readiness(timeline);
  final risk = _risk(timeline, readiness);

  return IncomingTalentSuccessionCandidate(
    candidateId: timeline.candidateId,
    candidateName: timeline.candidateName,
    role: timeline.role,
    department: timeline.department,
    targetRole: _targetRole(timeline.role, readiness),
    promotionTrack: _promotionTrack(timeline, readiness),
    readiness: readiness,
    risk: risk,
    readinessScore: timeline.readinessScore,
    confidenceScore: timeline.confidenceScore,
    openInterventionCount: timeline.openInterventionCount,
    latestCalibrationDecisionLabel: timeline.latestCalibrationDecisionLabel,
    evidenceSummary: _evidenceSummary(timeline),
    nextAction: _nextAction(timeline, readiness),
    latestEvidenceDate: timeline.latestEventDate,
  );
}

IncomingTalentSuccessionReadiness _readiness(
  IncomingTalentProfileTimeline timeline,
) {
  if (timeline.openInterventionCount > 0 ||
      _hasCriticalSignal(timeline) ||
      _hasCalibrationDecision(
        timeline,
        IncomingTalentCalibrationDecision.retentionEscalation,
      )) {
    return IncomingTalentSuccessionReadiness.blocked;
  }
  if (_hasCalibrationDecision(
        timeline,
        IncomingTalentCalibrationDecision.accelerateGrowth,
      ) &&
      timeline.readinessScore >= 85 &&
      timeline.confidenceScore >= 4 &&
      !timeline.needsAttention) {
    return IncomingTalentSuccessionReadiness.readyNow;
  }
  if (timeline.hasCalibration &&
      timeline.readinessScore >= 75 &&
      timeline.confidenceScore >= 4 &&
      !timeline.needsAttention) {
    return IncomingTalentSuccessionReadiness.readySoon;
  }
  return IncomingTalentSuccessionReadiness.developing;
}

IncomingTalentSuccessionRisk _risk(
  IncomingTalentProfileTimeline timeline,
  IncomingTalentSuccessionReadiness readiness,
) {
  if (readiness == IncomingTalentSuccessionReadiness.blocked ||
      timeline.openInterventionCount > 0 ||
      _hasCriticalSignal(timeline)) {
    return IncomingTalentSuccessionRisk.high;
  }
  if (readiness == IncomingTalentSuccessionReadiness.developing ||
      timeline.confidenceScore <= 3 ||
      timeline.events.any((event) => event.needsAttention)) {
    return IncomingTalentSuccessionRisk.medium;
  }
  return IncomingTalentSuccessionRisk.low;
}

String _targetRole(String role, IncomingTalentSuccessionReadiness readiness) {
  final prefix = switch (readiness) {
    IncomingTalentSuccessionReadiness.readyNow => 'Expanded',
    IncomingTalentSuccessionReadiness.readySoon => 'Next-step',
    IncomingTalentSuccessionReadiness.developing => 'Future',
    IncomingTalentSuccessionReadiness.blocked => 'Stabilized',
  };
  return '$prefix $role scope';
}

String _promotionTrack(
  IncomingTalentProfileTimeline timeline,
  IncomingTalentSuccessionReadiness readiness,
) {
  return switch (readiness) {
    IncomingTalentSuccessionReadiness.readyNow =>
      '${timeline.role} succession slate',
    IncomingTalentSuccessionReadiness.readySoon =>
      '${timeline.role} sponsor track',
    IncomingTalentSuccessionReadiness.developing =>
      '${timeline.role} development bench',
    IncomingTalentSuccessionReadiness.blocked =>
      '${timeline.role} recovery bench',
  };
}

String _evidenceSummary(IncomingTalentProfileTimeline timeline) {
  final evidenceLabels = timeline.events
      .take(3)
      .map((event) => event.type.label)
      .join(', ');
  return '${timeline.latestCalibrationDecisionLabel}; '
      '${timeline.readinessScore}% readiness; '
      '${timeline.confidenceScore}/5 confidence; '
      '${timeline.openInterventionCount} open actions; '
      '$evidenceLabels evidence.';
}

String _nextAction(
  IncomingTalentProfileTimeline timeline,
  IncomingTalentSuccessionReadiness readiness,
) {
  return switch (readiness) {
    IncomingTalentSuccessionReadiness.readyNow =>
      'Nominate for succession panel.',
    IncomingTalentSuccessionReadiness.readySoon =>
      'Assign sponsor and 90-day stretch scope.',
    IncomingTalentSuccessionReadiness.developing =>
      timeline.needsAttention
          ? timeline.nextAction
          : timeline.hasCalibration
          ? 'Continue development cadence toward target scope.'
          : 'Schedule calibration before succession nomination.',
    IncomingTalentSuccessionReadiness.blocked => timeline.nextAction,
  };
}

bool _hasCriticalSignal(IncomingTalentProfileTimeline timeline) {
  return timeline.events.any(
    (event) => event.tone == IncomingTalentProfileTimelineEventTone.critical,
  );
}

bool _hasCalibrationDecision(
  IncomingTalentProfileTimeline timeline,
  IncomingTalentCalibrationDecision decision,
) {
  return timeline.latestCalibrationDecisionLabel == decision.label;
}

int _compareCandidates(
  IncomingTalentSuccessionCandidate a,
  IncomingTalentSuccessionCandidate b,
) {
  final readinessCompare = _readinessRank(
    a.readiness,
  ).compareTo(_readinessRank(b.readiness));
  if (readinessCompare != 0) return readinessCompare;
  final riskCompare = _riskRank(a.risk).compareTo(_riskRank(b.risk));
  if (riskCompare != 0) return riskCompare;
  final scoreCompare = b.readinessScore.compareTo(a.readinessScore);
  if (scoreCompare != 0) return scoreCompare;
  return a.candidateName.compareTo(b.candidateName);
}

int _readinessRank(IncomingTalentSuccessionReadiness readiness) {
  return switch (readiness) {
    IncomingTalentSuccessionReadiness.readyNow => 0,
    IncomingTalentSuccessionReadiness.readySoon => 1,
    IncomingTalentSuccessionReadiness.developing => 2,
    IncomingTalentSuccessionReadiness.blocked => 3,
  };
}

int _riskRank(IncomingTalentSuccessionRisk risk) {
  return switch (risk) {
    IncomingTalentSuccessionRisk.low => 0,
    IncomingTalentSuccessionRisk.medium => 1,
    IncomingTalentSuccessionRisk.high => 2,
  };
}
