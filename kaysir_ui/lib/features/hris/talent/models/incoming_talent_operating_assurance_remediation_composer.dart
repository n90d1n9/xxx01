import 'incoming_talent_operating_assurance.dart';
import 'incoming_talent_operating_assurance_remediation.dart';
import 'incoming_talent_operating_evidence_gap.dart';

/// Builds owner-assigned remediation actions from assurance evidence gaps.
List<IncomingTalentOperatingAssuranceRemediationAction>
buildIncomingTalentOperatingAssuranceRemediationActions({
  required List<IncomingTalentOperatingEvidenceGap> gaps,
  required List<IncomingTalentOperatingAssuranceWorkstream> workstreams,
}) {
  final assuranceByWorkstream = {
    for (final workstream in workstreams)
      workstream.workstreamLabel: workstream.level,
  };
  final groupedGaps =
      <_RemediationGroupKey, List<IncomingTalentOperatingEvidenceGap>>{};

  for (final gap in gaps) {
    final key = _RemediationGroupKey(
      ownerName: gap.ownerName,
      workstreamLabel: gap.workstreamLabel,
    );
    groupedGaps.putIfAbsent(key, () => []).add(gap);
  }

  final actions =
      groupedGaps.entries.map((entry) {
          return _actionForGroup(
            key: entry.key,
            gaps: entry.value,
            assuranceLevel:
                assuranceByWorkstream[entry.key.workstreamLabel] ??
                IncomingTalentOperatingAssuranceLevel.guarded,
          );
        }).toList()
        ..sort(_compareActions);

  return actions;
}

class _RemediationGroupKey {
  final String ownerName;
  final String workstreamLabel;

  const _RemediationGroupKey({
    required this.ownerName,
    required this.workstreamLabel,
  });

  @override
  bool operator ==(Object other) {
    return other is _RemediationGroupKey &&
        other.ownerName == ownerName &&
        other.workstreamLabel == workstreamLabel;
  }

  @override
  int get hashCode => Object.hash(ownerName, workstreamLabel);
}

IncomingTalentOperatingAssuranceRemediationAction _actionForGroup({
  required _RemediationGroupKey key,
  required List<IncomingTalentOperatingEvidenceGap> gaps,
  required IncomingTalentOperatingAssuranceLevel assuranceLevel,
}) {
  final criticalGapCount = _countByRisk(
    gaps,
    IncomingTalentOperatingEvidenceGapRisk.critical,
  );
  final highGapCount = _countByRisk(
    gaps,
    IncomingTalentOperatingEvidenceGapRisk.high,
  );
  final overdueGapCount = gaps.where((gap) => gap.overdue).length;
  final dueTodayGapCount = gaps.where((gap) => gap.dueToday).length;
  final linkedEscalationCount = gaps.fold<int>(
    0,
    (total, gap) => total + gap.linkedEscalationCount,
  );
  final type = _typeFor(
    overdueGapCount: overdueGapCount,
    dueTodayGapCount: dueTodayGapCount,
    linkedEscalationCount: linkedEscalationCount,
  );
  final priority = _priorityFor(
    assuranceLevel: assuranceLevel,
    criticalGapCount: criticalGapCount,
    highGapCount: highGapCount,
    overdueGapCount: overdueGapCount,
    dueTodayGapCount: dueTodayGapCount,
    linkedEscalationCount: linkedEscalationCount,
  );
  final nextDueDate = _nextDueDate(gaps);

  return IncomingTalentOperatingAssuranceRemediationAction(
    id: _actionId(key),
    type: type,
    priority: priority,
    assuranceLevel: assuranceLevel,
    ownerName: key.ownerName,
    workstreamLabel: key.workstreamLabel,
    title: '${key.ownerName} - ${key.workstreamLabel} evidence',
    detail:
        '${gaps.length} assurance ${_plural(gaps.length, 'gap')} in ${key.workstreamLabel.toLowerCase()}',
    nextAction: _nextAction(
      ownerName: key.ownerName,
      workstreamLabel: key.workstreamLabel,
      type: type,
      gapCount: gaps.length,
      overdueGapCount: overdueGapCount,
      dueTodayGapCount: dueTodayGapCount,
      linkedEscalationCount: linkedEscalationCount,
    ),
    gapCount: gaps.length,
    criticalGapCount: criticalGapCount,
    highGapCount: highGapCount,
    overdueGapCount: overdueGapCount,
    dueTodayGapCount: dueTodayGapCount,
    linkedEscalationCount: linkedEscalationCount,
    nextDueDate: nextDueDate,
    pressureRatio: _pressureRatio(
      assuranceLevel: assuranceLevel,
      gapCount: gaps.length,
      criticalGapCount: criticalGapCount,
      highGapCount: highGapCount,
      overdueGapCount: overdueGapCount,
      dueTodayGapCount: dueTodayGapCount,
      linkedEscalationCount: linkedEscalationCount,
    ),
    evidenceRequests: _evidenceRequests(gaps),
    gapIds: gaps.map((gap) => gap.id).toList(),
  );
}

