import 'incoming_talent_operating_escalation.dart';
import 'incoming_talent_operating_evidence_gap.dart';
import 'incoming_talent_operating_inbox_item.dart';

/// Builds auditable evidence gaps from active talent operating work.
List<IncomingTalentOperatingEvidenceGap>
buildIncomingTalentOperatingEvidenceGaps({
  required List<IncomingTalentOperatingInboxItem> items,
  required List<IncomingTalentOperatingEscalationItem> escalations,
  required DateTime asOfDate,
}) {
  final escalationCountByReferenceId = _escalationCountByReferenceId(
    escalations,
  );
  final gaps =
      items
          .where((item) => _needsEvidenceGap(item, asOfDate))
          .map(
            (item) => _gapForItem(
              item: item,
              linkedEscalationCount: escalationCountByReferenceId[item.id] ?? 0,
              asOfDate: asOfDate,
            ),
          )
          .toList()
        ..sort(_compareGaps);

  return gaps;
}

Map<String, int> _escalationCountByReferenceId(
  List<IncomingTalentOperatingEscalationItem> escalations,
) {
  final counts = <String, int>{};
  for (final escalation in escalations) {
    for (final referenceId in escalation.referenceIds) {
      counts.update(referenceId, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  return counts;
}

IncomingTalentOperatingEvidenceGap _gapForItem({
  required IncomingTalentOperatingInboxItem item,
  required int linkedEscalationCount,
  required DateTime asOfDate,
}) {
  final daysUntilDue = item.daysUntilDue(asOfDate);
  final type = _typeFor(item.source);
  final risk = _riskFor(
    item: item,
    linkedEscalationCount: linkedEscalationCount,
    daysUntilDue: daysUntilDue,
  );

  return IncomingTalentOperatingEvidenceGap(
    id: 'evidence-${item.id}',
    type: type,
    risk: risk,
    title: '${type.label}: ${item.subjectName}',
    subjectName: item.subjectName,
    ownerName: _ownerName(item.ownerName),
    workstreamLabel: _workstreamLabelFor(item.source),
    statusLabel: item.statusLabel,
    evidenceRequest: _evidenceRequestFor(type),
    nextAction: _nextActionFor(
      item: item,
      type: type,
      linkedEscalationCount: linkedEscalationCount,
      daysUntilDue: daysUntilDue,
    ),
    dueDate: item.dueDate,
    daysUntilDue: daysUntilDue,
    overdue: daysUntilDue < 0,
    dueToday: daysUntilDue == 0,
    linkedEscalationCount: linkedEscalationCount,
    pressureRatio: _pressureRatioFor(
      item: item,
      linkedEscalationCount: linkedEscalationCount,
      daysUntilDue: daysUntilDue,
    ),
    referenceIds: [item.id],
  );
}

bool _needsEvidenceGap(
  IncomingTalentOperatingInboxItem item,
  DateTime asOfDate,
) {
  if (item.priority == IncomingTalentOperatingInboxPriority.critical) {
    return true;
  }
  if (item.isOverdue(asOfDate) || item.isDueSoon(asOfDate)) return true;
  if (item.priority == IncomingTalentOperatingInboxPriority.watch) return true;
  return _statusNeedsEvidence(item.statusLabel);
}

IncomingTalentOperatingEvidenceGapType _typeFor(
  IncomingTalentOperatingInboxSource source,
) {
  return switch (source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision ||
    IncomingTalentOperatingInboxSource.riskCouncilFollowUp =>
      IncomingTalentOperatingEvidenceGapType.riskCouncilEvidence,
    IncomingTalentOperatingInboxSource.trainingSession =>
      IncomingTalentOperatingEvidenceGapType.learningEvidence,
    IncomingTalentOperatingInboxSource.careerPathReview =>
      IncomingTalentOperatingEvidenceGapType.careerPathEvidence,
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      IncomingTalentOperatingEvidenceGapType.successionEvidence,
    IncomingTalentOperatingInboxSource.promotionStabilization =>
      IncomingTalentOperatingEvidenceGapType.promotionEvidence,
  };
}

IncomingTalentOperatingEvidenceGapRisk _riskFor({
  required IncomingTalentOperatingInboxItem item,
  required int linkedEscalationCount,
  required int daysUntilDue,
}) {
  if (daysUntilDue < 0 ||
      (item.priority == IncomingTalentOperatingInboxPriority.critical &&
          linkedEscalationCount > 0)) {
    return IncomingTalentOperatingEvidenceGapRisk.critical;
  }
  if (daysUntilDue == 0 ||
      item.priority == IncomingTalentOperatingInboxPriority.critical ||
      linkedEscalationCount > 0) {
    return IncomingTalentOperatingEvidenceGapRisk.high;
  }
  return IncomingTalentOperatingEvidenceGapRisk.watch;
}

String _ownerName(String value) {
  final ownerName = value.trim();
  return ownerName.isEmpty ? 'Unassigned owner' : ownerName;
}

String _workstreamLabelFor(IncomingTalentOperatingInboxSource source) {
  return switch (source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision ||
    IncomingTalentOperatingInboxSource.riskCouncilFollowUp => 'Risk council',
    IncomingTalentOperatingInboxSource.trainingSession ||
    IncomingTalentOperatingInboxSource.careerPathReview => 'Development',
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      'Succession',
    IncomingTalentOperatingInboxSource.promotionStabilization => 'Promotion',
  };
}

String _evidenceRequestFor(IncomingTalentOperatingEvidenceGapType type) {
  return switch (type) {
    IncomingTalentOperatingEvidenceGapType.riskCouncilEvidence =>
      'Attach decision notes, owner commitment, and follow-up acceptance.',
    IncomingTalentOperatingEvidenceGapType.learningEvidence =>
      'Attach attendance, completion proof, and learner feedback.',
    IncomingTalentOperatingEvidenceGapType.careerPathEvidence =>
      'Attach level evidence, manager calibration, and agreed next step.',
    IncomingTalentOperatingEvidenceGapType.successionEvidence =>
      'Attach coverage rationale, bench action proof, and panel notes.',
    IncomingTalentOperatingEvidenceGapType.promotionEvidence =>
      'Attach implementation proof, stabilization check, and comp routing.',
  };
}

String _nextActionFor({
  required IncomingTalentOperatingInboxItem item,
  required IncomingTalentOperatingEvidenceGapType type,
  required int linkedEscalationCount,
  required int daysUntilDue,
}) {
  if (daysUntilDue < 0) {
    return 'Recover overdue ${type.label.toLowerCase()} for ${item.subjectName}.';
  }
  if (daysUntilDue == 0) {
    return 'Close ${type.label.toLowerCase()} for ${item.subjectName} today.';
  }
  if (linkedEscalationCount > 0) {
    return 'Attach ${type.label.toLowerCase()} before clearing linked escalation.';
  }
  if (item.priority == IncomingTalentOperatingInboxPriority.critical) {
    return 'Collect ${type.label.toLowerCase()} before the critical review.';
  }
  return 'Prepare ${type.label.toLowerCase()} for ${item.subjectName}.';
}

double _pressureRatioFor({
  required IncomingTalentOperatingInboxItem item,
  required int linkedEscalationCount,
  required int daysUntilDue,
}) {
  var score = 0;
  if (item.priority == IncomingTalentOperatingInboxPriority.critical) {
    score += 4;
  } else if (item.priority == IncomingTalentOperatingInboxPriority.watch) {
    score += 2;
  } else {
    score += 1;
  }

  if (daysUntilDue < 0) {
    score += 4;
  } else if (daysUntilDue == 0) {
    score += 3;
  } else if (daysUntilDue <= 7) {
    score += 2;
  }

  score += linkedEscalationCount.clamp(0, 3);
  final ratio = score / 11;

  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}

bool _statusNeedsEvidence(String statusLabel) {
  final status = statusLabel.toLowerCase();
  return status.contains('blocked') ||
      status.contains('pending') ||
      status.contains('review') ||
      status.contains('open') ||
      status.contains('watch');
}

int _compareGaps(
  IncomingTalentOperatingEvidenceGap left,
  IncomingTalentOperatingEvidenceGap right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final overdue = _boolRank(right.overdue).compareTo(_boolRank(left.overdue));
  if (overdue != 0) return overdue;

  final dueToday = _boolRank(
    right.dueToday,
  ).compareTo(_boolRank(left.dueToday));
  if (dueToday != 0) return dueToday;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final escalations = right.linkedEscalationCount.compareTo(
    left.linkedEscalationCount,
  );
  if (escalations != 0) return escalations;

  return left.title.compareTo(right.title);
}

int _boolRank(bool value) => value ? 1 : 0;
