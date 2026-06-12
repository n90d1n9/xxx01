import 'incoming_talent_operating_assurance.dart';
import 'incoming_talent_operating_evidence_gap.dart';

/// Builds audit assurance rows from active talent operating evidence gaps.
List<IncomingTalentOperatingAssuranceWorkstream>
buildIncomingTalentOperatingAssuranceWorkstreams({
  required List<IncomingTalentOperatingEvidenceGap> gaps,
}) {
  final labels =
      <String>{
        ..._knownWorkstreamLabels,
        ...gaps.map((gap) => gap.workstreamLabel),
      }.toList();

  final workstreams =
      labels.map((label) {
          final workstreamGaps =
              gaps.where((gap) => gap.workstreamLabel == label).toList();
          return _workstreamFor(label: label, gaps: workstreamGaps);
        }).toList()
        ..sort(_compareWorkstreams);

  return workstreams;
}

const _knownWorkstreamLabels = [
  'Risk council',
  'Development',
  'Succession',
  'Promotion',
];

IncomingTalentOperatingAssuranceWorkstream _workstreamFor({
  required String label,
  required List<IncomingTalentOperatingEvidenceGap> gaps,
}) {
  final criticalGapCount = _countByRisk(
    gaps,
    IncomingTalentOperatingEvidenceGapRisk.critical,
  );
  final highGapCount = _countByRisk(
    gaps,
    IncomingTalentOperatingEvidenceGapRisk.high,
  );
  final watchGapCount = _countByRisk(
    gaps,
    IncomingTalentOperatingEvidenceGapRisk.watch,
  );
  final overdueGapCount = gaps.where((gap) => gap.overdue).length;
  final dueTodayGapCount = gaps.where((gap) => gap.dueToday).length;
  final linkedEscalationCount = gaps.fold<int>(
    0,
    (total, gap) => total + gap.linkedEscalationCount,
  );
  final level = _levelFor(
    gapCount: gaps.length,
    criticalGapCount: criticalGapCount,
    highGapCount: highGapCount,
    overdueGapCount: overdueGapCount,
    dueTodayGapCount: dueTodayGapCount,
    linkedEscalationCount: linkedEscalationCount,
  );

  return IncomingTalentOperatingAssuranceWorkstream(
    workstreamLabel: label,
    level: level,
    gapCount: gaps.length,
    criticalGapCount: criticalGapCount,
    highGapCount: highGapCount,
    watchGapCount: watchGapCount,
    overdueGapCount: overdueGapCount,
    dueTodayGapCount: dueTodayGapCount,
    linkedEscalationCount: linkedEscalationCount,
    ownerCount: gaps.map((gap) => gap.ownerName).toSet().length,
    nextDueDate: _nextDueDate(gaps),
    nextAction: _nextAction(
      label: label,
      gapCount: gaps.length,
      criticalGapCount: criticalGapCount,
      highGapCount: highGapCount,
      overdueGapCount: overdueGapCount,
      dueTodayGapCount: dueTodayGapCount,
      linkedEscalationCount: linkedEscalationCount,
    ),
    gapIds: gaps.map((gap) => gap.id).toList(),
  );
}

IncomingTalentOperatingAssuranceLevel _levelFor({
  required int gapCount,
  required int criticalGapCount,
  required int highGapCount,
  required int overdueGapCount,
  required int dueTodayGapCount,
  required int linkedEscalationCount,
}) {
  if (gapCount == 0) return IncomingTalentOperatingAssuranceLevel.ready;
  if (criticalGapCount > 0 ||
      overdueGapCount > 0 ||
      linkedEscalationCount >= 3) {
    return IncomingTalentOperatingAssuranceLevel.exposed;
  }
  if (highGapCount > 0 ||
      dueTodayGapCount > 0 ||
      linkedEscalationCount > 0 ||
      gapCount > 0) {
    return IncomingTalentOperatingAssuranceLevel.guarded;
  }
  return IncomingTalentOperatingAssuranceLevel.ready;
}

int _countByRisk(
  List<IncomingTalentOperatingEvidenceGap> gaps,
  IncomingTalentOperatingEvidenceGapRisk risk,
) {
  return gaps.where((gap) => gap.risk == risk).length;
}

DateTime? _nextDueDate(List<IncomingTalentOperatingEvidenceGap> gaps) {
  final dueDates = gaps.map((gap) => gap.dueDate).toList()..sort();
  if (dueDates.isEmpty) return null;
  return dueDates.first;
}

String _nextAction({
  required String label,
  required int gapCount,
  required int criticalGapCount,
  required int highGapCount,
  required int overdueGapCount,
  required int dueTodayGapCount,
  required int linkedEscalationCount,
}) {
  final workstream = label.toLowerCase();
  if (gapCount == 0) return '$label assurance is ready.';
  if (overdueGapCount > 0) {
    return 'Recover $overdueGapCount overdue $workstream evidence ${_plural(overdueGapCount, 'gap')}.';
  }
  if (criticalGapCount > 0) {
    return 'Close $criticalGapCount critical $workstream evidence ${_plural(criticalGapCount, 'gap')}.';
  }
  if (dueTodayGapCount > 0) {
    return 'Close $dueTodayGapCount $workstream evidence ${_plural(dueTodayGapCount, 'gap')} due today.';
  }
  if (linkedEscalationCount > 0) {
    return 'Attach evidence for $linkedEscalationCount linked $workstream ${_plural(linkedEscalationCount, 'escalation')}.';
  }
  if (highGapCount > 0) {
    return 'Prepare $highGapCount high-priority $workstream evidence ${_plural(highGapCount, 'gap')}.';
  }
  return 'Prepare $gapCount $workstream evidence ${_plural(gapCount, 'gap')}.';
}

int _compareWorkstreams(
  IncomingTalentOperatingAssuranceWorkstream left,
  IncomingTalentOperatingAssuranceWorkstream right,
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

  final gaps = right.gapCount.compareTo(left.gapCount);
  if (gaps != 0) return gaps;

  return left.workstreamLabel.compareTo(right.workstreamLabel);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
