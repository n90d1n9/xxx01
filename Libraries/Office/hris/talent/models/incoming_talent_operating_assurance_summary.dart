import 'incoming_talent_operating_assurance.dart';

/// Summary of audit assurance across talent operating workstreams.
class IncomingTalentOperatingAssuranceSummary {
  final int workstreamCount;
  final int exposedWorkstreamCount;
  final int guardedWorkstreamCount;
  final int readyWorkstreamCount;
  final int totalGapCount;
  final int criticalGapCount;
  final int overdueGapCount;
  final int linkedEscalationCount;
  final String nextAction;

  const IncomingTalentOperatingAssuranceSummary({
    required this.workstreamCount,
    required this.exposedWorkstreamCount,
    required this.guardedWorkstreamCount,
    required this.readyWorkstreamCount,
    required this.totalGapCount,
    required this.criticalGapCount,
    required this.overdueGapCount,
    required this.linkedEscalationCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingAssuranceSummary.fromWorkstreams(
    List<IncomingTalentOperatingAssuranceWorkstream> workstreams,
  ) {
    final exposedWorkstreamCount = _countByLevel(
      workstreams,
      IncomingTalentOperatingAssuranceLevel.exposed,
    );
    final guardedWorkstreamCount = _countByLevel(
      workstreams,
      IncomingTalentOperatingAssuranceLevel.guarded,
    );
    final readyWorkstreamCount = _countByLevel(
      workstreams,
      IncomingTalentOperatingAssuranceLevel.ready,
    );
    final totalGapCount = workstreams.fold<int>(
      0,
      (total, workstream) => total + workstream.gapCount,
    );
    final criticalGapCount = workstreams.fold<int>(
      0,
      (total, workstream) => total + workstream.criticalGapCount,
    );
    final overdueGapCount = workstreams.fold<int>(
      0,
      (total, workstream) => total + workstream.overdueGapCount,
    );
    final linkedEscalationCount = workstreams.fold<int>(
      0,
      (total, workstream) => total + workstream.linkedEscalationCount,
    );

    return IncomingTalentOperatingAssuranceSummary(
      workstreamCount: workstreams.length,
      exposedWorkstreamCount: exposedWorkstreamCount,
      guardedWorkstreamCount: guardedWorkstreamCount,
      readyWorkstreamCount: readyWorkstreamCount,
      totalGapCount: totalGapCount,
      criticalGapCount: criticalGapCount,
      overdueGapCount: overdueGapCount,
      linkedEscalationCount: linkedEscalationCount,
      nextAction: _nextAction(
        totalGapCount: totalGapCount,
        exposedWorkstreamCount: exposedWorkstreamCount,
        guardedWorkstreamCount: guardedWorkstreamCount,
        overdueGapCount: overdueGapCount,
      ),
    );
  }
}

int _countByLevel(
  List<IncomingTalentOperatingAssuranceWorkstream> workstreams,
  IncomingTalentOperatingAssuranceLevel level,
) {
  return workstreams.where((workstream) => workstream.level == level).length;
}

String _nextAction({
  required int totalGapCount,
  required int exposedWorkstreamCount,
  required int guardedWorkstreamCount,
  required int overdueGapCount,
}) {
  if (totalGapCount == 0) return 'Talent assurance is audit-ready.';
  if (exposedWorkstreamCount > 0) {
    return 'Stabilize $exposedWorkstreamCount audit-exposed talent ${_plural(exposedWorkstreamCount, 'workstream')}.';
  }
  if (overdueGapCount > 0) {
    return 'Recover $overdueGapCount overdue talent assurance ${_plural(overdueGapCount, 'gap')}.';
  }
  if (guardedWorkstreamCount > 0) {
    return 'Clear evidence gaps in $guardedWorkstreamCount guarded talent ${_plural(guardedWorkstreamCount, 'workstream')}.';
  }
  return 'Track $totalGapCount talent assurance ${_plural(totalGapCount, 'gap')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