IncomingTalentOperatingAssuranceRemediationType _typeFor({
  required int overdueGapCount,
  required int dueTodayGapCount,
  required int linkedEscalationCount,
}) {
  if (overdueGapCount > 0) {
    return IncomingTalentOperatingAssuranceRemediationType
        .recoverOverdueEvidence;
  }
  if (linkedEscalationCount > 0) {
    return IncomingTalentOperatingAssuranceRemediationType
        .clearLinkedEscalation;
  }
  if (dueTodayGapCount > 0) {
    return IncomingTalentOperatingAssuranceRemediationType.closeDueToday;
  }
  return IncomingTalentOperatingAssuranceRemediationType.prepareAuditPack;
}

IncomingTalentOperatingAssuranceRemediationPriority _priorityFor({
  required IncomingTalentOperatingAssuranceLevel assuranceLevel,
  required int criticalGapCount,
  required int highGapCount,
  required int overdueGapCount,
  required int dueTodayGapCount,
  required int linkedEscalationCount,
}) {
  if (overdueGapCount > 0 ||
      criticalGapCount > 0 ||
      assuranceLevel == IncomingTalentOperatingAssuranceLevel.exposed) {
    return IncomingTalentOperatingAssuranceRemediationPriority.critical;
  }
  if (highGapCount > 0 || dueTodayGapCount > 0 || linkedEscalationCount > 0) {
    return IncomingTalentOperatingAssuranceRemediationPriority.high;
  }
  return IncomingTalentOperatingAssuranceRemediationPriority.standard;
}

int _countByRisk(
  List<IncomingTalentOperatingEvidenceGap> gaps,
  IncomingTalentOperatingEvidenceGapRisk risk,
) {
  return gaps.where((gap) => gap.risk == risk).length;
}

DateTime _nextDueDate(List<IncomingTalentOperatingEvidenceGap> gaps) {
  final dueDates = gaps.map((gap) => gap.dueDate).toList()..sort();
  return dueDates.first;
}

String _actionId(_RemediationGroupKey key) {
  return 'assurance-remediation-${_slug(key.ownerName)}-${_slug(key.workstreamLabel)}';
}

String _slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

String _nextAction({
  required String ownerName,
  required String workstreamLabel,
  required IncomingTalentOperatingAssuranceRemediationType type,
  required int gapCount,
  required int overdueGapCount,
  required int dueTodayGapCount,
  required int linkedEscalationCount,
}) {
  final workstream = workstreamLabel.toLowerCase();
  return switch (type) {
    IncomingTalentOperatingAssuranceRemediationType.recoverOverdueEvidence =>
      'Ask $ownerName to recover $overdueGapCount overdue $workstream evidence ${_plural(overdueGapCount, 'gap')}.',
    IncomingTalentOperatingAssuranceRemediationType.clearLinkedEscalation =>
      'Ask $ownerName to attach evidence for $linkedEscalationCount linked $workstream ${_plural(linkedEscalationCount, 'escalation')}.',
    IncomingTalentOperatingAssuranceRemediationType.closeDueToday =>
      'Ask $ownerName to close $dueTodayGapCount $workstream evidence ${_plural(dueTodayGapCount, 'gap')} due today.',
    IncomingTalentOperatingAssuranceRemediationType.prepareAuditPack =>
      'Ask $ownerName to prepare $gapCount $workstream assurance ${_plural(gapCount, 'gap')}.',
  };
}

double _pressureRatio({
  required IncomingTalentOperatingAssuranceLevel assuranceLevel,
  required int gapCount,
  required int criticalGapCount,
  required int highGapCount,
  required int overdueGapCount,
  required int dueTodayGapCount,
  required int linkedEscalationCount,
}) {
  final assuranceScore = switch (assuranceLevel) {
    IncomingTalentOperatingAssuranceLevel.exposed => 3,
    IncomingTalentOperatingAssuranceLevel.guarded => 2,
    IncomingTalentOperatingAssuranceLevel.ready => 0,
  };
  final score =
      assuranceScore +
      (criticalGapCount * 3) +
      (highGapCount * 2) +
      (overdueGapCount * 3) +
      (dueTodayGapCount * 2) +
      linkedEscalationCount;
  final ratio = score / ((gapCount * 10) + 3);

  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}

List<String> _evidenceRequests(List<IncomingTalentOperatingEvidenceGap> gaps) {
  return gaps.map((gap) => gap.evidenceRequest).toSet().toList()..sort();
}

int _compareActions(
  IncomingTalentOperatingAssuranceRemediationAction left,
  IncomingTalentOperatingAssuranceRemediationAction right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final overdue = right.overdueGapCount.compareTo(left.overdueGapCount);
  if (overdue != 0) return overdue;

  final critical = right.criticalGapCount.compareTo(left.criticalGapCount);
  if (critical != 0) return critical;

  final linked = right.linkedEscalationCount.compareTo(
    left.linkedEscalationCount,
  );
  if (linked != 0) return linked;

  final dueDate = left.nextDueDate.compareTo(right.nextDueDate);
  if (dueDate != 0) return dueDate;

  final gaps = right.gapCount.compareTo(left.gapCount);
  if (gaps != 0) return gaps;

  return left.title.compareTo(right.title);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
